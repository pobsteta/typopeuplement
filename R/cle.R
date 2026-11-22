# Clé de détermination à appartenance floue (cle.py du prototype).
#
# Une clé est une liste de types ; chaque type est défini par des intervalles sur des
# variables continues. Une condition dure « min <= v < max » devient le produit de deux
# sigmoïdes dont la pente est réglée par une « souplesse » propre à la variable. Quand la
# souplesse est nulle, on retrouve exactement la clé à seuils durs. Une variable inconnue
# (NA) neutralise la condition qui la porte.

sigmoide <- function(x) 0.5 * (1 + tanh(0.5 * x))

appartenance_condition <- function(v, cond, s) {
  m <- rep(1, length(v))
  mn <- cond$min
  mx <- cond$max
  if (s <= 0) {
    if (!is.null(mn)) m <- m * (v >= mn)
    if (!is.null(mx)) m <- m * (v < mx)
  } else {
    if (!is.null(mn)) m <- m * sigmoide((v - mn) / s)
    if (!is.null(mx)) m <- m * sigmoide((mx - v) / s)
  }
  # Variable inconnue : condition neutralisée.
  ifelse(is.na(v), 1, m)
}

codes_cle <- function(cle) vapply(cle$types, function(t) as.character(t$code), character(1))

libelles_cle <- function(cle) {
  vapply(cle$types, function(t) as.character(t$libelle %||% t$code), character(1))
}

#' Probabilités d'appartenance aux types d'une clé floue
#'
#' Pour chaque ligne de `variables`, probabilité d'appartenir à chaque type de la clé
#' (les probabilités d'une ligne somment à 1). Une ligne qui ne satisfait aucun type
#' (hors clé) reçoit des probabilités égales et est signalée dans l'attribut `hors_cle`.
#'
#' @param cle La clé d'une SER, telle que la rend `lire_configuration(...)$cle`.
#' @param variables data.frame des variables de la clé (une ligne par pixel ou placette).
#'   Une valeur `NA` neutralise la condition qui la porte.
#'
#' @return data.frame à une colonne par code de type, avec l'attribut logique `hors_cle`.
#' @seealso [classer_types()], [decider_type()]
#' @export
appartenances_types <- function(cle, variables) {
  n <- nrow(variables)
  types <- cle$types
  codes <- codes_cle(cle)
  scores <- matrix(1, nrow = n, ncol = length(types))
  for (k in seq_along(types)) {
    for (cond in types[[k]]$conditions) {
      if (!(cond$variable %in% names(variables))) {
        arreter(sprintf("variable absente pour la cl\u00e9 : %s", cond$variable))
      }
      v <- as.numeric(variables[[cond$variable]])
      s <- as.numeric(cle$souplesse[[cond$variable]] %||% 0)
      scores[, k] <- scores[, k] * appartenance_condition(v, cond, s)
    }
  }
  total <- rowSums(scores)
  hors_cle <- total <= 1e-12
  probas <- scores / ifelse(hors_cle, 1, total)
  probas[hors_cle, ] <- 1 / length(types)
  out <- as.data.frame(probas)
  names(out) <- codes
  attr(out, "hors_cle") <- hors_cle
  out
}

#' Décider du type à partir des probabilités
#'
#' Type retenu (plus forte probabilité), sa probabilité, le second type et le drapeau
#' « entre deux types » : levé quand l'écart entre les deux premières probabilités est
#' inférieur à `marge_entre_deux`.
#'
#' @param probas data.frame ou matrice de probabilités, une colonne par code de type.
#' @param marge_entre_deux Marge « entre deux types ». **Provisoire** : 0,15, reprise du
#'   prototype ; à mesurer sur les SER pilotes.
#'
#' @return data.frame : `type`, `proba`, `type_second`, `proba_second`, `entre_deux`.
#' @export
decider_type <- function(probas, marge_entre_deux = 0.15) {
  p <- as.matrix(probas)
  storage.mode(p) <- "double"
  codes <- colnames(p)
  n <- nrow(p)
  if (n == 0) {
    return(data.frame(type = character(0), proba = numeric(0), type_second = character(0),
                      proba_second = numeric(0), entre_deux = logical(0)))
  }
  # Rang 1 puis rang 2, à égalité le premier type de la clé (comme order(-r)), sans
  # boucle sur les lignes : 450 000 pixels d'un massif en moins d'une seconde.
  lignes <- seq_len(n)
  k1 <- indice_max_ligne(p)
  p1 <- p[cbind(lignes, k1)]
  if (ncol(p) > 1) {
    reste <- p
    reste[cbind(lignes, k1)] <- -Inf
    k2 <- indice_max_ligne(reste)
    p2 <- p[cbind(lignes, k2)]
    second <- codes[k2]
  } else {
    p2 <- rep(0, n)
    second <- rep(NA_character_, n)
  }
  data.frame(
    type = codes[k1],
    proba = p1,
    type_second = second,
    proba_second = p2,
    entre_deux = (p1 - p2) < marge_entre_deux,
    stringsAsFactors = FALSE
  )
}

#' Classer avec la clé floue d'une SER
#'
#' Applique la clé floue à des variables : décision (voir [decider_type()]), drapeau
#' `hors_cle` et probabilités de chaque type en colonnes `p_<code>`.
#'
#' @inheritParams appartenances_types
#' @return data.frame : `type`, `proba`, `type_second`, `proba_second`, `entre_deux`,
#'   `hors_cle`, puis `p_<code>` pour chaque type.
#' @examples
#' chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
#' cle <- lire_configuration(chemin, "exemple-alpes-du-nord")$cle
#' classer_types(cle, data.frame(part_resineux = c(0.1, 0.9), part_pb = 0.2,
#'                               part_bm = 0.3, part_gb = 0.5, rapport_h = 0.8))
#' @export
classer_types <- function(cle, variables) {
  probas <- appartenances_types(cle, variables)
  dec <- decider_type(probas, as.numeric(cle$marge_entre_deux %||% 0.15))
  dec$hors_cle <- attr(probas, "hors_cle")
  pp <- probas
  attr(pp, "hors_cle") <- NULL
  names(pp) <- paste0("p_", names(pp))
  cbind(dec, pp)
}

#' Type observé : la clé à seuils durs appliquée aux mesures
#'
#' La référence de validation est la clé appliquée aux mesures, pas le type relevé à
#' dire d'expert (Souchon, 2020). La souplesse de la clé est mise à zéro : on applique
#' la clé dure.
#'
#' @inheritParams appartenances_types
#' @param mesures data.frame des variables mesurées (une ligne par placette).
#' @return Vecteur de codes de types, un par ligne de `mesures`.
#' @export
types_observes <- function(cle, mesures) {
  dure <- cle
  dure$souplesse <- list()
  decider_type(appartenances_types(dure, mesures))$type
}

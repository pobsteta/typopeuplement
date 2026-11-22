# Clé de détermination à appartenance floue (cle.py du prototype).
#
# Une clé est une liste de types ; chaque type est défini par des intervalles sur des
# variables continues. Une condition dure « min <= v < max » devient le produit de deux
# sigmoïdes dont la pente est réglée par une « souplesse » propre à la variable. Quand la
# souplesse est nulle, on retrouve exactement la clé à seuils durs. Une variable inconnue
# (NA) neutralise la condition qui la porte.
#
# Disjonctions (« ou »). Un type peut porter, à côté de `conditions` (reliées par « et »,
# produit), une liste `alternatives` : plusieurs jeux de conditions reliés par « ou ».
# En JSON : "alternatives": [[cond, cond], [cond]] ; chaque jeu est un tableau de
# conditions {"variable", "min", "max"}. L'appartenance d'un type est
#   produit(conditions) x max(sur les alternatives : produit(conditions du jeu)).
# Le « ou » est le maximum (clé floue) ; le « et » reste le produit de sigmoïdes
# (choix provisoire, à juger sur la carte de H10). Un type sans `alternatives` se lit
# exactement comme avant ; un type peut n'avoir que des `alternatives`. Avec une
# souplesse nulle, le « ou » devient un vrai « ou » de la clé dure.

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

# Conditions « et » d'un type, puis ses jeux « ou » (liste de listes de conditions).
alternatives_type <- function(type) {
  alts <- type$alternatives
  if (length(alts) == 0) return(list())
  if (!is.list(alts) || !is.null(names(alts))) {
    arreter(sprintf("type %s : `alternatives` doit \u00eatre une liste de jeux de conditions",
                    as.character(type$code)))
  }
  for (a in alts) {
    if (!is.list(a) || !is.null(names(a)) || length(a) == 0 ||
        !all(vapply(a, function(cd) is.list(cd) && !is.null(cd$variable), logical(1)))) {
      arreter(sprintf(paste0("type %s : chaque alternative doit \u00eatre un tableau non vide ",
                             "de conditions {\"variable\", \"min\", \"max\"}"),
                      as.character(type$code)))
    }
  }
  alts
}

# Toutes les variables citées par un type (conditions et alternatives).
variables_type <- function(type) {
  conds <- c(type$conditions, unlist(alternatives_type(type), recursive = FALSE))
  unique(vapply(conds, function(cd) as.character(cd$variable), character(1)))
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
#' L'attribut `touche_na` (matrice logique lignes x types) dit quels types portent une
#' condition sur une variable inconnue de la ligne (voir [decider_type()]).
#'
#' Un type est défini par des `conditions` reliées par « et » (produit) et, facultatif,
#' par des `alternatives` : plusieurs jeux de conditions reliés par « ou ». L'appartenance
#' d'un type est le produit de ses `conditions` par le **maximum** des produits de ses
#' alternatives. Une clé sans `alternatives` se lit comme avant. Format JSON : voir
#' [lire_configuration()].
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
  touche_na <- matrix(FALSE, nrow = n, ncol = length(types))
  produit <- function(conds) {
    m <- rep(1, n)
    for (cond in conds) {
      if (!(cond$variable %in% names(variables))) {
        arreter(sprintf("variable absente pour la cl\u00e9 : %s", cond$variable))
      }
      v <- as.numeric(variables[[cond$variable]])
      s <- as.numeric(cle$souplesse[[cond$variable]] %||% 0)
      m <- m * appartenance_condition(v, cond, s)
    }
    m
  }
  for (k in seq_along(types)) {
    scores[, k] <- produit(types[[k]]$conditions)
    alts <- alternatives_type(types[[k]])
    if (length(alts) > 0) {
      ou <- do.call(pmax, lapply(alts, produit))
      scores[, k] <- scores[, k] * ou
    }
    for (nom in variables_type(types[[k]])) {
      touche_na[, k] <- touche_na[, k] | is.na(as.numeric(variables[[nom]]))
    }
  }
  total <- rowSums(scores)
  hors_cle <- total <= 1e-12
  probas <- scores / ifelse(hors_cle, 1, total)
  probas[hors_cle, ] <- 1 / length(types)
  out <- as.data.frame(probas)
  names(out) <- codes
  attr(out, "hors_cle") <- hors_cle
  colnames(touche_na) <- codes
  attr(out, "touche_na") <- touche_na
  out
}

#' Décider du type à partir des probabilités
#'
#' Type retenu (plus forte probabilité), sa probabilité, le second type et le drapeau
#' « entre deux types » : levé quand l'écart entre les deux premières probabilités est
#' inférieur à `marge_entre_deux`.
#'
#' Les probabilités ne contiennent pas de `NA` (la clé n'en produit pas) ; si une valeur
#' manque, elle est traitée comme la plus faible. À égalité, le premier type de la clé.
#'
#' **Groupe de types.** Avec `touche_na` (attribut du même nom rendu par
#' [appartenances_types()]), quand les types à égalité de tête ne se départagent que par
#' une variable manquante (chacun porte une condition sur une variable inconnue de la
#' ligne), on ne choisit pas le premier de la clé : `type` est le groupe des types
#' possibles, codes réunis par `" | "` (par exemple `"R-PB-J | R-PB-C"`), dans l'ordre de
#' la clé, et `entre_deux` est levé. Le second type est alors le meilleur type hors du
#' groupe. Sans `touche_na`, le comportement est celui de toujours.
#'
#' @param probas data.frame ou matrice de probabilités, une colonne par code de type.
#' @param marge_entre_deux Marge « entre deux types ». **Provisoire** : 0,15, reprise du
#'   prototype ; à mesurer sur les SER pilotes.
#' @param touche_na Matrice logique (une ligne par ligne de `probas`, une colonne par
#'   type) des types qui portent une condition sur une variable manquante ; `NULL` : pas
#'   de groupe.
#'
#' @return data.frame : `type`, `proba`, `type_second`, `proba_second`, `entre_deux`.
#' @export
decider_type <- function(probas, marge_entre_deux = 0.15, touche_na = NULL) {
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
  type <- codes[k1]
  groupe <- rep(FALSE, n)
  retire <- matrix(FALSE, n, ncol(p))
  retire[cbind(lignes, k1)] <- TRUE
  if (!is.null(touche_na) && ncol(p) > 1) {
    tna <- as.matrix(touche_na)
    if (!identical(dim(tna), dim(p))) arreter("touche_na doit avoir les dimensions de probas")
    tna <- tna & !is.na(tna)
    ex_aequo <- !is.na(p) & abs(p - p1) <= 1e-9 & tna & tna[cbind(lignes, k1)]
    ex_aequo[cbind(lignes, k1)] <- TRUE
    groupe <- tna[cbind(lignes, k1)] & rowSums(ex_aequo) > 1
    retire <- retire | (ex_aequo & groupe)
    if (any(groupe)) {
      type[groupe] <- vapply(which(groupe), function(r) paste(codes[ex_aequo[r, ]], collapse = " | "),
                             character(1))
    }
  }
  if (ncol(p) > 1) {
    reste <- p
    reste[retire] <- -Inf
    k2 <- indice_max_ligne(reste)
    p2 <- p[cbind(lignes, k2)]
    second <- codes[k2]
    vide <- rowSums(!retire) == 0
    p2[vide] <- 0
    second[vide] <- NA_character_
  } else {
    p2 <- rep(0, n)
    second <- rep(NA_character_, n)
  }
  data.frame(
    type = type,
    proba = p1,
    type_second = second,
    proba_second = p2,
    entre_deux = ((p1 - p2) < marge_entre_deux) | groupe,
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

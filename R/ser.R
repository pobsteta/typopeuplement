# Déclinaison par sylvoécorégion : un socle national, une calibration locale (ser.py).
#
# - Une SER reçoit son propre modèle quand elle a assez de placettes pour chaque type ;
#   sinon elle hérite du modèle de sa grande région écologique (GRECO).
# - Les limites de SER ne doivent pas créer de ruptures : dans une bande de transition,
#   les probabilités des deux modèles sont pondérées selon la distance à la limite.

.cache_ser <- new.env(parent = emptyenv())

# Référentiel des SER (GeoData INRAE) : inst/extdata/ser/ser_codes.csv.
codes_ser_referentiel <- function() {
  if (is.null(.cache_ser$codes)) {
    chemin <- system.file("extdata", "ser", "ser_codes.csv", package = "typopeuplement")
    if (!nzchar(chemin)) arreter("r\u00e9f\u00e9rentiel des SER introuvable (ser_codes.csv)")
    .cache_ser$codes <- utils::read.csv(chemin, comment.char = "#", stringsAsFactors = FALSE,
                                        encoding = "UTF-8")
  }
  .cache_ser$codes
}

#' Grande région écologique (GRECO) d'une SER
#'
#' La GRECO est la première lettre du code SER (référentiel GeoData INRAE : 86 SER
#' principales, GRECO A à K, et 5 SER d'alluvions récentes, GRECO L). Un code absent du
#' référentiel (`inst/extdata/ser/ser_codes.csv`) est refusé : on n'invente pas de GRECO.
#'
#' @param code_ser Codes SER (par exemple `"H10"`).
#' @return Vecteur de codes GRECO, nommé par code SER.
#' @examples
#' greco_de_ser(c("H10", "L5"))
#' @export
greco_de_ser <- function(code_ser) {
  code_ser <- as.character(code_ser)
  ref <- codes_ser_referentiel()
  inconnus <- unique(code_ser[is.na(code_ser) | !(code_ser %in% ref$code_ser)])
  if (length(inconnus) > 0) {
    arreter(sprintf("code SER hors du r\u00e9f\u00e9rentiel GeoData INRAE : %s",
                 paste(inconnus, collapse = ", ")))
  }
  stats::setNames(ref$code_greco[match(code_ser, ref$code_ser)], code_ser)
}

#' Niveau du modèle : SER ou grande région
#'
#' « ser » si chaque type de la clé a au moins `minimum` placettes, sinon
#' « grande_region » : la SER hérite alors du modèle de sa GRECO.
#'
#' @param effectifs Effectifs de placettes par type : vecteur nommé ou `table`.
#' @param codes Codes des types de la clé.
#' @param minimum Nombre minimal de placettes par type. **Provisoire** : 30
#'   (`placettes_min_par_type` de la configuration d'exemple).
#' @return `"ser"` ou `"grande_region"`.
#' @export
niveau_modele <- function(effectifs, codes, minimum = 30) {
  e <- stats::setNames(as.numeric(effectifs), names(effectifs))
  n <- e[codes]
  n[is.na(n)] <- 0
  if (all(n >= minimum)) "ser" else "grande_region"
}

#' Poids du modèle de la SER du pixel dans la bande de transition
#'
#' Selon la distance signée à la limite (positive à l'intérieur de la SER du pixel) :
#' 0,5 sur la limite, 1 au-delà de la demi-largeur de bande, variation linéaire.
#'
#' @param distance_m Distance signée à la limite de SER, en m.
#' @param demi_largeur_m Demi-largeur de la bande de transition, en m. **Provisoire** : 500.
#' @return Poids entre 0,5 et 1.
#' @export
poids_transition <- function(distance_m, demi_largeur_m = 500) {
  d <- as.numeric(distance_m)
  if (demi_largeur_m <= 0) return(rep(1, length(d)))
  pmin(pmax(0.5 + d / (2 * demi_largeur_m), 0.5), 1)
}

#' Raccorder les probabilités de deux modèles de SER
#'
#' Mélange pondéré des probabilités du modèle de la SER du pixel et de celui de la SER
#' voisine ; un type absent d'un côté y vaut 0 ; les lignes sont ramenées à 1.
#'
#' @param p_ser,p_voisine data.frame de probabilités (une colonne par type).
#' @param poids Poids du modèle de la SER du pixel (voir [poids_transition()]).
#' @return data.frame, une colonne par type présent d'un côté ou de l'autre.
#' @export
raccorder_probabilites <- function(p_ser, p_voisine, poids) {
  codes <- unique(c(names(p_ser), names(p_voisine)))
  etendre <- function(p) {
    m <- matrix(0, nrow(p), length(codes), dimnames = list(NULL, codes))
    for (c in names(p)) m[, c] <- as.numeric(p[[c]])
    m
  }
  w <- rep_len(as.numeric(poids), nrow(p_ser))
  m <- w * etendre(p_ser) + (1 - w) * etendre(p_voisine)
  m <- m / rowSums(m)
  out <- as.data.frame(m)
  names(out) <- codes
  out
}

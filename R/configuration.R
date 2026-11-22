# Configuration par SER : un socle national, une grande région, une SER.
# Équivalent de charger_configuration() du prototype (ser.py).

# Fusion récursive de deux listes nommées : `dessus` l'emporte sur `base`.
fusionner_listes <- function(base, dessus) {
  out <- base
  for (k in names(dessus)) {
    v <- dessus[[k]]
    if (est_dictionnaire(v) && est_dictionnaire(out[[k]])) {
      out[[k]] <- fusionner_listes(out[[k]], v)
    } else {
      out[k] <- list(v)
    }
  }
  out
}

est_dictionnaire <- function(x) is.list(x) && !is.null(names(x))

#' Lire la configuration effective d'une SER
#'
#' Lit un fichier JSON de configuration et rend la configuration effective d'une SER :
#' le socle `national`, puis la grande région de la SER (`grandes_regions`), puis la SER
#' elle-même (`ser`), chaque niveau l'emportant sur le précédent, champ par champ.
#'
#' Les seuils, la clé de types et ses souplesses sont propres à chaque SER. La clé de
#' `inst/extdata/config/exemple.json` est un **exemple** pour faire tourner la chaîne,
#' pas une typologie : chaque SER pilote la remplacera par la sienne, sourcée.
#'
#' @param chemin Chemin du fichier JSON de configuration.
#' @param ser Nom de la SER dans la rubrique `ser` du fichier.
#'
#' @return Une liste : les champs fusionnés, plus `ser` (le nom demandé). La clé est
#'   dans `$cle` : `types` (liste de types, chacun `code`, `libelle`, `conditions`),
#'   `souplesse` (liste nommée par variable) et `marge_entre_deux`.
#'
#' @examples
#' chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
#' conf <- lire_configuration(chemin, "exemple-vosges")
#' conf$seuils_diametre$bm_gb_cm   # 47,5 cm dans les Vosges (Souchon, 2020)
#' @export
lire_configuration <- function(chemin, ser) {
  if (!file.exists(chemin)) {
    arreter(sprintf("fichier de configuration introuvable : %s", chemin))
  }
  conf <- jsonlite::fromJSON(chemin, simplifyVector = TRUE, simplifyDataFrame = FALSE,
                             simplifyMatrix = FALSE)
  sers <- conf$ser %||% list()
  if (!(ser %in% names(sers))) {
    arreter(sprintf("SER inconnue dans la configuration : %s", ser))
  }
  s <- sers[[ser]]
  if (length(s) == 0) s <- list()
  greco <- list()
  if (!is.null(s$grande_region)) greco <- conf$grandes_regions[[s$grande_region]] %||% list()
  eff <- fusionner_listes(fusionner_listes(conf$national %||% list(), greco), s)
  eff$ser <- ser
  eff
}

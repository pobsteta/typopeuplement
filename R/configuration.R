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
#' **Format de la clé.** `cle$types` est une liste de types ; chacun a un `code`, un
#' `libelle` et des `conditions` : `{"variable": "part_gb", "min": 0.5, "max": 0.8}`
#' (`min` inclus, `max` exclu, l'un ou l'autre facultatif), reliées par « et ». Pour un
#' « ou », le type porte en plus des `alternatives` : un tableau de jeux de conditions.
#'
#' ```
#' {"code": "X", "libelle": "...",
#'  "conditions": [{"variable": "part_resineux", "min": 0.65}],
#'  "alternatives": [
#'    [{"variable": "part_gb", "min": 0.5}],
#'    [{"variable": "part_pb", "max": 0.2}, {"variable": "rapport_h", "min": 0.6}]]}
#' ```
#'
#' Ce type vaut : `conditions` **et** (premier jeu **ou** second jeu). Dans la clé floue,
#' l'appartenance est le produit des `conditions` par le maximum des produits des jeux.
#' `conditions` peut être absent quand le type n'a que des `alternatives`. Une clé sans
#' `alternatives` se lit exactement comme avant. Une alternative vide ou mal formée est
#' une erreur.
#'
#' **Bloc `jeux`.** Les souplesses propres à un jeu de données (erreurs d'un producteur)
#' se déclarent à côté de la clé, sous `jeux.<nom du jeu>`, à la racine du fichier (ou dans une SER) :
#' `{"jeux": {"vercors_onf": {"source": "fiche ONF, p. 1", "souplesse": {"part_gb": 0.11}}}}`.
#' Pour les variables qu'il nomme, `souplesse` remplace celles de la clé quand les
#' variables viennent de ce jeu ([couches_onf()] porte le nom `vercors_onf`). `source` est
#' reprise dans la fiche. Une souplesse négative ou non numérique est une erreur.
#'
#' @param chemin Chemin du fichier JSON de configuration.
#' @param ser Nom de la SER dans la rubrique `ser` du fichier.
#'
#' @return Une liste : les champs fusionnés, plus `ser` (le nom demandé). La clé est
#'   dans `$cle` : `types` (liste de types, chacun `code`, `libelle`, `conditions`,
#'   et `alternatives` s'il y a des « ou »), `souplesse` (liste nommée par variable) et
#'   `marge_entre_deux`. Le bloc `jeux` est rendu tel quel.
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
  # Les jeux se déclarent à la racine du fichier (ou, s'ils sont propres à une SER, dans la SER).
  jeux <- fusionner_listes(conf$jeux %||% list(), eff$jeux %||% list())
  if (length(jeux) > 0) eff$jeux <- jeux
  verifier_cle_et_jeux(eff)
  eff
}

# Contrôle de forme de la clé (alternatives) et des jeux (souplesses).
verifier_cle_et_jeux <- function(conf) {
  for (t in conf$cle$types) alternatives_type(t)
  for (nom in names(conf$jeux)) {
    sou <- conf$jeux[[nom]]$souplesse
    for (v in names(sou)) {
      x <- sou[[v]]
      if (!is.numeric(x) || length(x) != 1 || is.na(x) || x < 0) {
        arreter(sprintf("jeu %s : la souplesse de %s doit \u00eatre un nombre positif ou nul", nom, v))
      }
    }
  }
  invisible(TRUE)
}

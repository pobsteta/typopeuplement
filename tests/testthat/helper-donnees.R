# Aides communes aux tests d'acceptation (mission 004).
#
# Hypothese de travail, a confirmer a la mission 003 : les noms de colonnes et de champs
# reprennent ceux du prototype Python (carte$type, carte$proba, carte$entre_deux,
# resultat$fiche_validation, etc.), car le plan de 003 fixe les noms de fonctions mais pas
# ceux des colonnes. Chaque test dit ce qu'il suppose.

SER_EXEMPLE <- "exemple-alpes-du-nord"

lire_fixture <- function(nom, ...) {
  utils::read.csv(
    testthat::test_path("fixtures", nom),
    na.strings = c("", "NA"), stringsAsFactors = FALSE, encoding = "UTF-8",
    check.names = FALSE, ...
  )
}

# Configuration d'exemple : celle que 003 range dans inst/extdata/config/ (plan, reponse 3) ;
# a defaut, config/exemple.json a la racine (celle du prototype).
chemin_config_exemple <- function() {
  racine <- normalizePath(testthat::test_path("..", ".."))
  dossier <- file.path(racine, "inst", "extdata", "config")
  json <- list.files(dossier, pattern = "\\.json$", full.names = TRUE)
  if (length(json) > 0) {
    prefere <- json[grepl("exemple", basename(json))]
    return(if (length(prefere) > 0) prefere[1] else json[1])
  }
  file.path(racine, "config", "exemple.json")
}

chemin_ser_codes <- function() {
  normalizePath(testthat::test_path("..", "..", "inst", "extdata", "ser", "ser_codes.csv"))
}

# Ecrit un JSON de configuration temporaire et rend son chemin.
ecrire_json <- function(texte) {
  f <- tempfile(fileext = ".json")
  writeLines(texte, f, useBytes = TRUE)
  f
}

# Cle jouet du prototype (tests/test_cle.py), passee par lire_configuration() pour que sa
# forme en R soit celle que produit la chaine, quelle qu'elle soit.
cle_jouet <- function(souplesse = '{"x": 0.05}') {
  f <- ecrire_json(sprintf('{
    "national": {"cle": {
      "marge_entre_deux": 0.2,
      "souplesse": %s,
      "types": [
        {"code": "A", "conditions": [{"variable": "x", "max": 0.5}]},
        {"code": "B", "conditions": [{"variable": "x", "min": 0.5}]}
      ]}},
    "ser": {"s": {}}
  }', souplesse))
  lire_configuration(f, "s")$cle
}

# Ligne d'une table par identifiant de placette, que l'identifiant soit une colonne
# `placette` ou le nom de ligne.
ligne_placette <- function(df, id) {
  if ("placette" %in% names(df)) df[df$placette == id, , drop = FALSE] else df[id, , drop = FALSE]
}

# Noms des lignes d'un tableau de comparaison, en colonne `classifieur` ou en noms de ligne.
noms_classifieurs <- function(r) {
  if ("classifieur" %in% names(r)) as.character(r$classifieur) else rownames(r)
}

expect_proche <- function(x, y, tol, info = NULL) {
  testthat::expect_lt(max(abs(as.numeric(x) - as.numeric(y))), tol, label = info)
}

# Jeu synthetique exporte du prototype (30 x 30 pixels, 200 placettes, graine 1).
placettes_fixture <- function() lire_fixture("placettes.csv")
pixels_fixture <- function() lire_fixture("pixels.csv")
references_prototype <- function() {
  r <- lire_fixture("references_prototype.csv")
  stats::setNames(r$valeur, r$grandeur)
}

# Resultat de la chaine sur le jeu exporte, calcule une seule fois par session de tests.
.cache_tests <- new.env()
resultat_chaine <- function() {
  if (is.null(.cache_tests$res)) {
    conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
    .cache_tests$res <- executer_chaine(placettes_fixture(), pixels_fixture(), conf)
  }
  .cache_tests$res
}

# Une erreur attendue doit etre l'erreur de la fonction, pas « fonction introuvable » : sans cette
# precaution, un test d'erreur passerait au vert alors que R/ n'existe pas encore.
expect_erreur <- function(expr, motif = NULL) {
  err <- tryCatch({
    force(expr)
    NULL
  }, error = function(e) e)
  testthat::expect_false(is.null(err), label = "une erreur est levee")
  if (is.null(err)) return(invisible(NULL))
  msg <- conditionMessage(err)
  testthat::expect_false(
    grepl("could not find function|impossible de trouver la fonction|unused argument|argument inutilis", msg),
    label = paste("l'erreur vient de la fonction testee, pas d'une fonction absente :", msg)
  )
  if (!is.null(motif)) testthat::expect_match(msg, motif)
  invisible(err)
}

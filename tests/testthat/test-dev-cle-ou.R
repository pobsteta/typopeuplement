# Tests unitaires de la mission 007 (agent dev) : clé à disjonctions, groupe de types quand
# une variable manque, bloc `jeux`, bande de transition strictement positive, mineurs de 006.

# Configuration temporaire : l'exemple du package plus un bloc `jeux` (texte JSON).
conf_exemple_avec_jeux <- function(jeux_json) {
  conf <- jsonlite::fromJSON(chemin_config_exemple(), simplifyVector = FALSE)
  conf$jeux <- jsonlite::fromJSON(jeux_json, simplifyVector = FALSE)
  f <- tempfile(fileext = ".json")
  writeLines(jsonlite::toJSON(conf, auto_unbox = TRUE, digits = NA), f, useBytes = TRUE)
  f
}

cle_ou <- function(souplesse = '{"x": 0.05, "y": 0.05}') {
  f <- ecrire_json(sprintf('{
    "national": {"cle": {
      "marge_entre_deux": 0.15,
      "souplesse": %s,
      "types": [
        {"code": "A", "conditions": [{"variable": "x", "max": 0.3}]},
        {"code": "B", "conditions": [{"variable": "x", "min": 0.3, "max": 0.6}]},
        {"code": "C", "alternatives": [
          [{"variable": "x", "min": 0.6}, {"variable": "y", "max": 0.5}],
          [{"variable": "x", "min": 0.6}, {"variable": "y", "min": 0.8}]]}
      ]}},
    "ser": {"s": {}}
  }', souplesse))
  lire_configuration(f, "s")$cle
}

test_that("une cle sans « ou » : probabilites identiques a celles de la formule d'avant", {
  cle <- cle_jouet()
  x <- c(0.05, 0.45, 0.5, 0.55, 0.95)
  p <- appartenances_types(cle, data.frame(x = x))
  sa <- 1 / (1 + exp(-(0.5 - x) / 0.05)); sb <- 1 / (1 + exp(-(x - 0.5) / 0.05))
  expect_equal(p$A, sa / (sa + sb), tolerance = 1e-12)
  expect_equal(p$B, sb / (sa + sb), tolerance = 1e-12)
  # Un type aux alternatives vides ou absentes se lit comme avant.
  cle$types[[1]]$alternatives <- list()
  expect_equal(appartenances_types(cle, data.frame(x = x))$A, p$A, tolerance = 1e-12)
})

test_that("un type « A ou B » a pour appartenance le maximum des deux jeux", {
  cle <- cle_ou()
  v <- data.frame(x = c(0.9, 0.9, 0.9, 0.9), y = c(0.2, 0.65, 0.8, 0.95))
  # Appartenance brute de C (avant normalisation) : la fonction interne, jeu par jeu.
  mu <- function(cond, s) {
    appartenance_condition(v[[cond$variable]], cond, s)
  }
  j1 <- mu(list(variable = "x", min = 0.6), 0.05) * mu(list(variable = "y", max = 0.5), 0.05)
  j2 <- mu(list(variable = "x", min = 0.6), 0.05) * mu(list(variable = "y", min = 0.8), 0.05)
  attendu <- pmax(j1, j2)
  p <- appartenances_types(cle, v)
  # A et B valent ~0 pour x = 0,9 : la probabilite de C est attendu / (attendu + petit).
  brut <- attendu / (attendu + appartenance_condition(v$x, list(max = 0.3), 0.05) +
                       appartenance_condition(v$x, list(min = 0.3, max = 0.6), 0.05))
  expect_equal(p$C, brut, tolerance = 1e-12)
  expect_gt(p$C[1], 0.99)   # premier jeu
  expect_gt(p$C[3], 0.99)   # second jeu
  expect_equal(rowSums(p), rep(1, 4), tolerance = 1e-12)
})

test_that("« ou » avec une souplesse nulle : on retrouve la cle dure", {
  cle <- cle_ou(souplesse = "{}")
  v <- data.frame(x = c(0.1, 0.4, 0.9, 0.9, 0.9, 0.9, 0.6), y = c(0, 0, 0.2, 0.5, 0.8, 0.9, 0.2))
  p <- as.matrix(appartenances_types(cle, v))
  hors <- attr(appartenances_types(cle, v), "hors_cle")
  expect_true(all(p[!hors, ] %in% c(0, 1)))
  attendu <- c("A", "B", "C", NA, "C", "C", "C")
  retenu <- ifelse(rowSums(p) == 1 & p[cbind(seq_len(nrow(p)), max.col(p, "first"))] == 1,
                   colnames(p)[max.col(p, "first")], NA)
  # y = 0,5 : ni y < 0,5 ni y >= 0,8, hors cle (probabilites egales, pas de type franc).
  expect_identical(attr(appartenances_types(cle, v), "hors_cle"),
                   c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE))
  expect_identical(retenu[-4], attendu[-4])
})

test_that("alternatives mal formees : erreur claire a la lecture de la configuration", {
  f <- ecrire_json('{"national": {"cle": {"types": [
      {"code": "A", "alternatives": [{"variable": "x", "min": 0.5}]}]}}, "ser": {"s": {}}}')
  expect_erreur(lire_configuration(f, "s"), "alternative")
  f <- ecrire_json('{"national": {"cle": {"types": [
      {"code": "A", "alternatives": [[]]}]}}, "ser": {"s": {}}}')
  expect_erreur(lire_configuration(f, "s"), "alternative")
  # Variable absente d'une alternative : arret comme pour une condition.
  cle <- cle_ou()
  expect_erreur(appartenances_types(cle, data.frame(x = 0.9)), "variable absente")
})

test_that("variable absente : les types qui ne se departagent que par elle forment un groupe", {
  f <- ecrire_json('{"national": {"cle": {"marge_entre_deux": 0.15, "types": [
      {"code": "F", "libelle": "Feuillus", "conditions": [{"variable": "r", "max": 0.35}]},
      {"code": "J", "libelle": "Jeune", "conditions": [{"variable": "r", "min": 0.65}, {"variable": "rh", "max": 0.6}]},
      {"code": "C", "libelle": "Chetif", "conditions": [{"variable": "r", "min": 0.65}, {"variable": "rh", "min": 0.6}]},
      {"code": "I", "libelle": "Irregulier", "conditions": [{"variable": "r", "min": 0.65}, {"variable": "pb", "max": 0.5}]}]}},
      "ser": {"s": {}}}')
  cle <- lire_configuration(f, "s")$cle
  v <- data.frame(r = c(0.1, 0.9, 0.9), rh = c(NA, NA, 0.3), pb = c(NA, 0.45, NA))
  pr <- appartenances_types(cle, v)
  tna <- attr(pr, "touche_na")
  d <- decider_type(pr, 0.15, touche_na = tna)
  # Ligne 1 : F l'emporte, rh manque mais F ne la porte pas : pas de groupe.
  expect_identical(d$type[1], "F")
  # Ligne 2 : J et C (rh manquante) a egalite, I (pb = 0,45, mesuree) a egalite mais hors groupe : groupe J | C.
  expect_identical(d$type[2], "J | C")
  expect_true(d$entre_deux[2])
  expect_identical(d$type_second[2], "I")
  # Ligne 3 : J (rh = 0,3 < 0,6) et I (pb manquante) : J gagne franchement ; pas de groupe.
  expect_identical(d$type[3], "J")
  # Sans touche_na : comportement d'avant, le premier de la cle.
  expect_identical(decider_type(pr)$type[2], "J")
  expect_identical(classer_types(cle, v)$type[2], "J")
  # Table de correspondance : les groupes ont leur valeur et leur libelle.
  corr <- correspondance_types(cle, c(d$type, d$type_second))
  expect_identical(corr$code, c("F", "J", "C", "I", "J | C"))
  expect_identical(corr$valeur, 1:5)
  expect_identical(corr$libelle[5], "Jeune | Chetif")
  expect_identical(correspondance_types(cle)$code, c("F", "J", "C", "I"))
})

test_that("decider_type : NA traites comme la plus faible probabilite, egalites au premier type", {
  p <- data.frame(A = c(NA, 0.5, 0.5), B = c(0.4, NA, 0.5), C = c(0.6, 0.5, 0.2))
  d <- decider_type(p)
  expect_identical(d$type, c("C", "A", "A"))
  expect_identical(d$type_second, c("B", "C", "B"))
  expect_identical(d$entre_deux, c(FALSE, TRUE, TRUE))
})

test_that("livrables : un groupe de types a sa valeur dans types.tif et dans correspondance_types.csv", {
  px <- pixels_fixture()
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  vars <- data.frame(i = px$i, j = px$j, h_dom = px$h_dom, couvert = px$couvert,
                     famille = px$famille, G = 25, part_resineux = 0.8, part_pb = 0.6,
                     part_gb = 0.1)
  res <- executer_chaine_fournie(vars, conf, milieu = NULL)  # rapport_h absent partout
  expect_true(all(res$carte$type == "R-PB-J | R-PB-C"))
  expect_true(all(res$carte$entre_deux))
  dossier <- file.path(tempdir(), "dev_cle_ou_groupe")
  ecrire_livrables(res, dossier)
  corr <- utils::read.csv(file.path(dossier, "correspondance_types.csv"))
  expect_true("R-PB-J | R-PB-C" %in% corr$code)
  r <- terra::rast(file.path(dossier, "types.tif"))
  v <- unique(stats::na.omit(terra::values(r[["type"]])))
  expect_identical(corr$code[match(v, corr$valeur)], "R-PB-J | R-PB-C")
  niv <- utils::read.csv(file.path(dossier, "correspondance_niveau_modele.csv"))
  expect_equal(niv$valeur, c(0, 1, 2))
  expect_identical(niv$niveau, c("producteur", "ser", "grande_region"))
})

test_that("jeux : souplesse du jeu lue dans la configuration, validee, jamais en dur", {
  conf <- conf_exemple_avec_jeux('{"vercors_onf": {"souplesse": {"part_gb": 0.2}}, "autre": {"souplesse": {"G": 1}}}')
  eff <- lire_configuration(conf, SER_EXEMPLE)
  expect_equal(eff$jeux$vercors_onf$souplesse$part_gb, 0.2)
  expect_erreur(lire_configuration(conf_exemple_avec_jeux('{"j": {"souplesse": {"G": -1}}}'),
                                   SER_EXEMPLE), "positif ou nul")
  expect_erreur(lire_configuration(conf_exemple_avec_jeux('{"j": {"souplesse": {"G": "a"}}}'),
                                   SER_EXEMPLE), "positif ou nul")
})

test_that("poids_transition : demi-largeur nulle, negative ou NA = erreur claire", {
  expect_erreur(poids_transition(0, 0), "strictement positive")
  expect_erreur(poids_transition(0, -5), "strictement positive")
  expect_erreur(poids_transition(0, NA_real_), "strictement positive")
  expect_equal(poids_transition(c(-1000, 0, 1000), 500), c(0.5, 0.5, 1))
})

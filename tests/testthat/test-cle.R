# Critere 1 de la spec : cle floue.
#  - souplesse nulle : on retrouve exactement la cle dure ;
#  - les probabilites somment a 1 ;
#  - un pixel a egalite est marque « entre deux types ».
# Equivalents R de tests/test_cle.py, plus la comparaison au prototype sur des lignes fixees.
# Fonctions : appartenances_types, decider_type, classer_types, types_observes (plan 003, section 3).
# Suppose : la cle est celle que rend lire_configuration()$cle ; appartenances_types() rend un
# tableau (data.frame ou matrice) a une colonne par code ; classer_types() rend un data.frame de
# colonnes type, proba, type_second, proba_second, entre_deux, hors_cle, p_<code>.

test_that("critere 1 : souplesse nulle, on retrouve exactement la cle dure", {
  cle <- cle_jouet(souplesse = "{}")
  p <- as.matrix(appartenances_types(cle, data.frame(x = c(0.1, 0.49, 0.5, 0.9))))
  expect_equal(colnames(p), c("A", "B"))
  expect_equal(colnames(p)[apply(p, 1, which.max)], c("A", "A", "B", "B"))
  # Seulement des 0 et des 1 : la valeur 0,5 va a B (condition « min <= x < max »).
  expect_true(all(p %in% c(0, 1)))
})

test_that("critere 1 : les probabilites somment a 1 et sont entre 0 et 1", {
  cle <- cle_jouet()
  r <- classer_types(cle, data.frame(x = c(0.05, 0.5, 0.95)))
  expect_equal(r$p_A + r$p_B, c(1, 1, 1), tolerance = 1e-12)
  expect_true(all(r$proba >= 0 & r$proba <= 1))
})

test_that("critere 1 : un pixel a egalite est marque entre deux types", {
  cle <- cle_jouet()
  r <- classer_types(cle, data.frame(x = c(0.05, 0.5, 0.95)))
  expect_identical(as.logical(r$entre_deux), c(FALSE, TRUE, FALSE))
  expect_equal(r$proba[2], 0.5, tolerance = 1e-12)
  expect_equal(r$type[c(1, 3)], c("A", "B"))
})

test_that("critere 1 : une variable inconnue (NA) neutralise sa condition et le pixel est signale", {
  f <- ecrire_json('{
    "national": {"cle": {"types": [
      {"code": "J", "conditions": [{"variable": "pb", "min": 0.5}, {"variable": "rh", "max": 0.6}]},
      {"code": "C", "conditions": [{"variable": "pb", "min": 0.5}, {"variable": "rh", "min": 0.6}]},
      {"code": "X", "conditions": [{"variable": "pb", "max": 0.5}]}
    ]}},
    "ser": {"s": {}}
  }')
  cle <- lire_configuration(f, "s")$cle
  r <- classer_types(cle, data.frame(pb = c(0.8, 0.8, 0.2), rh = c(0.3, NA, NA)))
  expect_equal(r$type[1], "J")
  # Sans hauteur potentielle, J et C restent a egalite : p = 0,5 et pixel signale.
  expect_equal(r$p_J[2], 0.5, tolerance = 1e-12)
  expect_equal(r$p_C[2], 0.5, tolerance = 1e-12)
  expect_true(as.logical(r$entre_deux[2]))
  expect_equal(r$type[3], "X")
})

test_that("une variable absente de la table leve une erreur (pas un resultat muet)", {
  expect_erreur(appartenances_types(cle_jouet(), data.frame(y = 1)))
})

test_that("decider_type : second type, marge et type unique", {
  # Trois lignes de probabilites a la main : marge 0,15 (valeur par defaut du prototype).
  p <- data.frame(A = c(0.60, 0.50, 1.00), B = c(0.30, 0.45, 0.00), C = c(0.10, 0.05, 0.00))
  d <- decider_type(p, marge_entre_deux = 0.15)
  expect_equal(d$type, c("A", "A", "A"))
  expect_equal(d$type_second, c("B", "B", "B"))
  expect_equal(d$proba, c(0.60, 0.50, 1.00))
  expect_equal(d$proba_second, c(0.30, 0.45, 0.00))
  # 0,60 - 0,30 = 0,30 >= 0,15 : franc ; 0,50 - 0,45 = 0,05 < 0,15 : entre deux.
  expect_identical(as.logical(d$entre_deux), c(FALSE, TRUE, FALSE))
})

test_that("types_observes : la reference est la cle appliquee aux mesures, a seuils durs", {
  # CLAUDE.md : « la reference de validation est la cle appliquee aux mesures » (Souchon, 2020).
  # Meme avec une souplesse non nulle dans la configuration, le type observe est celui de la cle dure.
  cle <- cle_jouet()  # souplesse 0,05
  mes <- data.frame(x = c(0.1, 0.49, 0.5, 0.9))
  expect_equal(as.character(types_observes(cle, mes)), c("A", "A", "B", "B"))
})

test_that("critere 1 : probabilites de la cle d'exemple identiques a celles du prototype (20 lignes fixees)", {
  # Reference : fixtures/cle_reference.csv, produite par tests/testthat/fixtures/exporter_fixtures.py
  # (config/exemple.json, SER exemple-alpes-du-nord). Calcul deterministe, sans hasard : tolerance 1e-8.
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  ref <- lire_fixture("cle_reference.csv")
  expect_equal(nrow(ref), 20L)
  vars <- ref[, c("part_resineux", "part_pb", "part_bm", "part_gb", "rapport_h")]
  codes <- c("F", "M", "R-PB-J", "R-PB-C", "R-GB", "R-IRR")
  r <- classer_types(conf$cle, vars)
  attendu <- as.matrix(ref[, paste0("p_", codes)])
  obtenu <- as.matrix(r[, paste0("p_", codes)])
  expect_proche(obtenu, attendu, 1e-8, "probabilites de la cle")
  expect_proche(r$proba, ref$proba, 1e-8, "probabilite du type retenu")
  expect_identical(as.logical(r$entre_deux), as.logical(ref$entre_deux))
  # Le type retenu n'est comparable que hors egalite exacte (l'ordre des ex aequo n'est pas specifie).
  franc <- (ref$proba - ref$proba_second) > 1e-9
  expect_gt(sum(franc), 10)
  expect_equal(r$type[franc], ref$type[franc])
  # Cle dure appliquee aux memes lignes : y compris les valeurs pile sur les seuils.
  # Hors rapport_h inconnu : sans hauteur potentielle, R-PB-J et R-PB-C sont a egalite exacte et le choix
  # entre ex aequo n'est pas specifie.
  connu <- !is.na(vars$rapport_h)
  expect_gt(sum(connu), 10)
  expect_equal(as.character(types_observes(conf$cle, vars))[connu], ref$type_dur[connu])
})

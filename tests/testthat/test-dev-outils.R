# Tests unitaires de la mission 003 (agent dev) : outils internes, clé, lissage, configuration.

test_that("avec_graine : reproductible et sans toucher au hasard de l'utilisateur", {
  set.seed(42)
  avant <- .Random.seed
  a <- typopeuplement:::avec_graine(3, stats::runif(3))
  expect_identical(.Random.seed, avant)
  b <- typopeuplement:::avec_graine(3, stats::runif(3))
  expect_identical(a, b)
})

test_that("graine_ranger : la graine 0 du prototype reste une graine fixe pour ranger", {
  # Pour ranger, seed = 0 veut dire « au hasard » : on decale de 1.
  expect_identical(typopeuplement:::graine_ranger(0), 1L)
})

test_that("plis contigus comme KFold sans melange (premiers plis plus grands)", {
  expect_identical(typopeuplement:::plis_contigus(7, 3), c(1L, 1L, 1L, 2L, 2L, 3L, 3L))
})

test_that("plis stratifies : chaque classe est repartie dans tous les plis", {
  y <- rep(c("a", "b"), c(9, 6))
  pli <- typopeuplement:::plis_stratifies(y, 3, 0)
  expect_equal(as.vector(table(pli[y == "a"])), c(3, 3, 3))
  expect_equal(as.vector(table(pli[y == "b"])), c(2, 2, 2))
})

test_that("arret : le message garde ses accents, quelle que soit la locale", {
  msg <- tryCatch(typopeuplement:::arreter("mod\u00e8le"), error = conditionMessage)
  expect_identical(charToRaw(msg), charToRaw(enc2utf8("mod\u00e8le")))
})

test_that("cle : une ligne hors de tout type a des probabilites egales et est signalee", {
  f <- ecrire_json('{"national": {"cle": {"types": [
      {"code": "A", "conditions": [{"variable": "x", "max": 0.3}]},
      {"code": "B", "conditions": [{"variable": "x", "min": 0.7}]}]}},
    "ser": {"s": {}}}')
  cle <- lire_configuration(f, "s")$cle
  r <- classer_types(cle, data.frame(x = c(0.1, 0.5)))
  expect_identical(r$hors_cle, c(FALSE, TRUE))
  expect_equal(c(r$p_A[2], r$p_B[2]), c(0.5, 0.5))
})

test_that("decider_type : une cle a un seul type, pas de second type", {
  d <- decider_type(data.frame(A = c(1, 1)))
  expect_equal(d$type, c("A", "A"))
  expect_true(all(is.na(d$type_second)))
  expect_false(any(d$entre_deux))
})

test_that("lissage, fenetre paire : alignement de scipy (fenetre de i - 1 a i)", {
  # Reference calculee avec lisser() du prototype (fenetre 2).
  p <- data.frame(A = c(0.9, 0.2, 0.5, 0.1), B = c(0.1, 0.8, 0.5, 0.9))
  l <- lisser_probabilites(p, c(0, 0, 0, 1), c(0, 1, 2, 2), 2)
  expect_equal(l$A, c(0.9, 0.55, 0.35, 0.8 / 3), tolerance = 1e-12)
})

test_that("configuration : un tableau est remplace, pas fusionne ; la SER l'emporte", {
  f <- ecrire_json('{"national": {"predicteurs": ["a", "b"], "h": {"x": 1, "y": 2}},
    "grandes_regions": {"g": {"h": {"y": 3}}},
    "ser": {"s": {"grande_region": "g", "predicteurs": ["c"]}}}')
  conf <- lire_configuration(f, "s")
  expect_identical(conf$predicteurs, "c")
  expect_equal(conf$h, list(x = 1, y = 3))
})

test_that("configuration d'exemple du package identique a celle du prototype", {
  racine <- normalizePath(testthat::test_path("..", ".."))
  pkg <- jsonlite::fromJSON(file.path(racine, "inst", "extdata", "config", "exemple.json"))
  proto <- jsonlite::fromJSON(file.path(racine, "config", "exemple.json"))
  expect_identical(pkg, proto)
})

test_that("fichier de configuration absent : erreur qui le nomme", {
  expect_erreur(lire_configuration("introuvable.json", "s"), "introuvable")
})

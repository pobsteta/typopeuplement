# Critere 2 de la spec : seuils par SER.
#  « un arbre de 45 cm compte en gros bois en Savoie (42,5 cm) et en bois moyen dans les Vosges (47,5 cm) ».
# Equivalents R de tests/test_dendro_ser_validation.py (surface terriere, categories).
# Fonctions : surface_terriere_arbre, variables_placette (plan 003, section 3), lire_configuration.
# Suppose : arbres = data.frame(placette, diametre_cm, resineux logique) ; variables_placette(arbres,
# surface_placette_ha, seuils) rend un data.frame G, part_resineux, part_pb, part_bm, part_gb, une ligne
# par placette (colonne `placette` ou noms de ligne).

SEUILS_SAVOIE <- list(precomptage_cm = 17.5, pb_bm_cm = 27.5, bm_gb_cm = 42.5)
SEUILS_VOSGES <- list(precomptage_cm = 17.5, pb_bm_cm = 27.5, bm_gb_cm = 47.5)

arbres_45 <- function() {
  data.frame(
    placette = rep("p", 3),
    diametre_cm = c(15, 45, 45),
    resineux = c(TRUE, TRUE, FALSE)
  )
}

test_that("surface terriere d'un arbre : diametre en cm, resultat en m2", {
  expect_equal(surface_terriere_arbre(100), pi / 4, tolerance = 1e-12)
  expect_equal(surface_terriere_arbre(c(0, 100, 50)), c(0, pi / 4, pi / 16), tolerance = 1e-12)
})

test_that("critere 2 : un arbre de 45 cm est gros bois en Savoie (42,5 cm) et bois moyen dans les Vosges (47,5 cm)", {
  savoie <- variables_placette(arbres_45(), 0.0707, SEUILS_SAVOIE)
  vosges <- variables_placette(arbres_45(), 0.0707, SEUILS_VOSGES)
  s <- ligne_placette(savoie, "p")
  v <- ligne_placette(vosges, "p")
  # L'arbre de 15 cm est sous le precomptage (17,5 cm) : il ne compte pas.
  expect_equal(s$part_gb, 1, tolerance = 1e-12)
  expect_equal(s$part_bm, 0, tolerance = 1e-12)
  expect_equal(v$part_bm, 1, tolerance = 1e-12)
  expect_equal(v$part_gb, 0, tolerance = 1e-12)
  expect_equal(s$part_pb, 0, tolerance = 1e-12)
  # Un des deux arbres retenus est resineux : part de resineux 0,5.
  expect_equal(s$part_resineux, 0.5, tolerance = 1e-12)
  # G en m2/ha : deux arbres de 45 cm sur 0,0707 ha.
  expect_equal(s$G, 2 * pi * 0.45^2 / 4 / 0.0707, tolerance = 1e-9)
  expect_equal(v$G, s$G, tolerance = 1e-12)
})

test_that("critere 2 : les seuils viennent de la configuration de la SER (42,5 Alpes, 47,5 Vosges)", {
  chemin <- chemin_config_exemple()
  alpes <- lire_configuration(chemin, "exemple-alpes-du-nord")
  vosges <- lire_configuration(chemin, "exemple-vosges")
  expect_equal(alpes$seuils_diametre$bm_gb_cm, 42.5)
  expect_equal(vosges$seuils_diametre$bm_gb_cm, 47.5)
  # Les autres seuils du socle national se retrouvent dans les deux SER.
  for (conf in list(alpes, vosges)) {
    expect_equal(conf$seuils_diametre$precomptage_cm, 17.5)
    expect_equal(conf$seuils_diametre$pb_bm_cm, 27.5)
  }
  # De bout en bout : meme arbre, deux SER, deux categories.
  a <- ligne_placette(variables_placette(arbres_45(), 0.0707, alpes$seuils_diametre), "p")
  v <- ligne_placette(variables_placette(arbres_45(), 0.0707, vosges$seuils_diametre), "p")
  expect_equal(a$part_gb, 1, tolerance = 1e-12)
  expect_equal(v$part_bm, 1, tolerance = 1e-12)
})

test_that("limites de categories : precomptage, PB/BM et BM/GB sont inclus dans la categorie du dessus", {
  # Convention du prototype : d >= 17,5 compte ; d < 27,5 petit bois ; d < 42,5 bois moyen ; sinon gros bois.
  arbres <- data.frame(
    placette = c("pb", "bm", "gb", "sous"),
    diametre_cm = c(17.5, 27.5, 42.5, 17.4),
    resineux = c(TRUE, TRUE, TRUE, TRUE)
  )
  r <- variables_placette(arbres, 0.0707, SEUILS_SAVOIE)
  expect_equal(ligne_placette(r, "pb")$part_pb, 1, tolerance = 1e-12)
  expect_equal(ligne_placette(r, "bm")$part_bm, 1, tolerance = 1e-12)
  expect_equal(ligne_placette(r, "gb")$part_gb, 1, tolerance = 1e-12)
})

test_that("placette sans arbre compte : G nul et parts non definies (NA), pas de faux zero", {
  arbres <- data.frame(
    placette = c("ok", "sous"),
    diametre_cm = c(30, 12),
    resineux = c(TRUE, TRUE)
  )
  r <- variables_placette(arbres, 0.0707, SEUILS_SAVOIE)
  vide <- ligne_placette(r, "sous")
  expect_equal(vide$G, 0)
  expect_true(is.na(vide$part_gb) && is.na(vide$part_resineux))
  expect_equal(ligne_placette(r, "ok")$part_bm, 1, tolerance = 1e-12)
})

test_that("les parts de categories d'une placette somment a 1 (parts entre 0 et 1)", {
  arbres <- data.frame(
    placette = rep(c("a", "b"), each = 4),
    diametre_cm = c(20, 30, 45, 60, 18, 19, 26, 50),
    resineux = c(TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE)
  )
  r <- variables_placette(arbres, 0.0707, SEUILS_SAVOIE)
  somme <- r$part_pb + r$part_bm + r$part_gb
  expect_equal(somme, rep(1, nrow(r)), tolerance = 1e-12)
  expect_true(all(r$part_resineux >= 0 & r$part_resineux <= 1))
})

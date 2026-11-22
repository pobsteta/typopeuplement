# Lissage a l'echelle de lecture (CLAUDE.md : « valider a l'echelle de lecture »).
# Equivalent R de test_lissage_conserve_les_probabilites. Fonction : lisser_probabilites (plan 003, sect. 3).
# Suppose : lisser_probabilites(probas, i, j, fenetre = 3) rend un data.frame de memes colonnes ; bords
# remplis de zeros comme scipy (plan, section 4) ; les pixels absents ne comptent pas dans la moyenne.

test_that("le lissage conserve les probabilites (lignes de somme 1)", {
  p <- data.frame(A = c(1, 0, 0, 0), B = c(0, 1, 1, 1))
  l <- lisser_probabilites(p, c(0, 0, 1, 1), c(0, 1, 0, 1), 3)
  expect_equal(rowSums(l), rep(1, 4), tolerance = 1e-12)
  # Grille 2 x 2, fenetre 3 x 3 : chaque pixel voit les quatre, A vaut 1/4.
  expect_equal(l$A, rep(0.25, 4), tolerance = 1e-12)
  expect_equal(l$B, rep(0.75, 4), tolerance = 1e-12)
})

test_that("fenetre de 1 : pas de lissage", {
  p <- data.frame(A = c(0.9, 0.1), B = c(0.1, 0.9))
  expect_equal(lisser_probabilites(p, c(0, 0), c(0, 1), 1), p)
})

test_that("lissage identique au prototype sur une grille avec un trou (pixel hors foret)", {
  # fixtures/lissage_reference.csv : grille 4 x 5 sans le pixel (1, 2), probabilites tirees (graine 2).
  ref <- lire_fixture("lissage_reference.csv")
  expect_equal(nrow(ref), 19L)
  p <- ref[, c("p_A", "p_B", "p_C")]
  names(p) <- c("A", "B", "C")
  l <- lisser_probabilites(p, ref$i, ref$j, 3)
  expect_proche(as.matrix(l), as.matrix(ref[, c("l_A", "l_B", "l_C")]), 1e-9, "lissage du prototype")
  expect_equal(rowSums(l), rep(1, 19), tolerance = 1e-12)
})

test_that("un pixel isole (voisins absents) garde ses probabilites", {
  p <- data.frame(A = 0.3, B = 0.7)
  l <- lisser_probabilites(p, 5, 7, 3)
  expect_equal(l$A, 0.3, tolerance = 1e-12)
})

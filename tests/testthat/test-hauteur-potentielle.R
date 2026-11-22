# Critere 5 de la spec : hauteur potentielle.
#  « incertaine -> rapport vide et drapeau leve ; la ou l'age est connu, ecart aux courbes de nemeton
#    rapporte dans la fiche de validation. »
# Equivalents R de tests/test_chaine.py (test_hauteur_potentielle_retrouvee, test_hauteur_incertaine_signalee).
# Fonctions : ajuster_hauteur_potentielle, predire_hauteur_potentielle, peuplements_adultes (plan 003, sect. 3).
# Suppose : ajuster_hauteur_potentielle(pixels, variables_milieu, couvert_min = 0.7, hauteur_min_m = 15,
# incertitude_relative_max = 0.2, quantile_enveloppe = 0.9, graine = 0) rend un modele ;
# predire_hauteur_potentielle(modele, df) rend un data.frame h_pot, h_pot_sd, rapport_h, hp_incertaine ;
# peuplements_adultes(modele, df) rend un vecteur logique.
# Les valeurs par defaut sont les valeurs provisoires de la fiche (plan 003, section 6).

MILIEU <- c("altitude", "pente", "bilan_hydrique", "reserve_utile")

test_that("hauteur potentielle : retrouvee sur le jeu synthetique, a moins de 3 m (RMSE)", {
  pixels <- pixels_fixture()
  verite <- lire_fixture("verite.csv")
  expect_equal(verite[, c("i", "j")], pixels[, c("i", "j")])  # meme ordre de pixels
  m <- ajuster_hauteur_potentielle(pixels, variables_milieu = MILIEU, graine = 0)
  hp <- predire_hauteur_potentielle(m, pixels)
  adultes <- peuplements_adultes(m, pixels)
  expect_equal(sum(adultes), unname(references_prototype()["n_adultes"]))  # 390 pixels adultes fermes
  rmse <- sqrt(mean((hp$h_pot - verite$h_pot)[adultes]^2))
  # Seuil du test Python (< 3,0 m) ; le prototype fait 1,72 m sur ce jeu (references_prototype.csv).
  expect_lt(rmse, 3.0)
  expect_setequal(names(hp), c("h_pot", "h_pot_sd", "rapport_h", "hp_incertaine"))
  expect_equal(nrow(hp), nrow(pixels))
})

test_that("critere 5 : hauteur potentielle incertaine, rapport vide et drapeau leve", {
  pixels <- pixels_fixture()
  # Incertitude relative maximale nulle : tout pixel est juge incertain.
  m <- ajuster_hauteur_potentielle(pixels, variables_milieu = "altitude", incertitude_relative_max = 0)
  hp <- predire_hauteur_potentielle(m, pixels)
  expect_true(all(hp$hp_incertaine))
  expect_true(all(is.na(hp$rapport_h)))
})

test_that("critere 5 : hauteur potentielle certaine, rapport = hauteur dominante / hauteur potentielle", {
  pixels <- pixels_fixture()
  m <- ajuster_hauteur_potentielle(pixels, variables_milieu = MILIEU, incertitude_relative_max = Inf)
  hp <- predire_hauteur_potentielle(m, pixels)
  expect_false(any(hp$hp_incertaine))
  expect_false(anyNA(hp$rapport_h))
  expect_equal(hp$rapport_h, pixels$h_dom / hp$h_pot, tolerance = 1e-9)
  expect_true(all(hp$h_pot > 0 & hp$h_pot_sd >= 0))
})

test_that("critere 5 : drapeau et rapport sont toujours coherents (incertain <=> rapport vide)", {
  pixels <- pixels_fixture()
  m <- ajuster_hauteur_potentielle(pixels, variables_milieu = MILIEU)
  hp <- predire_hauteur_potentielle(m, pixels)
  expect_identical(as.logical(hp$hp_incertaine), is.na(hp$rapport_h))
  # Proportion de pixels incertains du prototype sur ce jeu : 1,3 % ; tolerance absolue 5 points
  # (forets aleatoires differentes entre sklearn et ranger).
  ref <- references_prototype()
  expect_lt(abs(mean(hp$hp_incertaine) - ref[["pct_hp_incertaine"]]), 0.05)
})

test_that("peuplements adultes : couvert >= 0,7 et hauteur dominante >= 15 m (valeurs provisoires)", {
  pixels <- pixels_fixture()
  m <- ajuster_hauteur_potentielle(pixels, variables_milieu = MILIEU)
  adultes <- peuplements_adultes(m, pixels)
  expect_identical(adultes, pixels$couvert >= 0.7 & pixels$h_dom >= 15)
})

test_that("trop peu de peuplements adultes fermes : erreur claire (pas de modele invente)", {
  # Cas terrain : une AOI sans peuplement adulte ferme. Le prototype exige 20 adultes au moins par famille.
  pixels <- pixels_fixture()
  pixels$couvert <- 0.1
  expect_erreur(ajuster_hauteur_potentielle(pixels, variables_milieu = MILIEU), "adultes")
})

test_that("critere 5 : ecart aux courbes de nemeton rapporte dans la fiche de validation", {
  skip_if_not_installed("nemeton")
  # Plan 003, reponse 6 : correlation de rang entre h_pot et l'indice de station de nemeton, la ou l'age et
  # l'essence sont connus, rapportee dans la fiche. Ce n'est pas une egalite.
  # Non branche ici : le jeu synthetique n'a ni age ni essence en colonnes, et le prototype n'a pas cet
  # ecart. Ce test ne fait que verifier que la fiche porte la mention ; la valeur de la correlation n'est pas
  # testee faute de reference (question posee a Pascal dans le rendu 004).
  res <- resultat_chaine()
  md <- paste(fiche_en_markdown(res$fiche_validation), collapse = "\n")
  expect_match(md, "corr[\u00e9e]lation de rang", ignore.case = TRUE)
  expect_match(md, "indice de station", ignore.case = TRUE)
})

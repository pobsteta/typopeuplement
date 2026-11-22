# Critere 6 de la spec : validation.
#  « precision et kappa a la placette et a la grappe de 0,5 ha, sur des placettes non utilisees pour
#    calibrer ; controle par les placettes IFN de la SER. »
# Equivalents R de test_matrice_et_kappa, test_grappes_au_demi_hectare et de la fiche (test_chaine_complete).
# Fonctions : matrice_confusion, indicateurs_confusion, grappes_par_maille, agreger_grappes,
# fiche_validation, fiche_en_markdown (plan 003, section 3).
# Suppose : matrice_confusion(observe, predit, codes = NULL) rend une matrice ou une table observe x predit ;
# indicateurs_confusion(matrice) rend une liste n, precision_globale, kappa, rappel_par_type,
# precision_par_type ; fiche_validation(observe, probas, grappe, ser = "") rend une liste ser, placette,
# grappe (chacune avec matrice, n, precision_globale, kappa).

test_that("critere 6 : precision globale 0,75 et kappa 0,5 sur la matrice du prototype", {
  m <- matrice_confusion(c("A", "A", "B", "B"), c("A", "B", "B", "B"), c("A", "B"))
  mm <- unclass(as.matrix(m))
  expect_equal(unname(mm), matrix(c(1, 0, 1, 2), 2))  # lignes : observe A, B ; colonnes : predit A, B
  ind <- indicateurs_confusion(m)
  expect_equal(ind$n, 4)
  expect_equal(ind$precision_globale, 0.75, tolerance = 1e-12)
  expect_equal(ind$kappa, 0.5, tolerance = 1e-12)
})

test_that("critere 6 : rappel et precision par type", {
  m <- matrice_confusion(c("A", "A", "B", "B"), c("A", "B", "B", "B"), c("A", "B"))
  ind <- indicateurs_confusion(m)
  expect_equal(unlist(ind$rappel_par_type)[c("A", "B")], c(A = 0.5, B = 1), tolerance = 1e-12)
  expect_equal(unlist(ind$precision_par_type)[c("A", "B")], c(A = 1, B = 2 / 3), tolerance = 1e-12)
})

test_that("matrice de confusion : un type jamais observe ni predit garde sa ligne et sa colonne", {
  m <- matrice_confusion(c("A", "B"), c("A", "B"), c("A", "B", "C"))
  expect_equal(dim(m), c(3L, 3L))
  expect_equal(sum(as.matrix(m)["C", ]), 0)
  expect_equal(sum(as.matrix(m)[, "C"]), 0)
})

test_that("indicateurs : accord parfait, kappa 1 ; matrice vide, rien d'invente", {
  parfait <- matrice_confusion(c("A", "B", "A", "B"), c("A", "B", "A", "B"), c("A", "B"))
  ind <- indicateurs_confusion(parfait)
  expect_equal(ind$precision_globale, 1)
  expect_equal(ind$kappa, 1, tolerance = 1e-12)
  vide <- indicateurs_confusion(matrice_confusion(character(0), character(0), c("A", "B")))
  expect_equal(vide$n, 0)
  expect_true(is.na(vide$precision_globale) && is.na(vide$kappa))
})

test_that("indicateurs : une seule classe, kappa non defini (NA), pas 0 ni 1", {
  m <- matrice_confusion(c("A", "A", "A"), c("A", "A", "A"), "A")
  expect_true(is.na(indicateurs_confusion(m)$kappa))
})

test_that("critere 6 : grappes au demi-hectare (mailles de 70,7 m)", {
  g <- grappes_par_maille(c(0, 50, 80), c(0, 60, 0))
  expect_identical(g[1], g[2])
  expect_false(g[1] == g[3])
  expect_length(g, 3L)
})

test_that("grappes : bord de maille et coordonnees negatives (pas de troncature vers zero)", {
  # Le prototype prend la partie entiere par le bas : -1 m est dans la maille -1, pas dans la maille 0.
  g <- grappes_par_maille(c(-1, 1, 70.6, 70.7), c(0, 0, 0, 0))
  expect_false(g[1] == g[2])
  expect_identical(g[2], g[3])
  expect_false(g[3] == g[4])
  # Une maille fait 70,7 m de cote (0,4998 ha) : un demi-hectare.
  expect_equal(70.7^2 / 10000, 0.5, tolerance = 1e-3)
})

test_that("critere 6 : agregation en grappes, type observe majoritaire et probabilites moyennes", {
  g <- grappes_par_maille(c(0, 50, 80), c(0, 60, 0))
  probas <- data.frame(A = c(0.6, 0.6, 0.1), B = c(0.4, 0.4, 0.9))
  r <- agreger_grappes(c("A", "A", "B"), probas, g)
  expect_equal(nrow(r), 2L)
  expect_setequal(paste(r$observe, r$predit, sep = "/"), c("A/A", "B/B"))
})

test_that("agregation en grappes : observe = majorite, predit = type de plus forte probabilite moyenne (deux regles distinctes)", {
  # g1 : deux pixels, observe A, A ; probabilites moyennes A 0,9 -> predit A.
  # g2 : trois pixels, observe B, B, A -> majorite B ; probabilites moyennes A (0,6 + 0,7 + 0,9)/3 = 0,733 -> predit A.
  probas <- data.frame(
    A = c(0.9, 0.9, 0.6, 0.7, 0.9),
    B = c(0.1, 0.1, 0.4, 0.3, 0.1)
  )
  r <- agreger_grappes(c("A", "A", "B", "B", "A"), probas, c("g1", "g1", "g2", "g2", "g2"))
  expect_equal(nrow(r), 2L)
  expect_setequal(paste(r$observe, r$predit, sep = "/"), c("A/A", "B/A"))
})

test_that("fiche de validation : placette et grappe, n de grappes <= n de placettes", {
  probas <- data.frame(A = c(0.9, 0.9, 0.2, 0.3, 0.6), B = c(0.1, 0.1, 0.8, 0.7, 0.4))
  obs <- c("A", "A", "B", "A", "B")
  g <- c("g1", "g1", "g2", "g2", "g3")
  f <- fiche_validation(obs, probas, g, ser = "s1")
  expect_equal(f$ser, "s1")
  expect_equal(f$placette$n, 5)
  expect_equal(f$grappe$n, 3)
  expect_lte(f$grappe$n, f$placette$n)
  # Placette : predit A A B B A contre observe A A B A B -> 3 bons sur 5.
  expect_equal(f$placette$precision_globale, 0.6, tolerance = 1e-12)
  expect_true(all(c("matrice", "n", "precision_globale", "kappa") %in% names(f$placette)))
  expect_true(all(c("matrice", "n", "precision_globale", "kappa") %in% names(f$grappe)))
})

test_that("fiche en markdown : titre, deux niveaux, precision, kappa et matrice", {
  probas <- data.frame(A = c(0.9, 0.1, 0.8, 0.3), B = c(0.1, 0.9, 0.2, 0.7))
  f <- fiche_validation(c("A", "B", "A", "B"), probas, c("g1", "g1", "g2", "g2"), ser = "exemple")
  md <- paste(fiche_en_markdown(f), collapse = "\n")
  expect_match(md, "Fiche de validation", fixed = TRUE)
  expect_match(md, "exemple", fixed = TRUE)
  expect_match(md, "## \u00c0 la placette", fixed = TRUE)
  expect_match(md, "## \u00c0 la grappe", fixed = TRUE)
  expect_match(md, "Kappa", fixed = TRUE)
  expect_match(md, "100[.,]0 ?%")        # precision globale a la placette : 4 sur 4
  expect_match(md, "| A | ", fixed = TRUE)  # une ligne de matrice par type
})

test_that("critere 6 : validation sur des placettes non utilisees pour calibrer (hors echantillon)", {
  # Les predictions de validation sont croisees : une placette n'est jamais predite par un modele qui
  # l'a vue. Preuve par l'ecart : l'erreur hors echantillon depasse l'erreur d'ajustement (forets aleatoires).
  plac <- placettes_fixture()
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  mod <- ajuster_modeles_dendro(plac, conf$predicteurs, conf$variables_cibles, graine = 0)
  dedans <- predire_dendro(mod, plac)
  dehors <- predire_dendro_validation(mod, plac, plis = 5)
  rmse <- function(p) sqrt(mean((p$G - plac$G)^2))
  expect_gt(rmse(dehors), rmse(dedans))
  expect_equal(nrow(dehors), nrow(plac))
})

test_that("critere 6 : la chaine rend precision et kappa a la placette et a la grappe, comparables au prototype", {
  # Valeurs de references_prototype.csv (jeu 30 x 30, 200 placettes, graine 1) :
  #   placette 0,84 (kappa 0,79), grappe 0,80 (kappa 0,73), 94 grappes.
  # Les forets aleatoires de ranger et de scikit-learn ne tirent pas les memes arbres : tolerances fixees par
  # le testeur, a valider par Pascal : precision +- 0,10 a la placette et +- 0,12 a la grappe (94 grappes
  # seulement, donc plus de dispersion), kappa +- 0,15 aux deux echelles.
  ref <- references_prototype()
  f <- resultat_chaine()$fiche_validation
  expect_equal(f$placette$n, ref[["placette_n"]])
  expect_equal(f$placette$n, 200)
  expect_lt(abs(f$placette$precision_globale - ref[["placette_precision_globale"]]), 0.10)
  expect_lt(abs(f$placette$kappa - ref[["placette_kappa"]]), 0.15)
  expect_lt(abs(f$grappe$precision_globale - ref[["grappe_precision_globale"]]), 0.12)
  expect_lt(abs(f$grappe$kappa - ref[["grappe_kappa"]]), 0.15)
  # Seuil du test Python : mieux que le hasard ; et pas plus de grappes que de placettes.
  expect_gt(f$placette$precision_globale, 0.6)
  expect_lte(f$grappe$n, f$placette$n)
  # Nombre de grappes : determine par les coordonnees seules, donc exact.
  expect_equal(f$grappe$n, ref[["grappe_n"]])
})

test_that("critere 6 : controle par les placettes IFN de la SER", {
  skip("non couvert : le plan de 003 ne prevoit ni lecture ni fonction pour les placettes IFN (spec, critere 6, 2e partie) ; question posee a Pascal")
})

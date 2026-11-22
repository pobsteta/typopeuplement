# Chaine complete sur le jeu synthetique exporte du prototype (30 x 30 pixels, 200 placettes, graine 1).
# Equivalents R de test_chaine_complete et des contraintes de CLAUDE.md :
#  - chaque carte porte sa couche de confiance (probabilite, drapeau entre deux types, drapeau hauteur
#    potentielle incertaine) ;
#  - unites : parts entre 0 et 1 ; la reference de validation est la cle appliquee aux mesures.
# Fonction : executer_chaine(placettes, pixels, conf), types_observes (plan 003, section 3).
# Suppose : le resultat est une liste de champs carte, fiche_validation, erreurs_variables,
# rmse_hauteur_potentielle, types_observes, niveau_modele (noms du prototype ; le plan nomme les champs sans
# donner leurs identifiants). carte : une ligne par pixel, colonnes i, j, type, proba, type_second,
# proba_second, entre_deux, hors_cle, variables, h_pot, h_pot_sd, rapport_h, hp_incertaine, p_<code>.

test_that("chaine complete : une ligne de carte par pixel, probabilites sommees a 1", {
  res <- resultat_chaine()
  carte <- res$carte
  expect_equal(nrow(carte), 900L)
  expect_equal(carte[, c("i", "j")], pixels_fixture()[, c("i", "j")], ignore_attr = TRUE)
  p <- as.matrix(carte[, paste0("p_", CODES_EXEMPLE)])
  expect_equal(rowSums(p), rep(1, 900), tolerance = 1e-9)
  expect_true(all(carte$proba >= 0 & carte$proba <= 1))
})

test_that("CLAUDE.md : chaque carte porte sa couche de confiance", {
  carte <- resultat_chaine()$carte
  # probabilite du type, drapeau « entre deux types », drapeau « hauteur potentielle incertaine ».
  expect_true(all(c("proba", "entre_deux", "hp_incertaine") %in% names(carte)))
  expect_false(anyNA(carte$proba))
  expect_false(anyNA(carte$entre_deux))
  expect_false(anyNA(carte$hp_incertaine))
  # Coherence : la hauteur potentielle incertaine vide le rapport.
  expect_identical(as.logical(carte$hp_incertaine), is.na(carte$rapport_h))
})

test_that("codes : tout type produit appartient a la cle de la SER", {
  res <- resultat_chaine()
  expect_true(all(res$carte$type %in% CODES_EXEMPLE))
  expect_true(all(res$carte$type_second %in% CODES_EXEMPLE))
  expect_true(all(res$types_observes %in% CODES_EXEMPLE))
})

test_that("unites : parts entre 0 et 1, G en m2/ha positive, hauteurs en m plausibles", {
  carte <- resultat_chaine()$carte
  for (v in c("part_resineux", "part_pb", "part_bm", "part_gb")) {
    expect_true(all(carte[[v]] >= 0 & carte[[v]] <= 1), info = v)
  }
  expect_true(all(carte$G > 0 & carte$G < 100))
  ok <- carte$h_pot[!is.na(carte$h_pot)]
  expect_true(all(ok > 5 & ok < 60))
})

test_that("le type observe est la cle dure appliquee aux mesures (references_prototype.csv)", {
  res <- resultat_chaine()
  ref <- references_prototype()
  expect_equal(length(res$types_observes), 200L)
  obs <- table(factor(res$types_observes, levels = CODES_EXEMPLE))
  # Les mesures de placettes sont celles du fichier ; seul rapport_h depend du modele de hauteur
  # potentielle (ranger contre scikit-learn) : on tolere 4 placettes d'ecart par type (2 %).
  for (code in CODES_EXEMPLE) {
    attendu <- ref[[paste0("n_observe_", code)]]
    expect_lte(abs(as.integer(obs[[code]]) - attendu), 4, label = paste("effectif observe", code))
  }
})

test_that("repartition de la carte comparable au prototype (part de pixels entre deux types)", {
  # Prototype : 16,1 % des pixels entre deux types. Tolerance absolue de 8 points, fixee par le testeur.
  ref <- references_prototype()
  carte <- resultat_chaine()$carte
  expect_lt(abs(mean(carte$entre_deux) - ref[["pct_entre_deux"]]), 0.08)
})

test_that("RMSE de la hauteur potentielle, par famille, du meme ordre que le prototype", {
  # Prototype : feuillus 4,24 m ; resineux 2,03 m (validation croisee a 5 plis sur les adultes fermes).
  # Tolerance de 1,5 m, fixee par le testeur (a valider par Pascal).
  r <- unlist(resultat_chaine()$rmse_hauteur_potentielle)
  ref <- references_prototype()
  expect_setequal(names(r), c("feuillus", "resineux"))
  expect_lt(abs(r[["feuillus"]] - ref[["rmse_hp_feuillus"]]), 1.5)
  expect_lt(abs(r[["resineux"]] - ref[["rmse_hp_resineux"]]), 1.5)
})

test_that("la chaine est reproductible a graine fixee", {
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  a <- resultat_chaine()
  b <- executer_chaine(placettes_fixture(), pixels_fixture(), conf)
  expect_identical(a$carte$type, b$carte$type)
  expect_equal(a$carte$proba, b$carte$proba, tolerance = 1e-12)
})

test_that("cas terrain : une colonne de predicteur absente des pixels arrete la chaine", {
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  pixels <- pixels_fixture()
  pixels$lidar_h95 <- NULL
  expect_erreur(executer_chaine(placettes_fixture(), pixels, conf), "lidar_h95")
})

test_that("cas terrain : une SER inconnue de la configuration arrete avant tout calcul", {
  expect_erreur(lire_configuration(chemin_config_exemple(), "ser-inexistante"), "ser-inexistante")
})

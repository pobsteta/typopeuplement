# Modeles dendrometriques et comparaison des classifieurs (equivalents R de modeles.py).
# Fonctions : ajuster_modeles_dendro, predire_dendro, predire_dendro_validation, erreurs_dendro,
# comparer_classifieurs (plan 003, section 3 ; ranger, e1071, MASS, section 4).
# Suppose : ajuster_modeles_dendro(placettes, predicteurs, cibles, graine = 0) ; predire_dendro(modeles, df) ;
# predire_dendro_validation(modeles, placettes, plis = 5) ; erreurs_dendro(modeles, placettes, plis = 5) rend un
# data.frame variable, biais, rmse ; comparer_classifieurs(X, y, plis = 5, graine = 0) rend un tableau dont les
# lignes (ou la colonne `classifieur`) sont forets_aleatoires, svm, analyse_discriminante, avec precision_globale
# et kappa.

modeles_fixture <- function() {
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  list(
    conf = conf,
    plac = placettes_fixture(),
    mod = ajuster_modeles_dendro(placettes_fixture(), conf$predicteurs, conf$variables_cibles, graine = conf$graine)
  )
}

test_that("predictions dendrometriques : G positive, parts entre 0 et 1, parts PB+BM+GB = 1", {
  x <- modeles_fixture()
  p <- predire_dendro(x$mod, pixels_fixture())
  expect_equal(nrow(p), 900L)
  expect_setequal(names(p), x$conf$variables_cibles)
  expect_true(all(p$G > 0))
  for (v in c("part_resineux", "part_pb", "part_bm", "part_gb")) {
    expect_true(all(p[[v]] >= 0 & p[[v]] <= 1), info = v)
  }
  expect_equal(p$part_pb + p$part_bm + p$part_gb, rep(1, 900), tolerance = 1e-9)
})

test_that("erreurs dendrometriques hors echantillon : du meme ordre que le prototype", {
  # references_prototype.csv : RMSE (validation croisee a 5 plis) G 3,19 ; part_resineux 0,075 ;
  # part_pb 0,054 ; part_bm 0,052 ; part_gb 0,069. Forets aleatoires differentes : tolerance relative de
  # 35 %, fixee par le testeur (a valider par Pascal).
  x <- modeles_fixture()
  err <- erreurs_dendro(x$mod, x$plac, plis = 5)
  noms <- if ("variable" %in% names(err)) err$variable else rownames(err)
  ref <- references_prototype()
  for (v in x$conf$variables_cibles) {
    obtenu <- err$rmse[noms == v]
    attendu <- ref[[paste0("rmse_", v)]]
    expect_lt(abs(obtenu - attendu) / attendu, 0.35, label = paste("RMSE de", v))
  }
})

test_that("la validation croisee est reproductible a graine fixee", {
  x <- modeles_fixture()
  a <- predire_dendro_validation(x$mod, x$plac, plis = 5)
  b <- predire_dendro_validation(x$mod, x$plac, plis = 5)
  expect_equal(a, b)
})

test_that("comparaison des classifieurs : les trois sont evalues, kappa dans [-1, 1]", {
  x <- modeles_fixture()
  y <- resultat_chaine()$types_observes
  r <- comparer_classifieurs(x$plac[, x$conf$predicteurs], y, plis = 3)
  expect_setequal(noms_classifieurs(r), c("forets_aleatoires", "svm", "analyse_discriminante"))
  expect_true(all(r$kappa >= -1 & r$kappa <= 1))
  expect_true(all(r$precision_globale > 0.5))
  # Prototype (references_prototype.csv) : kappa 0,78 forets, 0,76 SVM, 0,72 analyse discriminante, 3 plis.
  # Tolerance +- 0,15 (types rares ecartes comme dans le prototype).
  ref <- references_prototype()
  k <- stats::setNames(r$kappa, noms_classifieurs(r))
  expect_lt(abs(k[["forets_aleatoires"]] - ref[["kappa_forets_aleatoires"]]), 0.15)
  expect_lt(abs(k[["svm"]] - ref[["kappa_svm"]]), 0.15)
  expect_lt(abs(k[["analyse_discriminante"]] - ref[["kappa_analyse_discriminante"]]), 0.15)
})

test_that("comparaison des classifieurs : un type a un seul exemple est ecarte et on le dit", {
  # Cas terrain : un type trop rare pour la validation croisee. Le prototype l'ecarte et le consigne dans
  # l'attribut `types_ecartes`.
  x <- modeles_fixture()
  y <- resultat_chaine()$types_observes
  y[1] <- "R-PB-C"  # type jamais observe ailleurs : un seul exemple
  r <- comparer_classifieurs(x$plac[, x$conf$predicteurs], y, plis = 3)
  expect_true("R-PB-C" %in% attr(r, "types_ecartes"))
  expect_equal(length(noms_classifieurs(r)), 3L)
})

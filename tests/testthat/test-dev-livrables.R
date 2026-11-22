# Tests unitaires de la mission 003 (agent dev) : jeu synthetique, livrables, point d'entree.

test_that("jeu synthetique : colonnes du prototype, tailles, parts et coordonnees", {
  jeu <- generer_jeu_synthetique(12, 10, 30, graine = 1)
  expect_equal(nrow(jeu$pixels), 120L)
  expect_equal(nrow(jeu$placettes), 30L)
  expect_setequal(names(jeu$pixels), names(pixels_fixture()))
  expect_setequal(names(jeu$placettes), names(placettes_fixture()))
  p <- jeu$placettes
  expect_equal(p$part_pb + p$part_bm + p$part_gb, rep(1, 30), tolerance = 1e-12)
  expect_true(all(p$part_resineux >= 0 & p$part_resineux <= 1))
  # Pixels de 25 m : x = i * 25, y = j * 25 (m).
  expect_equal(p$x, p$i * 25)
  expect_equal(p$y, p$j * 25)
  expect_identical(jeu$pixels$i[1:3], c(0L, 0L, 0L))
  expect_identical(jeu$pixels$j[1:3], c(0L, 1L, 2L))
})

test_that("jeu synthetique : reproductible a graine fixee", {
  expect_identical(generer_jeu_synthetique(8, 8, 10, graine = 2),
                   generer_jeu_synthetique(8, 8, 10, graine = 2))
})

test_that("livrables : un pixel du terrain tombe dans la bonne cellule du raster", {
  # Pixel (i = 3, j = 7) : centre x = 3 * 25 = 75 m, y = 7 * 25 = 175 m, Lambert-93.
  res <- resultat_chaine()
  dossier <- file.path(tempdir(), "dev_livrables")
  ecrire_livrables(res, dossier)
  k <- which(res$carte$i == 3 & res$carte$j == 7)
  types <- terra::rast(file.path(dossier, "types.tif"))
  v <- terra::extract(types, cbind(75, 175))
  corr <- correspondance_types(res$cle)
  expect_equal(corr$code[v$type], res$carte$type[k])
  expect_equal(v$proba, res$carte$proba[k], tolerance = 1e-6)
  # Le coin bas-gauche de l'emprise est le bord du pixel (0, 0), pas son centre.
  e <- as.vector(terra::ext(types))
  expect_equal(unname(e[c("xmin", "ymin")]), c(-12.5, -12.5))
})

test_that("livrables : niveau du modele ecrit dans confiance.tif (2 = grande region)", {
  res <- resultat_chaine()
  dossier <- file.path(tempdir(), "dev_livrables_conf")
  ecrire_livrables(res, dossier)
  conf <- terra::rast(file.path(dossier, "confiance.tif"))
  attendu <- if (res$niveau_modele == "ser") 1 else 2
  expect_true(all(terra::values(conf[["niveau_modele"]]) == attendu))
})

test_that("livrables : la table de correspondance garde les accents (UTF-8)", {
  res <- resultat_chaine()
  dossier <- file.path(tempdir(), "dev_livrables_utf8")
  ecrire_livrables(res, dossier)
  brut <- readBin(file.path(dossier, "correspondance_types.csv"), "raw", 1e5)
  # « é » de « Mélange » en UTF-8 : c3 a9.
  expect_true(grepl("M\u00e9lange", rawToChar(brut), useBytes = TRUE) ||
                length(grepRaw(as.raw(c(0x4d, 0xc3, 0xa9)), brut)) > 0)
})

test_that("fiche de la chaine : niveau, erreurs, hauteur potentielle et ecart aux courbes de station", {
  md <- paste(fiche_en_markdown(resultat_chaine()$fiche_validation), collapse = "\n")
  expect_match(md, "Niveau du mod", fixed = TRUE)
  expect_match(md, "RMSE", fixed = TRUE)
  expect_match(md, "indice de station", fixed = TRUE)
})

test_that("typer_peuplements : AOI en sf avec SER donnee, arret net (lecture non ecrite)", {
  carre <- sf::st_sfc(sf::st_polygon(list(rbind(c(914000, 6457000), c(915000, 6457000),
                                                  c(915000, 6458000), c(914000, 6458000),
                                                  c(914000, 6457000)))), crs = 2154)
  aoi <- sf::st_sf(id = 1, geometry = carre)
  expect_erreur(
    typer_peuplements(aoi, placettes_fixture(), SER_EXEMPLE, chemin_config_exemple()),
    "lecture des donn\u00e9es ouvertes non \u00e9crite"
  )
})

test_that("sans nemeton : localiser la SER ou l'indice de station s'arrete en le disant", {
  skip_if(requireNamespace("nemeton", quietly = TRUE), "nemeton est installe")
  carre <- sf::st_sfc(sf::st_point(c(925000, 6505000)), crs = 2154)
  aoi <- sf::st_sf(id = 1, geometry = carre)
  expect_erreur(typer_peuplements(aoi, placettes_fixture(), NULL, chemin_config_exemple()),
                "nemeton")
  expect_erreur(ecart_courbes_station(30, 20, 50, "PIAB"), "nemeton")
})

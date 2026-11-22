# Tests unitaires de la mission 009 (agent dev) : relief tiré du MNT de l'IGN et hauteur
# potentielle.
#
# Extrait de test (fixtures/vercors/milieu/mnt.tif) : MNT RGE ALTI de l'IGN, service
# WMS-Raster de la Géoplateforme (couche ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES), requête
# du 2026-11-22 :
#   https://data.geopf.fr/wms-r/wms?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap
#   &LAYERS=ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES&STYLES=&CRS=EPSG:2154
#   &BBOX=883849.6,6425301.0,885924.4,6427375.8&WIDTH=156&HEIGHT=156&FORMAT=image/geotiff
# 156 x 156 cellules de 13,3 m, Lambert-93 (EPSG:2154) : l'emprise de l'extrait ONF
# (fixtures/vercors/, 40 x 40 pixels de 26,6 m) élargie de 19 pixels (505,4 m).

dossier_vercors_m <- function() testthat::test_path("fixtures", "vercors")
mnt_extrait <- function() testthat::test_path("fixtures", "vercors", "milieu", "mnt.tif")

extrait_et_relief <- function() {
  v <- lire_parametres_lidar(dossier_vercors_m())
  rel <- calculer_relief(mnt_extrait(), attr(v, "gabarit"))
  list(v = v, rel = rel, milieu = milieu_pixels(rel, v))
}

test_that("dalles : requetes WMS-Raster alignees sur la grille du jeu, x puis y en Lambert-93", {
  v <- lire_parametres_lidar(dossier_vercors_m())
  d <- dalles_mnt_ign(attr(v, "gabarit"))
  expect_equal(nrow(d), 1)
  # Marge de 500 m arrondie au pixel superieur : 19 x 26,6 = 505,4 m.
  expect_equal(d$xmin, 884355 - 505.4, tolerance = 1e-6)
  expect_equal(d$ymax, 6426870.4 + 505.4, tolerance = 1e-6)
  expect_equal(d$largeur, 156L)
  expect_true(grepl("BBOX=883849.6,6425301.0,885924.4,6427375.8&", d$url, fixed = TRUE))
  expect_true(grepl("CRS=EPSG:2154", d$url, fixed = TRUE))
  expect_true(grepl("^https://data.geopf.fr/wms-r/wms\\?", d$url))
  # Grande emprise : plusieurs dalles, jointives, au plus taille_max pixels.
  g <- list(xmin = 868421.6, xmax = 923590, ymin = 6397078, ymax = 6445996,
            resolution = c(26.6, 26.6), crs = "EPSG:2154")
  dd <- dalles_mnt_ign(g)
  expect_equal(nrow(dd), 6)
  expect_true(all(dd$largeur <= 2000 & dd$hauteur <= 2000))
  expect_equal(sum(dd$largeur[dd$ymax == max(dd$ymax)]) * 13.3,
               (923590 - 868421.6) + 2 * 505.4, tolerance = 1e-6)
  expect_error(dalles_mnt_ign(modifyList(g, list(crs = "EPSG:4326"))), "Lambert-93")
})

test_that("relief : rasters alignes sur la grille de l'ONF, unites et bornes", {
  x <- extrait_et_relief()
  g <- terra::rast(file.path(dossier_vercors_m(), "G.tif"))
  expect_true(terra::compareGeom(x$rel, g, stopOnError = FALSE))
  expect_equal(as.vector(terra::ext(x$rel)), as.vector(terra::ext(g)), tolerance = 1e-6)
  expect_equal(names(x$rel), variables_relief())
  m <- x$milieu
  expect_equal(nrow(m), nrow(x$v))
  expect_false(anyNA(m))  # la marge couvre le voisinage de la position topographique
  expect_true(all(m$pente >= 0 & m$pente < 90))
  expect_true(all(abs(m$expo_sin) <= 1 & abs(m$expo_cos) <= 1))
  plat <- m$pente < 1
  expect_true(all(m$expo_sin[plat] == 0 & m$expo_cos[plat] == 0))
  # Sur un versant, sin^2 + cos^2 = 1.
  expect_equal(m$expo_sin[!plat]^2 + m$expo_cos[!plat]^2, rep(1, sum(!plat)), tolerance = 1e-9)
  expect_identical(attr(m, "variables_milieu"), variables_relief())
  expect_match(attr(m, "source"), "ni climat ni sol")
})

test_that("relief : un point du terrain tombe au bon endroit (altitude de l'IGN)", {
  x <- extrait_et_relief()
  # Coin nord-ouest de l'extrait : x = 884 368,3 m, y = 6 426 857,1 m (Lambert-93, x puis y),
  # soit 5,336571 E, 44,916357 N. Altitude du service d'altimetrie de la Geoplateforme en ce
  # point, interrogee le 2026-11-22 : 1 397,68 m. Le pixel est une moyenne sur 26,6 m d'un
  # versant a 11 degres (environ 5 m de denivele) : tolerance de 5 m.
  k <- which(x$v$i == 0 & x$v$j == 39)
  expect_equal(x$v$x[k], 884368.3, tolerance = 1e-6)
  expect_equal(x$milieu$altitude[k], 1397.68, tolerance = 5 / 1397.68)
  # Pixel (i = 20, j = 20) de l'extrait : x = 884 900,3 m, y = 6 426 351,7 m (Lambert-93,
  # x puis y). Altitude du service d'altimetrie de la Geoplateforme (IGN) en ce point :
  # 1 428,28 m. Tolerance de 1 m.
  k2 <- which(x$v$i == 20 & x$v$j == 20)
  expect_equal(x$v$x[k2], 884900.3, tolerance = 1e-6)
  expect_lt(abs(x$milieu$altitude[k2] - 1428.28), 1)
  # Coordonnees inversees (y, x) : hors du MNT, valeur vide.
  inv <- data.frame(x = x$v$y[k], y = x$v$x[k])
  expect_true(all(is.na(milieu_pixels(x$rel, inv))))
})

test_that("relief : pente et exposition d'un plan incline connu", {
  # Plan qui monte vers l'est de 0,1 m par m : pente atan(0,1) = 5,71 degres, versant
  # tourne vers l'ouest (exposition 270 degres : sin = -1, cos = 0) ; position
  # topographique nulle au centre (plan).
  r <- terra::rast(xmin = 0, xmax = 2000, ymin = 0, ymax = 2000, resolution = 10,
                   crs = "EPSG:2154")
  terra::values(r) <- 1000 + 0.1 * terra::xFromCell(r, seq_len(terra::ncell(r)))
  g <- list(xmin = 500, xmax = 1500, ymin = 500, ymax = 1500, resolution = c(20, 20),
            crs = "EPSG:2154")
  rel <- calculer_relief(r, g, rayon_tpi_m = 200)
  v <- terra::values(rel, mat = TRUE)
  expect_equal(terra::nrow(rel), 50)
  expect_equal(unname(v[, "pente"]), rep(atan(0.1) * 180 / pi, 2500), tolerance = 1e-6)
  expect_equal(unname(v[, "expo_sin"]), rep(-1, 2500), tolerance = 1e-9)
  expect_equal(unname(v[, "expo_cos"]), rep(0, 2500), tolerance = 1e-9)
  expect_equal(unname(v[, "position_topo"]), rep(0, 2500), tolerance = 1e-6)
  expect_error(calculer_relief(r, g, rayon_tpi_m = 0), "strictement positif")
})

test_that("hauteur potentielle : au moins H0 mesuree chez les adultes, au quantile pres", {
  x <- extrait_et_relief()
  df <- cbind(as.data.frame(x$v), x$milieu)
  m <- ajuster_hauteur_potentielle(df, variables_relief(), adultes_min = 20)
  expect_true(length(m$modeles) >= 1)
  hp <- predire_hauteur_potentielle(m, df)
  ad <- peuplements_adultes(m, df) & df$famille %in% names(m$modeles)
  expect_gt(sum(ad), 20)
  # Enveloppe haute au quantile 0,9, mesuree et appliquee hors sac : environ 10 % des
  # adultes appris au-dessus de h_pot (ni 0 %, ce que donnerait une forêt qui les a vus).
  expect_true(all(attr(hp, "hors_sac")[ad]))
  part <- mean(df$h_dom[ad] <= hp$h_pot[ad])
  expect_gte(part, 0.85)
  expect_lte(part, 0.95)
  # La moyenne hors sac est celle de ranger (out-of-bag, m$predictions).
  for (f in names(m$modeles)) {
    expect_equal(m$apprentissage[[f]]$moy, m$modeles[[f]]$predictions, tolerance = 1e-9)
  }
  # Un non-adulte, ou un adulte qu'on n'a pas appris, a la prediction ordinaire.
  expect_false(any(attr(hp, "hors_sac")[!peuplements_adultes(m, df)]))
  autre <- df[ad, , drop = FALSE][1, ]
  autre$h_dom <- autre$h_dom + 0.01
  expect_false(attr(predire_hauteur_potentielle(m, autre), "hors_sac"))
  # L'incertitude est rendue partout ou le milieu est connu : k x RMSE de validation
  # croisee, sans la dispersion des arbres (rendue a part dans l'attribut sd_arbres).
  expect_false(anyNA(hp$h_pot_sd))
  expect_true(all(hp$h_pot_sd > 0))
  f1 <- names(m$modeles)[1]
  dans <- df$famille == f1
  expect_equal(hp$h_pot_sd[dans], rep(m$facteur[[f1]] * m$rmse_cv[[f1]], sum(dans)), tolerance = 1e-12)
  sa <- attr(hp, "sd_arbres")
  expect_length(sa, nrow(df))
  expect_true(all(sa >= 0))
  expect_true(all(is.na(hp$rapport_h[hp$hp_incertaine])))
  expect_true(all(unlist(m$rmse_cv) > 0))
})

test_that("hauteur potentielle : milieu manquant = vide et incertaine, pas d'arret", {
  x <- extrait_et_relief()
  df <- cbind(as.data.frame(x$v), x$milieu)
  m <- ajuster_hauteur_potentielle(df, variables_relief(), adultes_min = 20)
  df$altitude[1:5] <- NA
  df$h_dom[6] <- NA
  hp <- predire_hauteur_potentielle(m, df, taille_paquet = 100L)
  expect_true(all(is.na(hp$h_pot[1:5])))
  expect_true(all(hp$hp_incertaine[1:5]))
  expect_false(is.na(hp$h_pot[6]))
  # Par paquets ou d'un coup : meme resultat.
  hp2 <- predire_hauteur_potentielle(m, df)
  expect_equal(hp$h_pot, hp2$h_pot)
  # Un adulte sans milieu n'apprend rien ; un couvert manquant n'est pas adulte.
  expect_identical(peuplements_adultes(list(couvert_min = 0.7, hauteur_min_m = 15),
                                       data.frame(couvert = c(NA, 0.8), h_dom = c(20, 20))),
                   c(FALSE, TRUE))
})

test_that("chaine : le relief entre par `milieu`, la fiche dit ce qui manque et ce qu'elle voit", {
  x <- extrait_et_relief()
  res <- typer_peuplements(NULL, ser = SER_EXEMPLE, configuration = chemin_config_exemple(),
                           variables = x$v, milieu = x$milieu)
  c <- res$carte
  ok <- !c$non_precomptable
  expect_false(all(c$hp_incertaine[ok]))
  expect_false(anyNA(c$h_pot_sd[ok]))
  expect_false(anyNA(c$sd_arbres[ok]))
  dec <- res$fiche_validation$declarations
  expect_true(any(grepl("relief seul", dec)))
  expect_true(any(grepl("absentes du milieu fourni : bilan_hydrique, reserve_utile", dec, fixed = TRUE)))
  expect_true(any(grepl("RMSE de validation crois", dec)))
  expect_true(any(grepl("hors sac", dec)))
  expect_true(any(grepl("incertaine sur", dec)))
  expect_true(any(grepl("non calibr", dec)))
  expect_true(length(res$rmse_hauteur_potentielle) >= 1)
  expect_true("hauteur_potentielle" %in% res$temps$etage)
  # Jeu sans bloc `jeux` dans la configuration : declare.
  expect_true(any(grepl("vercors_onf : souplesses de la cl", dec)))
  # Sous-ensemble par l'AOI : les attributs du milieu sont gardes.
  aoi <- sf::st_as_sf(sf::st_as_sfc(sf::st_bbox(c(xmin = 884355, ymin = 6425806.4,
                                                   xmax = 884900, ymax = 6426400),
                                                 crs = sf::st_crs(2154))))
  res2 <- typer_peuplements(aoi, ser = SER_EXEMPLE, configuration = chemin_config_exemple(),
                            variables = x$v, milieu = x$milieu)
  # Peu de pixels : trop peu d'adultes, hauteur potentielle vide et dite, pas d'arret.
  expect_lt(nrow(res2$carte), nrow(res$carte))
  expect_true(all(res2$carte$hp_incertaine))
  expect_true(any(grepl("trop peu de peuplements adultes", res2$fiche_validation$declarations)))
})

test_that("groupe de types : sa probabilite est la somme de celles de ses membres", {
  p <- data.frame(A = c(0.4, 0.6), B = c(0.4, 0.3), C = c(0.2, 0.1))
  tna <- matrix(c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE), nrow = 2)
  d <- decider_type(p, 0.15, touche_na = tna)
  expect_identical(d$type[1], "A | B")
  expect_equal(d$proba[1], 0.8, tolerance = 1e-12)
  expect_identical(d$type_second[1], "C")
  expect_true(d$entre_deux[1])
  # Pas de groupe : la probabilite du type, inchangee.
  expect_identical(d$type[2], "A")
  expect_equal(d$proba[2], 0.6, tolerance = 1e-12)
})

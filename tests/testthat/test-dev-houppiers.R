# Tests unitaires de la mission 013 (agent dev) : couvert des strates par houppier, et
# methode des strates (hybride, houppiers, tranches) dans la chaine.
#
# Houppiers synthetiques : deux pixels de 10 m (x 0 a 20 m, y 0 a 10 m, Lambert-93
# EPSG:2154, x puis y), MNH de 0,5 m ; chaque houppier est un rectangle de cellules d'un
# meme numero, de hauteur connue, avec une cellule plus haute (son sommet).
# Extrait reel : fixtures/vercors/strates/nuage.laz (voir test-dev-strates.R).

dossier_extrait_h <- function() testthat::test_path("fixtures", "vercors", "strates")
K_VERCORS_H <- c("1" = 1.167, "2" = 1.106, "3" = 1.130)

gab_deux <- list(xmin = 0, xmax = 20, ymin = 0, ymax = 10, resolution = 10, crs = "EPSG:2154")

# Rasters vides : pas de houppier, MNH a 1 m partout.
rasters_vides <- function() {
  ids <- terra::rast(nrows = 20, ncols = 40, xmin = 0, xmax = 20, ymin = 0, ymax = 10,
                     crs = "EPSG:2154")
  h <- ids
  terra::values(ids) <- NA_real_
  terra::values(h) <- 1
  list(houppiers = ids, mnh = h)
}

# Pose un houppier rectangulaire [x0, x1[ x [y0, y1[ (m), numero `id`, hauteur `h`, sommet
# de hauteur `cime` dans la cellule de centre (xs, ys).
poser <- function(r, x0, x1, y0, y1, id, h, cime, xs, ys) {
  xy <- terra::xyFromCell(r$houppiers, seq_len(terra::ncell(r$houppiers)))
  k <- which(xy[, 1] >= x0 & xy[, 1] < x1 & xy[, 2] >= y0 & xy[, 2] < y1)
  vi <- terra::values(r$houppiers)[, 1]
  vh <- terra::values(r$mnh)[, 1]
  vi[k] <- id
  vh[k] <- h
  vh[terra::cellFromXY(r$mnh, cbind(xs, ys))] <- cime
  terra::values(r$houppiers) <- vi
  terra::values(r$mnh) <- vh
  r
}

# Quatre arbres connus :
# 1 : 4 x 4 m dans le pixel 1, cime 18 m ; 2 : 2 x 2 m dans le pixel 1, cime 12 m ;
# 3 : 4 x 2 m a cheval (x 8 a 12 m), cime 7 m dans le pixel 2 (x 11,25 m) ;
# 4 : 2 x 2 m dans le pixel 2, cime 3 m.
houppiers_connus <- function() {
  r <- rasters_vides()
  r <- poser(r, 2, 6, 2, 6, 1, 16, 18, 4.25, 4.25)
  r <- poser(r, 7, 9, 7, 9, 2, 10, 12, 8.25, 8.25)
  r <- poser(r, 8, 12, 1, 3, 3, 6, 7, 11.25, 2.25)
  r <- poser(r, 15, 17, 6, 8, 4, 2.5, 3, 16.25, 7.25)
  r
}

test_that("houppiers synthetiques : chaque arbre dans sa strate, couvert juste", {
  refs <- data.frame(x = c(5, 15), y = 5, h = c(20, 10))
  cv <- couvert_houppiers(houppiers_connus(), gab_deux, refs)
  expect_equal(cv$cellule, 1:2)
  expect_equal(cv$x, c(5, 15))
  expect_equal(cv$n_cellules, c(400, 400))
  expect_equal(cv$n_houppiers, c(2, 2))
  expect_equal(cv$densite_houppiers, c(200, 200))   # 2 sommets sur 0,01 ha
  # Pixel 1 (H = 20 m) : arbre 1 (18 m, >= 15 m) en strate 1 : 16 m2 sur 100 ;
  # arbre 2 (12 m, >= 10 m) en strate 2, et la moitie ouest de l'arbre 3, dont le sommet
  # est dans le pixel 2 (H = 10 m : 7 m >= 7,5 m ? non, >= 5 m : strate 2) : 4 + 4 m2.
  expect_equal(cv$c1_h, c(0.16, 0))
  expect_equal(cv$c2_h, c(0.08, 0.04))
  # Pixel 2 : arbre 4 (3 m, >= 2,5 m) en strate 3.
  expect_equal(cv$c3_h, c(0, 0.04))
  expect_equal(cv$c4_h, c(0, 0))
  # La strate vient du pixel du sommet, pas de celui de la cellule : avec la reference du
  # pixel 1 (20 m), la moitie ouest de l'arbre 3 serait en strate 3 (7 / 20 = 0,35).
  # Vu du dessus : les quatre couverts s'additionnent au plus a 1.
  expect_true(all(rowSums(cv[, paste0("c", 1:4, "_h")]) <= 1))
})

test_that("houppiers : sommet sans reference, blocs de lecture, plusieurs references", {
  r <- houppiers_connus()
  # Pixel 2 sans reference : ses couverts sont vides ; l'arbre 3 (sommet dans le pixel 2)
  # prend, dans le pixel 1, la reference de ce pixel (20 m) : 7 m < 10 m, strate 3.
  cv <- couvert_houppiers(r, gab_deux, data.frame(x = 5, y = 5, h = 20))
  expect_equal(cv$c2_h, c(0.04, NA))
  expect_equal(cv$c3_h, c(0.04, NA))
  expect_equal(cv$n_houppiers, c(2, 2))
  # Lecture par blocs de 3 lignes : un houppier coupe par deux blocs garde son sommet.
  refs <- data.frame(x = c(5, 15), y = 5, a = c(20, 10), b = c(40, 40))
  tout <- couvert_houppiers(r, gab_deux, refs)
  expect_equal(couvert_houppiers(r, gab_deux, refs, lignes_bloc = 3L), tout)
  # Reference b = 40 m (quarts 30, 20, 10 m) : arbres 1 et 2 en strate 3, 3 et 4 en strate 4.
  expect_equal(tout$c3_b, c(0.20, 0))
  expect_equal(tout$c4_b, c(0.04, 0.08))
  expect_equal(tout$c1_a, c(0.16, 0))
  # Deux segmentations (paquets de dalles) : les surfaces s'additionnent pixel par pixel.
  vide <- rasters_vides()
  double <- couvert_houppiers(list(r, vide), gab_deux, refs)
  expect_equal(double$n_cellules, c(800, 800))
  expect_equal(double$c1_a, c(0.08, 0))
})

test_that("houppiers : entrees refusees", {
  r <- houppiers_connus()
  expect_erreur(couvert_houppiers(r, gab_deux, data.frame(x = 5, y = 5)), "aucune hauteur")
  expect_erreur(couvert_houppiers(r, gab_deux, data.frame(x = c(5, 6), y = 5, h = 20)),
                "même pixel")
  autre <- r
  autre$mnh <- terra::aggregate(r$mnh, 2)
  expect_erreur(couvert_houppiers(autre, gab_deux, data.frame(x = 5, y = 5, h = 20)),
                "même grille")
  expect_erreur(couvert_houppiers(list(a = 1), gab_deux, data.frame(x = 5, y = 5, h = 20)),
                "segmentation")
})

test_that("sans lasR, la segmentation s'arrete en le disant", {
  skip_if(requireNamespace("lasR", quietly = TRUE), "lasR est installe")
  expect_erreur(segmenter_houppiers(file.path(dossier_extrait_h(), "nuage.laz"), tempdir()), "lasR")
})

test_that("extrait reel LiDAR HD : houppiers plausibles (nombre, hauteurs), strate 1 remplie", {
  skip_if_not_installed("lasR")
  px <- lire_fixture(file.path("vercors", "strates", "pixels.csv"))
  gab <- list(xmin = 875204.6, xmax = 875284.4, ymin = 6425434.0, ymax = 6425513.8,
              resolution = c(26.6, 26.6), crs = "EPSG:2154")
  expect_erreur(segmenter_houppiers(file.path(dossier_extrait_h(), "nuage.laz"), tempdir(),
                                    fenetre_m = 0), "strictement positif")
  s <- segmenter_houppiers(file.path(dossier_extrait_h(), "nuage.laz"),
                           file.path(tempdir(), "houppiers_extrait"), ncores = lasR::sequential())
  expect_s3_class(s, "typo_houppiers")
  expect_equal(s$parametres$fenetre_m, 3)
  som <- sf::st_read(s$sommets, quiet = TRUE)
  z <- sf::st_coordinates(som)[, 3]
  # 0,64 ha de futaie de Leoncel (H0 du jeu ONF 20 a 24 m) : mesure du 2026-11-23,
  # 281 sommets, mediane 19,1 m, maximum 26,9 m.
  expect_gt(length(z), 100)
  expect_lt(length(z), 1300)
  expect_true(all(z >= 2))
  expect_gt(stats::median(z), 12)
  expect_lt(max(z), 45)
  cv <- couvert_houppiers(s, gab, references_strates(px, facteur = K_VERCORS_H))
  expect_equal(nrow(cv), 9)
  cc <- as.matrix(cv[, paste0("c", 1:4, "_hpot")])
  expect_true(all(cc >= 0 & cc <= 1))
  expect_true(all(rowSums(cc) <= 1 + 1e-9))
  expect_true(all(cv$densite_houppiers > 100 & cv$densite_houppiers < 2000))
  # Le but de la mission : la strate 1 par houppiers est plus remplie que par tranches
  # (mesure : 0,49 contre 0,18 en moyenne sur ces 9 pixels).
  i <- match(paste(round(px$x, 1), round(px$y, 1)), paste(round(cv$x, 1), round(cv$y, 1)))
  expect_gt(mean(cv$c1_hpot[i]), mean(px$c1_hpot) + 0.15)
})

# --- Dans la chaine ---------------------------------------------------------------------

extrait_h10 <- function() {
  v <- lire_parametres_lidar(testthat::test_path("fixtures", "vercors"))
  list(v = v, conf = lire_configuration(normalizePath(testthat::test_path(
    "..", "..", "inst", "extdata", "config", "vercors-h10.json")), "H10"))
}
tranches_const <- function(v) {
  data.frame(x = v$x, y = v$y, c1_hpot = 0.05, c2_hpot = 0.2, c3_hpot = 0.3, c4_hpot = 0.1)
}
houppiers_const <- function(v) {
  data.frame(cellule = seq_len(nrow(v)), x = v$x, y = v$y, n_cellules = 2830,
             n_houppiers = 20, densite_houppiers = 283, c1_hpot = 0.6, c2_hpot = 0.1,
             c3_hpot = 0.02, c4_hpot = 0)
}

test_that("methode hybride (defaut) : strate 1 des houppiers, 2 a 4 des tranches", {
  x <- extrait_h10()
  s <- list(tranches = tranches_const(x$v), houppiers = houppiers_const(x$v))
  res <- executer_chaine_fournie(x$v, x$conf, strates = s)
  c <- res$carte
  expect_true(all(c$c1_hpot == 0.6))
  expect_true(all(c$c2_hpot == 0.2 & c$c3_hpot == 0.3 & c$c4_hpot == 0.1))
  # Les colonnes c*_<ref> ne changent pas de nom ; la densite est rendue a part.
  expect_true(all(c$densite_houppiers == 283))
  expect_true(all(c$strates_basses_estimees))
  dec <- res$fiche_validation$declarations
  expect_true(any(grepl("HYBRIDE", dec, fixed = TRUE)))
  expect_true(any(grepl("ne sert pas à la clé", dec, fixed = TRUE)))
  # Houppiers seuls, tranches seules.
  h <- executer_chaine_fournie(x$v, x$conf, strates = s, methode_strates = "houppiers")$carte
  expect_true(all(h$c1_hpot == 0.6 & h$c2_hpot == 0.1 & h$c4_hpot == 0))
  t <- executer_chaine_fournie(x$v, x$conf, strates = s, methode_strates = "tranches")$carte
  expect_true(all(t$c1_hpot == 0.05))
  expect_false("densite_houppiers" %in% names(t))
  # Une table de houppiers seule suffit a la methode « houppiers ».
  h2 <- executer_chaine_fournie(x$v, x$conf, strates = houppiers_const(x$v),
                                methode_strates = "houppiers")$carte
  expect_equal(h2$c1_hpot, h$c1_hpot)
})

test_that("la densite des houppiers ne sert pas a la cle (seuil sur N de l'ONF)", {
  x <- extrait_h10()
  a <- houppiers_const(x$v)
  b <- a
  b$densite_houppiers <- 5000  # tres au-dessus de 800 tiges/ha
  ta <- executer_chaine_fournie(x$v, x$conf, strates = list(tranches = tranches_const(x$v), houppiers = a))
  tb <- executer_chaine_fournie(x$v, x$conf, strates = list(tranches = tranches_const(x$v), houppiers = b))
  expect_identical(ta$carte$type, tb$carte$type)
  expect_equal(ta$carte$proba, tb$carte$proba)
})

test_that("methode : source manquante, methode inconnue, couverts fournis pris tels quels", {
  x <- extrait_h10()
  cpt <- data.frame(cellule = 1L, x = x$v$x[1], y = x$v$y[1], n_tous = 10L, n_premiers = 10L,
                    p1_hpot = 5L, n2_hpot = 1L, s2_hpot = 5L, n3_hpot = 1L, s3_hpot = 4L,
                    n4_hpot = 1L, s4_hpot = 3L)
  expect_erreur(executer_chaine_fournie(x$v, x$conf, strates = cpt), "houppiers manquant")
  expect_erreur(executer_chaine_fournie(x$v, x$conf, strates = houppiers_const(x$v)),
                "tranches manquant")
  expect_erreur(executer_chaine_fournie(x$v, x$conf, strates = tranches_const(x$v),
                                        methode_strates = "lidar"), "inconnue")
  # Des couverts deja calcules (ni comptes ni houppiers) : pris tels quels, dit, sans drapeau.
  res <- executer_chaine_fournie(x$v, x$conf, strates = tranches_const(x$v))
  expect_true(all(res$carte$c1_hpot == 0.05))
  expect_false("strates_basses_estimees" %in% names(res$carte))
  expect_true(any(grepl("couverts fournis", res$fiche_validation$declarations, fixed = TRUE)))
})

test_that("segmentation dans la chaine : couvert calcule avec la reference de la chaine", {
  # Les deux pixels synthetiques, reference h0 (h_dom) : 20 et 10 m.
  v <- data.frame(i = 0:1, j = 0L, x = c(5, 15), y = 5, h_dom = c(20, 10), couvert = 0.8,
                  G = 20, part_gb = 0.3)
  attr(v, "gabarit") <- gab_deux
  conf <- extrait_h10()$conf
  tr <- data.frame(x = c(5, 15), y = 5, c1_h0 = 0, c2_h0 = 0.3, c3_h0 = 0.3, c4_h0 = 0.3)
  res <- executer_chaine_fournie(v, conf, strates = list(tranches = tr, houppiers = houppiers_connus()),
                                 reference_strates = "h0")
  c <- res$carte
  expect_equal(c$c1_h0, c(0.16, 0))
  expect_equal(c$c2_h0, c(0.3, 0.3))
  expect_equal(c$densite_houppiers, c(200, 200))
  # Livrables : densite dans variables.tif, drapeau dans confiance.tif.
  d <- file.path(tempdir(), "livrables_houppiers")
  ecrire_livrables(res, d)
  expect_true("densite_houppiers" %in% names(terra::rast(file.path(d, "variables.tif"))))
  conf_r <- terra::rast(file.path(d, "confiance.tif"))
  expect_true("strates_basses_estimees" %in% names(conf_r))
  expect_equal(as.numeric(terra::values(conf_r[["strates_basses_estimees"]])), c(1, 1))
})

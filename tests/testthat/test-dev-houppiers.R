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
  # Tranches deja calculees (sans comptes) : part des retours sous la strate 1 inconnue,
  # retrait des houppiers de la strate 1 non verifiable, et dit.
  expect_true("part_retours_sous_s1" %in% names(c))
  expect_true(all(is.na(c$part_retours_sous_s1)))
  expect_false("strates_basses_estimees" %in% names(c))
  dec <- res$fiche_validation$declarations
  expect_true(any(grepl("HYBRIDE", dec, fixed = TRUE)))
  expect_true(any(grepl("pas v\u00e9rifiable", dec, fixed = TRUE)))
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
  expect_false("part_retours_sous_s1" %in% names(res$carte))
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
  # Livrables : densite dans variables.tif.
  d <- file.path(tempdir(), "livrables_houppiers")
  ecrire_livrables(res, d)
  expect_true("densite_houppiers" %in% names(terra::rast(file.path(d, "variables.tif"))))
})

# --- Reprise 1/3 (2026-11-23) : retrait, catalogue unique, part graduee, mineurs ---------

test_that("houppier numero 0 : un arbre comme les autres ; cellule sans hauteur hors du couvert", {
  # lasR numerote ses houppiers a partir de 0 (extrait de Leoncel : 281 sommets, 0 a 280).
  r <- houppiers_connus()
  vi <- terra::values(r$houppiers)[, 1]
  vi[vi == 1] <- 0
  terra::values(r$houppiers) <- vi
  refs <- data.frame(x = c(5, 15), y = 5, h = c(20, 10))
  cv <- couvert_houppiers(r, gab_deux, refs)
  expect_equal(cv$c1_h, c(0.16, 0))
  expect_equal(cv$n_houppiers, c(2, 2))
  som <- sommets_houppiers(r)
  expect_equal(som$id, c(0, 2, 3, 4))
  expect_equal(som$h[som$id == 0], 18)
  expect_equal(c(som$x[som$id == 0], som$y[som$id == 0]), c(4.25, 4.25))
  # Cellules de houppier sans hauteur (MNH vide) : ni au numerateur ni au denominateur ;
  # le couvert reste dans [0, 1]. Pixel 1 : 4 cellules de l'arbre 0 sans hauteur.
  vh <- terra::values(r$mnh)[, 1]
  xy <- terra::xyFromCell(r$mnh, seq_along(vh))
  trou <- which(xy[, 1] > 2 & xy[, 1] < 3 & xy[, 2] > 2 & xy[, 2] < 3)
  expect_length(trou, 4)
  vh[trou] <- NA
  terra::values(r$mnh) <- vh
  cv2 <- couvert_houppiers(r, gab_deux, refs)
  expect_equal(cv2$n_cellules, c(396, 400))
  expect_equal(cv2$c1_h, c(60 / 396, 0))
  expect_true(all(rowSums(cv2[, paste0("c", 1:4, "_h")]) <= 1))
})

test_that("cime d'un point : le point du terrain tombe dans le bon houppier (Lambert-93, x puis y)", {
  r <- houppiers_connus()
  m <- list(ids = r$houppiers, sommets = sommets_houppiers(r))
  g <- typopeuplement:::grille_strates(gab_deux)
  # x puis y, en m : dans l'arbre 1 (cime 18 m, sommet au pixel 1), dans la moitie ouest
  # de l'arbre 3 (cime 7 m, sommet au pixel 2), hors houppier, hors raster.
  x <- c(4.1, 9.9, 0.2, 25)
  y <- c(4.1, 2.1, 9.8, 5)
  cm <- typopeuplement:::cimes_points(m, g, x, y)
  expect_equal(cm$h, c(18, 7, NA, NA))
  expect_equal(cm$cellule, c(1L, 2L, NA, NA))
  # x et y inverses : le point (2,1 ; 9,9) n'est dans aucun houppier.
  expect_true(is.na(typopeuplement:::cimes_points(m, g, 2.1, 9.9)$h))
})

# Un pixel (H = 20 m), 100 retours, tous premiers. Sous un houppier de la strate 1 (cime
# 18 m) : 30 retours a 18 m (le haut du houppier), 20 a 12 m (le bas du houppier, tranche
# de la strate 2), 10 au sol. Dans la trouee : 10 a 12 m (strate 2), 10 a 3 m (strate 4),
# 20 au sol.
nuage_sous_houppier <- function() {
  sous <- data.frame(Z = c(rep(18, 30), rep(12, 20), rep(0, 10)), h_cime = 18, cellule_cime = 1L)
  trouee <- data.frame(Z = c(rep(12, 10), rep(3, 10), rep(0, 20)), h_cime = NA_real_,
                       cellule_cime = NA_integer_)
  p <- rbind(sous, trouee)
  p$cellule <- 1L
  p$ReturnNumber <- 1L
  p$Classification <- ifelse(p$Z == 0, 2L, 5L)
  p
}

test_that("hybride : les retours des houppiers de la strate 1 sont retires des strates 2 a 4", {
  p <- nuage_sous_houppier()
  ref <- data.frame(cellule = 1L, h = 20)
  avant <- couvert_strates(p[, c("cellule", "Z", "ReturnNumber", "Classification")], ref)
  apres <- couvert_strates(p, ref)
  # Sans retrait : le bas du houppier compte en strate 2 (30 / 70).
  expect_equal(avant$c2_h, 30 / 70)
  # Avec retrait : la strate 2 se mesure dans la trouee seule (10 / 40), la strate 4 aussi.
  expect_equal(apres$c2_h, 10 / 40)
  expect_equal(apres$c3_h, 0 / 30)
  expect_equal(apres$c4_h, 10 / 30)
  # La strate 1 (premiers retours) ne change pas.
  expect_equal(apres$c1_h, avant$c1_h)
  expect_equal(apres$c1_h, 0.3)
  # Retours retires : 20 a 12 m et 10 au sol, sous le houppier.
  cpt <- comptes_strates(p, ref)
  expect_equal(cpt$r1_h, 30L)
  expect_true(attr(apres, "retrait_s1"))
  expect_false(attr(avant, "retrait_s1"))
  # Part des retours qui passent sous la strate 1 et servent aux strates 2 a 4 :
  # 40 / 100 avec retrait (la trouee), 70 / 100 sans.
  expect_equal(apres$sous_s1_h, 0.4)
  expect_equal(avant$sous_s1_h, 0.7)
  # Un arbre de la strate 2 (cime 12 m) ne retire rien : seul le houppier de la strate 1
  # masque.
  q <- p
  q$h_cime[!is.na(q$h_cime)] <- 12
  expect_equal(couvert_strates(q, ref)$c2_h, avant$c2_h)
  # La strate de l'arbre se lit au pixel de son sommet : sommet au pixel 2 (H = 40 m),
  # cime 18 m < 30 m, pas la strate 1, rien n'est retire.
  r2 <- p
  r2$cellule_cime[!is.na(r2$cellule_cime)] <- 2L
  refs2 <- data.frame(cellule = 1:2, h = c(20, 40))
  expect_equal(couvert_strates(r2, refs2)$c2_h[1], avant$c2_h)
  # Sommet hors grille : la reference du pixel du retour (20 m), strate 1, retire.
  r3 <- p
  r3$cellule_cime[!is.na(r3$cellule_cime)] <- NA_integer_
  expect_equal(couvert_strates(r3, ref)$c2_h, 10 / 40)
  expect_erreur(comptes_strates(p[, setdiff(names(p), "cellule_cime")], ref), "ensemble")
})

test_that("part graduee : de 0 a 1, dans la carte et dans confiance.tif ; retrait dit", {
  # Les deux pixels synthetiques, reference h0 (20 et 10 m), tranches en comptes.
  v <- data.frame(i = 0:1, j = 0L, x = c(5, 15), y = 5, h_dom = c(20, 10), couvert = 0.8,
                  G = 20, part_gb = 0.3)
  attr(v, "gabarit") <- gab_deux
  conf <- extrait_h10()$conf
  cpt <- data.frame(cellule = 1:2, x = c(5, 15), y = 5, n_tous = c(100L, 200L),
                    n_premiers = c(60L, 120L), p1_h0 = c(30L, 10L),
                    n2_h0 = c(10L, 30L), s2_h0 = c(40L, 150L), n3_h0 = c(5L, 20L),
                    s3_h0 = c(30L, 120L), n4_h0 = c(5L, 20L), s4_h0 = c(25L, 100L),
                    r1_h0 = c(30L, 0L))
  res <- executer_chaine_fournie(v, conf, strates = list(tranches = cpt, houppiers = houppiers_connus()),
                                 reference_strates = "h0")
  c <- res$carte
  expect_equal(c$part_retours_sous_s1, c(40 / 100, 150 / 200))
  expect_equal(c$c2_h0, c(10 / 40, 30 / 150))
  dec <- res$fiche_validation$declarations
  expect_false(any(grepl("ATTENTION", dec, fixed = TRUE)))
  expect_true(any(grepl("Part des retours qui passent sous la strate 1", dec, fixed = TRUE)))
  # Somme des couverts dite : pixel 1 0,16 + 0,25 + 5/30 + 5/25 = 0,777 ; pixel 2 0 + 0,2 +
  # 1/6 + 0,2 = 0,567.
  ligne <- dec[grepl("^Somme c1", dec)]
  expect_length(ligne, 1)
  expect_match(ligne, "au-delà de 1 sur 0,0 %", fixed = TRUE)
  d <- file.path(tempdir(), "livrables_part_s1")
  ecrire_livrables(res, d)
  conf_r <- terra::rast(file.path(d, "confiance.tif"))
  expect_true("part_retours_sous_s1" %in% names(conf_r))
  expect_false("strates_basses_estimees" %in% names(conf_r))
  # Graduee, pas un booleen : le pixel du terrain (x 15 m, y 5 m) porte 0,75.
  expect_equal(terra::extract(conf_r[["part_retours_sous_s1"]], cbind(15, 5))[[1]], 0.75)
  expect_equal(terra::extract(conf_r[["part_retours_sous_s1"]], cbind(5, 5))[[1]], 0.4)
  # Comptes sans retrait (pas de colonnes r1_*) en hybride : la fiche le crie.
  sans <- executer_chaine_fournie(v, conf, strates = list(tranches = cpt[, names(cpt) != "r1_h0"],
                                                          houppiers = houppiers_connus()),
                                  reference_strates = "h0")
  expect_true(any(grepl("ATTENTION", sans$fiche_validation$declarations, fixed = TRUE)))
})

test_that("extrait reel : un seul catalogue de deux dalles, retrait dans la chaine", {
  skip_if_not_installed("lasR")
  px <- lire_fixture(file.path("vercors", "strates", "pixels.csv"))
  gab <- list(xmin = 875204.6, xmax = 875284.4, ymin = 6425434.0, ymax = 6425513.8,
              resolution = c(26.6, 26.6), crs = "EPSG:2154")
  nuage <- file.path(dossier_extrait_h(), "nuage.laz")
  # Deux dalles (ouest, est), coupees a x = 875 244,5 m, segmentees en un seul exec avec
  # tampon : aucun houppier coupe, les numeros restent uniques.
  d <- file.path(tempdir(), "deux_dalles")
  dir.create(d, showWarnings = FALSE)
  dalles <- file.path(d, c("ouest.laz", "est.laz"))
  lasR::exec(lasR::write_las(dalles[1], filter = "X < 875244.5"), on = nuage)
  lasR::exec(lasR::write_las(dalles[2], filter = "X >= 875244.5"), on = nuage)
  un <- segmenter_houppiers(nuage, file.path(tempdir(), "seg_un"), ncores = lasR::sequential())
  deux <- segmenter_houppiers(dalles, file.path(tempdir(), "seg_deux"), ncores = lasR::sequential())
  s1 <- sommets_houppiers(un)
  s2 <- sommets_houppiers(deux)
  expect_false(anyDuplicated(s2$id) > 0)
  # Mesure du 2026-11-23 : 281 sommets en une dalle, 282 en deux (un sommet de plus au
  # bord de la coupe) ; sans tampon, les houppiers a cheval compteraient deux fois.
  expect_lt(abs(nrow(s2) - nrow(s1)), 5)
  # Hybride dans la chaine : strate 2 plus faible qu'avec les seules tranches.
  refs <- references_strates(px, facteur = K_VERCORS_H)
  v <- data.frame(x = px$x, y = px$y, h_dom = px$h_dom)
  attr(v, "gabarit") <- gab
  hp <- data.frame(hpot = refs$hpot, h_pot = refs$hpot_k)
  pr <- typopeuplement:::preparer_strates
  hy <- pr(list(tranches = nuage, houppiers = un), v, hp, "hpot")
  tr <- pr(nuage, v, hp, "hpot", methode = "tranches")
  expect_true(attr(hy, "retrait_s1"))
  expect_lt(mean(hy$c2_hpot), mean(tr$c2_hpot))
  expect_true(all(hy$part_retours_sous_s1 > 0 & hy$part_retours_sous_s1 <= 1))
  expect_true(all(hy$part_retours_sous_s1 < tr$part_retours_sous_s1))
  # Les memes comptes a la main.
  cpt <- couvert_strates_dalle(nuage, gab, refs, houppiers = un)
  expect_true(all(cpt$r1_hpot > 0))
  cv <- couvert_depuis_comptes(cpt)
  i <- match(paste(round(v$x, 1), round(v$y, 1)), paste(round(cv$x, 1), round(cv$y, 1)))
  # Deux passes de lasR sur la meme dalle different de quelques retours (normalisation non
  # deterministe, deja vrai sans houppiers, mesure du 2026-11-23 : 1 retour sur 25 000).
  expect_equal(hy$c2_hpot, cv$c2_hpot[i], tolerance = 1e-2)
  expect_equal(hy$c3_hpot, cv$c3_hpot[i], tolerance = 1e-2)
  expect_erreur(couvert_strates_dalle(nuage, gab, refs, houppiers = list(un, deux)), "une seule")
})

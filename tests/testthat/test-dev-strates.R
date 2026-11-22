# Tests unitaires de la mission 008 (agent dev) : couvert des strates du GSM par le nuage
# de points LiDAR HD, et mineurs de la relecture de 009.
#
# Extrait réel (fixtures/vercors/strates/) :
# - nuage.laz : nuage LiDAR HD de l'IGN (Licence Ouverte Etalab 2.0), dalle
#   LHD_FXX_0875_6426_PTS_LAMB93_IGN69.copc.laz (édition 2025-08-13, acquisition avril-mai
#   2022), découpé par lasR sur X 875 204,6 à 875 284,4 m et Y 6 425 434,0 à
#   6 425 513,8 m (Lambert-93, EPSG:2154, altitudes IGN69) : 3 x 3 pixels de 26,6 m de la
#   grille du jeu ONF « Paramètres forestiers LiDAR – Vercors drômois », forêt de Léoncel ;
#   toutes les classes, 1,5 Mo.
# - pixels.csv : ces 9 pixels (centres x, y) ; h_dom (H0_lidar), couvert (Tx_couv / 100),
#   famille (Compo1), typo_etage du jeu ONF ; h_pot de la chaîne sur le massif (mission
#   009, relief seul, enveloppes k 1,167 / 1,106 / 1,130 pour les familles 1 / 2 / 3) ;
#   c1_<r> à c4_<r> : couverts calculés par couvert_strates_dalle() sur la dalle ENTIÈRE
#   (le 2026-11-22), pour les trois références.

dossier_strates <- function() testthat::test_path("fixtures", "vercors", "strates")
K_VERCORS <- c("1" = 1.167, "2" = 1.106, "3" = 1.130)

# Un pixel, H = 20 m (quarts : 15, 10, 5 m), plancher 1 m. Tous les retours sont des
# premiers retours : 60 à 18 m, 12 à 12 m, 7 à 7 m, 6 à 3 m, 15 au sol.
nuage_connu <- function(cellule = 1L) {
  z <- c(rep(18, 60), rep(12, 12), rep(7, 7), rep(3, 6), rep(0, 15))
  data.frame(cellule = cellule, Z = z, ReturnNumber = 1L, Classification = 5L)
}

test_that("nuage synthetique : le couvert de chaque strate est celui qu'on a construit", {
  cv <- couvert_strates(nuage_connu(), data.frame(cellule = 1L, h = 20))
  expect_equal(nrow(cv), 1)
  expect_equal(cv$n_premiers, 100)
  expect_equal(cv$c1_h, 60 / 100)               # premiers retours >= 15 m
  expect_equal(cv$c2_h, 12 / (12 + 7 + 6 + 15)) # parmi les retours < 15 m
  expect_equal(cv$c3_h, 7 / (7 + 6 + 15))       # parmi les retours < 10 m
  expect_equal(cv$c4_h, 6 / (6 + 15))           # de 1 a 5 m, parmi les retours < 5 m
  # Strate 1 : premiers retours seulement. Un retour 2 au-dessus de 15 m n'y compte pas.
  p <- rbind(nuage_connu(), data.frame(cellule = 1L, Z = 16, ReturnNumber = 2L, Classification = 5L))
  expect_equal(couvert_strates(p, data.frame(cellule = 1L, h = 20))$c1_h, 0.6)
  # Les limites sont des quarts de la reference.
  # Avec H = 40 m (quarts 30, 20, 10 m) : 18 et 12 m tombent en strate 3.
  cv40 <- couvert_strates(nuage_connu(), data.frame(cellule = 1L, h = 40))
  expect_equal(cv40$c1_h, 0)
  expect_equal(cv40$c2_h, 0)
  expect_equal(cv40$c3_h, 72 / 100)
  expect_equal(cv40$c4_h, 13 / 28)
  # Le plancher : a 4 m, les retours a 3 m sont du sol pour la strate 4.
  expect_equal(couvert_strates(nuage_connu(), data.frame(cellule = 1L, h = 20),
                               plancher_m = 4)$c4_h, 0)
})

test_that("classes, sol et hauteurs negatives : batiments et bruit ecartes, Z < 0 vaut le sol", {
  ref <- data.frame(cellule = 1L, h = 20)
  base <- couvert_strates(nuage_connu(), ref)
  bati <- rbind(nuage_connu(),
                data.frame(cellule = 1L, Z = c(18, 18, 8), ReturnNumber = 1L,
                           Classification = c(6L, 65L, 9L)))
  expect_equal(couvert_strates(bati, ref)[, -(1:3)], base[, -(1:3)])
  neg <- nuage_connu()
  neg$Z[neg$Z == 0] <- -0.4
  expect_equal(couvert_strates(neg, ref), base)
  # Un point sans pixel (hors de la grille) ne compte pas.
  hors <- rbind(nuage_connu(), data.frame(cellule = NA, Z = 18, ReturnNumber = 1L, Classification = 5L))
  expect_equal(couvert_strates(hors, ref), base)
})

test_that("plusieurs references, reference vide, comptes additifs entre dalles", {
  p <- rbind(nuage_connu(1L), nuage_connu(2L))
  refs <- data.frame(cellule = c(1L, 2L), a = c(20, NA), b = c(40, 40))
  cv <- couvert_strates(p, refs)
  expect_setequal(grep("^c[1-4]_", names(cv), value = TRUE),
                  c(paste0("c", 1:4, "_a"), paste0("c", 1:4, "_b")))
  expect_equal(cv$c1_a, c(0.6, NA))
  expect_true(all(is.na(unlist(cv[2, paste0("c", 1:4, "_a")]))))
  expect_equal(cv$c3_b, c(0.72, 0.72))
  # Un pixel coupe par la limite de deux dalles : les comptes s'additionnent.
  moitie <- seq(1, nrow(p), by = 2)
  cpt <- rbind(comptes_strates(p[moitie, ], refs), comptes_strates(p[-moitie, ], refs))
  expect_equal(nrow(cpt), 4)
  expect_equal(couvert_depuis_comptes(cpt), cv)
  # Aucun point dans la grille (dalle au bord de l'emprise) : aucun pixel, pas d'arret.
  vide <- nuage_connu()
  vide$cellule <- NA_integer_
  expect_equal(nrow(couvert_strates(vide, refs)), 0)
  # Pixel sans point : absent ; reference nulle : vide.
  cv0 <- couvert_strates(nuage_connu(1L), data.frame(cellule = c(1L, 3L), h = c(0, 20)))
  expect_equal(cv0$cellule, 1L)
  expect_true(is.na(cv0$c2_h))
})

test_that("entrees refusees : plancher nul, colonnes absentes, pixel en double", {
  ref <- data.frame(cellule = 1L, h = 20)
  expect_erreur(couvert_strates(nuage_connu(), ref, plancher_m = 0), "strictement positif")
  expect_erreur(couvert_strates(nuage_connu()[, -2], ref), "Z")
  expect_erreur(couvert_strates(nuage_connu(), data.frame(cellule = c(1L, 1L), h = 20)),
                "une seule ligne")
  expect_erreur(couvert_strates(nuage_connu(), data.frame(cellule = 1L)), "aucune hauteur")
  expect_erreur(couvert_strates(nuage_connu(), data.frame(cellule = 1L, h = "20")), "num")
})

test_that("references_strates : h_pot avec k, sans k par famille, H0 du pixel", {
  carte <- data.frame(x = c(1, 2, 3, 4), y = 5, h_pot = c(23.34, 22.12, 22.6, NA),
                      h_dom = c(20, 21, 22, 23), famille = c(1, 2, 9, 3))
  r <- references_strates(carte, facteur = list(`1` = 1.167, `2` = 1.106, `3` = 1.13))
  expect_named(r, c("x", "y", "hpot_k", "hpot", "h0"))
  expect_equal(r$hpot_k, carte$h_pot)
  # Famille 9 sans facteur : celui de la premiere famille, comme predire_hauteur_potentielle().
  expect_equal(r$hpot, c(20, 20, 22.6 / 1.167, NA), tolerance = 1e-12)
  expect_equal(r$h0, carte$h_dom)
  expect_named(references_strates(carte), c("x", "y", "hpot_k", "h0"))
  expect_erreur(references_strates(carte, facteur = c(1.1, 1.2)), "nomm")
  expect_erreur(references_strates(carte[, -5], facteur = K_VERCORS), "famille")
})

test_that("pixels : un point du terrain tombe dans le bon pixel (Lambert-93, x puis y)", {
  px <- lire_fixture(file.path("vercors", "strates", "pixels.csv"))
  gab <- list(xmin = 875204.6, xmax = 875284.4, ymin = 6425434.0, ymax = 6425513.8,
              resolution = c(26.6, 26.6), crs = "EPSG:2154")
  r <- terra::rast(terra::ext(875204.6, 875284.4, 6425434.0, 6425513.8), resolution = 26.6,
                   crs = "EPSG:2154")
  g1 <- typopeuplement:::grille_strates(gab)
  g2 <- typopeuplement:::grille_strates(r)
  expect_equal(g1[c("ncol", "nrow")], list(ncol = 3L, nrow = 3L))
  expect_equal(g1$xmin, g2$xmin)
  expect_equal(g1$ymax, g2$ymax)
  # Centres des 9 pixels : meme numero que terra (ligne par ligne depuis le nord-ouest).
  cel <- typopeuplement:::cellules_xy(g1, px$x, px$y)
  expect_equal(cel, terra::cellFromXY(r, cbind(px$x, px$y)))
  expect_setequal(cel, 1:9)
  # Un retour pres du coin nord-ouest (x = 875 205, y = 6 425 513) : pixel 1, celui de
  # centre (875 217,9 ; 6 425 500,5). Echanger x et y le met hors de la grille.
  expect_equal(typopeuplement:::cellules_xy(g1, 875205, 6425513), 1L)
  expect_equal(px$x[cel == 1], 875217.9, tolerance = 1e-6)
  expect_equal(px$y[cel == 1], 6425500.5, tolerance = 1e-6)
  expect_true(is.na(typopeuplement:::cellules_xy(g1, 6425513, 875205)))
  # Bords : le bord ouest est dans la grille, le bord est n'y est plus.
  expect_equal(typopeuplement:::cellules_xy(g1, c(875204.6, 875284.41), c(6425474, 6425474)),
               c(4L, NA))
  expect_erreur(typopeuplement:::grille_strates(list(a = 1)), "gabarit")
})

test_that("sans lasR, la lecture d'une dalle s'arrete en le disant", {
  skip_if(requireNamespace("lasR", quietly = TRUE), "lasR est installe")
  expect_erreur(couvert_strates_dalle(file.path(dossier_strates(), "nuage.laz"),
                                      list(xmin = 0, xmax = 1, ymin = 0, ymax = 1, resolution = 1),
                                      data.frame(x = 0.5, y = 0.5, h = 20)),
                "lasR")
})

test_that("une dalle a la fois", {
  skip_if_not_installed("lasR")
  gab <- list(xmin = 0, xmax = 1, ymin = 0, ymax = 1, resolution = 1)
  expect_erreur(couvert_strates_dalle(c("a.laz", "b.laz"), gab, data.frame(x = 0.5, y = 0.5, h = 20)),
                "une seule dalle")
  expect_erreur(couvert_strates_dalle("absente.laz", gab, data.frame(x = 0.5, y = 0.5, h = 20)),
                "introuvable")
})

test_that("extrait reel LiDAR HD : couverts de la dalle entiere retrouves, entre 0 et 1", {
  skip_if_not_installed("lasR")
  px <- lire_fixture(file.path("vercors", "strates", "pixels.csv"))
  gab <- list(xmin = 875204.6, xmax = 875284.4, ymin = 6425434.0, ymax = 6425513.8,
              resolution = c(26.6, 26.6), crs = "EPSG:2154")
  refs <- references_strates(px, facteur = K_VERCORS)
  cpt <- couvert_strates_dalle(file.path(dossier_strates(), "nuage.laz"), gab, refs, ncores = 1)
  cv <- couvert_depuis_comptes(cpt)
  expect_equal(nrow(cv), 9)
  i <- match(paste(round(px$x, 1), round(px$y, 1)), paste(round(cv$x, 1), round(cv$y, 1)))
  expect_false(anyNA(i))
  cols <- grep("^c[1-4]_", names(px), value = TRUE)
  expect_length(cols, 12)
  obs <- as.matrix(cv[i, cols])
  expect_true(all(obs >= 0 & obs <= 1))
  # L'extrait est normalise seul : au bord, le sol est interpole avec moins de points
  # qu'avec la dalle entiere. Ecart mesure le 2026-11-22 : au plus 0,015 (pixel d'angle).
  expect_lt(max(abs(obs - as.matrix(px[cols]))), 0.02)
  expect_gt(min(cv$n_premiers), 10000)  # LiDAR HD : environ 20 premiers retours par m2
})

test_that("mineurs de 009 : foret partagee, keep.inbag sans effet sur les predictions", {
  set.seed(1)
  X <- data.frame(a = runif(60), b = runif(60))
  y <- X$a * 10 + rnorm(60)
  m1 <- typopeuplement:::foret_regression(X, y, 50, 3, 0)
  m2 <- typopeuplement:::foret_regression(X, y, 50, 3, 0, keep.inbag = TRUE)
  expect_null(m1$inbag.counts)
  expect_length(m2$inbag.counts, 50)
  expect_equal(stats::predict(m1, X)$predictions, stats::predict(m2, X)$predictions)
  expect_false(exists("foret_hors_sac", envir = asNamespace("typopeuplement"), inherits = FALSE))
})

test_that("mineurs de 009 : la fiche dit le seuil de h_pot auquel revient le drapeau", {
  # Milieu jouet (une variable, liee a la position) : seul compte ici le texte de la fiche.
  v <- lire_parametres_lidar(testthat::test_path("fixtures", "vercors"))
  mi <- data.frame(gradient = v$i + 2 * v$j)
  attr(mi, "variables_milieu") <- "gradient"
  res <- typer_peuplements(NULL, ser = SER_EXEMPLE, configuration = chemin_config_exemple(),
                           variables = v, milieu = mi)
  dec <- res$fiche_validation$declarations
  ligne <- dec[grepl("seuil de hauteur potentielle par famille", dec)]
  expect_length(ligne, 1)
  m <- regmatches(ligne, gregexpr("famille [^ ]+ : [0-9]+(,[0-9])? m", ligne))[[1]]
  expect_gte(length(m), 1)
  c <- res$carte
  for (x in m) {
    fam <- sub("famille ([^ ]+) : .*", "\\1", x)
    seuil <- as.numeric(sub(",", ".", sub(".* : ([0-9,]+) m", "\\1", x)))
    d <- !c$non_precomptable & as.character(c$famille) == fam & !is.na(c$h_pot)
    # Au dixieme de metre pres (arrondi de la fiche) : incertaine <=> h_pot sous le seuil.
    loin <- abs(c$h_pot[d] - seuil) > 0.05
    expect_equal(c$hp_incertaine[d][loin], c$h_pot[d][loin] < seuil)
  }
})

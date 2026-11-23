# Tests unitaires de la mission 012 (agent dev) : couvert des strates, hauteur potentielle
# (h_pot, hpot) et densite N branches dans la cle ; mineurs de 008 (plancher sous 4 m,
# dalles sur le contour, controle par c1).
#
# Extrait : fixtures/vercors/ (40 x 40 pixels de 26,6 m, Lambert-93 EPSG:2154, x 884 355 a
# 885 419 m, y 6 425 806,4 a 6 426 870,4 m), avec N.tif ajoute le 2026-11-22 : couche N du
# jeu ONF « Parametres forestiers LiDAR – Vercors dromois » (serveur du CRAIG), decoupee sur
# la meme grille que G.tif. Relief : fixtures/vercors/milieu/mnt.tif (voir test-dev-milieu.R).

dossier_vercors_b <- function() testthat::test_path("fixtures", "vercors")
chemin_config_h10 <- function() {
  normalizePath(testthat::test_path("..", "..", "inst", "extdata", "config", "vercors-h10.json"))
}
CODES_GSM <- c("CH", "L", "3", "R", "1", "1GB", "2", "2GB", "12", "12GB", "13", "13GB", "23",
               "C", "J", "JGB")

extrait_relief_b <- function() {
  v <- lire_parametres_lidar(dossier_vercors_b())
  rel <- calculer_relief(testthat::test_path("fixtures", "vercors", "milieu", "mnt.tif"), attr(v, "gabarit"))
  list(v = v, milieu = milieu_pixels(rel, v))
}

# Couverts constants sur tous les pixels de l'extrait.
strates_constantes <- function(v, c1, c2, c3, c4) {
  data.frame(x = v$x, y = v$y, c1_hpot = c1, c2_hpot = c2, c3_hpot = c3, c4_hpot = c4)
}

types_de <- function(carte) unique(stats::na.omit(carte$type))

test_that("N : lue en tiges/ha (aucune conversion), facultative", {
  co <- couches_onf()
  expect_equal(co$facteur[co$variable == "N"], 1)
  expect_false(co$obligatoire[co$variable == "N"])
  v <- lire_parametres_lidar(dossier_vercors_b())
  r <- terra::rast(file.path(dossier_vercors_b(), "N.tif"))
  # Un pixel du terrain (x puis y, Lambert-93) : la valeur du raster, telle quelle.
  k <- which(v$i == 12 & v$j == 30)
  expect_equal(v$N[k], terra::extract(r, cbind(v$x[k], v$y[k]))[[1]], tolerance = 1e-6)
  # Des tiges par hectare, pas une part : de l'ordre de la centaine (placettes ONF : 14 a 948).
  expect_true(all(v$N >= 0 & v$N < 2000, na.rm = TRUE))
  expect_gt(stats::median(v$N[!v$non_precomptable], na.rm = TRUE), 50)
  # Sans N.tif : pas d'arret, pas de colonne.
  d <- file.path(tempdir(), "vercors_sans_n")
  dir.create(d, showWarnings = FALSE)
  f <- setdiff(list.files(dossier_vercors_b(), pattern = "\\.tif$"), "N.tif")
  file.copy(file.path(dossier_vercors_b(), f), d, overwrite = TRUE)
  expect_false("N" %in% names(lire_parametres_lidar(d)))
})

test_that("plancher : respecte quand la reference est sous 4 m (mineur de 008)", {
  # H = 2 m : quarts 1,5 / 1 / 0,5 m. 10 retours au sol, 10 a 0,8 m (sous le plancher de
  # 1 m, mais dans la tranche de la strate 3), 5 a 1,8 m (strate 1).
  p <- data.frame(cellule = 1L, Z = c(rep(0, 10), rep(0.8, 10), rep(1.8, 5)),
                  ReturnNumber = 1L, Classification = c(rep(2L, 10), rep(3L, 10), rep(4L, 5)))
  cv <- couvert_strates(p, data.frame(cellule = 1L, h = 2))
  expect_equal(cv$c1_h, 5 / 25)
  expect_equal(cv$c2_h, 0)
  expect_equal(cv$c3_h, 0)  # 0,8 m est du sol, pas de la strate 3 (10/20 avant le correctif)
  expect_equal(cv$c4_h, 0)
  # H = 3 m (quart 0,75 m) : 0,8 m est en strate 4 par la hauteur, mais sous le plancher.
  expect_equal(couvert_strates(p, data.frame(cellule = 1L, h = 3))$c4_h, 0)
  # Au-dessus de 4 m, rien ne change : H = 20 m, le plancher ne touche que la strate 4.
  q <- data.frame(cellule = 1L, Z = c(rep(0, 10), rep(0.8, 10), rep(3, 5)),
                  ReturnNumber = 1L, Classification = 5L)
  expect_equal(couvert_strates(q, data.frame(cellule = 1L, h = 20))$c4_h, 5 / 25)
})

test_that("dalles : choisies sur le contour de l'AOI et dans la grille (mineur de 008)", {
  # AOI en L (Lambert-93) : x 873 000 a 875 000 sur y 6 425 000 a 6 426 000, plus x 873 000
  # a 874 000 sur y 6 426 000 a 6 427 000. La dalle 0874_6427 (x 874-875 km, y 6426-6427 km)
  # est dans le rectangle englobant, pas sur le contour.
  l <- sf::st_polygon(list(rbind(c(873000, 6425000), c(875000, 6425000), c(875000, 6426000),
                                 c(874000, 6426000), c(874000, 6427000), c(873000, 6427000),
                                 c(873000, 6425000))))
  aoi <- sf::st_sf(id = 1, geometry = sf::st_sfc(l, crs = 2154))
  noms <- c("LHD_FXX_0873_6426_PTS_LAMB93_IGN69.copc.laz", "0874-6426", "0873_6427",
            "0874_6427", "0875_6426", "0872_6426")
  expect_identical(dalles_sur_aoi(noms, aoi), noms[1:3])
  # Le rectangle aurait pris 0874_6427 ; 0875_6426 et 0872_6426 ne partagent qu'un bord.
  # Avec la grille des pixels (x 873 000 a 874 000) : la partie de l'AOI hors grille
  # n'appelle aucune dalle.
  gab <- list(xmin = 873000, xmax = 874000, ymin = 6425000, ymax = 6427000, resolution = 25)
  expect_identical(dalles_sur_aoi(noms, aoi, gabarit = gab), noms[c(1, 3)])
  # Emprises sf (WFS) : memes dalles, lignes gardees.
  carre <- function(x, y) sf::st_polygon(list(rbind(c(x, y), c(x + 1000, y), c(x + 1000, y - 1000),
                                                     c(x, y - 1000), c(x, y))))
  d <- sf::st_sf(nom = c("a", "b", "c"),
                 geometry = sf::st_sfc(carre(873000, 6426000), carre(874000, 6427000),
                                       carre(874000, 6426000), crs = 2154))
  expect_identical(dalles_sur_aoi(d, aoi)$nom, c("a", "c"))
  expect_erreur(dalles_sur_aoi("dalle", aoi), "coin nord-ouest")
})

test_that("controle : c1 contre le taux de couvert, pas la somme des strates (mineur de 008)", {
  k <- typopeuplement:::controle_couvert_c1(c(0.1, 0.2, 0.3, NA), c(0.2, 0.4, 0.6, 0.5))
  expect_equal(k$n, 3L)
  expect_equal(k$pearson, 1)
  v <- lire_parametres_lidar(dossier_vercors_b())
  s <- strates_constantes(v, 0.5, 0.1, 0.1, 0.1)
  s$c1_hpot <- v$couvert  # c1 egal au taux de couvert : r = 1
  s$c2_hpot <- 1 - v$couvert  # la somme c1 + c2 vaut 1 : sans lien avec le couvert
  conf <- lire_configuration(chemin_config_h10(), "H10")
  res <- executer_chaine_fournie(v, conf, strates = s)
  dec <- res$fiche_validation$declarations
  ligne <- dec[grepl("^Contr", dec)]
  expect_length(ligne, 1)
  expect_match(ligne, "c1_hpot", fixed = TRUE)
  expect_match(ligne, "Pearson 1,00", fixed = TRUE)
  expect_true(any(grepl("hpot, PROVISOIRE", dec, fixed = TRUE)))
  expect_true("strates" %in% res$temps$etage)
})

test_that("cle du GSM sur l'extrait du Vercors, strates fournies : la chaine tourne", {
  x <- extrait_relief_b()
  # Strate 1 preponderante, les autres deficitaires : L (G < 10), 1 ou 1GB (G >= 10).
  s <- strates_constantes(x$v, 0.6, 0.1, 0.1, 0.1)
  dossier <- file.path(tempdir(), "dev_branchement_gsm")
  res <- typer_peuplements(NULL, ser = "H10", configuration = chemin_config_h10(),
                           variables = x$v, milieu = x$milieu, strates = s, sortie = dossier)
  c <- res$carte
  ok <- !c$non_precomptable
  expect_true(all(c(paste0("c", 1:4, "_hpot"), "h_pot", "hpot", "N") %in% names(c)))
  expect_true(all(types_de(c) %in% c("L", "1", "1GB")))
  expect_false(any(grepl("|", c$type, fixed = TRUE)))  # aucune variable absente : pas de groupe
  dec <- res$fiche_validation$declarations
  expect_false(any(grepl("absentes de la cha", dec)))
  # hpot = h_pot / k de la famille.
  k <- typopeuplement:::hpot_sans_enveloppe(c$h_pot, c$famille, list(`1` = 2, `2` = 2, `3` = 2))
  expect_equal(k, c$h_pot / 2)
  expect_true(all(c$hpot[ok] < c$h_pot[ok], na.rm = TRUE))
  # Les couverts et hpot sont livres dans variables.tif.
  vt <- terra::rast(file.path(dossier, "variables.tif"))
  expect_true(all(c("hpot", "N", "c1_hpot", "c4_hpot") %in% names(vt)))
  # Strates 1 et 3 moyennes, 2 deficitaire : 13 ou 13GB si G >= 10.
  s13 <- strates_constantes(x$v, 0.35, 0.1, 0.35, 0.1)
  r13 <- typer_peuplements(NULL, ser = "H10", configuration = chemin_config_h10(),
                           variables = x$v, milieu = x$milieu, strates = s13)
  forts <- !r13$carte$non_precomptable & r13$carte$G > 30 & !r13$carte$entre_deux
  expect_true(any(forts))
  expect_true(all(r13$carte$type[forts] %in% c("13", "13GB")))
})

test_that("cle du GSM sans strates : variables absentes nommees, neutralisees en groupes", {
  v <- lire_parametres_lidar(dossier_vercors_b())
  res <- typer_peuplements(NULL, ser = "H10", configuration = chemin_config_h10(), variables = v)
  dec <- res$fiche_validation$declarations
  expect_true(any(grepl("absentes de la chaîne : c1_hpot, c2_hpot, c3_hpot, c4_hpot",
                        dec, fixed = TRUE)))
  types <- types_de(res$carte)
  membres <- unique(unlist(strsplit(types, " | ", fixed = TRUE)))
  expect_true(all(membres %in% CODES_GSM))
  # Sans milieu ni strates, aucun type n'est franc : tout pixel type est « entre deux ».
  # (Limite constatee le 2026-11-22 : CH, qui n'a que deux conditions, sort en tete quand
  # h_pot manque ; voir le rendu de 012.)
  typ <- !is.na(res$carte$type)
  expect_true(all(res$carte$entre_deux[typ]))
  # Les memes pixels avec les strates et le milieu ne sont plus tous entre deux.
  x <- extrait_relief_b()
  r2 <- typer_peuplements(NULL, ser = "H10", configuration = chemin_config_h10(),
                          variables = x$v, milieu = x$milieu,
                          strates = strates_constantes(x$v, 0.6, 0.1, 0.1, 0.1))
  expect_false(all(r2$carte$entre_deux[!is.na(r2$carte$type)]))
})

test_that("variables de la cle : N, h_pot et hpot passent quand la cle les cite", {
  x <- extrait_relief_b()
  conf <- lire_configuration(ecrire_json('{"national": {"lissage_fenetre": 1,
    "hauteur_potentielle": {"couvert_min": 0.7, "hauteur_min_m": 15,
      "incertitude_relative_max": 0.2, "quantile_enveloppe": 0.9},
    "cle": {"marge_entre_deux": 0.15, "souplesse": {}, "types": [
      {"code": "A", "conditions": [{"variable": "N", "max": 300}, {"variable": "hpot", "max": 25}]},
      {"code": "B", "conditions": [{"variable": "N", "min": 300}, {"variable": "hpot", "max": 25}]},
      {"code": "C", "conditions": [{"variable": "h_pot", "min": 25}, {"variable": "hpot", "min": 25}]},
      {"code": "D", "conditions": [{"variable": "h_pot", "min": 25}, {"variable": "hpot", "max": 25}]}
    ]}}, "ser": {"s": {}}}'), "s")
  res <- executer_chaine_fournie(x$v, conf, milieu = x$milieu)
  c <- res$carte
  ok <- !c$non_precomptable & !c$hors_cle
  attendu <- ifelse(c$hpot < 25, ifelse(c$h_pot >= 25, "A|B|D", ifelse(c$N < 300, "A", "B")), "C")
  # Cle dure, sans lissage : le type suit N, hpot, h_pot pixel par pixel.
  net <- ok & attendu %in% c("A", "B", "C")
  expect_gt(sum(net), 100)
  expect_identical(c$type[net], attendu[net])
  expect_true(any(c$type[ok] == "A") && any(c$type[ok] == "B"))
  expect_false(any(grepl("absentes de la cha", res$fiche_validation$declarations)))
})

test_that("strates : un point du terrain tombe dans le bon pixel (Lambert-93, x puis y)", {
  v <- lire_parametres_lidar(dossier_vercors_b())
  conf <- lire_configuration(chemin_config_h10(), "H10")
  k <- which(v$i == 7 & v$j == 21)
  # Un point a 5 m a l'est et 7 m au sud du centre du pixel (moins d'un demi-pixel).
  s <- data.frame(x = v$x[k] + 5, y = v$y[k] - 7, c1_hpot = 0.11, c2_hpot = 0.22,
                  c3_hpot = 0.33, c4_hpot = 0.44)
  c <- executer_chaine_fournie(v, conf, strates = s)$carte
  expect_equal(unlist(c[k, paste0("c", 1:4, "_hpot")], use.names = FALSE),
               c(0.11, 0.22, 0.33, 0.44))
  expect_equal(sum(!is.na(c$c1_hpot)), 1)
  expect_equal(c$x[k], 884355 + 7.5 * 26.6, tolerance = 1e-6)
  expect_equal(c$y[k], 6425806.4 + 21.5 * 26.6, tolerance = 1e-3)
  # x et y echanges : hors de la grille, aucun pixel.
  t <- s
  t$x <- s$y
  t$y <- s$x
  expect_true(all(is.na(executer_chaine_fournie(v, conf, strates = t)$carte$c1_hpot)))
  # Deux lignes dans le meme pixel : arret.
  expect_erreur(executer_chaine_fournie(v, conf, strates = rbind(s, s)), "même pixel")
  # Reference sans colonnes : arret en les nommant.
  expect_erreur(executer_chaine_fournie(v, conf, strates = s, reference_strates = "h0"), "c1_h0")
})

test_that("strates en fichiers .rds de comptes (une dalle par fichier) : additionnes", {
  v <- lire_parametres_lidar(dossier_vercors_b())
  conf <- lire_configuration(chemin_config_h10(), "H10")
  k <- which(v$i == 3 & v$j == 4)
  z <- c(rep(18, 60), rep(12, 12), rep(7, 7), rep(3, 6), rep(0, 15))
  pts <- data.frame(cellule = 1L, Z = z, ReturnNumber = 1L, Classification = 5L)
  refs <- data.frame(cellule = 1L, hpot = 20, h0 = 40)
  moitie <- seq(1, nrow(pts), by = 2)
  f <- c(tempfile(fileext = ".rds"), tempfile(fileext = ".rds"))
  for (m in 1:2) {
    cpt <- comptes_strates(if (m == 1) pts[moitie, ] else pts[-moitie, ], refs)
    cpt$x <- v$x[k]
    cpt$y <- v$y[k]
    saveRDS(cpt, f[m])
  }
  # Des comptes par tranches seuls : methode « tranches », dite (mission 013 : le defaut
  # hybride demande aussi les houppiers).
  c <- executer_chaine_fournie(v, conf, strates = f, methode_strates = "tranches")$carte
  attendu <- couvert_strates(pts, refs)
  expect_equal(c$c1_hpot[k], attendu$c1_hpot)
  expect_equal(c$c4_hpot[k], attendu$c4_hpot)
  expect_false("c1_h0" %in% names(c))  # la reference choisie seulement
  expect_erreur(executer_chaine_fournie(v, conf, strates = "absent.rds"), "introuvables")
})

test_that("modele_hp : la hauteur potentielle apprise sur le jeu entier s'applique a une AOI", {
  x <- extrait_relief_b()
  conf <- lire_configuration(chemin_config_h10(), "H10")
  conf$graine <- 0
  m <- apprendre_hauteur_potentielle(x$v, x$milieu, conf)
  tout <- typer_peuplements(NULL, ser = "H10", configuration = chemin_config_h10(),
                            variables = x$v, milieu = x$milieu)
  aoi <- sf::st_as_sf(sf::st_as_sfc(sf::st_bbox(c(xmin = 884355, ymin = 6425806.4,
                                                   xmax = 884900, ymax = 6426400),
                                                 crs = sf::st_crs(2154))))
  part <- typer_peuplements(aoi, ser = "H10", configuration = chemin_config_h10(),
                            variables = x$v, milieu = x$milieu, modele_hp = m)
  # Seule, l'AOI a trop peu d'adultes ; avec le modele du jeu entier, memes h_pot.
  i <- match(paste(part$carte$x, part$carte$y), paste(tout$carte$x, tout$carte$y))
  expect_false(anyNA(i))
  expect_equal(part$carte$h_pot, tout$carte$h_pot[i])
  expect_equal(part$carte$hpot, tout$carte$hpot[i])
  expect_false(all(part$carte$hp_incertaine))
  expect_true(any(grepl("modèle fourni", part$fiche_validation$declarations)))
  expect_erreur(executer_chaine_fournie(x$v, conf, modele_hp = m), "sans milieu")
})

test_that("strates calculees depuis une dalle dans la chaine (lasR) : couverts de 008 retrouves", {
  skip_if_not_installed("lasR")
  # Les 9 pixels de fixtures/vercors/strates/ (Leoncel), reference h0 (h_dom du pixel) :
  # la seule que la chaine porte sans milieu.
  px <- lire_fixture(file.path("vercors", "strates", "pixels.csv"))
  v <- data.frame(i = rep(0:2, 3), j = rep(2:0, each = 3), x = px$x, y = px$y,
                  h_dom = px$h_dom, couvert = px$couvert, famille = px$famille, G = 20,
                  part_gb = 0.3)
  attr(v, "gabarit") <- list(xmin = 875204.6, xmax = 875284.4, ymin = 6425434.0,
                             ymax = 6425513.8, resolution = c(26.6, 26.6), crs = "EPSG:2154")
  conf <- lire_configuration(chemin_config_h10(), "H10")
  laz <- file.path(testthat::test_path("fixtures", "vercors", "strates"), "nuage.laz")
  c <- executer_chaine_fournie(v, conf, strates = laz, reference_strates = "h0",
                               methode_strates = "tranches")$carte
  cols <- paste0("c", 1:4, "_h0")
  expect_lt(max(abs(as.matrix(c[, cols]) - as.matrix(px[, cols]))), 0.02)
  # La cle du GSM cite c*_hpot, pas c*_h0 : ils restent absents, et la fiche le dit.
  expect_false("c1_hpot" %in% names(c))
})

test_that("relief : pas du MNT arrondi, focalMat ne juge plus les pixels non carres (1/3, point 3)", {
  # La grille etendue du relief porte des pas en x et en y qui different de ~3e-12 m
  # (26,6 m du jeu ONF) ; sf charge, GDAL en faisait un avertissement « Pixels not square ».
  requireNamespace("sf", quietly = TRUE)
  v <- lire_parametres_lidar(dossier_vercors_b())
  expect_no_warning(
    rel <- calculer_relief(testthat::test_path("fixtures", "vercors", "milieu", "mnt.tif"),
                           attr(v, "gabarit")))
  expect_true(all(terra::res(rel) > 26.59 & terra::res(rel) < 26.61))
})

test_that("lissage : un pixel de poids nul ne dilue pas ses voisins et ne leur emprunte rien", {
  # Grille 1 x 3 : A franc, pixel du milieu a probabilites egales (hors cle), A franc.
  p <- data.frame(A = c(1, 0.5, 1), B = c(0, 0.5, 0))
  sans <- lisser_probabilites(p, c(0, 0, 0), c(0, 1, 2), 3)
  expect_lt(sans$A[1], 1)  # sans poids : le pixel hors cle dilue ses voisins
  l <- lisser_probabilites(p, c(0, 0, 0), c(0, 1, 2), 3, poids = c(1, 0, 1))
  expect_equal(l$A, c(1, 0.5, 1), tolerance = 1e-12)  # voisins intacts, pixel nul inchange
  expect_equal(rowSums(l), rep(1, 3), tolerance = 1e-12)
  # Poids 1 partout : le lissage d'avant, a l'identique.
  expect_identical(lisser_probabilites(p, c(0, 0, 0), c(0, 1, 2), 3, poids = c(1, 1, 1)), sans)
  expect_erreur(lisser_probabilites(p, c(0, 0, 0), c(0, 1, 2), 3, poids = c(1, -1, 1)), "poids")
})

test_that("hors cle : pas de type, drapeau garde, poids nul au lissage (aller-retour 1/3)", {
  v <- lire_parametres_lidar(dossier_vercors_b())
  conf <- lire_configuration(ecrire_json('{"national": {"lissage_fenetre": 3,
    "hauteur_potentielle": {"couvert_min": 0.7, "hauteur_min_m": 15,
      "incertitude_relative_max": 0.2, "quantile_enveloppe": 0.9},
    "cle": {"marge_entre_deux": 0.15, "souplesse": {}, "types": [
      {"code": "A", "conditions": [{"variable": "couvert", "min": 0.5}]},
      {"code": "B", "conditions": [{"variable": "couvert", "min": 0.1, "max": 0.5}]}
    ]}}, "ser": {"s": {}}}'), "s")
  # Tout le couvert a 0,8 (A), sauf un pixel a 0,05 : aucun type ne le decrit.
  v$couvert <- 0.8
  k <- which(v$i == 20 & v$j == 20 & !v$non_precomptable)
  expect_length(k, 1)
  v$couvert[k] <- 0.05
  res <- executer_chaine_fournie(v, conf)
  c <- res$carte
  expect_true(c$hors_cle[k])
  expect_true(is.na(c$type[k]) && is.na(c$proba[k]) && is.na(c$type_second[k]) &&
                is.na(c$entre_deux[k]))
  expect_true(all(is.na(c[k, c("p_A", "p_B")])))
  # Ses voisins (fenetre 3 x 3) gardent A a 1 : il ne les dilue pas.
  vois <- which(abs(c$i - c$i[k]) <= 1 & abs(c$j - c$j[k]) <= 1 & seq_len(nrow(c)) != k &
                  !c$non_precomptable)
  expect_gt(length(vois), 0)
  expect_equal(c$p_A[vois], rep(1, length(vois)))
  expect_true(all(c$type[vois] == "A") && !any(c$entre_deux[vois]))
  expect_false(any(c$hors_cle[-k], na.rm = TRUE))
  # La fiche donne la part hors cle et la repartition des types.
  dec <- res$fiche_validation$declarations
  n_ok <- sum(!c$non_precomptable)
  expect_true(any(grepl(sprintf("(1 sur %d)", n_ok), dec, fixed = TRUE)))
  expect_true(any(grepl(sprintf("R\u00e9partition des types (pixels typ\u00e9s, n = %d) : A 100,0 %%",
                                n_ok - 1), dec, fixed = TRUE)))
  # Livrables : type vide dans types.tif, drapeau dans confiance.tif.
  d <- file.path(tempdir(), "dev_hors_cle")
  ecrire_livrables(res, d)
  ty <- terra::rast(file.path(d, "types.tif"))
  co <- terra::rast(file.path(d, "confiance.tif"))
  xy <- cbind(c$x[k], c$y[k])
  expect_true(is.na(terra::extract(ty[["type"]], xy)[[1]]))
  expect_equal(terra::extract(co[["hors_cle"]], xy)[[1]], 1)
})

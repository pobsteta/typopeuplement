# Tests unitaires de la mission 006 (agent dev) : lecture des parametres forestiers LiDAR
# de l'ONF (jeu « Vercors dromois 2021-2022 ») et mode « variables fournies ».
#
# Extrait de test (fixtures/vercors/) : 40 x 40 pixels de 26,6 m du jeu complet (lignes 720
# a 759, colonnes 600 a 639 de la grille de 1839 x 2074), Lambert-93 (EPSG:2154),
# emprise x 884 355 a 885 419 m, y 6 425 806,4 a 6 426 870,4 m. Sept couches : G, p100GR,
# p100GGB, H0_lidar, Tx_couv, Compo1, Typo_etage. Source : serveur WebDAV du CRAIG.

dossier_vercors <- function() testthat::test_path("fixtures", "vercors")

lire_extrait <- function(...) lire_parametres_lidar(dossier_vercors(), ...)

# Configuration temporaire : l'exemple du package plus un bloc `jeux` (texte JSON).
conf_exemple_avec_jeux <- function(jeux_json) {
  conf <- jsonlite::fromJSON(chemin_config_exemple(), simplifyVector = FALSE)
  conf$jeux <- jsonlite::fromJSON(jeux_json, simplifyVector = FALSE)
  f <- tempfile(fileext = ".json")
  writeLines(jsonlite::toJSON(conf, auto_unbox = TRUE, digits = NA), f, useBytes = TRUE)
  f
}

conf_json_vide <- function() {
  ecrire_json('{"national": {"seuils_diametre": {"bm_gb_cm": 42.5},
    "cle": {"types": []}}, "ser": {"H10": {}}}')
}

typer_extrait <- function(..., ser = SER_EXEMPLE, configuration = chemin_config_exemple()) {
  typer_peuplements(NULL, ser = ser, configuration = configuration,
                    variables = lire_extrait(), ...)
}

test_that("couches_onf : conversions, gros bois a 47,5 cm, aucune souplesse en dur (bloc jeux)", {
  co <- couches_onf()
  expect_setequal(co$variable, c("G", "part_resineux", "part_gb", "h_dom", "couvert", "famille",
                                 "typo_etage", "N"))  # N : mission 012
  expect_false("Struc_fam.tif" %in% co$fichier)  # decision de Pascal : non utilisee
  expect_equal(co$facteur[co$variable == "part_resineux"], 0.01)
  expect_equal(co$seuil_cm[co$variable == "part_gb"], 47.5)
  expect_false("souplesse" %in% names(co))  # les valeurs viennent de la configuration (jeux)
  expect_true(all(co$jeu == "vercors_onf"))
})

test_that("lecture : un pixel du terrain tombe au bon endroit (Lambert-93, x puis y)", {
  v <- lire_extrait()
  r <- terra::rast(file.path(dossier_vercors(), "G.tif"))
  expect_equal(terra::crs(r, describe = TRUE)$code, "2154")
  # Coin nord-ouest : premiere colonne (i = 0), ligne du haut (j = 39, compte depuis le sud).
  # Centre : x = 884 355 + 13,3 m, y = 6 426 870,4 - 13,3 m. x est l'abscisse (x < y en L93).
  k <- which(v$i == 0 & v$j == 39)
  expect_length(k, 1)
  expect_equal(v$x[k], 884355 + 13.3, tolerance = 1e-6)
  expect_equal(v$y[k], 6426870.4 - 13.3, tolerance = 1e-3)
  expect_lt(v$x[k], v$y[k])
  g <- terra::extract(r, cbind(v$x[k], v$y[k]))[[1]]
  expect_equal(v$G[k], g, tolerance = 1e-6)
  # Un pixel au hasard : la part de resineux est p100GR / 100, entre 0 et 1.
  pr <- terra::rast(file.path(dossier_vercors(), "p100GR.tif"))
  m <- 777
  expect_equal(v$part_resineux[m], terra::extract(pr, cbind(v$x[m], v$y[m]))[[1]] / 100,
               tolerance = 1e-6)
  expect_true(all(v$part_resineux >= 0 & v$part_resineux <= 1, na.rm = TRUE))
  expect_true(all(v$couvert >= 0 & v$couvert <= 1, na.rm = TRUE))
})

test_that("lecture : part_pb absente et drapeau non_precomptable (Compo1 = 0, G nul ou vide)", {
  v <- lire_extrait()
  expect_true(all(is.na(v$part_pb)))
  expect_true(all(v$part_pb_absente))
  attendu <- (v$famille %in% 0) | is.na(v$G) | v$G == 0
  expect_identical(v$non_precomptable, attendu)
  expect_true(any(v$non_precomptable) && !all(v$non_precomptable))
  g <- attr(v, "gabarit")
  expect_equal(g$resolution, c(26.6, 26.6))
  expect_true(attr(v, "temps_lecture") >= 0)
})

test_that("lecture : une couche obligatoire absente arrete en la nommant", {
  co <- couches_onf()
  co$fichier[co$variable == "G"] <- "introuvable.tif"
  expect_erreur(lire_parametres_lidar(dossier_vercors(), couches = co), "introuvable.tif")
})

test_that("lecture sur une AOI sf : seuls les pixels dont le centre est dedans", {
  carre <- sf::st_sfc(sf::st_polygon(list(rbind(
    c(884500, 6426000), c(884800, 6426000), c(884800, 6426300), c(884500, 6426300),
    c(884500, 6426000)))), crs = 2154)
  v <- lire_extrait(aoi = sf::st_sf(id = 1, geometry = carre))
  expect_gt(nrow(v), 0)
  expect_lt(nrow(v), 1600)
  expect_true(all(v$x > 884500 & v$x < 884800 & v$y > 6426000 & v$y < 6426300))
  # Le gabarit reste aligne sur la grille du jeu (bords a un multiple de 26,6 m du bord d'origine).
  g <- attr(v, "gabarit")
  expect_equal(((g$xmin - 884355) / 26.6) %% 1, 0, tolerance = 1e-6)
})

test_that("variables fournies : les livrables se superposent a la grille du jeu", {
  dossier <- file.path(tempdir(), "dev_vercors")
  res <- typer_extrait(sortie = dossier)
  r_in <- terra::rast(file.path(dossier_vercors(), "G.tif"))
  types <- terra::rast(file.path(dossier, "types.tif"))
  expect_true(terra::compareGeom(r_in, types, stopOnError = FALSE))
  expect_equal(terra::crs(types, describe = TRUE)$code, "2154")
  # Un pixel du terrain : le type lu dans types.tif a ses coordonnees est celui de la carte.
  carte <- res$carte
  k <- which(!is.na(carte$type))[10]
  v <- terra::extract(types, cbind(carte$x[k], carte$y[k]))
  corr <- correspondance_types(res$cle)
  expect_equal(corr$code[v$type], carte$type[k])
  expect_equal(v$proba, carte$proba[k], tolerance = 1e-6)
  # Un pixel non precomptable n'est pas type.
  np <- which(carte$non_precomptable)[1]
  expect_true(is.na(carte$type[np]))
  expect_true(is.na(terra::extract(types, cbind(carte$x[np], carte$y[np]))$type))
})

test_that("variables fournies : confiance.tif porte niveau 0, intérim GB, part_pb absente, hp vide", {
  dossier <- file.path(tempdir(), "dev_vercors_conf")
  res <- typer_extrait(sortie = dossier)
  conf <- terra::rast(file.path(dossier, "confiance.tif"))
  expect_true(all(c("hp_incertaine", "hors_cle", "niveau_modele", "non_precomptable",
                    "part_pb_absente", "gb_interim") %in% names(conf)))
  val <- as.data.frame(conf, na.rm = FALSE)[!is.na(terra::values(conf[["niveau_modele"]])), ]
  expect_true(all(val$niveau_modele == 0))
  expect_true(all(val$hp_incertaine == 1))
  expect_true(all(val$part_pb_absente == 1))
  # Interim : leve sur tous les pixels types (47,5 cm du producteur contre 42,5 cm de la SER).
  expect_true(all(res$carte$gb_interim == !res$carte$non_precomptable))
  expect_true(all(is.na(res$carte$h_pot)))
})

test_that("variables fournies : gb_interim baisse si la SER a le meme seuil que le producteur", {
  res <- typer_extrait(ser = "exemple-vosges")  # 47,5 cm (Souchon, 2020)
  expect_false(any(res$carte$gb_interim))
  md <- paste(fiche_en_markdown(res$fiche_validation), collapse = "\n")
  expect_false(grepl("INTÉRIM", md, fixed = TRUE))
})

test_that("variables fournies : souplesses du jeu lues dans le bloc jeux de la configuration", {
  res <- typer_extrait()  # configuration d'exemple : pas de bloc jeux, rien n'est remplace
  expect_equal(res$cle$souplesse$part_resineux, 0.05)
  conf <- conf_exemple_avec_jeux('{"vercors_onf": {"source": "fiche d essai",
    "souplesse": {"part_resineux": 0.10, "part_gb": 0.11, "G": 6.7}}}')
  res <- typer_extrait(configuration = conf)
  expect_equal(res$cle$souplesse$part_resineux, 0.10)
  expect_equal(res$cle$souplesse$part_gb, 0.11)
  expect_equal(res$cle$souplesse$rapport_h, 0.05)  # non fournie : celle de la configuration
  # Declaration pour les variables que la cle utilise, pas pour G (absente de la cle).
  decl <- paste(res$fiche_validation$declarations, collapse = "\n")
  expect_match(decl, "Souplesse de part_resineux : 0,1 (fiche d essai)", fixed = TRUE)
  expect_false(grepl("Souplesse de G", decl, fixed = TRUE))
})

test_that("variables fournies : fiche sans validation, controle de coherence et declarations", {
  res <- typer_extrait()
  expect_null(res$fiche_validation$placette)
  md <- paste(fiche_en_markdown(res$fiche_validation), collapse = "\n")
  expect_match(md, "pas de validation", fixed = TRUE)
  expect_match(md, "pas une validation", fixed = TRUE)
  expect_match(md, "Typo_etage", fixed = TRUE)
  expect_match(md, "INTÉRIM", fixed = TRUE)
  expect_match(md, "47,5 cm", fixed = TRUE)
  expect_match(md, "part_pb absente", fixed = TRUE)
  expect_true(res$fiche_validation$controle$v_cramer >= 0 &&
                res$fiche_validation$controle$v_cramer <= 1)
  expect_match(paste(utils::capture.output(print(res)), collapse = "\n"), "pas de validation")
})

test_that("variables fournies : temps par etage consignes dans temps_etages.csv", {
  dossier <- file.path(tempdir(), "dev_vercors_temps")
  typer_extrait(sortie = dossier)
  t <- utils::read.csv(file.path(dossier, "temps_etages.csv"))
  expect_identical(t$etage, c("lecture", "hauteur_potentielle", "cle", "lissage", "decision",
                              "controle", "ecriture_rasters", "ecriture_tables"))
  expect_true(all(t$secondes >= 0))
  expect_equal(t$pixels[1], nrow(lire_extrait()))
})

test_that("variables fournies : une cle vide arrete (pas de carte sans typologie sourcee)", {
  expect_erreur(typer_extrait(ser = "H10", configuration = conf_json_vide()),
                "clé de types vide")
})

test_that("variables fournies : une AOI sf ne garde que ses pixels, attributs compris", {
  carre <- sf::st_sfc(sf::st_polygon(list(rbind(
    c(884500, 6426000), c(884800, 6426000), c(884800, 6426300), c(884500, 6426300),
    c(884500, 6426000)))), crs = 2154)
  res <- typer_peuplements(sf::st_sf(id = 1, geometry = carre), ser = SER_EXEMPLE,
                           configuration = chemin_config_exemple(), variables = lire_extrait())
  expect_true(all(res$carte$x > 884500 & res$carte$x < 884800))
  expect_false(is.null(res$gabarit))
  expect_identical(res$temps$etage[1], "lecture")
})

test_that("variables fournies avec milieu : la hauteur potentielle est apprise et utilisee", {
  px <- pixels_fixture()
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  vars <- data.frame(i = px$i, j = px$j, h_dom = px$h_dom, couvert = px$couvert,
                     famille = px$famille, G = 25, part_resineux = 0.8, part_pb = 0.6,
                     part_gb = 0.1)
  res <- executer_chaine_fournie(vars, conf, milieu = px[, conf$variables_milieu])
  expect_false(all(res$carte$hp_incertaine))
  expect_true(all(res$carte$type %in% c("R-PB-J", "R-PB-C")))
  expect_false(any(res$carte$part_pb_absente))
  expect_false(any(res$carte$gb_interim))  # pas de table de branchement : pas de seuil producteur
  expect_erreur(executer_chaine_fournie(vars, conf, milieu = px[1:5, conf$variables_milieu]),
                "une ligne par ligne")
})

test_that("controle_coherence : V de Cramer 1 en lien parfait, 0 en independance", {
  parfait <- controle_coherence(rep(c("A", "B"), each = 10), rep(c(1, 2), each = 10))
  expect_equal(parfait$v_cramer, 1)
  indep <- controle_coherence(rep(c("A", "B"), 10), rep(c(1, 1, 2, 2), 5))
  expect_equal(indep$v_cramer, 0)
  ecarte <- controle_coherence(c("A", "B", NA, "A"), c(1, 0, 2, 2), exclure = 0)
  expect_equal(ecarte$n, 2L)
  expect_true(is.na(ecarte$v_cramer))  # une seule ligne : non defini
})

test_that("decider_type vectorise : meme resultat que le tri ligne a ligne, egalites comprises", {
  p <- matrix(c(0.4, 0.4, 0.2,
                0.1, 0.3, 0.6,
                0.3, 0.3, 0.4,
                0.5, 0.25, 0.25), ncol = 3, byrow = TRUE,
              dimnames = list(NULL, c("A", "B", "C")))
  d <- decider_type(as.data.frame(p))
  ordre <- t(apply(p, 1, function(r) order(-r)))
  expect_identical(d$type, colnames(p)[ordre[, 1]])
  expect_identical(d$type_second, colnames(p)[ordre[, 2]])
  expect_identical(d$type, c("A", "C", "C", "A"))
  expect_identical(d$type_second, c("B", "B", "A", "B"))
})

test_that("mineurs de 003 : man en UTF-8, ranger avec min.bucket, depot de nemeton", {
  racine <- normalizePath(testthat::test_path("..", ".."))
  rd <- readLines(file.path(racine, "man", "typopeuplement-package.Rd"), encoding = "UTF-8")
  expect_false(any(grepl("<U+", rd, fixed = TRUE)))
  desc <- read.dcf(file.path(racine, "DESCRIPTION"))
  expect_match(desc[, "Imports"], "ranger (>= 0.15.0)", fixed = TRUE)
  expect_match(desc[, "Remotes"], "pobsteta/nemeton", fixed = TRUE)
})

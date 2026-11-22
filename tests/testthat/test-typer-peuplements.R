# Point d'entree typer_peuplements(), livrables (critere 8 en passant) et demonstration.
# Equivalents R de test_cli_demo. Fonctions : typer_peuplements, ecrire_livrables, lancer_demo
# (plan 003, section 2). Ce qui est en stub dans le plan est teste comme tel : arret net, message dit.
# Suppose : `configuration` est le chemin d'un JSON de configuration (comme lire_configuration) ;
# les noms de couches des rasters reprennent les colonnes de la carte (a confirmer a 003).

resultat_typer <- function(...) {
  typer_peuplements(
    aoi = pixels_fixture(), placettes = placettes_fixture(), ser = SER_EXEMPLE,
    configuration = chemin_config_exemple(), graine = 0, ...
  )
}

test_that("typer_peuplements sur un data.frame de pixels rend un objet typo_resultat complet", {
  res <- resultat_typer()
  expect_s3_class(res, "typo_resultat")
  attendus <- c("carte", "fiche_validation", "erreurs_variables", "rmse_hauteur_potentielle",
                "types_observes", "niveau_modele")
  expect_true(all(attendus %in% names(res)))
  expect_equal(nrow(res$carte), 900L)
  expect_true(res$niveau_modele %in% c("ser", "grande_region"))
})

test_that("typer_peuplements : sans placettes, arret net (modeles de grande region indisponibles)", {
  # Stub dit par le plan 003 : le vert ne prouve rien sur les modeles de grande region, seulement l'arret.
  expect_erreur(
    typer_peuplements(aoi = pixels_fixture(), placettes = NULL, ser = SER_EXEMPLE,
                      configuration = chemin_config_exemple()),
    "mod\u00e8les de grande r\u00e9gion indisponibles"
  )
})

test_that("typer_peuplements : un data.frame sans SER est refuse (la SER ne se devine pas)", {
  expect_erreur(
    typer_peuplements(aoi = pixels_fixture(), placettes = placettes_fixture(), ser = NULL,
                      configuration = chemin_config_exemple()),
    "ser|SER"
  )
})

test_that("typer_peuplements : une AOI en sf localise la SER par nemeton puis s'arrete (lecture des donnees ouvertes non ecrite)", {
  skip_if_not_installed("nemeton")
  # Critere 5/9 et plan 003, section 2. Carre de 1 km en Lambert-93 pres de Grenoble (x, y en m : x < y,
  # pour ne pas inverser les axes comme une latitude/longitude).
  carre <- sf::st_sfc(
    sf::st_polygon(list(rbind(c(914000, 6457000), c(915000, 6457000), c(915000, 6458000),
                              c(914000, 6458000), c(914000, 6457000)))),
    crs = 2154
  )
  aoi <- sf::st_sf(id = 1, geometry = carre)
  expect_erreur(
    typer_peuplements(aoi = aoi, placettes = placettes_fixture(), ser = NULL,
                      configuration = chemin_config_exemple()),
    "lecture des donn\u00e9es ouvertes non \u00e9crite"
  )
})

test_that("localiser_ser de nemeton : un point en Savoie tombe dans une SER des Alpes (jamais en Somalie)", {
  skip_if_not_installed("nemeton")
  # Regle de test du projet : un point du terrain doit tomber au bon endroit. Point en Lambert-93 (m),
  # Chambery environ (x 925 000, y 6 505 000). La GRECO attendue est H (Alpes), la premiere lettre du code.
  pt <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(925000, 6505000)), crs = 2154))
  ser <- nemeton::localiser_ser(pt)
  code <- as.character(unlist(ser)[1])
  expect_true(code %in% utils::read.csv(chemin_ser_codes(), comment.char = "#")$code_ser)
  expect_identical(unname(greco_de_ser(code)), "H")
})

test_that("ecrire_livrables : les six fichiers de la spec, lisibles par terra et sf (critere 8)", {
  res <- resultat_chaine()
  dossier <- file.path(tempdir(), "livrables")
  ecrire_livrables(res, dossier, taille_pixel = 25, crs = "EPSG:2154")
  for (f in c("types.tif", "variables.tif", "confiance.tif", "fiche_validation.md",
              "carte_types.csv", "correspondance_types.csv")) {
    expect_true(file.exists(file.path(dossier, f)), info = f)
  }
  for (f in c("types.tif", "variables.tif", "confiance.tif")) {
    r <- terra::rast(file.path(dossier, f))
    expect_equal(c(terra::nrow(r), terra::ncol(r)), c(30L, 30L), info = f)
    expect_equal(terra::res(r), c(25, 25), info = f)
    expect_equal(terra::crs(r, describe = TRUE)$code, "2154", info = f)
  }
})

test_that("ecrire_livrables : couches de types.tif, variables.tif et confiance.tif (spec, section Livrables)", {
  res <- resultat_chaine()
  dossier <- file.path(tempdir(), "livrables2")
  ecrire_livrables(res, dossier)
  n_types <- names(terra::rast(file.path(dossier, "types.tif")))
  n_var <- names(terra::rast(file.path(dossier, "variables.tif")))
  n_conf <- names(terra::rast(file.path(dossier, "confiance.tif")))
  # types.tif : code du type, probabilite, second type, drapeau « entre deux types ».
  expect_true(all(c("type", "proba", "type_second", "entre_deux") %in% n_types))
  # variables.tif : G, parts, hauteur dominante, hauteur potentielle et son incertitude, rapport.
  expect_true(all(c("G", "part_resineux", "part_pb", "part_bm", "part_gb", "h_dom", "h_pot", "h_pot_sd",
                    "rapport_h") %in% n_var))
  # confiance.tif : hauteur potentielle incertaine, niveau du modele (plan, reponse 7). Les zones sans
  # donnee (ZICAD, hors LiDAR) ne sont pas testees : le jeu synthetique n'en a pas.
  expect_true(all(c("hp_incertaine", "niveau_modele") %in% n_conf))
})

test_that("ecrire_livrables : carte_types.csv et table de correspondance, codes de la cle seulement", {
  res <- resultat_chaine()
  dossier <- file.path(tempdir(), "livrables3")
  ecrire_livrables(res, dossier)
  carte <- utils::read.csv(file.path(dossier, "carte_types.csv"), encoding = "UTF-8")
  expect_equal(nrow(carte), 900L)
  expect_true(all(c("type", "proba", "entre_deux", "hp_incertaine") %in% names(carte)))
  corr <- utils::read.csv(file.path(dossier, "correspondance_types.csv"), encoding = "UTF-8")
  expect_equal(nrow(corr), 6L)
  # Les noms de colonnes de la table ne sont pas fixes par le plan : on verifie que tous les codes de la
  # cle d'exemple y figurent, et eux seuls comme codes.
  expect_true(all(CODES_EXEMPLE %in% unlist(corr)))
  # fiche : texte de la fiche de validation.
  md <- paste(readLines(file.path(dossier, "fiche_validation.md"), encoding = "UTF-8"), collapse = "\n")
  expect_match(md, "Fiche de validation", fixed = TRUE)
})

test_that("typer_peuplements avec `sortie` ecrit les livrables dans ce dossier", {
  dossier <- file.path(tempdir(), "via_typer")
  resultat_typer(sortie = dossier)
  expect_true(all(file.exists(file.path(dossier, c("types.tif", "fiche_validation.md")))))
})

test_that("lancer_demo : chaine sur donnees synthetiques, livrables et resume a la console", {
  dossier <- file.path(tempdir(), "demo")
  sortie <- utils::capture.output(
    withCallingHandlers(
      lancer_demo(dossier, chemin_config_exemple(), SER_EXEMPLE, graine = 0),
      message = function(m) {
        cat(conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    )
  )
  expect_true(file.exists(file.path(dossier, "carte_types.csv")))
  md <- paste(readLines(file.path(dossier, "fiche_validation.md"), encoding = "UTF-8"), collapse = "\n")
  expect_match(md, "Fiche de validation", fixed = TRUE)
  # Resume du prototype : « précision à la grappe » (la casse et la mise en forme du chiffre sont libres).
  expect_match(paste(sortie, collapse = "\n"), "pr\u00e9cision \u00e0 la grappe", ignore.case = TRUE)
})

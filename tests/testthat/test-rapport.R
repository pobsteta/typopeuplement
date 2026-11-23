# Tests de la mission 015 : rapport Quarto de l'AOI, etat de preuve, limites, pipeline targets.

livrables_rapport <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      cache <<- file.path(tempdir(), "livrables_rapport")
      ecrire_livrables(resultat_chaine(), cache)
    }
    cache
  }
})

copie_livrables <- function() {
  d <- tempfile("livr_")
  dir.create(d)
  file.copy(list.files(livrables_rapport(), full.names = TRUE), d)
  d
}

# Reecrit un raster lu sur disque : on passe par un fichier temporaire (source et cible distinctes).
ajouter_ecrire <- function(r, chemin) {
  tmp <- tempfile(fileext = ".tif")
  terra::writeRaster(r, tmp)
  terra::tmpFiles(remove = TRUE)
  file.copy(tmp, chemin, overwrite = TRUE)
}

quarto_ok <- function() {
  skip_on_cran()
  skip_if_not_installed("quarto")
  skip_if(is.null(quarto::quarto_path()), "Quarto absent")
}

test_that("etat de preuve : statuts permis, pas de validation independante, pas de 'probabilite' calibree", {
  ep <- etat_de_preuve(livrables_rapport())
  expect_named(ep, c("chiffre", "statut", "commentaire"))
  expect_true(all(ep$statut %in% c("mesuré", "provisoire", "non vérifié")))
  v <- ep[grepl("Validation indépendante", ep$chiffre), ]
  expect_equal(nrow(v), 1L)
  expect_equal(v$statut, "non vérifié")
  expect_match(v$commentaire, "aucune placette publiée dans H10")
  # Le nombre du type est une appartenance, non calibree (C12) : jamais une probabilite affirmee.
  app <- ep[ep$chiffre == "Appartenance au type", ]
  expect_equal(app$statut, "provisoire")
  expect_match(app$commentaire, "pas une probabilité")
})

test_that("etat de preuve : en demonstration, tout est non verifie ; sans demo, la precision d'une fiche sans placette l'est aussi", {
  ep <- etat_de_preuve(livrables_rapport(), demo = TRUE)
  expect_equal(ep$statut[ep$chiffre == "Tous les chiffres de ce rapport"], "non vérifié")
  d <- copie_livrables()
  writeLines(c("# Fiche", "Mode « variables fournies » : sans placettes, **pas de validation**."),
             file.path(d, "fiche_validation.md"), useBytes = TRUE)
  ep2 <- etat_de_preuve(d)
  expect_equal(ep2$statut[ep2$chiffre == "Précision et kappa"], "non vérifié")
  expect_match(ep2$commentaire[ep2$chiffre == "Précision et kappa"], "pas de kappa")
})

test_that("parts de types : comptage fidele a la carte, position du pixel comprise", {
  res <- resultat_chaine()
  leg <- typopeuplement:::legendes_livrables(livrables_rapport())
  expect_equal(leg$id, "types")
  p <- typopeuplement:::parts_types(leg$raster, leg$table)
  attendu <- table(factor(res$carte$type, levels = p$code))
  expect_equal(p$pixels, as.numeric(attendu), ignore_attr = TRUE)
  expect_equal(sum(p$part), 1, tolerance = 1e-12)
  # Pixel (i = 3, j = 7) : centre x = 75 m, y = 175 m (Lambert-93, x est, y nord).
  types <- terra::rast(file.path(livrables_rapport(), "types.tif"))
  k <- which(res$carte$i == 3 & res$carte$j == 7)
  corr <- correspondance_types(res$cle, c(res$carte$type, res$carte$type_second))
  expect_equal(corr$code[terra::extract(types, cbind(75, 175))$type], res$carte$type[k])
})

test_that("drapeaux : la part d'entre-deux du rapport est celle de la carte", {
  res <- resultat_chaine()
  dr <- typopeuplement:::resume_drapeaux(livrables_rapport())
  expect_equal(dr$part[dr$couche == "entre_deux"], mean(res$carte$entre_deux), tolerance = 1e-12)
  expect_true(all(c("hp_incertaine", "hors_cle") %in% dr$couche))
})

test_that("legendes : types_srgs.tif, s'il est present, passe en premier (SRGS, puis GSM)", {
  d <- copie_livrables()
  expect_equal(typopeuplement:::legendes_livrables(d)$id, "types")
  file.copy(file.path(d, "types.tif"), file.path(d, "types_srgs.tif"))
  file.copy(file.path(d, "correspondance_types.csv"), file.path(d, "correspondance_types_srgs.csv"))
  leg <- typopeuplement:::legendes_livrables(d)
  expect_equal(leg$id, c("srgs", "types"))
  expect_match(leg$titre[1], "SRGS")
  tab <- tables_rapport(d, file.path(d, "t"))
  expect_true(all(c("parts_srgs.csv", "parts_types.csv") %in% basename(tab)))
})

test_that("limites : phrase sans validation, drapeaux, houppiers, strates basses, types non exprimables", {
  lim <- limites_rapport(livrables_rapport())
  expect_true(any(grepl("Pas de validation indépendante", lim)))
  expect_true(any(grepl("^Entre deux types", lim)))
  expect_false(any(grepl("Houppiers", lim)))
  d <- copie_livrables()
  v <- terra::rast(file.path(d, "variables.tif"))
  v$densite_houppiers <- v[[1]] * 0 + 120
  ajouter_ecrire(v, file.path(d, "variables.tif"))
  conf <- terra::rast(file.path(d, "confiance.tif"))
  conf$strates_basses_estimees <- conf[[1]] * 0 + 1
  ajouter_ecrire(conf, file.path(d, "confiance.tif"))
  writeLines(c("# Journal", "- 013 : fenêtre de segmentation 3 m, provisoire"),
             file.path(d, "journal_aoi.md"), useBytes = TRUE)
  srgs <- normalizePath(testthat::test_path("..", "..", "inst", "extdata", "config", "srgs-aura.json"))
  lim <- limites_rapport(d, configuration = srgs, ser = "H10")
  expect_true(any(grepl("^Houppiers", lim)))
  expect_true(any(grepl("100,0 % des pixels ont des strates basses", lim)))
  expect_true(any(grepl("^Journal : 013", lim)))
  expect_true(any(grepl("non exprimables.*MFT", lim)))
})

test_that("rendu : le rapport de demonstration se rend sans reseau et dit 'non validee' et 'appartenance'", {
  quarto_ok()
  d <- copie_livrables()
  avant <- tools::md5sum(list.files(d, full.names = TRUE))
  html <- rendre_rapport(d, sortie = file.path(d, "rapport"), demo = TRUE, titre_aoi = "Test",
                         etiquette_types = "Type (clé d'exemple)")
  expect_true(file.exists(html))
  txt <- paste(readLines(html, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  expect_match(txt, "non validée")
  expect_match(txt, "appartenance", ignore.case = TRUE)
  expect_match(txt, "État de preuve")
  expect_match(txt, "Limites")
  # Mode reel : les livrables lus ne sont jamais modifies.
  apres <- tools::md5sum(names(avant))
  expect_equal(unname(apres), unname(avant))
})

test_that("rendu : livrables absents = erreur claire", {
  skip_if_not_installed("quarto")
  skip_if(is.null(quarto::quarto_path()), "Quarto absent")
  expect_erreur(rendre_rapport(tempfile("vide_"), sortie = tempfile()), "Livrables absents")
})

test_that("pipeline : le rapport se refait quand son modele change (tar_outdated)", {
  quarto_ok()
  skip_if_not_installed("targets")
  racine <- tempfile("projet_")
  dir.create(racine)
  modele <- file.path(racine, "rapport.qmd")
  file.copy(modele_rapport(), modele)
  sortie <- file.path(racine, "sortie")
  script <- file.path(racine, "_targets.R")
  store <- file.path(racine, "store")
  writeLines(c(
    "library(targets)",
    sprintf("typopeuplement::cibles_rapport(sortie = %s, modele = %s)",
            deparse(sortie), deparse(modele))), script)
  outdated <- function() targets::tar_outdated(script = script, store = store, callr_function = NULL)
  make <- function() targets::tar_make(script = script, store = store, callr_function = NULL,
                                       reporter = "silent")
  suppressMessages(make())
  expect_true(file.exists(file.path(sortie, "rapport.html")))
  expect_length(outdated(), 0)
  # Un changement du modele rend `rapport` perime, et lui seul (pas les livrables).
  cat("\n<!-- modele modifie -->\n", file = modele, append = TRUE)
  expect_equal(sort(outdated()), c("modele", "rapport"))
  suppressMessages(make())
  expect_length(outdated(), 0)
})

test_that("pipeline : en mode reel, les livrables sont suivis, jamais recalcules", {
  skip_if_not_installed("targets")
  d <- copie_livrables()
  cibles <- cibles_rapport(aoi = d, sortie = tempfile("s_"))
  noms <- vapply(cibles, function(x) x$settings$name, "")
  expect_equal(noms, c("modele", "livrables", "rapport"))
  cmd <- paste(deparse(cibles[[2]]$command$expr), collapse = " ")
  expect_false(grepl("lancer_demo|executer_chaine", cmd))
})

# Point d'entrée, livrables et démonstration (cli.py du prototype).

#' Typer les peuplements d'une emprise
#'
#' Point d'entrée de la chaîne : produit la carte du type de peuplement d'une emprise
#' (AOI), sa couche de confiance et la fiche de validation de la SER.
#'
#' Ce qui tourne aujourd'hui : `aoi` est un data.frame de pixels déjà préparés (les
#' colonnes décrites dans [executer_chaine()]), avec `placettes` et `ser` donnés.
#'
#' Ce qui reste en attente (arrêt net, message dit) :
#' - `aoi` en `sf` ou chemin de GeoPackage : la SER est localisée par
#'   `nemeton::localiser_ser()` (nemeton en Suggests), puis arrêt : la lecture des
#'   données ouvertes (LiDAR HD, Sentinel-2, BD Forêt v3, climat, sol) n'est pas écrite ;
#' - `placettes = NULL` : arrêt, les modèles de grande région ne sont pas disponibles ;
#' - `ser = NULL` avec un data.frame : arrêt, la SER ne se devine pas.
#'
#' La typologie est descriptive : la carte aide à décider, elle ne remplace pas le
#' diagnostic de terrain. Vérifier en priorité les pixels « entre deux types ».
#'
#' @param aoi Emprise : data.frame de pixels préparés, objet `sf` ou chemin de GeoPackage
#'   (Lambert-93).
#' @param placettes data.frame des placettes de calibration (voir [executer_chaine()]).
#' @param ser Nom de la SER dans la configuration.
#' @param configuration Chemin du fichier JSON de configuration ([lire_configuration()]).
#' @param sortie Dossier où écrire les livrables ([ecrire_livrables()]) ; `NULL` : rien
#'   n'est écrit.
#' @param graine Graine du hasard ; remplace celle de la configuration.
#'
#' @return Objet `typo_resultat` (voir [executer_chaine()]), invisible si `sortie` est donné.
#' @examples
#' \donttest{
#' jeu <- generer_jeu_synthetique(30, 30, 200, graine = 1)
#' chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
#' res <- typer_peuplements(jeu$pixels, jeu$placettes, "exemple-alpes-du-nord", chemin)
#' res
#' }
#' @export
typer_peuplements <- function(aoi, placettes = NULL, ser = NULL, configuration, sortie = NULL,
                              graine = 0) {
  if (is.character(aoi) || inherits(aoi, "sf")) {
    if (is.character(aoi)) aoi <- sf::st_read(aoi, quiet = TRUE)
    if (is.null(ser)) ser <- localiser_ser_aoi(aoi)
    arreter(sprintf(paste0("SER %s : lecture des donn\u00e9es ouvertes non \u00e9crite ",
                        "(LiDAR HD, Sentinel-2, BD For\u00eat, climat, sol) ; ",
                        "fournir un data.frame de pixels pr\u00e9par\u00e9s"), ser))
  }
  if (!is.data.frame(aoi)) {
    arreter("aoi doit \u00eatre un data.frame de pixels, un objet sf ou un chemin de GeoPackage")
  }
  if (is.null(ser)) {
    arreter("SER non donn\u00e9e : avec un data.frame de pixels, la SER ne se devine pas")
  }
  if (is.null(placettes)) {
    arreter(paste0("placettes absentes : mod\u00e8les de grande r\u00e9gion indisponibles ",
                "(calibration nationale ou par GRECO non \u00e9crite)"))
  }
  conf <- lire_configuration(configuration, ser)
  conf$graine <- graine
  res <- executer_chaine(placettes, aoi, conf)
  if (!is.null(sortie)) {
    ecrire_livrables(res, sortie)
    return(invisible(res))
  }
  res
}

# SER majoritaire d'une AOI, par nemeton::localiser_ser() (plus grande intersection).
localiser_ser_aoi <- function(aoi) {
  if (!requireNamespace("nemeton", quietly = TRUE)) {
    arreter("nemeton n'est pas install\u00e9 : la SER de l'AOI ne peut pas \u00eatre localis\u00e9e ; donner `ser`")
  }
  loc <- nemeton::localiser_ser(aoi)
  codes <- stats::na.omit(as.character(loc$ser))
  if (length(codes) == 0) arreter("AOI hors de toute SER")
  names(sort(table(codes), decreasing = TRUE))[1]
}

# Coordonnées des centres de pixels : colonnes x, y de la carte si elles existent ; sinon
# x = i * taille_pixel, y = j * taille_pixel (convention du jeu synthétique).
centres_pixels <- function(carte, taille_pixel) {
  if (all(c("x", "y") %in% names(carte))) return(cbind(as.numeric(carte$x), as.numeric(carte$y)))
  cbind(as.numeric(carte$i) * taille_pixel, as.numeric(carte$j) * taille_pixel)
}

# Raster multicouche à partir de colonnes numériques de la carte.
raster_couches <- function(xy, valeurs, taille_pixel, crs) {
  demi <- taille_pixel / 2
  r <- terra::rast(
    xmin = min(xy[, 1]) - demi, xmax = max(xy[, 1]) + demi,
    ymin = min(xy[, 2]) - demi, ymax = max(xy[, 2]) + demi,
    resolution = taille_pixel, crs = crs, nlyrs = ncol(valeurs)
  )
  cellules <- terra::cellFromXY(r, xy)
  m <- matrix(NA_real_, terra::ncell(r), ncol(valeurs))
  m[cellules, ] <- as.matrix(valeurs)
  terra::values(r) <- m
  names(r) <- colnames(valeurs)
  r
}

#' Table de correspondance des types
#'
#' Valeur entière de chaque type dans `types.tif`, son code et son libellé dans la clé de
#' la SER.
#'
#' @param cle La clé d'une SER (`lire_configuration(...)$cle`).
#' @return data.frame : `valeur`, `code`, `libelle`.
#' @export
correspondance_types <- function(cle) {
  codes <- codes_cle(cle)
  data.frame(valeur = seq_along(codes), code = codes, libelle = libelles_cle(cle),
             stringsAsFactors = FALSE)
}

#' Écrire les livrables d'une emprise
#'
#' Écrit dans `dossier` :
#' - `types.tif` : `type` (valeur entière, voir la table de correspondance), `proba`,
#'   `type_second`, `entre_deux` (0 ou 1) ;
#' - `variables.tif` : `G`, `part_resineux`, `part_pb`, `part_bm`, `part_gb`, `h_dom`,
#'   `h_pot`, `h_pot_sd`, `rapport_h` ;
#' - `confiance.tif` : `hp_incertaine`, `hors_cle` (0 ou 1), `niveau_modele` (1 : SER,
#'   2 : grande région) ;
#' - `fiche_validation.md` ; `carte_types.csv` (la carte, une ligne par pixel) ;
#' - `correspondance_types.csv` (`valeur`, `code`, `libelle`).
#'
#' Les rasters sont des GeoTIFF : ils s'ouvrent dans QGIS et dans R (terra) sans
#' conversion. Les zones sans donnée (ZICAD, hors LiDAR) ne sont pas encore portées par
#' `confiance.tif` : la lecture des données ouvertes n'est pas écrite.
#'
#' @param resultat Objet `typo_resultat` ([typer_peuplements()], [executer_chaine()]).
#' @param dossier Dossier de sortie (créé au besoin).
#' @param taille_pixel Côté des pixels, en m. **Provisoire** : 25.
#' @param crs Système de coordonnées. Lambert-93 (`"EPSG:2154"`) par défaut.
#' @return Le chemin du dossier, invisible.
#' @export
ecrire_livrables <- function(resultat, dossier, taille_pixel = 25, crs = "EPSG:2154") {
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  carte <- resultat$carte
  corr <- correspondance_types(resultat$cle)
  xy <- centres_pixels(carte, taille_pixel)

  types <- data.frame(
    type = match(carte$type, corr$code),
    proba = carte$proba,
    type_second = match(carte$type_second, corr$code),
    entre_deux = as.numeric(carte$entre_deux)
  )
  noms_var <- c("G", "part_resineux", "part_pb", "part_bm", "part_gb", "h_dom", "h_pot",
                "h_pot_sd", "rapport_h")
  variables <- carte[, intersect(noms_var, names(carte)), drop = FALSE]
  confiance <- data.frame(
    hp_incertaine = as.numeric(carte$hp_incertaine),
    hors_cle = as.numeric(carte$hors_cle),
    niveau_modele = rep(if (identical(resultat$niveau_modele, "ser")) 1 else 2, nrow(carte))
  )
  couches <- list(types.tif = types, variables.tif = variables, confiance.tif = confiance)
  for (f in names(couches)) {
    r <- raster_couches(xy, couches[[f]], taille_pixel, crs)
    terra::writeRaster(r, file.path(dossier, f), overwrite = TRUE)
  }
  ecrire_lignes_utf8(fiche_en_markdown(resultat$fiche_validation),
                     file.path(dossier, "fiche_validation.md"))
  ecrire_csv_utf8(carte, file.path(dossier, "carte_types.csv"))
  ecrire_csv_utf8(corr, file.path(dossier, "correspondance_types.csv"))
  invisible(dossier)
}

#' Lancer la démonstration
#'
#' Fait tourner la chaîne sur un jeu synthétique ([generer_jeu_synthetique()]), écrit les
#' livrables dans `sortie` et affiche un résumé (précision et kappa à la placette et à la
#' grappe, part des pixels entre deux types, part de hauteur potentielle incertaine).
#' Le jeu n'imite aucune forêt réelle et la clé est celle de l'exemple.
#'
#' @param sortie Dossier des livrables.
#' @param configuration Chemin du JSON de configuration ; par défaut l'exemple du package.
#' @param ser Nom de la SER dans la configuration.
#' @param graine Graine du hasard (jeu synthétique et modèles).
#' @return Objet `typo_resultat`, invisible.
#' @examples
#' \donttest{
#' lancer_demo(file.path(tempdir(), "demo"))
#' }
#' @export
lancer_demo <- function(sortie = file.path(tempdir(), "typopeuplement_demo"),
                        configuration = system.file("extdata", "config", "exemple.json",
                                                    package = "typopeuplement"),
                        ser = "exemple-alpes-du-nord", graine = 0) {
  conf <- lire_configuration(configuration, ser)
  conf$graine <- graine
  jeu <- generer_jeu_synthetique(graine = graine)
  res <- executer_chaine(jeu$placettes, jeu$pixels, conf)
  ecrire_livrables(res, sortie)
  message(paste(c(resume_resultat(res), paste0("  livrables : ", sortie)), collapse = "\n"))
  invisible(res)
}

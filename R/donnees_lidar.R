# Lecture des paramètres forestiers LiDAR d'un producteur (mission 006).
#
# Mode « variables fournies » : les variables de la clé viennent déjà calculées par le
# producteur (ONF, jeu « Paramètres forestiers LiDAR – Vercors drômois 2021-2022 »,
# rasters de 26,6 m en Lambert-93). On saute l'ajustement dendrométrique.

#' Couches du jeu ONF « Paramètres forestiers LiDAR » et leur branchement
#'
#' Table de branchement des rasters du producteur sur les variables de la chaîne
#' (fiche synthétique du jeu Vercors drômois, A. Hedel, ONF, 25/09/2024, p. 4) :
#'
#' | fichier | variable | conversion |
#' |---|---|---|
#' | `G.tif` | `G` (m²/ha) | aucune |
#' | `p100GR.tif` | `part_resineux` (0 à 1) | ÷ 100 |
#' | `p100GGB.tif` | `part_gb` (0 à 1) | ÷ 100 |
#' | `H0_lidar.tif` | `h_dom` (m) | aucune ; hauteur brute, **non calibrée** (p. 2) |
#' | `Tx_couv.tif` | `couvert` (0 à 1) | ÷ 100 |
#' | `Compo1.tif` | `famille` (0 non précomptable, 1 feuillus, 2 résineux, 3 mélange) | aucune |
#' | `Typo_etage.tif` | `typo_etage` (0 non précomptable, 1 non étagé, 2 faiblement étagé, 3 étagé) | aucune ; contrôle de cohérence seulement |
#' | `N.tif` | `N` (tiges/ha) | aucune ; facultative |
#'
#' `N` est la densité prédite par l'ONF, en tiges par hectare (fiche p. 1 : placettes
#' de calibration, N de 14,2 à 947,9, moyenne 374,4 ; p. 2 : biais en « t/ha »). Les
#' placettes ont un diamètre précomptable de 17,5 cm (p. 1) : `N` compte donc, selon
#' toute vraisemblance (la fiche ne le dit pas en toutes lettres), les tiges
#' précomptables (colonne `seuil_cm`). Le seuil de 800 tiges/ha du GSM (types L et R)
#' vise une régénération, qui n'y serait pas. Couche facultative : sans
#' `N.tif`, la colonne manque et une clé qui la cite la neutralise.
#'
#' `Struc_fam` n'est pas utilisée (décision de Pascal, plan 006). `part_pb` n'existe pas
#' dans le jeu : elle reste vide et le drapeau `part_pb_absente` est levé.
#'
#' **Gros bois : intérim déclaré.** La part de gros bois du producteur est calculée à
#' 47,5 cm (fiche, p. 1 : « GB : 47.5 ≤ Ø < 62.5 cm ») alors que la limite retenue pour
#' H10 est 42,5 cm (Pascal, 2026-11-22). La colonne `seuil_cm` porte 47,5 pour
#' `part_gb` ; la chaîne lève le drapeau `gb_interim` quand ce seuil diffère de celui de
#' la configuration.
#'
#' **Souplesses : dans la configuration, pas ici.** Les souplesses du jeu (erreurs du
#' producteur, fiche p. 3) ne sont plus portées par cette table : elles se déclarent dans
#' le bloc `jeux.vercors_onf.souplesse` de la configuration ([lire_configuration()]), que
#' la chaîne applique quand les variables viennent de ce jeu (colonne `jeu`). Elles ne
#' sont pas des paramètres de la SER : elles disent l'erreur de ce jeu. Les valeurs
#' (EQM de la fiche ONF, p. 1) viennent de la mission 010.
#'
#' @return data.frame : `fichier`, `variable`, `facteur` (multiplicateur), `obligatoire`,
#'   `seuil_cm` (seuil de diamètre du producteur, `NA` sinon), `jeu` (nom du jeu dans le
#'   bloc `jeux` de la configuration : `"vercors_onf"`), `source`.
#' @seealso [lire_parametres_lidar()]
#' @export
couches_onf <- function() {
  fiche <- "fiche ONF Vercors dr\u00f4mois (A. Hedel, 25/09/2024)"
  data.frame(
    fichier = c("G.tif", "p100GR.tif", "p100GGB.tif", "H0_lidar.tif", "Tx_couv.tif",
                "Compo1.tif", "Typo_etage.tif", "N.tif"),
    variable = c("G", "part_resineux", "part_gb", "h_dom", "couvert", "famille", "typo_etage", "N"),
    facteur = c(1, 0.01, 0.01, 1, 0.01, 1, 1, 1),
    obligatoire = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE),
    seuil_cm = c(NA, NA, 47.5, NA, NA, NA, NA, 17.5),
    jeu = "vercors_onf",
    source = c(
      paste0(fiche, ", p. 4 : surface terri\u00e8re en m\u00b2/ha"),
      paste0(fiche, ", p. 4 : part de r\u00e9sineux en %"),
      paste0(fiche, ", p. 1 : GB \u00e0 47,5 cm ; p. 4 : part de gros bois en %"),
      paste0(fiche, ", p. 2 : hauteur dominante brute, non calibr\u00e9e"),
      paste0(fiche, ", p. 4 : taux de couvert en %"),
      paste0(fiche, ", p. 4 : 0 non pr\u00e9comptable, 1 feuillus, 2 r\u00e9sineux, 3 m\u00e9lange"),
      paste0(fiche, ", p. 4 : \u00e9tagement, contr\u00f4le de coh\u00e9rence seulement"),
      paste0(fiche, ", p. 1-2 : densit\u00e9 en tiges/ha (placettes \u00e0 \u00d8 pr\u00e9comptable 17,5 cm)")
    ),
    stringsAsFactors = FALSE
  )
}

#' Lire les paramètres forestiers LiDAR d'un producteur sur une emprise
#'
#' Lit les rasters du producteur (par défaut ceux de l'ONF, [couches_onf()]), les découpe
#' sur l'emprise `aoi` et rend un data.frame de pixels prêt pour
#' `typer_peuplements(variables = ...)`.
#'
#' Sont retenus les pixels où au moins une couche a une valeur. Le drapeau
#' `non_precomptable` est levé là où `famille` vaut 0, ou `G` vaut 0 ou est vide : ces
#' pixels ne sont pas typés.
#'
#' Coordonnées : `x`, `y` sont les centres des pixels, en m, dans le système des rasters
#' (Lambert-93, EPSG:2154, pour le jeu ONF). `i` est l'indice de colonne (0 à l'ouest),
#' `j` l'indice de ligne compté depuis le sud (0 au sud), sur la grille découpée.
#'
#' @param dossier Dossier qui contient les rasters.
#' @param aoi Emprise : `NULL` (tout le jeu), objet `sf`/`sfc`, `SpatVector` ou
#'   `SpatExtent` de terra. Un polygone est reprojeté dans le système des rasters ; seuls
#'   les pixels dont le centre tombe dedans sont gardés.
#' @param couches Table de branchement ([couches_onf()] par défaut).
#'
#' @return data.frame : `i`, `j`, `x`, `y`, une colonne par `variable` de `couches`,
#'   `part_pb` (vide), `non_precomptable`, `part_pb_absente`. Attributs : `gabarit`
#'   (grille d'origine découpée : `xmin`, `xmax`, `ymin`, `ymax`, `resolution`, `crs`),
#'   `couches` (la table de branchement), `temps_lecture` (secondes).
#' @examples
#' \dontrun{
#' # Rasters du jeu téléchargés depuis le serveur du CRAIG, hors du dépôt.
#' v <- lire_parametres_lidar("chemin/vers/vercors", aoi = sf::st_read("foret.gpkg"))
#' }
#' @export
lire_parametres_lidar <- function(dossier, aoi = NULL, couches = couches_onf()) {
  debut <- proc.time()[["elapsed"]]
  chemins <- file.path(dossier, couches$fichier)
  present <- file.exists(chemins)
  manque <- couches$fichier[!present & couches$obligatoire]
  if (length(manque) > 0) {
    arreter(sprintf("couches absentes de %s : %s", dossier, paste(manque, collapse = ", ")))
  }
  couches <- couches[present, , drop = FALSE]
  r <- terra::rast(chemins[present])
  names(r) <- couches$variable

  if (!is.null(aoi)) {
    if (inherits(aoi, c("sf", "sfc"))) {
      aoi <- terra::vect(sf::st_transform(sf::st_geometry(aoi), terra::crs(r)))
    }
    if (inherits(aoi, "SpatVector")) {
      if (!terra::same.crs(aoi, r)) aoi <- terra::project(aoi, terra::crs(r))
      r <- terra::crop(r, aoi, snap = "out", mask = TRUE)
    } else if (inherits(aoi, "SpatExtent")) {
      r <- terra::crop(r, aoi, snap = "out")
    } else {
      arreter("aoi doit \u00eatre NULL, un objet sf, un SpatVector ou un SpatExtent")
    }
  }

  v <- terra::values(r, mat = TRUE)
  garde <- which(rowSums(!is.na(v)) > 0)
  if (length(garde) == 0) arreter("aucun pixel renseign\u00e9 dans l'emprise")
  xy <- terra::xyFromCell(r, garde)
  rc <- terra::rowColFromCell(r, garde)
  out <- data.frame(i = as.integer(rc[, 2] - 1L), j = as.integer(terra::nrow(r) - rc[, 1]),
                    x = xy[, 1], y = xy[, 2])
  for (k in seq_len(nrow(couches))) {
    out[[couches$variable[k]]] <- as.numeric(v[garde, k]) * couches$facteur[k]
  }
  if (!"part_pb" %in% names(out)) {
    out$part_pb <- NA_real_
    out$part_pb_absente <- TRUE
  } else {
    out$part_pb_absente <- is.na(out$part_pb)
  }
  fam0 <- if ("famille" %in% names(out)) !is.na(out$famille) & out$famille == 0 else FALSE
  out$non_precomptable <- fam0 | is.na(out$G) | out$G == 0

  e <- as.vector(terra::ext(r))
  attr(out, "gabarit") <- list(xmin = e[["xmin"]], xmax = e[["xmax"]], ymin = e[["ymin"]],
                               ymax = e[["ymax"]], resolution = terra::res(r),
                               crs = terra::crs(r))
  attr(out, "couches") <- couches
  attr(out, "temps_lecture") <- proc.time()[["elapsed"]] - debut
  out
}

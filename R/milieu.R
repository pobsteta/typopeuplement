# Milieu : le relief tiré du MNT ouvert de l'IGN, pour la hauteur potentielle (mission 009).
#
# 1. télécharger le MNT (RGE ALTI, service WMS-Raster de la Géoplateforme) sur la grille
#    du jeu, avec une marge pour les voisinages ;
# 2. ramener le MNT sur la grille du jeu (moyenne des cellules fines) et en tirer
#    l'altitude, la pente, l'exposition (sinus, cosinus) et la position topographique ;
# 3. relever ces variables pixel par pixel, dans l'ordre des lignes du jeu.
#
# Le relief seul : ni climat ni sol. Aucune couche de climat ou de sol n'est inventée ;
# tant qu'elles ne sont pas acquises, la hauteur potentielle ne voit que le relief, et la
# fiche de validation le dit. Le milieu sert à la hauteur potentielle, pas à une
# typologie de stations.

#' Variables de relief calculées par [calculer_relief()]
#'
#' | variable | unité | définition |
#' |---|---|---|
#' | `altitude` | m | moyenne du MNT sur le pixel |
#' | `pente` | degrés | pente du MNT ramené sur la grille (voisinage 3 × 3, méthode de Horn, `terra::terrain()`) |
#' | `expo_sin` | sans unité, -1 à 1 | sinus de l'exposition (1 : versant est) ; 0 en terrain plat |
#' | `expo_cos` | sans unité, -1 à 1 | cosinus de l'exposition (1 : versant nord) ; 0 en terrain plat |
#' | `position_topo` | m | altitude moins l'altitude moyenne dans un disque de rayon `rayon_tpi_m` (négatif : creux, bas de versant ; positif : croupe, crête) |
#'
#' @return Vecteur de caractères des noms de variables.
#' @seealso [calculer_relief()], [milieu_pixels()]
#' @export
variables_relief <- function() {
  c("altitude", "pente", "expo_sin", "expo_cos", "position_topo")
}

# Gabarit (liste xmin, xmax, ymin, ymax, resolution, crs) en SpatRaster vide.
gabarit_raster <- function(gabarit) {
  if (inherits(gabarit, "SpatRaster")) return(terra::rast(gabarit))
  champs <- c("xmin", "xmax", "ymin", "ymax", "resolution", "crs")
  manque <- setdiff(champs, names(gabarit))
  if (length(manque) > 0) arreter(sprintf("gabarit incomplet : %s", paste(manque, collapse = ", ")))
  terra::rast(xmin = gabarit$xmin, xmax = gabarit$xmax, ymin = gabarit$ymin,
              ymax = gabarit$ymax, resolution = gabarit$resolution, crs = gabarit$crs)
}

#' Requêtes WMS-Raster du MNT de l'IGN sur une grille
#'
#' Découpe en dalles l'emprise du gabarit élargie d'une marge, sur une grille fine
#' alignée sur celle du gabarit (résolution du gabarit divisée par `facteur`), et rend les
#' requêtes `GetMap` du service WMS-Raster de la Géoplateforme (GeoTIFF flottant 32 bits,
#' Lambert-93). Aucun accès réseau : voir [telecharger_mnt_ign()].
#'
#' @param gabarit Grille du jeu : liste `xmin`, `xmax`, `ymin`, `ymax`, `resolution`,
#'   `crs` (attribut `gabarit` de [lire_parametres_lidar()]) ou `SpatRaster`.
#' @param facteur Rapport entier entre la résolution du gabarit et celle du MNT
#'   téléchargé. **Provisoire** : 2 (13,3 m pour la grille ONF de 26,6 m).
#' @param marge_m Marge autour de l'emprise, en m, arrondie au pixel du gabarit
#'   supérieur ; elle doit couvrir le rayon de la position topographique.
#'   **Provisoire** : 500.
#' @param taille_max Nombre maximal de colonnes et de lignes d'une dalle (le service en
#'   accepte 5 010). **Provisoire** : 2 000.
#' @param couche Couche WMS-Raster. Par défaut `ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES`
#'   (RGE ALTI, MNT au pas de 1 à 5 m de l'IGN, données ouvertes, Licence ouverte 2.0).
#' @param url Point d'accès du service WMS-Raster.
#'
#' @return data.frame, une ligne par dalle : `xmin`, `xmax`, `ymin`, `ymax` (m,
#'   Lambert-93), `largeur`, `hauteur` (pixels), `url` (requête complète).
#' @seealso [telecharger_mnt_ign()]
#' @export
dalles_mnt_ign <- function(gabarit, facteur = 2L, marge_m = 500, taille_max = 2000L,
                           couche = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
                           url = "https://data.geopf.fr/wms-r/wms") {
  g <- gabarit_raster(gabarit)
  code <- terra::crs(g, describe = TRUE)$code
  if (is.na(code) || code != "2154") arreter("le gabarit doit être en Lambert-93 (EPSG:2154)")
  facteur <- as.integer(facteur)
  if (facteur < 1) arreter("facteur doit être un entier positif")
  res_g <- terra::res(g)[1]
  if (abs(terra::res(g)[2] - res_g) > 1e-9) arreter("le gabarit doit avoir des pixels carrés")
  marge <- ceiling(marge_m / res_g) * res_g
  e <- as.vector(terra::ext(g)) + c(-marge, marge, -marge, marge)
  pas <- res_g / facteur
  ncol_tot <- round((e[["xmax"]] - e[["xmin"]]) / pas)
  nrow_tot <- round((e[["ymax"]] - e[["ymin"]]) / pas)
  bornes <- function(n) {
    debut <- seq(0L, n - 1L, by = taille_max)
    cbind(debut, pmin(debut + taille_max, n))
  }
  bc <- bornes(ncol_tot)
  br <- bornes(nrow_tot)
  out <- do.call(rbind, lapply(seq_len(nrow(br)), function(r) {
    do.call(rbind, lapply(seq_len(nrow(bc)), function(k) {
      data.frame(xmin = e[["xmin"]] + bc[k, 1] * pas, xmax = e[["xmin"]] + bc[k, 2] * pas,
                 ymin = e[["ymax"]] - br[r, 2] * pas, ymax = e[["ymax"]] - br[r, 1] * pas,
                 largeur = as.integer(bc[k, 2] - bc[k, 1]),
                 hauteur = as.integer(br[r, 2] - br[r, 1]))
    }))
  }))
  # WMS 1.3.0 en EPSG:2154 : ordre des axes x (est) puis y (nord).
  out$url <- sprintf(paste0("%s?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=%s&STYLES=",
                            "&CRS=EPSG:2154&BBOX=%s,%s,%s,%s&WIDTH=%d&HEIGHT=%d",
                            "&FORMAT=image/geotiff"),
                     url, couche, format(out$xmin, nsmall = 1, scientific = FALSE, trim = TRUE),
                     format(out$ymin, nsmall = 1, scientific = FALSE, trim = TRUE),
                     format(out$xmax, nsmall = 1, scientific = FALSE, trim = TRUE),
                     format(out$ymax, nsmall = 1, scientific = FALSE, trim = TRUE),
                     out$largeur, out$hauteur)
  out
}

#' Télécharger le MNT de l'IGN sur la grille d'un jeu
#'
#' Télécharge les dalles de [dalles_mnt_ign()] (service WMS-Raster de la Géoplateforme,
#' accès libre sans clé) dans `dossier`, les assemble et écrit `mnt.tif` (altitude en m,
#' Lambert-93). Les valeurs hors service (-99 999 ou moins) deviennent vides.
#' Les dalles déjà présentes ne sont pas retéléchargées.
#'
#' Le service rend le MNT rééchantillonné au pas demandé : c'est une moyenne d'affichage
#' du RGE ALTI, pas le fichier d'origine. À 13,3 m, l'écart est sans effet sur une pente
#' calculée au pas de 26,6 m.
#'
#' @inheritParams dalles_mnt_ign
#' @param dossier Dossier de téléchargement (hors du dépôt).
#' @return Chemin de `mnt.tif`, avec l'attribut `dalles` (table des requêtes) et
#'   `temps` (secondes).
#' @examples
#' \dontrun{
#' v <- lire_parametres_lidar("chemin/vers/vercors")
#' mnt <- telecharger_mnt_ign(attr(v, "gabarit"), "chemin/hors/depot")
#' }
#' @export
telecharger_mnt_ign <- function(gabarit, dossier, facteur = 2L, marge_m = 500,
                                taille_max = 2000L,
                                couche = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
                                url = "https://data.geopf.fr/wms-r/wms") {
  debut <- proc.time()[["elapsed"]]
  dalles <- dalles_mnt_ign(gabarit, facteur, marge_m, taille_max, couche, url)
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  fichiers <- file.path(dossier, sprintf("dalle_%03d.tif", seq_len(nrow(dalles))))
  for (k in seq_len(nrow(dalles))) {
    if (file.exists(fichiers[k]) && file.size(fichiers[k]) > 0) next
    tmp <- paste0(fichiers[k], ".part")
    ok <- tryCatch(utils::download.file(dalles$url[k], tmp, mode = "wb", quiet = TRUE),
                   error = function(e) conditionMessage(e))
    if (!identical(ok, 0L)) {
      unlink(tmp)
      arreter(sprintf("téléchargement du MNT refusé (%s) : %s", dalles$url[k],
                      if (is.character(ok)) ok else paste("code", ok)))
    }
    file.rename(tmp, fichiers[k])
  }
  pas <- terra::res(gabarit_raster(gabarit))[1] / as.integer(facteur)
  morceaux <- lapply(seq_len(nrow(dalles)), function(k) {
    r <- terra::rast(fichiers[k])
    # Le GeoTIFF du service est géoréférencé ; on impose la grille demandée par sûreté.
    terra::ext(r) <- terra::ext(dalles$xmin[k], dalles$xmax[k], dalles$ymin[k], dalles$ymax[k])
    terra::crs(r) <- "EPSG:2154"
    r
  })
  mnt <- if (length(morceaux) == 1) morceaux[[1]] else do.call(terra::merge, morceaux)
  mnt <- terra::classify(mnt, cbind(-Inf, -99998, NA))
  names(mnt) <- "altitude"
  if (any(abs(terra::res(mnt) - pas) > 1e-6)) arreter("dalles du MNT au mauvais pas")
  chemin <- file.path(dossier, "mnt.tif")
  terra::writeRaster(mnt, chemin, overwrite = TRUE, datatype = "FLT4S")
  attr(chemin, "dalles") <- dalles
  attr(chemin, "temps") <- proc.time()[["elapsed"]] - debut
  chemin
}

#' Calculer le relief sur la grille d'un jeu
#'
#' Ramène le MNT sur la grille du jeu (moyenne des cellules fines qui tombent dans chaque
#' pixel), puis calcule les variables de [variables_relief()]. Les voisinages (pente,
#' position topographique) sont calculés sur la grille élargie à toute l'étendue du MNT,
#' puis le résultat est découpé exactement sur le gabarit : même emprise, même
#' résolution, même système que les rasters du producteur.
#'
#' @param mnt MNT : chemin d'un raster ou `SpatRaster` (altitude en m, Lambert-93),
#'   par exemple rendu par [telecharger_mnt_ign()]. Il doit déborder du gabarit d'au moins
#'   `rayon_tpi_m` pour que la position topographique soit complète en bordure.
#' @param gabarit Grille du jeu (voir [dalles_mnt_ign()]).
#' @param rayon_tpi_m Rayon du disque de la position topographique, en m.
#'   **Provisoire** : 300.
#' @param pente_plate_deg Sous cette pente, en degrés, l'exposition n'a pas de sens :
#'   `expo_sin` et `expo_cos` valent 0. **Provisoire** : 1.
#'
#' @return `SpatRaster` à cinq couches ([variables_relief()]), aligné sur le gabarit.
#'   Attribut `temps` (secondes).
#' @seealso [milieu_pixels()]
#' @export
calculer_relief <- function(mnt, gabarit, rayon_tpi_m = 300, pente_plate_deg = 1) {
  debut <- proc.time()[["elapsed"]]
  if (is.character(mnt)) mnt <- terra::rast(mnt)
  if (!inherits(mnt, "SpatRaster")) arreter("mnt doit être un chemin de raster ou un SpatRaster")
  mnt <- mnt[[1]]
  g <- gabarit_raster(gabarit)
  if (!terra::same.crs(mnt, g)) mnt <- terra::project(mnt, terra::crs(g), method = "bilinear")
  if (rayon_tpi_m <= 0) arreter("rayon_tpi_m doit être strictement positif")
  # Grille du gabarit étendue à l'étendue du MNT (pixels entiers, même origine).
  res_g <- terra::res(g)
  eg <- as.vector(terra::ext(g))
  em <- as.vector(terra::ext(mnt))
  nx_o <- floor((eg[["xmin"]] - em[["xmin"]]) / res_g[1] + 1e-9)
  nx_e <- floor((em[["xmax"]] - eg[["xmax"]]) / res_g[1] + 1e-9)
  ny_s <- floor((eg[["ymin"]] - em[["ymin"]]) / res_g[2] + 1e-9)
  ny_n <- floor((em[["ymax"]] - eg[["ymax"]]) / res_g[2] + 1e-9)
  large <- terra::rast(xmin = eg[["xmin"]] - max(nx_o, 0) * res_g[1],
                       xmax = eg[["xmax"]] + max(nx_e, 0) * res_g[1],
                       ymin = eg[["ymin"]] - max(ny_s, 0) * res_g[2],
                       ymax = eg[["ymax"]] + max(ny_n, 0) * res_g[2],
                       resolution = res_g, crs = terra::crs(g))
  alt <- terra::resample(mnt, large, method = "average")
  names(alt) <- "altitude"
  pente <- terra::terrain(alt, v = "slope", neighbors = 8, unit = "degrees")
  asp <- terra::terrain(alt, v = "aspect", neighbors = 8, unit = "radians")
  plat <- pente < pente_plate_deg
  expo_sin <- terra::ifel(plat, 0, sin(asp))
  expo_cos <- terra::ifel(plat, 0, cos(asp))
  # Pas du MNT arrondi (au µm) pour les poids du TPI : la grille étendue porte des pas en
  # x et en y qui diffèrent de quelques 1e-12 m (26,6 m du jeu ONF), et terra::focalMat
  # les jugerait « non carrés » (avertissement de GDAL).
  pas <- round(terra::res(alt), 6)
  w <- terra::focalMat(terra::rast(nrows = 1, ncols = 1, xmin = 0, xmax = pas[1], ymin = 0,
                                   ymax = pas[2]), rayon_tpi_m, type = "circle")
  w[w > 0] <- 1
  w[w == 0] <- NA
  moy <- terra::focal(alt, w = w, fun = "mean", na.rm = TRUE)
  tpi <- alt - moy
  out <- c(alt, pente, expo_sin, expo_cos, tpi)
  names(out) <- variables_relief()
  coupe <- terra::crop(out, g, snap = "near")
  if (!terra::compareGeom(coupe, g, stopOnError = FALSE)) {
    arreter("le relief n'est pas aligné sur la grille du jeu")
  }
  # En mémoire, sur la grille exacte du gabarit (hors des fichiers temporaires de terra).
  out <- terra::rast(g, nlyrs = terra::nlyr(coupe))
  terra::values(out) <- terra::values(coupe, mat = TRUE)
  names(out) <- variables_relief()
  attr(out, "temps") <- proc.time()[["elapsed"]] - debut
  out
}

#' Variables de milieu, pixel par pixel
#'
#' Relève les variables de relief au centre de chaque pixel du jeu (`x`, `y`, dans le
#' système du relief, Lambert-93 pour le jeu ONF) et rend une table alignée ligne à ligne
#' sur `variables`, prête pour `typer_peuplements(milieu = ...)`.
#'
#' @param relief `SpatRaster` rendu par [calculer_relief()].
#' @param variables data.frame de pixels avec `x`, `y` ([lire_parametres_lidar()]).
#' @return data.frame, une ligne par ligne de `variables`, une colonne par couche du
#'   relief. Attributs : `variables_milieu` (noms des colonnes) et `source` (texte).
#' @export
milieu_pixels <- function(relief, variables) {
  verifier_colonnes(variables, c("x", "y"), "les variables")
  cellules <- terra::cellFromXY(relief, cbind(as.numeric(variables$x), as.numeric(variables$y)))
  v <- matrix(NA_real_, length(cellules), terra::nlyr(relief))
  ok <- !is.na(cellules)
  if (any(ok)) v[ok, ] <- as.matrix(terra::values(relief, mat = TRUE)[cellules[ok], , drop = FALSE])
  out <- as.data.frame(v)
  names(out) <- names(relief)
  attr(out, "variables_milieu") <- names(relief)
  attr(out, "source") <- paste0("relief seul (", paste(names(relief), collapse = ", "),
                                ") tiré du MNT RGE ALTI de l'IGN (WMS-Raster de la ",
                                "Géoplateforme) ; ni climat ni sol")
  out
}

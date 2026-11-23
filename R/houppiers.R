# Couvert des strates par houppier (mission 013).
#
# Le GSM Alpes du Nord (typologie de structure, p. 53) range chaque ARBRE dans une strate
# selon la hauteur de sa cime (quarts de la hauteur dominante potentielle), et le couvert
# d'une strate est la surface des houppiers de ses arbres. La mesure par tranches de
# hauteur (mission 008, R/strates.R) range des RETOURS, pas des arbres : la partie basse
# d'un houppier de la strate 1 compte en strate 2, et la strate 1 se vide (82 % de jeunes
# futaies à Léoncel, mission 012).
#
#   dalles (COPC) --lasR, un seul exec, avec tampon--> MNH 0,5 m, sommets, houppiers
#   houppiers + hauteur de référence du pixel du sommet --> strate de chaque arbre
#   surface des houppiers de chaque strate, par pixel de la grille --> c1 à c4
#
# Plan validé par Pascal (2026-11-23) : mode HYBRIDE par défaut, la strate 1 par les
# houppiers, les strates 2 à 4 par les tranches corrigées de l'occlusion (vu du dessus,
# le sous-étage est masqué par les houppiers de la strate 1). Paramètres de segmentation
# PROVISOIRES : MNH à 0,5 m, maxima locaux sur une fenêtre de 3 m, hauteur minimale 2 m,
# croissance de régions (region_growing de lasR, Dalponte et Coomes 2016).

# Méthodes de calcul du couvert des strates.
METHODES_STRATES <- c("hybride", "houppiers", "tranches")

#' Segmenter les houppiers d'un nuage de points LiDAR HD
#'
#' Segmente les arbres d'une ou plusieurs dalles de nuage de points (LAS, LAZ ou COPC,
#' par exemple les dalles LiDAR HD de l'IGN) avec lasR, en **un seul** `exec` sur toutes
#' les dalles, lues avec un tampon : un houppier à cheval sur deux dalles n'est pas coupé.
#'
#' Étapes : triangulation des points de sol (classe 2) et hauteur au-dessus du sol ;
#' modèle numérique de hauteur (MNH, maximum des points des classes `classes` par
#' cellule de `resolution_m`) ; bouchage des creux (`pit_fill`) ; sommets = maxima
#' locaux du MNH sur une fenêtre circulaire de `fenetre_m` de diamètre, au-dessus de
#' `hauteur_min_m` ; houppiers par croissance de régions depuis les sommets
#' (`region_growing`, Dalponte et Coomes 2016), sans cellule sous `hauteur_min_m`.
#'
#' Les fichiers sont écrits dans `dossier` : `mnh.tif` (MNH bouché, m), `houppiers.tif`
#' (numéro du houppier de chaque cellule, vide hors houppier), `sommets.gpkg`. Avec
#' plusieurs dalles, lasR peut écrire un raster par dalle et un fichier virtuel (`.vrt`)
#' qui les assemble : c'est ce fichier qui est rendu.
#'
#' lasR est en Suggests (installation : voir le README, il faut GDAL) ; sans lui, la
#' fonction s'arrête.
#'
#' @param dalles Chemins des dalles.
#' @param dossier Dossier de sortie (créé au besoin).
#' @param fenetre_m Diamètre de la fenêtre des maxima locaux, m. **Provisoire** : 3 m.
#' @param hauteur_min_m Hauteur minimale d'un sommet et d'une cellule de houppier, m.
#'   **Provisoire** : 2 m.
#' @param resolution_m Côté des cellules du MNH, m. **Provisoire** : 0,5 m.
#' @param tampon_m Tampon de lecture autour de chaque dalle, m (lasR prend le plus grand
#'   de cette valeur et de celle que demandent ses étapes). Par défaut 20 m, la largeur
#'   maximale d'un houppier dans `region_growing`.
#' @param traiter Vecteur logique, un par dalle : `FALSE` pour une dalle lue seulement
#'   comme tampon de ses voisines (pas de sortie sur son emprise) ; `NULL` : toutes.
#' @param classes Classes de points du MNH. **Provisoire** : 1 à 5 de l'ASPRS (non
#'   classé, sol, végétation basse, moyenne, haute).
#' @param ncores Stratégie de parallélisme de lasR (par exemple
#'   `lasR::concurrent_points(4)`) ; `NULL` : réglage de lasR. La mémoire croît avec le
#'   nombre de dalles traitées en même temps (environ 7 Go par dalle LiDAR HD).
#' @return Objet `typo_houppiers` : liste `mnh`, `houppiers`, `sommets` (chemins),
#'   `parametres` (liste), `dalles`, `secondes` (durée de l'`exec`).
#' @seealso [couvert_houppiers()], [dalles_sur_aoi()]
#' @examples
#' \dontrun{
#' d <- dalles_sur_aoi(noms_des_dalles, foret, gabarit = attr(v, "gabarit"))
#' s <- segmenter_houppiers(d, file.path(tempdir(), "houppiers"))
#' couvert_houppiers(s, attr(v, "gabarit"), references_strates(carte, facteur = k))
#' }
#' @export
segmenter_houppiers <- function(dalles, dossier, fenetre_m = 3, hauteur_min_m = 2,
                                resolution_m = 0.5, tampon_m = 20, traiter = NULL,
                                classes = 1:5, ncores = NULL) {
  if (!requireNamespace("lasR", quietly = TRUE)) {
    arreter(paste0("lasR n'est pas installé : le nuage de points ne peut pas être lu ",
                   "(installation depuis r-universe, voir le README)"))
  }
  if (length(dalles) == 0) arreter("aucune dalle à segmenter")
  manque <- dalles[!file.exists(dalles)]
  if (length(manque) > 0) arreter(sprintf("dalles introuvables : %s", paste(manque, collapse = ", ")))
  positif <- function(v, nom) {
    if (length(v) != 1 || !is.finite(v) || v <= 0) arreter(sprintf("%s doit être strictement positif (m)", nom))
  }
  positif(fenetre_m, "fenetre_m")
  positif(hauteur_min_m, "hauteur_min_m")
  positif(resolution_m, "resolution_m")
  if (length(tampon_m) != 1 || !is.finite(tampon_m) || tampon_m < 0) {
    arreter("tampon_m doit être positif ou nul (m)")
  }
  if (!is.null(traiter) && (length(traiter) != length(dalles) || anyNA(traiter) || !any(traiter))) {
    arreter("traiter : une valeur logique par dalle, au moins une dalle traitée")
  }
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  f_mnh <- file.path(dossier, "mnh_brut.tif")
  f_pf <- file.path(dossier, "mnh.tif")
  f_som <- file.path(dossier, "sommets.gpkg")
  f_hou <- file.path(dossier, "houppiers.tif")

  sol <- lasR::triangulate(filter = lasR::keep_ground())
  normalise <- lasR::transform_with(sol, "-")
  mnh <- lasR::rasterize(resolution_m, "max", filter = lasR::keep_class(as.integer(classes)),
                         ofile = f_mnh)
  pf <- lasR::pit_fill(mnh, ofile = f_pf)
  som <- lasR::local_maximum_raster(pf, ws = fenetre_m, min_height = hauteur_min_m, ofile = f_som)
  hou <- lasR::region_growing(pf, som, th_tree = hauteur_min_m, ofile = f_hou)
  options <- list(buffer = tampon_m, progress = FALSE)
  if (!is.null(ncores)) options$ncores <- ncores
  if (!is.null(traiter)) options$noprocess <- !as.logical(traiter)
  t0 <- proc.time()[["elapsed"]]
  res <- lasR::exec(sol + normalise + mnh + pf + som + hou, on = dalles, with = options)
  secondes <- proc.time()[["elapsed"]] - t0
  # Avec plusieurs dalles, lasR rend un fichier virtuel qui assemble un raster par dalle.
  chemin <- function(r, defaut) {
    if (inherits(r, "SpatRaster")) {
      s <- terra::sources(r)
      if (length(s) == 1 && nzchar(s)) return(s)
    }
    if (is.character(r) && length(r) == 1) return(r)
    vrt <- sub("\\.tif$", ".vrt", defaut)
    if (file.exists(vrt)) return(vrt)
    defaut
  }
  nommes <- if (is.list(res)) res else list()
  sortie <- list(
    mnh = chemin(nommes$pit_fill, f_pf),
    houppiers = chemin(nommes$region_growing, f_hou),
    sommets = f_som,
    parametres = list(fenetre_m = fenetre_m, hauteur_min_m = hauteur_min_m,
                      resolution_m = resolution_m, tampon_m = tampon_m,
                      classes = as.integer(classes), algorithme = "lasR region_growing"),
    dalles = if (is.null(traiter)) dalles else dalles[as.logical(traiter)],
    secondes = secondes
  )
  for (k in c("mnh", "houppiers")) {
    if (!file.exists(sortie[[k]])) arreter(sprintf("lasR n'a pas écrit %s", sortie[[k]]))
  }
  structure(sortie, class = "typo_houppiers")
}

# Rasters (identifiants des houppiers, hauteurs) d'une segmentation : objet
# typo_houppiers, ou liste houppiers / mnh (chemins ou SpatRaster).
rasters_houppiers <- function(s) {
  if (!is.list(s) || is.null(s$houppiers) || is.null(s$mnh)) {
    arreter("houppiers : segmentation attendue (segmenter_houppiers(), ou liste houppiers et mnh)")
  }
  lire <- function(x) if (inherits(x, "SpatRaster")) x else terra::rast(x)
  ids <- lire(s$houppiers)
  h <- lire(s$mnh)
  if (!isTRUE(terra::compareGeom(ids, h, stopOnError = FALSE))) {
    arreter("houppiers et mnh n'ont pas la même grille")
  }
  list(ids = ids[[1]], h = h[[1]])
}

# Lit un raster par blocs de lignes et appelle f(valeurs_id, valeurs_h, x, y) sur chaque
# bloc (cellules de houppier ou de MNH seulement).
parcourir_blocs <- function(r, lignes_bloc, f) {
  nc <- terra::ncol(r$ids)
  nr <- terra::nrow(r$ids)
  e <- as.vector(terra::ext(r$ids))
  rs <- terra::res(r$ids)
  terra::readStart(r$ids)
  terra::readStart(r$h)
  on.exit({
    terra::readStop(r$ids)
    terra::readStop(r$h)
  }, add = TRUE)
  for (debut in seq(1L, nr, by = lignes_bloc)) {
    n <- min(lignes_bloc, nr - debut + 1L)
    id <- terra::readValues(r$ids, row = debut, nrows = n, col = 1, ncols = nc)
    h <- terra::readValues(r$h, row = debut, nrows = n, col = 1, ncols = nc)
    garde <- which(!is.na(h) | !is.na(id))
    if (length(garde) == 0) next
    lig <- (garde - 1L) %/% nc + debut - 1L
    col <- (garde - 1L) %% nc
    f(id[garde], h[garde],
      e[["xmin"]] + (col + 0.5) * rs[1],
      e[["ymax"]] - (lig + 0.5) * rs[2])
  }
  invisible(NULL)
}

#' Sommets des houppiers d'une segmentation
#'
#' Sommet de chaque houppier = sa cellule la plus haute dans le MNH (à égalité, la
#' première lue) ; sa hauteur est celle de l'arbre. Un numéro de houppier vaut un arbre,
#' **0 compris** : lasR numérote ses houppiers à partir de 0 (à Léoncel, sur l'extrait de
#' test, 281 sommets numérotés de 0 à 280). Une cellule sans hauteur (MNH vide) n'est
#' pas lue.
#'
#' @param houppiers Objet `typo_houppiers` ([segmenter_houppiers()]), ou liste `houppiers`
#'   et `mnh` (chemins ou `SpatRaster` de même grille).
#' @param lignes_bloc Nombre de lignes du MNH lues à la fois.
#' @return data.frame, un sommet par houppier : `id`, `h` (m), `x`, `y` (centre de la
#'   cellule du sommet, m, système du nuage).
#' @seealso [couvert_houppiers()], [couvert_strates_dalle()]
#' @export
sommets_houppiers <- function(houppiers, lignes_bloc = 1000L) {
  sommets_rasters(rasters_houppiers(houppiers), lignes_bloc)
}

# Sommets à partir des rasters lus (rasters_houppiers()).
sommets_rasters <- function(r, lignes_bloc = 1000L) {
  som <- list()
  parcourir_blocs(r, lignes_bloc, function(id, h, x, y) {
    ok <- !is.na(id) & !is.na(h)
    if (!any(ok)) return(NULL)
    o <- which(ok)[order(id[ok], -h[ok])]
    p <- o[!duplicated(id[o])]
    som[[length(som) + 1L]] <<- data.frame(id = id[p], h = h[p], x = x[p], y = y[p])
  })
  if (length(som) == 0) {
    return(data.frame(id = numeric(0), h = numeric(0), x = numeric(0), y = numeric(0)))
  }
  som <- do.call(rbind, som)
  som <- som[order(som$id, -som$h), ]
  som <- som[!duplicated(som$id), ]
  rownames(som) <- NULL
  som
}

# Strate (1 à 4) d'arbres de cime `h_cime`, par la hauteur de référence `H` (m) ; NA si H
# manque. Même règle que les retours (comptes_strates) : quarts de H.
strate_cime <- function(h_cime, H) 4L - findInterval(h_cime / H, rev(QUARTS_STRATES))

# Cime de chaque point (x, y) : hauteur `h` du sommet du houppier où tombe le point (vu
# du dessus, cellule du raster des houppiers), et pixel de ce sommet dans `grille`
# (`cellule`). NA hors houppier. `masque` : list(ids = SpatRaster des houppiers,
# sommets = sommets_houppiers()). La fenêtre du raster couvrant les points est lue une fois.
cimes_points <- function(masque, grille, x, y) {
  n <- length(x)
  out <- list(h = rep(NA_real_, n), cellule = rep(NA_integer_, n))
  if (n == 0 || nrow(masque$sommets) == 0) return(out)
  ids <- masque$ids
  rs <- terra::res(ids)
  e0 <- as.vector(terra::ext(ids))
  # Fenêtre alignée sur la grille du raster, coupée à son emprise.
  xmin <- max(e0[["xmin"]], e0[["xmin"]] + floor((min(x) - e0[["xmin"]]) / rs[1]) * rs[1])
  xmax <- min(e0[["xmax"]], e0[["xmin"]] + ceiling((max(x) - e0[["xmin"]]) / rs[1] + 1e-9) * rs[1])
  ymin <- max(e0[["ymin"]], e0[["ymin"]] + floor((min(y) - e0[["ymin"]]) / rs[2]) * rs[2])
  ymax <- min(e0[["ymax"]], e0[["ymin"]] + ceiling((max(y) - e0[["ymin"]]) / rs[2] + 1e-9) * rs[2])
  if (xmax <= xmin || ymax <= ymin) return(out)
  f <- terra::crop(ids, terra::ext(xmin, xmax, ymin, ymax), snap = "out")
  e <- as.vector(terra::ext(f))
  nc <- terra::ncol(f)
  nr <- terra::nrow(f)
  v <- terra::values(f, mat = FALSE)
  col <- floor((x - e[["xmin"]]) / rs[1])
  lig <- floor((e[["ymax"]] - y) / rs[2])
  dedans <- which(col >= 0 & col < nc & lig >= 0 & lig < nr)
  id <- v[lig[dedans] * nc + col[dedans] + 1]
  k <- match(id, masque$sommets$id)
  out$h[dedans] <- masque$sommets$h[k]
  cel_som <- cellules_xy(grille, masque$sommets$x, masque$sommets$y)
  out$cellule[dedans] <- cel_som[k]
  out
}

#' Couvert des strates par houppier
#'
#' À partir d'une segmentation ([segmenter_houppiers()]), range chaque arbre dans une
#' strate du GSM selon la hauteur de sa cime, puis additionne, pour chaque pixel de la
#' grille, la surface des houppiers de chaque strate :
#'
#' - sommet d'un houppier = sa cellule la plus haute dans le MNH
#'   ([sommets_houppiers()]) ; sa hauteur est celle de l'arbre ; le houppier numéro 0
#'   est un arbre comme les autres ;
#' - strate de l'arbre = quart de la hauteur de référence H **du pixel de son sommet**
#'   (strate 1 : cime ≥ 3/4 H ; 2 : ≥ H/2 ; 3 : ≥ H/4 ; 4 : en dessous), comme
#'   [comptes_strates()] pour les retours. Un arbre dont le sommet tombe dans un pixel
#'   sans référence (hors de `references`) prend, cellule par cellule, la référence du
#'   pixel où tombe la cellule ;
#' - `c<k>_<r>` = surface des cellules des houppiers de la strate k dans le pixel,
#'   divisée par la surface du pixel couverte par le MNH. Numérateur et dénominateur ne
#'   comptent que les cellules qui ont une hauteur : un couvert ne dépasse pas 1. Un
#'   houppier à cheval sur deux pixels compte dans chacun pour sa part, avec la strate de
#'   son arbre.
#'
#' C'est un couvert **vu du dessus** : chaque cellule n'appartient qu'à un houppier, et
#' les quatre couverts s'additionnent au plus à 1. Les strates basses sont masquées par
#' les houppiers du dessus (sous-étage sous-estimé) : d'où le mode hybride de la chaîne
#' (strate 1 par les houppiers, strates 2 à 4 par les tranches, sans les retours qui
#' tombent dans les houppiers de la strate 1, [typer_peuplements()]).
#'
#' La densité des houppiers (`densite_houppiers`, sommets par hectare de MNH) est rendue
#' pour la lecture ; elle ne sert pas à la clé (le seuil de densité de la clé de H10
#' porte sur N du producteur, décision de Pascal du 2026-11-23).
#'
#' Plusieurs segmentations (une liste) s'additionnent pixel par pixel ; un houppier coupé
#' à la limite de deux segmentations y compte pour deux arbres : on segmente toutes les
#' dalles en un seul `exec` ([segmenter_houppiers()], décision du 2026-11-23). Les
#' rasters sont lus par blocs de `lignes_bloc` lignes.
#'
#' @param houppiers Objet `typo_houppiers` ([segmenter_houppiers()]), ou liste `houppiers`
#'   (identifiants) et `mnh` (hauteurs, m) : chemins ou `SpatRaster` de même grille ; ou
#'   une liste de tels objets.
#' @param gabarit Grille des pixels : `SpatRaster` de terra, ou gabarit de
#'   [lire_parametres_lidar()], dans le système de coordonnées du nuage (Lambert-93).
#' @param references data.frame : `x`, `y` (centres des pixels, m) et une colonne par
#'   hauteur de référence (m), par exemple [references_strates()].
#' @param lignes_bloc Nombre de lignes du MNH lues à la fois.
#' @return data.frame, une ligne par pixel touché par le MNH : `cellule`, `x`, `y`,
#'   `n_cellules` (cellules de MNH), `n_houppiers` (sommets dans le pixel),
#'   `densite_houppiers` (tiges/ha), puis `c1_r` à `c4_r` pour chaque référence `r`
#'   (vides si la référence du pixel manque). Attribut `parametres` : ceux de la
#'   segmentation.
#' @seealso [segmenter_houppiers()], [sommets_houppiers()], [couvert_strates_dalle()]
#' @examples
#' # Deux pixels de 10 m ; MNH de 1 m ; un houppier de 4 x 4 m, cime à 18 m, dans le
#' # premier pixel (H = 20 m) : strate 1, couvert 16 / 100.
#' ids <- terra::rast(nrows = 10, ncols = 20, xmin = 0, xmax = 20, ymin = 0, ymax = 10,
#'                    crs = "EPSG:2154")
#' h <- ids
#' terra::values(ids) <- NA
#' terra::values(h) <- 0
#' ids[3:6, 3:6] <- 1
#' h[3:6, 3:6] <- 15
#' h[4, 4] <- 18
#' gab <- list(xmin = 0, xmax = 20, ymin = 0, ymax = 10, resolution = 10)
#' couvert_houppiers(list(houppiers = ids, mnh = h), gab,
#'                   data.frame(x = c(5, 15), y = 5, h = 20))
#' @export
couvert_houppiers <- function(houppiers, gabarit, references, lignes_bloc = 1000L) {
  segs <- if (inherits(houppiers, "typo_houppiers") ||
              (is.list(houppiers) && !is.null(houppiers$houppiers))) list(houppiers) else houppiers
  if (!is.list(segs) || length(segs) == 0) arreter("houppiers : aucune segmentation")
  verifier_colonnes(references, c("x", "y"), "les références")
  noms <- setdiff(names(references), c("cellule", "x", "y"))
  if (length(noms) == 0) arreter("aucune hauteur de référence dans references")
  if (!all(vapply(as.data.frame(references)[noms], is.numeric, logical(1)))) {
    arreter("les hauteurs de référence doivent être numériques (m)")
  }
  grille <- grille_strates(gabarit)
  npix <- grille$ncol * grille$nrow
  H <- references_par_pixel(references, noms, grille)
  n_cel <- numeric(npix)
  n_som <- numeric(npix)
  par_strate <- lapply(H, function(v) numeric(npix * 4))
  parametres <- NULL
  for (s in segs) {
    r <- rasters_houppiers(s)
    parametres <- parametres %||% s$parametres
    # Passe 1 : sommet de chaque houppier (cellule la plus haute), sur tous les blocs.
    som <- sommets_rasters(r, lignes_bloc)
    som$pix <- cellules_xy(grille, som$x, som$y)
    n_som <- n_som + tabulate(som$pix[!is.na(som$pix)], nbins = npix)
    # Strate de chaque arbre, par la référence du pixel de son sommet.
    strate_arbre <- lapply(H, function(v) strate_cime(som$h, v[som$pix]))
    # Passe 2 : chaque cellule de houppier compte dans son pixel, avec la strate de son
    # arbre. Numérateur et dénominateur : les mêmes cellules, celles qui ont une hauteur.
    parcourir_blocs(r, lignes_bloc, function(id, h, x, y) {
      pix <- cellules_xy(grille, x, y)
      m <- !is.na(pix) & !is.na(h)
      n_cel <<- n_cel + tabulate(pix[m], nbins = npix)
      c <- m & !is.na(id)
      if (!any(c)) return(NULL)
      k <- match(id[c], som$id)
      p <- pix[c]
      for (nom in noms) {
        st <- strate_arbre[[nom]][k]
        sans <- is.na(st)
        if (any(sans)) st[sans] <- strate_cime(som$h[k[sans]], H[[nom]][p[sans]])
        ok <- !is.na(st)
        par_strate[[nom]] <<- par_strate[[nom]] +
          tabulate(p[ok] + npix * (st[ok] - 1L), nbins = npix * 4L)
      }
    })
  }
  touches <- which(n_cel > 0)
  lig <- (touches - 1L) %/% grille$ncol
  col <- (touches - 1L) %% grille$ncol
  aire_cel <- if (length(segs) > 0) prod(terra::res(rasters_houppiers(segs[[1]])$ids)) else NA_real_
  out <- data.frame(cellule = as.integer(touches),
                    x = grille$xmin + (col + 0.5) * grille$res[1],
                    y = grille$ymax - (lig + 0.5) * grille$res[2],
                    n_cellules = n_cel[touches], n_houppiers = n_som[touches])
  out$densite_houppiers <- out$n_houppiers / (out$n_cellules * aire_cel / 1e4)
  for (nom in noms) {
    m <- matrix(par_strate[[nom]], ncol = 4L)[touches, , drop = FALSE]
    valable <- !is.na(H[[nom]][touches])
    for (k in 1:4) {
      v <- m[, k] / out$n_cellules
      v[!valable] <- NA_real_
      out[[paste0("c", k, "_", nom)]] <- v
    }
  }
  rownames(out) <- NULL
  attr(out, "parametres") <- parametres
  out
}

# Référence de chaque pixel de la grille, une colonne de `references` par élément (NA sans
# référence valable : vide, nulle ou négative).
references_par_pixel <- function(references, noms, grille) {
  npix <- grille$ncol * grille$nrow
  cel_ref <- cellules_xy(grille, references$x, references$y)
  if (anyDuplicated(cel_ref[!is.na(cel_ref)])) arreter("references : deux lignes dans le même pixel")
  lapply(stats::setNames(noms, noms), function(r) {
    v <- rep(NA_real_, npix)
    ok <- !is.na(cel_ref)
    v[cel_ref[ok]] <- as.numeric(references[[r]])[ok]
    v[!is.na(v) & v <= 0] <- NA_real_
    v
  })
}

# Une seule segmentation (objet typo_houppiers, ou liste houppiers / mnh) ?
segmentation_unique <- function(x) {
  inherits(x, "typo_houppiers") ||
    (is.list(x) && !is.data.frame(x) && !is.null(x$houppiers) && !is.null(x$mnh))
}

# Rôle d'une entrée de strates : couverts par houppiers (colonne n_houppiers),
# segmentation, comptes par tranches (colonnes p1_*), couverts déjà calculés (c*), ou
# dalles de nuage de points.
nature_strates <- function(x) {
  if (inherits(x, "typo_houppiers")) return("segmentation")
  if (is.list(x) && !is.data.frame(x) && !is.null(x$houppiers) && !is.null(x$mnh)) return("segmentation")
  # Plusieurs segmentations (par exemple par paquets de dalles).
  if (is.list(x) && !is.data.frame(x) && length(x) > 0 &&
      all(vapply(x, function(e) inherits(e, "typo_houppiers") ||
                   (is.list(e) && !is.null(e$houppiers) && !is.null(e$mnh)), logical(1)))) {
    return("segmentation")
  }
  if (is.character(x)) {
    if (length(x) > 0 && all(grepl("\\.la[sz]$", x, ignore.case = TRUE))) return("dalles")
    if (length(x) > 0 && all(grepl("\\.rds$", x, ignore.case = TRUE))) {
      manque <- x[!file.exists(x)]
      if (length(manque) > 0) arreter(sprintf("strates introuvables : %s", paste(manque, collapse = ", ")))
      return(nature_strates(lire_rds_strates(x)))
    }
    arreter("strates : chemins .rds attendus (comptes ou couverts), ou dalles .la[sz]")
  }
  if (is.data.frame(x)) {
    if ("n_houppiers" %in% names(x)) return("houppiers")
    if (any(grepl("^p1_", names(x)))) return("comptes")
    return("couverts")
  }
  arreter("strates doit être un data.frame, des chemins de fichiers, une segmentation ou une liste tranches / houppiers")
}

# Lit et lie des .rds de strates (comptes de plusieurs dalles, ou couverts).
lire_rds_strates <- function(chemins) {
  if (!is.character(chemins)) return(chemins)
  do.call(rbind, lapply(chemins, readRDS))
}

# Couverts par houppiers, une ligne par ligne de `variables` : c1..c4_<ref>, n_houppiers,
# densite_houppiers. `x` : table de couvert_houppiers() (ou .rds), segmentation, ou dalles.
couverts_houppiers_chaine <- function(x, variables, refs, reference, gabarit, ncores = NULL) {
  nat <- nature_strates(x)
  if (nat == "dalles") {
    x <- segmenter_houppiers(x, file.path(tempdir(), paste0("houppiers_", Sys.getpid())), ncores = ncores)
    nat <- "segmentation"
  }
  if (nat == "segmentation") {
    if (is.null(gabarit)) arreter("houppiers : les variables doivent porter leur gabarit")
    x <- couvert_houppiers(x, gabarit, refs)
  } else {
    x <- lire_rds_strates(x)
    if (nat != "houppiers") arreter("strates$houppiers : couverts de couvert_houppiers() attendus (colonne n_houppiers)")
  }
  cols <- paste0("c", 1:4, "_", reference)
  verifier_colonnes(x, c("x", "y", cols, "n_houppiers", "densite_houppiers"),
                    "les couverts par houppiers")
  params <- attr(x, "parametres")
  out <- apparier_couverts(as.data.frame(x)[, c("x", "y", cols, "densite_houppiers")], variables, gabarit)
  attr(out, "parametres") <- params
  out
}

# Rattache une table de couverts (x, y, colonnes) aux lignes de `variables`.
apparier_couverts <- function(cv, variables, gabarit) {
  k <- apparier_pixels(variables$x, variables$y, cv$x, cv$y, gabarit)
  garde <- !is.na(k)
  if (anyDuplicated(k[garde])) arreter("strates : deux lignes de couverts pour un même pixel")
  cols <- setdiff(names(cv), c("x", "y"))
  out <- as.data.frame(matrix(NA_real_, nrow(variables), length(cols), dimnames = list(NULL, cols)))
  out[k[garde], ] <- as.matrix(cv[garde, cols])
  out
}

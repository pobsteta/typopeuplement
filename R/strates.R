# Couvert des strates par le nuage de points LiDAR HD (mission 008).
#
# Typologie de structure MASSIF ALPIN du Guide des sylvicultures de montagne (GSM)
# Alpes du Nord, p. 53 : la hauteur dominante potentielle Hₒ est divisée en quatre
# quarts, chaque quart est une strate (strate 1 en haut). La clé lit le couvert de chaque
# strate en dixièmes (prépondérante ≥ 5/10, moyenne 3 ou 4/10, déficitaire ≤ 2/10).
#
#   nuage (COPC) --lasR--> hauteurs normalisées --> comptes par pixel et par strate
#                                                    (une dalle à la fois)
#   comptes de toutes les dalles --> couvert c1 à c4 par pixel et par référence
#
# Référence des strates NON GELÉE (plan de 008 validé par délégation, 2026-11-22) : les
# couverts se calculent pour plusieurs hauteurs de référence, et le choix se fera sur
# Léoncel, sur la mesure et sur le terrain (voir references_strates()).

# Seuils des strates, en fraction de la hauteur de référence (GSM, p. 53 : quarts).
QUARTS_STRATES <- c(0.75, 0.5, 0.25)

#' Hauteurs de référence des strates
#'
#' Les strates du GSM sont des quarts de la hauteur dominante potentielle. Tant que la
#' référence n'est pas choisie (plan de la mission 008), on en calcule trois, colonnes
#' de la table rendue, dans cet ordre :
#'
#' - `hpot_k` : `h_pot`, hauteur potentielle relevée par l'enveloppe k
#'   ([predire_hauteur_potentielle()]). **Référence par défaut, provisoire** : la plus
#'   fidèle au GSM (une hauteur *potentielle*) ;
#' - `hpot` : `h_pot / k`, la hauteur potentielle sans l'enveloppe (moyenne de la forêt),
#'   si `facteur` est donné ;
#' - `h0` : `h_dom`, la hauteur dominante mesurée du pixel.
#'
#' Ces hauteurs sont dans l'échelle de `h_dom`. Avec le jeu ONF, `h_dom` est la hauteur
#' brute `H0_lidar`, **non calibrée** : les quarts sont alors des quarts de cette échelle,
#' pas des quarts d'une Hₒ en mètres vrais (réserve à garder à la lecture).
#'
#' @param carte data.frame de pixels : `h_pot` et `h_dom` (m), `famille` si `facteur` est
#'   donné ; `x`, `y` (m) sont repris s'ils y sont.
#' @param facteur Enveloppe k par famille : liste ou vecteur nommé (par exemple
#'   `modele$facteur` de [ajuster_hauteur_potentielle()]). Une famille sans facteur prend
#'   celui de la première famille, comme [predire_hauteur_potentielle()]. `NULL` : pas de
#'   colonne `hpot`.
#' @return data.frame : `x`, `y` (s'ils sont dans `carte`), `hpot_k`, `hpot` (si
#'   `facteur`), `h0`, une ligne par ligne de `carte`.
#' @seealso [couvert_strates()], [couvert_strates_dalle()]
#' @export
references_strates <- function(carte, facteur = NULL) {
  verifier_colonnes(carte, c("h_pot", "h_dom"), "la carte")
  out <- if (all(c("x", "y") %in% names(carte))) {
    data.frame(x = as.numeric(carte$x), y = as.numeric(carte$y))
  } else data.frame(row.names = seq_len(nrow(carte)))
  out$hpot_k <- as.numeric(carte$h_pot)
  if (!is.null(facteur)) {
    verifier_colonnes(carte, "famille", "la carte")
    f <- unlist(facteur)
    if (length(f) == 0 || is.null(names(f)) || any(!is.finite(f)) || any(f <= 0)) {
      arreter("facteur doit être un vecteur (ou une liste) nommé par famille, positif")
    }
    k <- f[match(as.character(carte$famille), names(f))]
    k[is.na(k)] <- f[[1]]
    out$hpot <- out$hpot_k / unname(k)
  }
  out$h0 <- as.numeric(carte$h_dom)
  out
}

#' Comptes de points par strate
#'
#' Compte, pour chaque pixel et chaque hauteur de référence H, les retours qui servent au
#' couvert des strates ([couvert_depuis_comptes()]). Les comptes s'additionnent : un
#' pixel coupé par la limite de deux dalles reçoit les comptes des deux.
#'
#' - strate 1 (Z ≥ 3/4 H) : premiers retours `p1`, sur `n_premiers` premiers retours ;
#' - strates 2 à 4 : tous les retours de la strate (`n2`, `n3`, `n4`), sur ceux qui
#'   sont arrivés sous son plafond (`s2` : Z < 3/4 H ; `s3` : Z < H/2 ; `s4` : Z < H/4).
#'   La strate 4 commence à `plancher_m`. Un retour sous `plancher_m` est du sol pour
#'   toutes les strates : sous une référence de moins de 4 m (H/4 < 1 m), il ne compte
#'   ni en strate 4 ni dans les strates du dessus qui descendraient sous le plancher.
#'
#' Les hauteurs Z négatives (sous le sol interpolé) valent 0. Seules les classes
#' `classes` comptent (par défaut 1 à 5 de l'ASPRS, celles du LiDAR HD de l'IGN : non
#' classé, sol, végétation basse, moyenne, haute) ; bâtiments, eau, ponts, bruit et
#' sursol pérenne sont écartés. Un pixel sans référence valable (vide, nulle ou
#' négative) a des comptes vides (`NA`) pour cette référence.
#'
#' @param points data.frame : `cellule` (numéro de pixel, entier), `Z` (hauteur au-dessus
#'   du sol, m), `ReturnNumber`, `Classification`. Une ligne par retour.
#' @param references data.frame : `cellule`, et une colonne numérique (m) par hauteur de
#'   référence, nommée (par exemple celles de [references_strates()]). Une ligne par pixel.
#' @param plancher_m Bas de la strate 4, en m : ce qui est plus bas est le sol (le bruit
#'   du modèle de sol et la strate herbacée). **Provisoire** : 1 m. Ce n'est pas un seuil
#'   du GSM (qui ne fixe pas de diamètre minimum pour le couvert), c'est un seuil de
#'   mesure. Strictement positif : à 0, le sol compterait comme végétation.
#' @param classes Classes de points gardées. **Provisoire** : 1 à 5.
#' @return data.frame, une ligne par pixel touché : `cellule`, `n_tous`, `n_premiers`, et
#'   pour chaque référence `r` : `p1_r`, `n2_r`, `s2_r`, `n3_r`, `s3_r`, `n4_r`, `s4_r`.
#' @seealso [couvert_depuis_comptes()], [couvert_strates()]
#' @export
comptes_strates <- function(points, references, plancher_m = 1, classes = 1:5) {
  verifier_colonnes(points, c("cellule", "Z", "ReturnNumber", "Classification"), "les points")
  verifier_colonnes(references, "cellule", "les références")
  noms <- setdiff(names(references), c("cellule", "x", "y"))
  if (length(noms) == 0) arreter("aucune hauteur de référence dans references")
  if (!all(vapply(as.data.frame(references)[noms], is.numeric, logical(1)))) {
    arreter("les hauteurs de référence doivent être numériques (m)")
  }
  if (anyDuplicated(references$cellule[!is.na(references$cellule)])) {
    arreter("references : une seule ligne par cellule")
  }
  if (length(plancher_m) != 1 || !is.finite(plancher_m) || plancher_m <= 0) {
    arreter("plancher_m doit être strictement positif (m)")
  }
  garde <- points$Classification %in% classes & !is.na(points$cellule) & !is.na(points$Z)
  cel <- as.integer(points$cellule[garde])
  z <- pmax(as.numeric(points$Z[garde]), 0)
  prem <- points$ReturnNumber[garde] == 1
  ids <- sort(unique(cel))
  nb <- length(ids)
  k <- match(cel, ids)
  rm(cel)
  out <- data.frame(cellule = ids, n_tous = tabulate(k, nbins = nb),
                    n_premiers = tabulate(k[prem], nbins = nb))
  ir <- match(ids, references$cellule)
  # Strate de chaque retour, par une seule division (mémoire : une dalle LiDAR HD compte
  # près de 50 millions de retours) : 1 à 4, et 5 pour le sol (sous le plancher).
  bornes <- rev(QUARTS_STRATES)
  sol <- z < plancher_m
  for (r in noms) {
    h_cel <- as.numeric(references[[r]])[ir]
    valable <- !is.na(h_cel) & h_cel > 0
    h_cel[!valable] <- NA_real_
    strate <- 4L - findInterval(z / h_cel[k], bornes)
    # Sous le plancher, c'est le sol, quelle que soit la strate où tomberait le retour :
    # sous une référence de moins de 4 m, le quart du bas est sous le plancher et les
    # strates 3, 2 voire 1 y descendent (mineur de 008).
    strate[sol] <- 5L
    # Comptes par pixel (lignes) et par strate (colonnes) ; NA ignorés par tabulate().
    tous <- matrix(tabulate(k + nb * (strate - 1L), nbins = nb * 5L), nrow = nb, ncol = 5L)
    p1 <- tabulate(k[prem & strate == 1L], nbins = nb)
    rm(strate)
    col <- list(
      p1 = p1,
      n2 = tous[, 2], s2 = rowSums(tous[, 2:5, drop = FALSE]),
      n3 = tous[, 3], s3 = rowSums(tous[, 3:5, drop = FALSE]),
      n4 = tous[, 4], s4 = rowSums(tous[, 4:5, drop = FALSE])
    )
    for (nom in names(col)) {
      v <- as.integer(col[[nom]])
      v[!valable] <- NA_integer_
      out[[paste0(nom, "_", r)]] <- v
    }
  }
  out
}

#' Couvert des strates à partir des comptes
#'
#' Additionne les comptes d'un même pixel (venus de plusieurs dalles) puis calcule, pour
#' chaque référence `r` :
#'
#' - `c1_r` = `p1 / n_premiers` : part des premiers retours au-dessus de 3/4 H, le
#'   couvert de la strate haute vu du dessus ;
#' - `c2_r` = `n2 / s2`, `c3_r` = `n3 / s3`, `c4_r` = `n4 / s4` : part des retours de la
#'   strate parmi ceux qui sont descendus sous son plafond. C'est la probabilité qu'un
#'   rayon arrivé jusqu'à la strate y soit arrêté : le couvert de la strate corrigé de
#'   l'occlusion par les strates du dessus.
#'
#' Les quatre couverts sont entre 0 et 1, chacun pour sa strate : ils ne s'additionnent
#' pas en un couvert total (une strate basse cachée sous une strate haute compte pour son
#' propre couvert). Dénominateur nul : `NA`.
#'
#' @param comptes data.frame rendu par [comptes_strates()] (ou plusieurs, liés par
#'   `rbind`). Les colonnes `x`, `y`, si elles y sont, sont reprises.
#' @return data.frame, une ligne par pixel : `cellule`, `x`, `y` (si présents), `n_tous`,
#'   `n_premiers`, puis `c1_r`, `c2_r`, `c3_r`, `c4_r` pour chaque référence `r`.
#' @export
couvert_depuis_comptes <- function(comptes) {
  verifier_colonnes(comptes, c("cellule", "n_tous", "n_premiers"), "les comptes")
  refs <- sub("^p1_", "", grep("^p1_", names(comptes), value = TRUE))
  if (length(refs) == 0) arreter("aucune référence dans les comptes (colonnes p1_*)")
  num <- setdiff(names(comptes), c("cellule", "x", "y"))
  mat <- as.matrix(as.data.frame(comptes)[num])
  if (nrow(mat) == 0) {
    somme <- mat
    cel <- integer(0)
  } else {
    somme <- rowsum(mat, as.integer(comptes$cellule), reorder = TRUE)
    cel <- as.integer(rownames(somme))
  }
  out <- data.frame(cellule = cel)
  if (all(c("x", "y") %in% names(comptes))) {
    i <- match(cel, comptes$cellule)
    out$x <- comptes$x[i]
    out$y <- comptes$y[i]
  }
  out$n_tous <- somme[, "n_tous"]
  out$n_premiers <- somme[, "n_premiers"]
  part <- function(a, b) ifelse(is.na(b) | b == 0, NA_real_, a / b)
  for (r in refs) {
    s <- function(nom) somme[, paste0(nom, "_", r)]
    out[[paste0("c1_", r)]] <- part(s("p1"), somme[, "n_premiers"])
    out[[paste0("c2_", r)]] <- part(s("n2"), s("s2"))
    out[[paste0("c3_", r)]] <- part(s("n3"), s("s3"))
    out[[paste0("c4_", r)]] <- part(s("n4"), s("s4"))
  }
  rownames(out) <- NULL
  out
}

#' Couvert des strates d'un nuage de points
#'
#' [comptes_strates()] puis [couvert_depuis_comptes()], pour un nuage déjà normalisé
#' (hauteurs au-dessus du sol) et déjà rattaché aux pixels.
#'
#' @inheritParams comptes_strates
#' @return Voir [couvert_depuis_comptes()].
#' @examples
#' # Un pixel, H = 20 m : 10 premiers retours dont 6 au-dessus de 15 m.
#' pts <- data.frame(cellule = 1L, ReturnNumber = 1L, Classification = 5L,
#'                   Z = c(rep(18, 6), rep(8, 2), 0, 0))
#' couvert_strates(pts, data.frame(cellule = 1L, h = 20))
#' @export
couvert_strates <- function(points, references, plancher_m = 1, classes = 1:5) {
  couvert_depuis_comptes(comptes_strates(points, references, plancher_m, classes))
}

# Grille de pixels : SpatRaster de terra, ou gabarit de lire_parametres_lidar() (liste
# xmin, xmax, ymin, ymax, resolution).
grille_strates <- function(gabarit) {
  if (inherits(gabarit, "SpatRaster")) {
    e <- as.vector(terra::ext(gabarit))
    return(list(xmin = e[["xmin"]], ymax = e[["ymax"]], res = terra::res(gabarit),
                ncol = terra::ncol(gabarit), nrow = terra::nrow(gabarit)))
  }
  if (is.list(gabarit) && all(c("xmin", "xmax", "ymin", "ymax", "resolution") %in% names(gabarit))) {
    res <- rep_len(as.numeric(gabarit$resolution), 2)
    return(list(xmin = gabarit$xmin, ymax = gabarit$ymax, res = res,
                ncol = as.integer(round((gabarit$xmax - gabarit$xmin) / res[1])),
                nrow = as.integer(round((gabarit$ymax - gabarit$ymin) / res[2]))))
  }
  arreter("gabarit doit être un SpatRaster ou le gabarit de lire_parametres_lidar()")
}

# Numéro de pixel (ordre de terra : ligne par ligne depuis le nord-ouest, à partir de 1)
# des points (x, y) ; NA hors de la grille. Arithmétique pure, sans terra, pour être
# appelée dans le rappel de lasR.
cellules_xy <- function(grille, x, y) {
  col <- floor((x - grille$xmin) / grille$res[1])
  lig <- floor((grille$ymax - y) / grille$res[2])
  dedans <- !is.na(col) & !is.na(lig) & col >= 0 & col < grille$ncol & lig >= 0 & lig < grille$nrow
  out <- rep(NA_integer_, length(x))
  out[dedans] <- as.integer(lig[dedans] * grille$ncol + col[dedans] + 1)
  out
}

#' Couvert des strates d'une dalle LiDAR HD (comptes)
#'
#' Lit une dalle de nuage de points (LAS, LAZ ou COPC, par exemple une dalle LiDAR HD de
#' l'IGN), la normalise avec lasR (triangulation des points de sol, classe 2, et hauteur
#' au-dessus de ce sol), rattache chaque retour au pixel de `gabarit` qui le contient, et
#' rend les comptes de [comptes_strates()] des pixels touchés, avec leur centre `x`, `y`.
#' On traite une dalle à la fois ; les comptes de plusieurs dalles se lient par `rbind`
#' et se terminent par [couvert_depuis_comptes()].
#'
#' La dalle est normalisée seule, sans tampon : au bord, le sol est interpolé avec les
#' seuls points de la dalle.
#'
#' lasR est en Suggests (installation : voir le README, il faut GDAL) ; sans lui, la
#' fonction s'arrête.
#'
#' @param fichier Chemin de la dalle.
#' @param gabarit Grille des pixels : `SpatRaster` de terra, ou gabarit de
#'   [lire_parametres_lidar()] (attribut `gabarit`), dans le système de coordonnées du
#'   nuage (Lambert-93 pour le LiDAR HD).
#' @param references data.frame : `x`, `y` (centres des pixels, m, même système) et une
#'   colonne par hauteur de référence (par exemple [references_strates()]).
#' @param ncores Nombre de cœurs donnés à lasR ; `NULL` : réglage de lasR.
#' @inheritParams comptes_strates
#' @return Les comptes de [comptes_strates()], plus `x`, `y` (centre du pixel, m).
#' @examples
#' \dontrun{
#' v <- lire_parametres_lidar("chemin/vers/vercors")
#' refs <- references_strates(carte, facteur = modele$facteur)
#' cpt <- couvert_strates_dalle("LHD_FXX_0875_6426_PTS_LAMB93_IGN69.copc.laz",
#'                              attr(v, "gabarit"), refs)
#' couvert_depuis_comptes(cpt)
#' }
#' @export
couvert_strates_dalle <- function(fichier, gabarit, references, plancher_m = 1,
                                  classes = 1:5, ncores = NULL) {
  if (!requireNamespace("lasR", quietly = TRUE)) {
    arreter(paste0("lasR n'est pas installé : le nuage de points ne peut pas être lu ",
                   "(installation depuis r-universe, voir le README)"))
  }
  if (length(fichier) != 1) arreter("une seule dalle \u00e0 la fois (fichier de longueur 1)")
  if (!file.exists(fichier)) arreter(sprintf("dalle introuvable : %s", fichier))
  verifier_colonnes(references, c("x", "y"), "les références")
  grille <- grille_strates(gabarit)
  refs <- as.data.frame(references)
  refs$cellule <- cellules_xy(grille, refs$x, refs$y)
  refs <- refs[!is.na(refs$cellule), setdiff(names(refs), c("x", "y")), drop = FALSE]
  if (anyDuplicated(refs$cellule)) arreter("references : deux lignes dans le même pixel")

  sol <- lasR::triangulate(filter = lasR::keep_ground())
  normalise <- lasR::transform_with(sol, "-")
  rappel <- lasR::callback(function(d) {
    pts <- data.frame(cellule = cellules_xy(grille, d$X, d$Y), Z = d$Z,
                      ReturnNumber = d$ReturnNumber, Classification = d$Classification)
    comptes_strates(pts, refs, plancher_m, classes)
  }, expose = "xyzrc", no_las_update = TRUE)
  args <- list(sol + normalise + rappel, on = fichier, progress = FALSE)
  if (!is.null(ncores)) args$ncores <- ncores
  res <- do.call(lasR::exec, args)
  if (!is.data.frame(res)) {
    morceaux <- Filter(is.data.frame, if (is.list(res)) res else list())
    if (length(morceaux) == 0) arreter("lasR n'a rendu aucun compte pour cette dalle")
    res <- do.call(rbind, morceaux)
  }
  lig <- (res$cellule - 1L) %/% grille$ncol
  col <- (res$cellule - 1L) %% grille$ncol
  res$x <- grille$xmin + (col + 0.5) * grille$res[1]
  res$y <- grille$ymax - (lig + 0.5) * grille$res[2]
  res
}

#' Dalles LiDAR HD sur le contour d'une emprise
#'
#' Garde les dalles dont l'emprise touche le **contour** de l'AOI (ses polygones), et non
#' son rectangle englobant (mineur de 008). Avec `gabarit`, le contour est d'abord coupé
#' à l'emprise de la grille des pixels : une dalle qui ne touche que la partie de l'AOI
#' hors de la grille n'apporterait aucun compte (à Léoncel, une parcelle détachée à
#' l'ouest, hors du jeu ONF, appelait trois dalles pour rien).
#'
#' @param dalles Les dalles : objet `sf`/`sfc` de leurs emprises (par exemple le WFS
#'   `IGNF_LIDAR-HD_METADONNEE:metadata` de la Géoplateforme), ou vecteur de noms
#'   (`"LHD_FXX_0873_6430_PTS_..."`, `"0873-6430"`, `"0873_6430"`, URL comprises) : les
#'   deux nombres sont le coin nord-ouest en km (Lambert-93), la dalle fait `cote_m` de
#'   côté.
#' @param aoi Emprise : objet `sf` ou `sfc` (polygones), reprojetée en Lambert-93.
#' @param gabarit Grille des pixels ([grille_strates()] : `SpatRaster` ou gabarit de
#'   [lire_parametres_lidar()]) ; `NULL` : contour entier.
#' @param cote_m Côté d'une dalle nommée, en m (1 000 m pour le LiDAR HD).
#' @return Le sous-ensemble de `dalles` (même forme qu'en entrée), dans le même ordre.
#' @export
dalles_sur_aoi <- function(dalles, aoi, gabarit = NULL, cote_m = 1000) {
  if (!inherits(aoi, c("sf", "sfc"))) arreter("aoi doit être un objet sf ou sfc")
  zone <- sf::st_union(sf::st_make_valid(sf::st_transform(sf::st_geometry(aoi), 2154)))
  if (!is.null(gabarit)) {
    g <- grille_strates(gabarit)
    cadre <- sf::st_as_sfc(sf::st_bbox(c(xmin = g$xmin, ymin = g$ymax - g$nrow * g$res[2],
                                         xmax = g$xmin + g$ncol * g$res[1], ymax = g$ymax),
                                       crs = sf::st_crs(2154)))
    zone <- sf::st_intersection(zone, cadre)
  }
  if (is.character(dalles)) {
    m <- regmatches(basename(dalles), regexpr("[0-9]{4}[_-][0-9]{4}", basename(dalles)))
    if (length(m) != length(dalles)) arreter("nom de dalle sans coin nord-ouest (XXXX_YYYY, en km)")
    km <- do.call(rbind, strsplit(m, "[_-]"))
    x0 <- as.numeric(km[, 1]) * 1000
    y1 <- as.numeric(km[, 2]) * 1000
    carres <- lapply(seq_along(x0), function(k) sf::st_polygon(list(rbind(
      c(x0[k], y1[k]), c(x0[k] + cote_m, y1[k]), c(x0[k] + cote_m, y1[k] - cote_m),
      c(x0[k], y1[k] - cote_m), c(x0[k], y1[k])))))
    geom <- sf::st_sfc(carres, crs = 2154)
  } else if (inherits(dalles, c("sf", "sfc"))) {
    geom <- sf::st_transform(sf::st_geometry(dalles), 2154)
  } else {
    arreter("dalles doit être un objet sf, sfc ou un vecteur de noms de dalles")
  }
  garde <- if (length(zone) == 0 || all(sf::st_is_empty(zone))) {
    rep(FALSE, length(geom))
  } else {
    # Toucher, pas seulement partager un bord : l'intérieur de la dalle coupe la zone.
    lengths(sf::st_relate(geom, zone, pattern = "2********")) > 0
  }
  if (is.data.frame(dalles)) dalles[garde, , drop = FALSE] else dalles[garde]
}

# Lit les couverts des strates fournis : data.frame de couvert_depuis_comptes() ou de
# comptes_strates() (colonnes p1_*), ou chemins de fichiers .rds (un ou plusieurs ; des
# comptes de plusieurs dalles s'additionnent). Rend x, y et c1..c4 de la référence.
lire_couverts_fournis <- function(strates, reference) {
  if (is.character(strates)) {
    if (!all(grepl("\\.rds$", strates, ignore.case = TRUE))) {
      arreter("strates : chemins .rds attendus (comptes ou couverts), ou dalles .la[sz]")
    }
    manque <- strates[!file.exists(strates)]
    if (length(manque) > 0) arreter(sprintf("strates introuvables : %s", paste(manque, collapse = ", ")))
    strates <- do.call(rbind, lapply(strates, readRDS))
  }
  if (!is.data.frame(strates)) arreter("strates doit être un data.frame ou des chemins de fichiers")
  if (any(grepl("^p1_", names(strates)))) strates <- couvert_depuis_comptes(strates)
  cols <- paste0("c", 1:4, "_", reference)
  verifier_colonnes(strates, c("x", "y", cols), "les couverts des strates")
  as.data.frame(strates)[, c("x", "y", cols)]
}

# Pixel de chaque point (x, y), dans la grille du gabarit si on l'a ; sinon par centre
# exact (arrondi au mm).
apparier_pixels <- function(x_pix, y_pix, x, y, gabarit = NULL) {
  if (!is.null(gabarit)) {
    g <- grille_strates(gabarit)
    return(match(cellules_xy(g, x, y), cellules_xy(g, x_pix, y_pix)))
  }
  match(paste(round(x, 3), round(y, 3)), paste(round(x_pix, 3), round(y_pix, 3)))
}

# Contrôle du couvert de la strate 1 contre le taux de couvert du producteur : le taux de
# couvert (Tx_couv) se compare au couvert vu du dessus, c1, pas à la somme des strates,
# qui n'a pas de sens (chaque strate est corrigée de l'occlusion ; mineur de 008).
# Corrélation mesurée, sans seuil (décision du 2026-11-22) ; pas une validation.
controle_couvert_c1 <- function(c1, couvert) {
  ok <- !is.na(c1) & !is.na(couvert)
  n <- sum(ok)
  if (n < 3 || stats::sd(c1[ok]) == 0 || stats::sd(couvert[ok]) == 0) {
    return(list(n = n, pearson = NA_real_, spearman = NA_real_))
  }
  list(n = n, pearson = stats::cor(c1[ok], couvert[ok]),
       spearman = stats::cor(c1[ok], couvert[ok], method = "spearman"))
}

# Hauteur potentielle sans enveloppe (h_pot / k de la famille), comme references_strates().
hpot_sans_enveloppe <- function(h_pot, famille, facteur) {
  f <- unlist(facteur)
  if (length(f) == 0) return(rep(NA_real_, length(h_pot)))
  k <- if (is.null(famille)) rep(f[[1]], length(h_pot)) else f[match(as.character(famille), names(f))]
  k[is.na(k)] <- f[[1]]
  as.numeric(h_pot) / unname(k)
}

# Couverts des strates d'un nuage : une dalle à la fois, comptes additionnés.
couverts_depuis_dalles <- function(dalles, gabarit, references, plancher_m = 1, ncores = NULL) {
  if (is.null(gabarit)) arreter("strates depuis des dalles : les variables doivent porter leur gabarit")
  cpt <- lapply(dalles, function(f) couvert_strates_dalle(f, gabarit, references,
                                                          plancher_m = plancher_m, ncores = ncores))
  couvert_depuis_comptes(do.call(rbind, cpt))
}

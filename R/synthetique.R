# Jeu de données synthétique, pour les tests et la démonstration (synthetique.py).
#
# Il n'imite aucune forêt réelle : il sert à vérifier que la chaîne tourne de bout en
# bout et qu'elle retrouve une structure connue. Même recette que le prototype, mais le
# hasard de R n'est pas celui de numpy : à graine égale, les tirages diffèrent. Pour
# comparer les deux versions sur les mêmes données, voir tests/testthat/fixtures/.

TAILLE_PIXEL_M <- 25

# Filtre gaussien 1D le long des lignes d'une matrice, bords en miroir (mode « reflect »
# de scipy : d c b a | a b c d | d c b a), noyau tronqué à 4 écarts-types.
gaussien_lignes <- function(z, sigma) {
  rayon <- as.integer(4 * sigma + 0.5)
  if (rayon < 1) return(z)
  x <- -rayon:rayon
  noyau <- exp(-0.5 * (x / sigma)^2)
  noyau <- noyau / sum(noyau)
  n <- ncol(z)
  miroir <- function(k) {
    periode <- 2 * n
    k <- (k - 1) %% periode
    ifelse(k < n, k + 1, periode - k)
  }
  out <- matrix(0, nrow(z), n)
  for (d in seq_along(x)) out <- out + noyau[d] * z[, miroir(seq_len(n) + x[d]), drop = FALSE]
  out
}

filtre_gaussien <- function(z, sigma) t(gaussien_lignes(t(gaussien_lignes(z, sigma)), sigma))

champ_lisse <- function(forme, echelle, bas, haut) {
  z <- filtre_gaussien(matrix(stats::rnorm(prod(forme)), forme[1], forme[2], byrow = TRUE), echelle)
  z <- (z - min(z)) / (max(z) - min(z) + 1e-12)
  bas + z * (haut - bas)
}

# Étire un champ pour que ses valeurs couvrent [bas, haut] uniformément (par rangs).
uniforme_rangs <- function(z, bas, haut) {
  r <- (rank(z, ties.method = "first") - 1) / (length(z) - 1)
  matrix(bas + r * (haut - bas), nrow(z), ncol(z))
}

bruit <- function(forme, sd) matrix(stats::rnorm(prod(forme), 0, sd), forme[1], forme[2], byrow = TRUE)

# Aplatit une matrice ligne par ligne (ordre des pixels du prototype : i puis j).
aplatir <- function(m) as.vector(t(m))

#' Générer le jeu de données synthétique
#'
#' Grille de pixels avec variables de milieu, hauteur dominante, couvert, famille et
#' prédicteurs simulés (métriques LiDAR, indices Sentinel-2), vérité dendrométrique et
#' placettes tirées dans la grille avec un bruit de mesure. Les vraies données entrent par
#' les mêmes colonnes. Ce jeu n'imite aucune forêt réelle.
#'
#' Les coordonnées des placettes sont `x = i * 25`, `y = j * 25` (m) : pixels de 25 m.
#'
#' @param ni,nj Taille de la grille, en pixels.
#' @param n_placettes Nombre de placettes tirées.
#' @param graine Graine du hasard (le générateur de l'utilisateur n'est pas touché).
#'
#' @return Liste : `placettes`, `pixels`, `verite` (data.frame ; `verite` porte aussi
#'   `i`, `j` et la hauteur potentielle vraie `h_pot`).
#' @examples
#' jeu <- generer_jeu_synthetique(20, 20, 50, graine = 1)
#' str(jeu$placettes)
#' @export
generer_jeu_synthetique <- function(ni = 60, nj = 60, n_placettes = 400, graine = 0) {
  if (n_placettes > ni * nj) arreter("plus de placettes que de pixels")
  avec_graine(graine, {
    forme <- c(ni, nj)
    altitude <- champ_lisse(forme, 8, 400, 1800)
    bilan_hydrique <- champ_lisse(forme, 6, -250, 150)
    reserve_utile <- champ_lisse(forme, 4, 40, 180)
    pente <- champ_lisse(forme, 3, 0, 40)
    # Hauteur atteignable : meilleure en basse altitude, sur sol profond et bien alimenté.
    h_pot <- 38 - 0.008 * (altitude - 400) + 0.03 * bilan_hydrique + 0.04 * (reserve_utile - 100)
    h_pot <- pmin(pmax(h_pot, 10), 45)
    age <- uniforme_rangs(champ_lisse(forme, 2, 0, 1), 10, 160)
    h_dom <- h_pot * (1 - exp(-age / 45)) + bruit(forme, 0.8)
    part_resineux <- pmin(pmax(champ_lisse(forme, 5, -0.3, 1.3), 0), 1)
    irregularite <- champ_lisse(forme, 3, 0, 0.6)

    # Parts de PB, BM, GB : l'âge fait passer des PB aux GB, l'irrégularité mélange.
    tt <- pmin(pmax(age / 160, 0), 1)
    pb <- (1 - tt)^2
    gb <- tt^2
    bm <- 2 * tt * (1 - tt)
    pb <- (1 - irregularite) * pb + irregularite / 3
    bm <- (1 - irregularite) * bm + irregularite / 3
    gb <- (1 - irregularite) * gb + irregularite / 3
    s <- pb + bm + gb
    pb <- pb / s
    bm <- bm / s
    gb <- gb / s
    G <- pmin(pmax(8 + 30 * tt * (h_pot / 35) + bruit(forme, 2), 2), 60)
    couvert <- pmin(pmax(0.4 + 0.5 * tt + bruit(forme, 0.05), 0), 1)

    pixels <- data.frame(
      i = rep(seq_len(ni) - 1L, each = nj),
      j = rep(seq_len(nj) - 1L, times = ni),
      altitude = aplatir(altitude),
      pente = aplatir(pente),
      bilan_hydrique = aplatir(bilan_hydrique),
      reserve_utile = aplatir(reserve_utile),
      h_dom = aplatir(h_dom),
      couvert = aplatir(couvert),
      famille = ifelse(aplatir(part_resineux) >= 0.5, "resineux", "feuillus"),
      lidar_h95 = aplatir(h_dom + bruit(forme, 1)),
      lidar_h50 = aplatir(h_dom * (0.75 - 0.25 * irregularite) + bruit(forme, 1)),
      lidar_cv_h = aplatir(0.15 + 0.5 * irregularite + bruit(forme, 0.04)),
      lidar_couvert = aplatir(couvert + bruit(forme, 0.03)),
      lidar_sous_etage = aplatir(pb * 0.6 + 0.4 * irregularite + bruit(forme, 0.05)),
      s2_ndvi_hiver = aplatir(0.2 + 0.6 * part_resineux + bruit(forme, 0.05)),
      s2_amplitude_ndvi = aplatir(0.6 - 0.45 * part_resineux + bruit(forme, 0.05)),
      stringsAsFactors = FALSE
    )
    verite <- data.frame(
      i = pixels$i, j = pixels$j,
      G = aplatir(G), part_resineux = aplatir(part_resineux),
      part_pb = aplatir(pb), part_bm = aplatir(bm), part_gb = aplatir(gb),
      h_pot = aplatir(h_pot)
    )
    idx <- sample.int(nrow(pixels), n_placettes)
    placettes <- pixels[idx, , drop = FALSE]
    mes <- verite[idx, , drop = FALSE]
    for (c in c("G", "part_resineux", "part_pb", "part_bm", "part_gb")) {
      sd <- if (startsWith(c, "part")) 0.03 else 1
      placettes[[c]] <- mes[[c]] + stats::rnorm(n_placettes, 0, sd)
    }
    for (c in c("part_resineux", "part_pb", "part_bm", "part_gb")) {
      placettes[[c]] <- pmin(pmax(placettes[[c]], 0), 1)
    }
    s <- placettes$part_pb + placettes$part_bm + placettes$part_gb
    for (c in PARTS_CATEGORIES) placettes[[c]] <- placettes[[c]] / s
    placettes$x <- placettes$i * TAILLE_PIXEL_M
    placettes$y <- placettes$j * TAILLE_PIXEL_M
    placettes <- cbind(placette = sprintf("P%04d", seq_len(n_placettes) - 1L), placettes,
                       stringsAsFactors = FALSE)
    rownames(placettes) <- NULL
    list(placettes = placettes, pixels = pixels, verite = verite)
  })
}

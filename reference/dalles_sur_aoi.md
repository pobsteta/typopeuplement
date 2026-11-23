# Dalles LiDAR HD sur le contour d'une emprise

Garde les dalles dont l'emprise touche le **contour** de l'AOI (ses
polygones), et non son rectangle englobant (mineur de 008). Avec
`gabarit`, le contour est d'abord coupé à l'emprise de la grille des
pixels : une dalle qui ne touche que la partie de l'AOI hors de la
grille n'apporterait aucun compte (à Léoncel, une parcelle détachée à
l'ouest, hors du jeu ONF, appelait trois dalles pour rien).

## Usage

``` r
dalles_sur_aoi(dalles, aoi, gabarit = NULL, cote_m = 1000)
```

## Arguments

- dalles:

  Les dalles : objet `sf`/`sfc` de leurs emprises (par exemple le WFS
  `IGNF_LIDAR-HD_METADONNEE:metadata` de la Géoplateforme), ou vecteur
  de noms (`"LHD_FXX_0873_6430_PTS_..."`, `"0873-6430"`, `"0873_6430"`,
  URL comprises) : les deux nombres sont le coin nord-ouest en km
  (Lambert-93), la dalle fait `cote_m` de côté.

- aoi:

  Emprise : objet `sf` ou `sfc` (polygones), reprojetée en Lambert-93.

- gabarit:

  Grille des pixels (`grille_strates()` : `SpatRaster` ou gabarit de
  [`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md))
  ; `NULL` : contour entier.

- cote_m:

  Côté d'une dalle nommée, en m (1 000 m pour le LiDAR HD).

## Value

Le sous-ensemble de `dalles` (même forme qu'en entrée), dans le même
ordre.

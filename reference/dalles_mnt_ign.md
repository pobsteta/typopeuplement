# Requêtes WMS-Raster du MNT de l'IGN sur une grille

Découpe en dalles l'emprise du gabarit élargie d'une marge, sur une
grille fine alignée sur celle du gabarit (résolution du gabarit divisée
par `facteur`), et rend les requêtes `GetMap` du service WMS-Raster de
la Géoplateforme (GeoTIFF flottant 32 bits, Lambert-93). Aucun accès
réseau : voir
[`telecharger_mnt_ign()`](https://pobsteta.github.io/typopeuplement/reference/telecharger_mnt_ign.md).

## Usage

``` r
dalles_mnt_ign(
  gabarit,
  facteur = 2L,
  marge_m = 500,
  taille_max = 2000L,
  couche = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
  url = "https://data.geopf.fr/wms-r/wms"
)
```

## Arguments

- gabarit:

  Grille du jeu : liste `xmin`, `xmax`, `ymin`, `ymax`, `resolution`,
  `crs` (attribut `gabarit` de
  [`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md))
  ou `SpatRaster`.

- facteur:

  Rapport entier entre la résolution du gabarit et celle du MNT
  téléchargé. **Provisoire** : 2 (13,3 m pour la grille ONF de 26,6 m).

- marge_m:

  Marge autour de l'emprise, en m, arrondie au pixel du gabarit
  supérieur ; elle doit couvrir le rayon de la position topographique.
  **Provisoire** : 500.

- taille_max:

  Nombre maximal de colonnes et de lignes d'une dalle (le service en
  accepte 5 010). **Provisoire** : 2 000.

- couche:

  Couche WMS-Raster. Par défaut
  `ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES` (RGE ALTI, MNT au pas de 1 à
  5 m de l'IGN, données ouvertes, Licence ouverte 2.0).

- url:

  Point d'accès du service WMS-Raster.

## Value

data.frame, une ligne par dalle : `xmin`, `xmax`, `ymin`, `ymax` (m,
Lambert-93), `largeur`, `hauteur` (pixels), `url` (requête complète).

## See also

[`telecharger_mnt_ign()`](https://pobsteta.github.io/typopeuplement/reference/telecharger_mnt_ign.md)

# Calculer le relief sur la grille d'un jeu

Ramène le MNT sur la grille du jeu (moyenne des cellules fines qui
tombent dans chaque pixel), puis calcule les variables de
[`variables_relief()`](https://pobsteta.github.io/typopeuplement/reference/variables_relief.md).
Les voisinages (pente, position topographique) sont calculés sur la
grille élargie à toute l'étendue du MNT, puis le résultat est découpé
exactement sur le gabarit : même emprise, même résolution, même système
que les rasters du producteur.

## Usage

``` r
calculer_relief(mnt, gabarit, rayon_tpi_m = 300, pente_plate_deg = 1)
```

## Arguments

- mnt:

  MNT : chemin d'un raster ou `SpatRaster` (altitude en m, Lambert-93),
  par exemple rendu par
  [`telecharger_mnt_ign()`](https://pobsteta.github.io/typopeuplement/reference/telecharger_mnt_ign.md).
  Il doit déborder du gabarit d'au moins `rayon_tpi_m` pour que la
  position topographique soit complète en bordure.

- gabarit:

  Grille du jeu (voir
  [`dalles_mnt_ign()`](https://pobsteta.github.io/typopeuplement/reference/dalles_mnt_ign.md)).

- rayon_tpi_m:

  Rayon du disque de la position topographique, en m. **Provisoire** :
  300.

- pente_plate_deg:

  Sous cette pente, en degrés, l'exposition n'a pas de sens : `expo_sin`
  et `expo_cos` valent 0. **Provisoire** : 1.

## Value

`SpatRaster` à cinq couches
([`variables_relief()`](https://pobsteta.github.io/typopeuplement/reference/variables_relief.md)),
aligné sur le gabarit. Attribut `temps` (secondes).

## See also

[`milieu_pixels()`](https://pobsteta.github.io/typopeuplement/reference/milieu_pixels.md)

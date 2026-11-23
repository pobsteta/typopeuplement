# Télécharger le MNT de l'IGN sur la grille d'un jeu

Télécharge les dalles de
[`dalles_mnt_ign()`](https://pobsteta.github.io/typopeuplement/reference/dalles_mnt_ign.md)
(service WMS-Raster de la Géoplateforme, accès libre sans clé) dans
`dossier`, les assemble et écrit `mnt.tif` (altitude en m, Lambert-93).
Les valeurs hors service (-99 999 ou moins) deviennent vides. Les dalles
déjà présentes ne sont pas retéléchargées.

## Usage

``` r
telecharger_mnt_ign(
  gabarit,
  dossier,
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

- dossier:

  Dossier de téléchargement (hors du dépôt).

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

Chemin de `mnt.tif`, avec l'attribut `dalles` (table des requêtes) et
`temps` (secondes).

## Details

Le service rend le MNT rééchantillonné au pas demandé : c'est une
moyenne d'affichage du RGE ALTI, pas le fichier d'origine. À 13,3 m,
l'écart est sans effet sur une pente calculée au pas de 26,6 m.

## Examples

``` r
if (FALSE) { # \dontrun{
v <- lire_parametres_lidar("chemin/vers/vercors")
mnt <- telecharger_mnt_ign(attr(v, "gabarit"), "chemin/hors/depot")
} # }
```

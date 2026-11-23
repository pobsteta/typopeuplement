# Couvert des strates d'une dalle LiDAR HD (comptes)

Lit une dalle de nuage de points (LAS, LAZ ou COPC, par exemple une
dalle LiDAR HD de l'IGN), la normalise avec lasR (triangulation des
points de sol, classe 2, et hauteur au-dessus de ce sol), rattache
chaque retour au pixel de `gabarit` qui le contient, et rend les comptes
de
[`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)
des pixels touchés, avec leur centre `x`, `y`. On traite une dalle à la
fois ; les comptes de plusieurs dalles se lient par `rbind` et se
terminent par
[`couvert_depuis_comptes()`](https://pobsteta.github.io/typopeuplement/reference/couvert_depuis_comptes.md).

## Usage

``` r
couvert_strates_dalle(
  fichier,
  gabarit,
  references,
  plancher_m = 1,
  classes = 1:5,
  ncores = NULL,
  houppiers = NULL,
  sommets = NULL
)
```

## Arguments

- fichier:

  Chemin de la dalle.

- gabarit:

  Grille des pixels : `SpatRaster` de terra, ou gabarit de
  [`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md)
  (attribut `gabarit`), dans le système de coordonnées du nuage
  (Lambert-93 pour le LiDAR HD).

- references:

  data.frame : `x`, `y` (centres des pixels, m, même système) et une
  colonne par hauteur de référence (par exemple
  [`references_strates()`](https://pobsteta.github.io/typopeuplement/reference/references_strates.md)).

- plancher_m:

  Bas de la strate 4, en m : ce qui est plus bas est le sol (le bruit du
  modèle de sol et la strate herbacée). **Provisoire** : 1 m. Ce n'est
  pas un seuil du GSM (qui ne fixe pas de diamètre minimum pour le
  couvert), c'est un seuil de mesure. Strictement positif : à 0, le sol
  compterait comme végétation.

- classes:

  Classes de points gardées. **Provisoire** : 1 à 5.

- ncores:

  Nombre de cœurs donnés à lasR ; `NULL` : réglage de lasR.

- houppiers:

  Segmentation
  ([`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md),
  ou liste `houppiers` et `mnh`), une seule ; `NULL` : pas de retrait.

- sommets:

  Sommets de cette segmentation
  ([`sommets_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/sommets_houppiers.md)),
  pour ne pas les relire à chaque dalle ; `NULL` : lus ici.

## Value

Les comptes de
[`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md),
plus `x`, `y` (centre du pixel, m).

## Details

La dalle est normalisée seule, sans tampon : au bord, le sol est
interpolé avec les seuls points de la dalle.

Avec `houppiers` (une segmentation de
[`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md),
faite sur toutes les dalles en un seul `exec`), chaque retour reçoit la
cime du houppier où il tombe, vu du dessus, et les retours des houppiers
de la strate 1 sont retirés des strates 2 à 4 (voir
[`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)
; mode hybride, décision du 2026-11-23).

lasR est en Suggests (installation : voir le README, il faut GDAL) ;
sans lui, la fonction s'arrête.

## Examples

``` r
if (FALSE) { # \dontrun{
v <- lire_parametres_lidar("chemin/vers/vercors")
refs <- references_strates(carte, facteur = modele$facteur)
cpt <- couvert_strates_dalle("LHD_FXX_0875_6426_PTS_LAMB93_IGN69.copc.laz",
                             attr(v, "gabarit"), refs)
couvert_depuis_comptes(cpt)
} # }
```

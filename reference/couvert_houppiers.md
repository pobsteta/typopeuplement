# Couvert des strates par houppier

À partir d'une segmentation
([`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md)),
range chaque arbre dans une strate du GSM selon la hauteur de sa cime,
puis additionne, pour chaque pixel de la grille, la surface des
houppiers de chaque strate :

## Usage

``` r
couvert_houppiers(houppiers, gabarit, references, lignes_bloc = 1000L)
```

## Arguments

- houppiers:

  Objet `typo_houppiers`
  ([`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md)),
  ou liste `houppiers` (identifiants) et `mnh` (hauteurs, m) : chemins
  ou `SpatRaster` de même grille ; ou une liste de tels objets.

- gabarit:

  Grille des pixels : `SpatRaster` de terra, ou gabarit de
  [`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md),
  dans le système de coordonnées du nuage (Lambert-93).

- references:

  data.frame : `x`, `y` (centres des pixels, m) et une colonne par
  hauteur de référence (m), par exemple
  [`references_strates()`](https://pobsteta.github.io/typopeuplement/reference/references_strates.md).

- lignes_bloc:

  Nombre de lignes du MNH lues à la fois.

## Value

data.frame, une ligne par pixel touché par le MNH : `cellule`, `x`, `y`,
`n_cellules` (cellules de MNH), `n_houppiers` (sommets dans le pixel),
`densite_houppiers` (tiges/ha), puis `c1_r` à `c4_r` pour chaque
référence `r` (vides si la référence du pixel manque). Attribut
`parametres` : ceux de la segmentation.

## Details

- sommet d'un houppier = sa cellule la plus haute dans le MNH
  ([`sommets_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/sommets_houppiers.md))
  ; sa hauteur est celle de l'arbre ; le houppier numéro 0 est un arbre
  comme les autres ;

- strate de l'arbre = quart de la hauteur de référence H **du pixel de
  son sommet** (strate 1 : cime ≥ 3/4 H ; 2 : ≥ H/2 ; 3 : ≥ H/4 ; 4 : en
  dessous), comme
  [`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)
  pour les retours. Un arbre dont le sommet tombe dans un pixel sans
  référence (hors de `references`) prend, cellule par cellule, la
  référence du pixel où tombe la cellule ;

- `c<k>_<r>` = surface des cellules des houppiers de la strate k dans le
  pixel, divisée par la surface du pixel couverte par le MNH. Numérateur
  et dénominateur ne comptent que les cellules qui ont une hauteur : un
  couvert ne dépasse pas 1. Un houppier à cheval sur deux pixels compte
  dans chacun pour sa part, avec la strate de son arbre.

C'est un couvert **vu du dessus** : chaque cellule n'appartient qu'à un
houppier, et les quatre couverts s'additionnent au plus à 1. Les strates
basses sont masquées par les houppiers du dessus (sous-étage
sous-estimé) : d'où le mode hybride de la chaîne (strate 1 par les
houppiers, strates 2 à 4 par les tranches, sans les retours qui tombent
dans les houppiers de la strate 1,
[`typer_peuplements()`](https://pobsteta.github.io/typopeuplement/reference/typer_peuplements.md)).

La densité des houppiers (`densite_houppiers`, sommets par hectare de
MNH) est rendue pour la lecture ; elle ne sert pas à la clé (le seuil de
densité de la clé de H10 porte sur N du producteur, décision de Pascal
du 2026-11-23).

Plusieurs segmentations (une liste) s'additionnent pixel par pixel ; un
houppier coupé à la limite de deux segmentations y compte pour deux
arbres : on segmente toutes les dalles en un seul `exec`
([`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md),
décision du 2026-11-23). Les rasters sont lus par blocs de `lignes_bloc`
lignes.

## See also

[`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md),
[`sommets_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/sommets_houppiers.md),
[`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md)

## Examples

``` r
# Deux pixels de 10 m ; MNH de 1 m ; un houppier de 4 x 4 m, cime à 18 m, dans le
# premier pixel (H = 20 m) : strate 1, couvert 16 / 100.
ids <- terra::rast(nrows = 10, ncols = 20, xmin = 0, xmax = 20, ymin = 0, ymax = 10,
                   crs = "EPSG:2154")
h <- ids
terra::values(ids) <- NA
terra::values(h) <- 0
ids[3:6, 3:6] <- 1
h[3:6, 3:6] <- 15
h[4, 4] <- 18
gab <- list(xmin = 0, xmax = 20, ymin = 0, ymax = 10, resolution = 10)
couvert_houppiers(list(houppiers = ids, mnh = h), gab,
                  data.frame(x = c(5, 15), y = 5, h = 20))
#>   cellule  x y n_cellules n_houppiers densite_houppiers c1_h c2_h c3_h c4_h
#> 1       1  5 5        100           1               100 0.16    0    0    0
#> 2       2 15 5        100           0                 0 0.00    0    0    0
```

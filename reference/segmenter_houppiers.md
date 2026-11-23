# Segmenter les houppiers d'un nuage de points LiDAR HD

Segmente les arbres d'une ou plusieurs dalles de nuage de points (LAS,
LAZ ou COPC, par exemple les dalles LiDAR HD de l'IGN) avec lasR, en
**un seul** `exec` sur toutes les dalles, lues avec un tampon : un
houppier à cheval sur deux dalles n'est pas coupé.

## Usage

``` r
segmenter_houppiers(
  dalles,
  dossier,
  fenetre_m = 3,
  hauteur_min_m = 2,
  resolution_m = 0.5,
  tampon_m = 20,
  traiter = NULL,
  classes = 1:5,
  ncores = NULL
)
```

## Arguments

- dalles:

  Chemins des dalles.

- dossier:

  Dossier de sortie (créé au besoin).

- fenetre_m:

  Diamètre de la fenêtre des maxima locaux, m. **Provisoire** : 3 m.

- hauteur_min_m:

  Hauteur minimale d'un sommet et d'une cellule de houppier, m.
  **Provisoire** : 2 m.

- resolution_m:

  Côté des cellules du MNH, m. **Provisoire** : 0,5 m.

- tampon_m:

  Tampon de lecture autour de chaque dalle, m (lasR prend le plus grand
  de cette valeur et de celle que demandent ses étapes). Par défaut 20
  m, la largeur maximale d'un houppier dans `region_growing`.

- traiter:

  Vecteur logique, un par dalle : `FALSE` pour une dalle lue seulement
  comme tampon de ses voisines (pas de sortie sur son emprise) ; `NULL`
  : toutes.

- classes:

  Classes de points du MNH. **Provisoire** : 1 à 5 de l'ASPRS (non
  classé, sol, végétation basse, moyenne, haute).

- ncores:

  Stratégie de parallélisme de lasR (par exemple
  `lasR::concurrent_points(4)`) ; `NULL` : réglage de lasR. La mémoire
  croît avec le nombre de dalles traitées en même temps (environ 7 Go
  par dalle LiDAR HD).

## Value

Objet `typo_houppiers` : liste `mnh`, `houppiers`, `sommets` (chemins),
`parametres` (liste), `dalles`, `secondes` (durée de l'`exec`).

## Details

Étapes : triangulation des points de sol (classe 2) et hauteur au-dessus
du sol ; modèle numérique de hauteur (MNH, maximum des points des
classes `classes` par cellule de `resolution_m`) ; bouchage des creux
(`pit_fill`) ; sommets = maxima locaux du MNH sur une fenêtre circulaire
de `fenetre_m` de diamètre, au-dessus de `hauteur_min_m` ; houppiers par
croissance de régions depuis les sommets (`region_growing`, Dalponte et
Coomes 2016), sans cellule sous `hauteur_min_m`.

Les fichiers sont écrits dans `dossier` : `mnh.tif` (MNH bouché, m),
`houppiers.tif` (numéro du houppier de chaque cellule, vide hors
houppier), `sommets.gpkg`. Avec plusieurs dalles, lasR peut écrire un
raster par dalle et un fichier virtuel (`.vrt`) qui les assemble : c'est
ce fichier qui est rendu.

lasR est en Suggests (installation : voir le README, il faut GDAL) ;
sans lui, la fonction s'arrête.

## See also

[`couvert_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/couvert_houppiers.md),
[`dalles_sur_aoi()`](https://pobsteta.github.io/typopeuplement/reference/dalles_sur_aoi.md)

## Examples

``` r
if (FALSE) { # \dontrun{
d <- dalles_sur_aoi(noms_des_dalles, foret, gabarit = attr(v, "gabarit"))
s <- segmenter_houppiers(d, file.path(tempdir(), "houppiers"))
couvert_houppiers(s, attr(v, "gabarit"), references_strates(carte, facteur = k))
} # }
```

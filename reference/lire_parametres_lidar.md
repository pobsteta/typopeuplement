# Lire les paramètres forestiers LiDAR d'un producteur sur une emprise

Lit les rasters du producteur (par défaut ceux de l'ONF,
[`couches_onf()`](https://pobsteta.github.io/typopeuplement/reference/couches_onf.md)),
les découpe sur l'emprise `aoi` et rend un data.frame de pixels prêt
pour `typer_peuplements(variables = ...)`.

## Usage

``` r
lire_parametres_lidar(dossier, aoi = NULL, couches = couches_onf())
```

## Arguments

- dossier:

  Dossier qui contient les rasters.

- aoi:

  Emprise : `NULL` (tout le jeu), objet `sf`/`sfc`, `SpatVector` ou
  `SpatExtent` de terra. Un polygone est reprojeté dans le système des
  rasters ; seuls les pixels dont le centre tombe dedans sont gardés.

- couches:

  Table de branchement
  ([`couches_onf()`](https://pobsteta.github.io/typopeuplement/reference/couches_onf.md)
  par défaut).

## Value

data.frame : `i`, `j`, `x`, `y`, une colonne par `variable` de
`couches`, `part_pb` (vide), `non_precomptable`, `part_pb_absente`.
Attributs : `gabarit` (grille d'origine découpée : `xmin`, `xmax`,
`ymin`, `ymax`, `resolution`, `crs`), `couches` (la table de
branchement), `temps_lecture` (secondes).

## Details

Sont retenus les pixels où au moins une couche a une valeur. Le drapeau
`non_precomptable` est levé là où `famille` vaut 0, ou `G` vaut 0 ou est
vide : ces pixels ne sont pas typés.

Coordonnées : `x`, `y` sont les centres des pixels, en m, dans le
système des rasters (Lambert-93, EPSG:2154, pour le jeu ONF). `i` est
l'indice de colonne (0 à l'ouest), `j` l'indice de ligne compté depuis
le sud (0 au sud), sur la grille découpée.

## Examples

``` r
if (FALSE) { # \dontrun{
# Rasters du jeu téléchargés depuis le serveur du CRAIG, hors du dépôt.
v <- lire_parametres_lidar("chemin/vers/vercors", aoi = sf::st_read("foret.gpkg"))
} # }
```

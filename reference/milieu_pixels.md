# Variables de milieu, pixel par pixel

Relève les variables de relief au centre de chaque pixel du jeu (`x`,
`y`, dans le système du relief, Lambert-93 pour le jeu ONF) et rend une
table alignée ligne à ligne sur `variables`, prête pour
`typer_peuplements(milieu = ...)`.

## Usage

``` r
milieu_pixels(relief, variables)
```

## Arguments

- relief:

  `SpatRaster` rendu par
  [`calculer_relief()`](https://pobsteta.github.io/typopeuplement/reference/calculer_relief.md).

- variables:

  data.frame de pixels avec `x`, `y`
  ([`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md)).

## Value

data.frame, une ligne par ligne de `variables`, une colonne par couche
du relief. Attributs : `variables_milieu` (noms des colonnes) et
`source` (texte).

# Variables dendrométriques d'une placette

Agrège les arbres par placette : surface terrière et parts de petits,
moyens et gros bois et de résineux. Les seuils de catégories sont
propres à chaque SER et viennent de sa configuration
(`lire_configuration(...)$seuils_diametre`) : la limite des gros bois
est à 42,5 cm en Savoie et dans les Pyrénées, à 47,5 cm dans les Vosges
(Souchon, 2020).

## Usage

``` r
variables_placette(arbres, surface_placette_ha, seuils)
```

## Arguments

- arbres:

  data.frame : `placette`, `diametre_cm` (cm à 1,30 m), `resineux`
  (logique).

- surface_placette_ha:

  Surface de la placette, en ha.

- seuils:

  Liste : `precomptage_cm`, `pb_bm_cm`, `bm_gb_cm`.

## Value

data.frame, une ligne par placette (dans l'ordre d'apparition) :
`placette`, `G` (m²/ha), `part_pb`, `part_bm`, `part_gb`,
`part_resineux` (parts de la surface terrière, entre 0 et 1).

## Details

Conventions : un arbre compte si `diametre_cm >= precomptage_cm` ; il
est petit bois si `diametre_cm < pb_bm_cm`, bois moyen si
`diametre_cm < bm_gb_cm`, gros bois sinon. Une placette sans arbre
compté a `G = 0` et des parts non définies (`NA`).

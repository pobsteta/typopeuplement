# Classer avec la clé floue d'une SER

Applique la clé floue à des variables : décision (voir
[`decider_type()`](https://pobsteta.github.io/typopeuplement/reference/decider_type.md)),
drapeau `hors_cle` et probabilités de chaque type en colonnes
`p_<code>`.

## Usage

``` r
classer_types(cle, variables)
```

## Arguments

- cle:

  La clé d'une SER, telle que la rend `lire_configuration(...)$cle`.

- variables:

  data.frame des variables de la clé (une ligne par pixel ou placette).
  Une valeur `NA` neutralise la condition qui la porte.

## Value

data.frame : `type`, `proba`, `type_second`, `proba_second`,
`entre_deux`, `hors_cle`, puis `p_<code>` pour chaque type.

## Examples

``` r
chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
cle <- lire_configuration(chemin, "exemple-alpes-du-nord")$cle
classer_types(cle, data.frame(part_resineux = c(0.1, 0.9), part_pb = 0.2,
                              part_bm = 0.3, part_gb = 0.5, rapport_h = 0.8))
#>   type     proba type_second proba_second entre_deux hors_cle          p_F
#> 1    F 0.9932907           M  0.006692628      FALSE    FALSE 9.932907e-01
#> 2 R-GB 0.4960362       R-IRR  0.494809684       TRUE    FALSE 1.668066e-05
#>           p_M     p_R-PB-J     p_R-PB-C       p_R-GB      p_R-IRR
#> 1 0.006692628 7.427520e-10 4.055288e-08 8.350572e-06 8.329924e-06
#> 2 0.006684420 4.412055e-05 2.408901e-03 4.960362e-01 4.948097e-01
```

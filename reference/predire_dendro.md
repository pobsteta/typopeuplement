# Prédire les variables dendrométriques

Prédire les variables dendrométriques

## Usage

``` r
predire_dendro(modeles, df)
```

## Arguments

- modeles:

  Objet rendu par
  [`ajuster_modeles_dendro()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_modeles_dendro.md).

- df:

  data.frame portant les colonnes de prédicteurs (pixels ou placettes).

## Value

data.frame, une colonne par variable cible ; parts bornées à 0, 1 et
parts PB + BM + GB ramenées à 1.

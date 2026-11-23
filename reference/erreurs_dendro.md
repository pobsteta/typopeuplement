# Erreurs des modèles dendrométriques hors échantillon

Biais et RMSE de chaque variable cible, en validation croisée.

## Usage

``` r
erreurs_dendro(modeles, placettes, plis = 5)
```

## Arguments

- modeles:

  Objet rendu par
  [`ajuster_modeles_dendro()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_modeles_dendro.md).

- placettes:

  data.frame des placettes : prédicteurs et variables cibles.

- plis:

  Nombre de plis. **Provisoire** : 5, repris du prototype.

## Value

data.frame : `variable`, `biais`, `rmse` (unités de la variable).

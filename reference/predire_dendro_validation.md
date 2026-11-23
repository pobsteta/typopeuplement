# Prédictions dendrométriques hors échantillon (validation croisée)

Chaque placette est prédite par un modèle qui ne l'a pas vue :
validation croisée à `plis` plis mélangés, à graine fixée (celle des
modèles).

## Usage

``` r
predire_dendro_validation(modeles, placettes, plis = 5)
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

data.frame, une colonne par variable cible, une ligne par placette.

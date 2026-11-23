# Comparer forêts aléatoires, SVM et analyse discriminante

Validation croisée stratifiée des trois classifieurs que le brief
demande de comparer : forêts aléatoires (ranger), SVM radiale (e1071,
`cost = 1`, variables réduites) et analyse discriminante linéaire (MASS,
variables standardisées). Un type trop rare pour la validation croisée
(un seul exemple) est écarté, et on le dit dans l'attribut
`types_ecartes`.

## Usage

``` r
comparer_classifieurs(X, y, plis = 5, graine = 0, nombre_arbres = 300)
```

## Arguments

- X:

  data.frame des prédicteurs.

- y:

  Types (un par ligne de `X`), par exemple ceux de
  [`types_observes()`](https://pobsteta.github.io/typopeuplement/reference/types_observes.md).

- plis:

  Nombre de plis (ramené à l'effectif du type le plus rare).
  **Provisoire** : 5.

- graine:

  Graine du hasard.

- nombre_arbres:

  Nombre d'arbres de la forêt de classement. **Provisoire** : 300,
  repris du prototype.

## Value

data.frame trié par kappa décroissant : `classifieur`
(`forets_aleatoires`, `svm`, `analyse_discriminante`),
`precision_globale`, `kappa` ; attribut `types_ecartes`.

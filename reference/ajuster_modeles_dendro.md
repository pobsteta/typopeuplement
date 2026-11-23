# Ajuster les modèles dendrométriques

Une forêt aléatoire de régression (ranger) par variable cible, apprise
sur les placettes.

## Usage

``` r
ajuster_modeles_dendro(
  placettes,
  predicteurs,
  cibles,
  graine = 0,
  nombre_arbres = 150,
  feuille_min = 3
)
```

## Arguments

- placettes:

  data.frame des placettes : prédicteurs et variables cibles mesurées.

- predicteurs:

  Noms des colonnes de prédicteurs (métriques LiDAR, indices
  Sentinel-2...).

- cibles:

  Noms des variables cibles (`G`, `part_resineux`, `part_pb`...).

- graine:

  Graine du hasard.

- nombre_arbres:

  Nombre d'arbres par forêt. **Provisoire** : 150, repris du prototype.

- feuille_min:

  Effectif minimal d'une feuille. **Provisoire** : 3, repris du
  prototype.

## Value

Objet `typo_modeles_dendro`.

## See also

[`predire_dendro()`](https://pobsteta.github.io/typopeuplement/reference/predire_dendro.md),
[`predire_dendro_validation()`](https://pobsteta.github.io/typopeuplement/reference/predire_dendro_validation.md),
[`erreurs_dendro()`](https://pobsteta.github.io/typopeuplement/reference/erreurs_dendro.md)

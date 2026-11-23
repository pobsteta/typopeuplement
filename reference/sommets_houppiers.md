# Sommets des houppiers d'une segmentation

Sommet de chaque houppier = sa cellule la plus haute dans le MNH (à
égalité, la première lue) ; sa hauteur est celle de l'arbre. Un numéro
de houppier vaut un arbre, **0 compris** : lasR numérote ses houppiers à
partir de 0 (à Léoncel, sur l'extrait de test, 281 sommets numérotés de
0 à 280). Une cellule sans hauteur (MNH vide) n'est pas lue.

## Usage

``` r
sommets_houppiers(houppiers, lignes_bloc = 1000L)
```

## Arguments

- houppiers:

  Objet `typo_houppiers`
  ([`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md)),
  ou liste `houppiers` et `mnh` (chemins ou `SpatRaster` de même
  grille).

- lignes_bloc:

  Nombre de lignes du MNH lues à la fois.

## Value

data.frame, un sommet par houppier : `id`, `h` (m), `x`, `y` (centre de
la cellule du sommet, m, système du nuage).

## See also

[`couvert_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/couvert_houppiers.md),
[`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md)

# Type observé : la clé à seuils durs appliquée aux mesures

La référence de validation est la clé appliquée aux mesures, pas le type
relevé à dire d'expert (Souchon, 2020). La souplesse de la clé est mise
à zéro : on applique la clé dure.

## Usage

``` r
types_observes(cle, mesures)
```

## Arguments

- cle:

  La clé d'une SER, telle que la rend `lire_configuration(...)$cle`.

- mesures:

  data.frame des variables mesurées (une ligne par placette).

## Value

Vecteur de codes de types, un par ligne de `mesures`.

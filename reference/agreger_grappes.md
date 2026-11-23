# Agréger en grappes

Par grappe : type observé majoritaire, et type prédit par les
probabilités moyennes (type de plus forte probabilité moyenne). Deux
règles distinctes.

## Usage

``` r
agreger_grappes(observe, probas, grappe)
```

## Arguments

- observe:

  Types observés (un par placette).

- probas:

  data.frame de probabilités prédites, une colonne par type.

- grappe:

  Identifiant de grappe de chaque placette.

## Value

data.frame : `grappe`, `observe`, `predit`, une ligne par grappe
(triées).

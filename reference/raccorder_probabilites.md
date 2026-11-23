# Raccorder les probabilités de deux modèles de SER

Mélange pondéré des probabilités du modèle de la SER du pixel et de
celui de la SER voisine ; un type absent d'un côté y vaut 0 ; les lignes
sont ramenées à 1.

## Usage

``` r
raccorder_probabilites(p_ser, p_voisine, poids)
```

## Arguments

- p_ser, p_voisine:

  data.frame de probabilités (une colonne par type).

- poids:

  Poids du modèle de la SER du pixel (voir
  [`poids_transition()`](https://pobsteta.github.io/typopeuplement/reference/poids_transition.md)).

## Value

data.frame, une colonne par type présent d'un côté ou de l'autre.

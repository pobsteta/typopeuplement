# Peuplements adultes fermés

Masque des lignes retenues pour apprendre la hauteur potentielle :
`couvert >= couvert_min` et `h_dom >= hauteur_min_m` (seuils du modèle).
Une ligne où le couvert ou la hauteur manque n'est pas adulte (`FALSE`,
jamais `NA`).

## Usage

``` r
peuplements_adultes(modele, df)
```

## Arguments

- modele:

  Objet rendu par
  [`ajuster_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_hauteur_potentielle.md)
  (ou toute liste portant `couvert_min` et `hauteur_min_m`).

- df:

  data.frame : `couvert`, `h_dom`.

## Value

Vecteur logique.

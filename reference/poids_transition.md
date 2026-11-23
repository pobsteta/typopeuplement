# Poids du modèle de la SER du pixel dans la bande de transition

Selon la distance signée à la limite (positive à l'intérieur de la SER
du pixel) : 0,5 sur la limite, 1 au-delà de la demi-largeur de bande,
variation linéaire.

## Usage

``` r
poids_transition(distance_m, demi_largeur_m = 500)
```

## Arguments

- distance_m:

  Distance signée à la limite de SER, en m.

- demi_largeur_m:

  Demi-largeur de la bande de transition, en m. **Provisoire** : 500.
  Strictement positive : une largeur nulle ferait une rupture à la
  limite des SER (critère 4), c'est une erreur.

## Value

Poids entre 0,5 et 1.

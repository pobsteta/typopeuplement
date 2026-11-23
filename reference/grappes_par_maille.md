# Grappes de placettes par maille carrée

Identifiant de grappe : maille carrée de `cote_m` (70,7 m de côté : 0,5
ha), partie entière par le bas (une coordonnée de -1 m est dans la
maille -1).

## Usage

``` r
grappes_par_maille(x, y, cote_m = 70.7)
```

## Arguments

- x, y:

  Coordonnées en m (Lambert-93 pour les vraies données).

- cote_m:

  Côté de la maille, en m. **Provisoire** : 70,7.

## Value

Vecteur de caractères `"<colonne>_<ligne>"`.

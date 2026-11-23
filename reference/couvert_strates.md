# Couvert des strates d'un nuage de points

[`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)
puis
[`couvert_depuis_comptes()`](https://pobsteta.github.io/typopeuplement/reference/couvert_depuis_comptes.md),
pour un nuage déjà normalisé (hauteurs au-dessus du sol) et déjà
rattaché aux pixels.

## Usage

``` r
couvert_strates(points, references, plancher_m = 1, classes = 1:5)
```

## Arguments

- points:

  data.frame : `cellule` (numéro de pixel, entier), `Z` (hauteur
  au-dessus du sol, m), `ReturnNumber`, `Classification`. Une ligne par
  retour. Facultatives : `h_cime` (hauteur de la cime du houppier où
  tombe le retour, m ; vide hors houppier) et `cellule_cime` (pixel du
  sommet de ce houppier) ; les deux ensemble.

- references:

  data.frame : `cellule`, et une colonne numérique (m) par hauteur de
  référence, nommée (par exemple celles de
  [`references_strates()`](https://pobsteta.github.io/typopeuplement/reference/references_strates.md)).
  Une ligne par pixel.

- plancher_m:

  Bas de la strate 4, en m : ce qui est plus bas est le sol (le bruit du
  modèle de sol et la strate herbacée). **Provisoire** : 1 m. Ce n'est
  pas un seuil du GSM (qui ne fixe pas de diamètre minimum pour le
  couvert), c'est un seuil de mesure. Strictement positif : à 0, le sol
  compterait comme végétation.

- classes:

  Classes de points gardées. **Provisoire** : 1 à 5.

## Value

Voir
[`couvert_depuis_comptes()`](https://pobsteta.github.io/typopeuplement/reference/couvert_depuis_comptes.md).

## Examples

``` r
# Un pixel, H = 20 m : 10 premiers retours dont 6 au-dessus de 15 m.
pts <- data.frame(cellule = 1L, ReturnNumber = 1L, Classification = 5L,
                  Z = c(rep(18, 6), rep(8, 2), 0, 0))
couvert_strates(pts, data.frame(cellule = 1L, h = 20))
#>   cellule n_tous n_premiers c1_h c2_h c3_h c4_h sous_s1_h
#> 1       1     10         10  0.6    0  0.5    0       0.4
```

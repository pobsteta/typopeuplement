# Comptes de points par strate

Compte, pour chaque pixel et chaque hauteur de référence H, les retours
qui servent au couvert des strates
([`couvert_depuis_comptes()`](https://pobsteta.github.io/typopeuplement/reference/couvert_depuis_comptes.md)).
Les comptes s'additionnent : un pixel coupé par la limite de deux dalles
reçoit les comptes des deux.

## Usage

``` r
comptes_strates(points, references, plancher_m = 1, classes = 1:5)
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

data.frame, une ligne par pixel touché : `cellule`, `n_tous`,
`n_premiers`, et pour chaque référence `r` : `p1_r`, `n2_r`, `s2_r`,
`n3_r`, `s3_r`, `n4_r`, `s4_r`, et `r1_r` (retours retirés) si les cimes
sont données.

## Details

- strate 1 (Z ≥ 3/4 H) : premiers retours `p1`, sur `n_premiers`
  premiers retours ;

- strates 2 à 4 : tous les retours de la strate (`n2`, `n3`, `n4`), sur
  ceux qui sont arrivés sous son plafond (`s2` : Z \< 3/4 H ; `s3` : Z
  \< H/2 ; `s4` : Z \< H/4). La strate 4 commence à `plancher_m`. Un
  retour sous `plancher_m` est du sol pour toutes les strates : sous une
  référence de moins de 4 m (H/4 \< 1 m), il ne compte ni en strate 4 ni
  dans les strates du dessus qui descendraient sous le plancher.

**Retours sous les houppiers de la strate 1** (mission 013, décision de
Pascal du 2026-11-23) : si `points` porte la cime de chaque retour
(`h_cime`, `cellule_cime`, voir
[`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md)
avec `houppiers`), un retour qui tombe, vu du dessus, dans le houppier
d'un arbre de la strate 1 et qui est sous 3/4 H ne compte plus dans les
strates 2 à 4 : ni au numérateur (`n2`, `n3`, `n4`), ni au dénominateur
(`s2`, `s3`, `s4`), sol compris. La strate de l'arbre se lit comme dans
[`couvert_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/couvert_houppiers.md)
: sa cime contre la référence du pixel de son sommet (à défaut, celle du
pixel du retour). Les strates 2 à 4 se mesurent alors dans les trouées
de la strate 1. Les retours retirés sont comptés dans `r1_r`.

Les hauteurs Z négatives (sous le sol interpolé) valent 0. Seules les
classes `classes` comptent (par défaut 1 à 5 de l'ASPRS, celles du LiDAR
HD de l'IGN : non classé, sol, végétation basse, moyenne, haute) ;
bâtiments, eau, ponts, bruit et sursol pérenne sont écartés. Un pixel
sans référence valable (vide, nulle ou négative) a des comptes vides
(`NA`) pour cette référence.

## See also

[`couvert_depuis_comptes()`](https://pobsteta.github.io/typopeuplement/reference/couvert_depuis_comptes.md),
[`couvert_strates()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates.md)

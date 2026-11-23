# Couvert des strates à partir des comptes

Additionne les comptes d'un même pixel (venus de plusieurs dalles) puis
calcule, pour chaque référence `r` :

## Usage

``` r
couvert_depuis_comptes(comptes)
```

## Arguments

- comptes:

  data.frame rendu par
  [`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)
  (ou plusieurs, liés par `rbind`). Les colonnes `x`, `y`, si elles y
  sont, sont reprises.

## Value

data.frame, une ligne par pixel : `cellule`, `x`, `y` (si présents),
`n_tous`, `n_premiers`, puis `c1_r`, `c2_r`, `c3_r`, `c4_r` et
`sous_s1_r` pour chaque référence `r`. Attribut `retrait_s1` : `TRUE` si
les comptes ont retiré les retours des houppiers de la strate 1
(colonnes `r1_*`).

## Details

- `c1_r` = `p1 / n_premiers` : part des premiers retours au-dessus de
  3/4 H, le couvert de la strate haute vu du dessus ;

- `c2_r` = `n2 / s2`, `c3_r` = `n3 / s3`, `c4_r` = `n4 / s4` : part des
  retours de la strate parmi ceux qui sont descendus sous son plafond.
  C'est la probabilité qu'un rayon arrivé jusqu'à la strate y soit
  arrêté : le couvert de la strate corrigé de l'occlusion par les
  strates du dessus.

Les quatre couverts sont entre 0 et 1, chacun pour sa strate : ils ne
s'additionnent pas en un couvert total (une strate basse cachée sous une
strate haute compte pour son propre couvert, comme au GSM) ; leur somme
peut dépasser 1. Dénominateur nul : `NA`.

`sous_s1_r` = `s2 / n_tous` : part des retours du pixel qui passent sous
la strate 1 (sous 3/4 H, sol compris) et servent aux strates 2 à 4 ;
sans les retours tombés dans les houppiers de la strate 1 si les comptes
les ont retirés (`r1_r`). C'est la mesure sur laquelle reposent les
strates basses : près de 0, elles sont estimées sur très peu de retours.

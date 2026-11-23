# Lisser les probabilités à l'échelle de lecture

Moyenne les probabilités de chaque type sur une fenêtre carrée de pixels
(3 × 3 pixels de 25 m font 0,56 ha : lecture au quart ou au
demi-hectare). Les pixels absents (hors forêt) ne comptent pas dans la
moyenne ; les lignes sont ramenées à une somme de 1.

## Usage

``` r
lisser_probabilites(probas, i, j, fenetre = 3, poids = NULL)
```

## Arguments

- probas:

  data.frame de probabilités, une colonne par type, une ligne par pixel.

- i, j:

  Indices entiers de ligne et de colonne de chaque pixel dans la grille.

- fenetre:

  Côté de la fenêtre, en pixels. **Provisoire** : 3, repris du
  prototype.

- poids:

  Poids positifs ou nuls de chaque pixel ; `NULL` : 1 partout (lissage
  d'avant).

## Value

data.frame de mêmes colonnes et de mêmes lignes que `probas`.

## Details

Avec `poids`, la moyenne est pondérée. Un pixel de **poids nul** (par
exemple hors clé, mission 012) ne compte pas dans la moyenne de ses
voisins (ses probabilités ne diluent pas les leurs) et n'emprunte rien à
ses voisins : il garde ses probabilités.

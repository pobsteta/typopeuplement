# Ajuster le modèle de hauteur potentielle

Apprend, par famille d'essences, la hauteur dominante des peuplements
adultes fermés en fonction des variables de milieu (forêt aléatoire
ranger). La prédiction est relevée par une enveloppe haute k : le
quantile `quantile_enveloppe` du rapport hauteur observée / hauteur
prédite hors sac (out-of-bag de ranger) chez les adultes (au moins 1),
car un peuplement adulte n'a pas toujours atteint sa hauteur
potentielle. Les adultes appris sont ensuite prédits hors sac
([`predire_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/predire_hauteur_potentielle.md))
: environ `1 - quantile_enveloppe` d'entre eux dépassent leur hauteur
potentielle.

## Usage

``` r
ajuster_hauteur_potentielle(
  df,
  variables_milieu,
  couvert_min = 0.7,
  hauteur_min_m = 15,
  incertitude_relative_max = 0.2,
  quantile_enveloppe = 0.9,
  graine = 0,
  famille = "famille",
  adultes_min = 20,
  plis = 5,
  nombre_arbres = 200,
  feuille_min = 5
)
```

## Arguments

- df:

  data.frame (pixels) : `h_dom` (m), `couvert` (0 à 1), les variables de
  milieu, et `famille` si l'on veut un modèle par famille d'essences.

- variables_milieu:

  Noms des variables de milieu (topographie, climat, sol).

- couvert_min:

  Couvert minimal d'un peuplement fermé. **Provisoire** : 0,7.

- hauteur_min_m:

  Hauteur dominante minimale d'un peuplement adulte, en m.
  **Provisoire** : 15.

- incertitude_relative_max:

  Au-delà de ce rapport écart-type / hauteur potentielle, la hauteur
  potentielle est jugée incertaine. **Provisoire** : 0,2.

- quantile_enveloppe:

  Quantile de l'enveloppe haute. **Provisoire** : 0,9.

- graine:

  Graine du hasard.

- famille:

  Nom de la colonne des familles d'essences ; absente, un seul modèle.

- adultes_min:

  Nombre minimal d'adultes fermés pour ajuster le modèle d'une famille.
  **Provisoire** : 20.

- plis:

  Nombre de plis (contigus) de la validation croisée. **Provisoire** :
  5.

- nombre_arbres:

  Nombre d'arbres de chaque forêt. **Provisoire** : 200.

- feuille_min:

  Effectif minimal d'une feuille. **Provisoire** : 5.

## Value

Objet `typo_hauteur_potentielle` : modèles, `rmse_cv` (RMSE de
validation croisée par famille, m), `facteur` (enveloppe k) et
`apprentissage` (lignes apprises et leur prédiction hors sac) par
famille.

## Details

La RMSE de validation croisée par blocs (plis contigus) donne
l'incertitude : `h_pot_sd` = k × RMSE.

## See also

[`predire_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/predire_hauteur_potentielle.md),
[`peuplements_adultes()`](https://pobsteta.github.io/typopeuplement/reference/peuplements_adultes.md)

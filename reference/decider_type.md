# Décider du type à partir des probabilités

Type retenu (plus forte probabilité), sa probabilité, le second type et
le drapeau « entre deux types » : levé quand l'écart entre les deux
premières probabilités est inférieur à `marge_entre_deux`.

## Usage

``` r
decider_type(probas, marge_entre_deux = 0.15, touche_na = NULL)
```

## Arguments

- probas:

  data.frame ou matrice de probabilités, une colonne par code de type.

- marge_entre_deux:

  Marge « entre deux types ». **Provisoire** : 0,15, reprise du
  prototype ; à mesurer sur les SER pilotes.

- touche_na:

  Matrice logique (une ligne par ligne de `probas`, une colonne par
  type) des types qui portent une condition sur une variable manquante ;
  `NULL` : pas de groupe.

## Value

data.frame : `type`, `proba`, `type_second`, `proba_second`,
`entre_deux`.

## Details

Les probabilités ne contiennent pas de `NA` (la clé n'en produit pas) ;
si une valeur manque, elle est traitée comme la plus faible. À égalité,
le premier type de la clé.

**Groupe de types.** Avec `touche_na` (attribut du même nom rendu par
[`appartenances_types()`](https://pobsteta.github.io/typopeuplement/reference/appartenances_types.md)),
quand les types à égalité de tête ne se départagent que par une variable
manquante (chacun porte une condition sur une variable inconnue de la
ligne), on ne choisit pas le premier de la clé : `type` est le groupe
des types possibles, codes réunis par `" | "` (par exemple
`"R-PB-J | R-PB-C"`), dans l'ordre de la clé, et `entre_deux` est levé.
La probabilité du groupe (`proba`) est la somme des probabilités de ses
membres (décision du 2026-11-22). Le second type est alors le meilleur
type hors du groupe. Sans `touche_na`, le comportement est celui de
toujours.

**Limite : `touche_na` est lu au pixel.** Il dit quelles variables
manquent au pixel lui-même, alors que les probabilités ont pu être
lissées avec celles des voisins
([`lisser_probabilites()`](https://pobsteta.github.io/typopeuplement/reference/lisser_probabilites.md)).
En bordure d'une zone sans milieu (par exemple sans hauteur
potentielle), un pixel dont la variable est connue peut donc prendre un
type franc alors que ses voisins forment un groupe, et inversement.

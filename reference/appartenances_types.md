# Probabilités d'appartenance aux types d'une clé floue

Pour chaque ligne de `variables`, probabilité d'appartenir à chaque type
de la clé (les probabilités d'une ligne somment à 1). Une ligne qui ne
satisfait aucun type (hors clé) reçoit des probabilités égales et est
signalée dans l'attribut `hors_cle`. L'attribut `touche_na` (matrice
logique lignes x types) dit quels types portent une condition sur une
variable inconnue de la ligne (voir
[`decider_type()`](https://pobsteta.github.io/typopeuplement/reference/decider_type.md)).

## Usage

``` r
appartenances_types(cle, variables)
```

## Arguments

- cle:

  La clé d'une SER, telle que la rend `lire_configuration(...)$cle`.

- variables:

  data.frame des variables de la clé (une ligne par pixel ou placette).
  Une valeur `NA` neutralise la condition qui la porte.

## Value

data.frame à une colonne par code de type, avec l'attribut logique
`hors_cle`.

## Details

Un type est défini par des `conditions` reliées par « et » (produit) et,
facultatif, par des `alternatives` : plusieurs jeux de conditions reliés
par « ou ». L'appartenance d'un type est le produit de ses `conditions`
par le **maximum** des produits de ses alternatives. Une clé sans
`alternatives` se lit comme avant. Format JSON : voir
[`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md).

## See also

[`classer_types()`](https://pobsteta.github.io/typopeuplement/reference/classer_types.md),
[`decider_type()`](https://pobsteta.github.io/typopeuplement/reference/decider_type.md)

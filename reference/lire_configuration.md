# Lire la configuration effective d'une SER

Lit un fichier JSON de configuration et rend la configuration effective
d'une SER : le socle `national`, puis la grande région de la SER
(`grandes_regions`), puis la SER elle-même (`ser`), chaque niveau
l'emportant sur le précédent, champ par champ.

## Usage

``` r
lire_configuration(chemin, ser)
```

## Arguments

- chemin:

  Chemin du fichier JSON de configuration.

- ser:

  Nom de la SER dans la rubrique `ser` du fichier.

## Value

Une liste : les champs fusionnés, plus `ser` (le nom demandé). La clé
est dans `$cle` : `types` (liste de types, chacun `code`, `libelle`,
`conditions`, et `alternatives` s'il y a des « ou »), `souplesse` (liste
nommée par variable) et `marge_entre_deux`. Le bloc `jeux` est rendu tel
quel.

## Details

Les seuils, la clé de types et ses souplesses sont propres à chaque SER.
La clé de `inst/extdata/config/exemple.json` est un **exemple** pour
faire tourner la chaîne, pas une typologie : chaque SER pilote la
remplacera par la sienne, sourcée.

**Format de la clé.** `cle$types` est une liste de types ; chacun a un
`code`, un `libelle` et des `conditions` :
`{"variable": "part_gb", "min": 0.5, "max": 0.8}` (`min` inclus, `max`
exclu, l'un ou l'autre facultatif), reliées par « et ». Pour un « ou »,
le type porte en plus des `alternatives` : un tableau de jeux de
conditions.

    {"code": "X", "libelle": "...",
     "conditions": [{"variable": "part_resineux", "min": 0.65}],
     "alternatives": [
       [{"variable": "part_gb", "min": 0.5}],
       [{"variable": "part_pb", "max": 0.2}, {"variable": "rapport_h", "min": 0.6}]]}

Ce type vaut : `conditions` **et** (premier jeu **ou** second jeu). Dans
la clé floue, l'appartenance est le produit des `conditions` par le
maximum des produits des jeux. `conditions` peut être absent quand le
type n'a que des `alternatives`. Une clé sans `alternatives` se lit
exactement comme avant. Une alternative vide ou mal formée est une
erreur.

**Bloc `jeux`.** Les souplesses propres à un jeu de données (erreurs
d'un producteur) se déclarent à côté de la clé, sous
`jeux.<nom du jeu>`, à la racine du fichier (ou dans une SER) :
`{"jeux": {"vercors_onf": {"source": "fiche ONF, p. 1", "souplesse": {"part_gb": 0.11}}}}`.
Pour les variables qu'il nomme, `souplesse` remplace celles de la clé
quand les variables viennent de ce jeu
([`couches_onf()`](https://pobsteta.github.io/typopeuplement/reference/couches_onf.md)
porte le nom `vercors_onf`). `source` est reprise dans la fiche. Une
souplesse négative ou non numérique est une erreur.

## Examples

``` r
chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
conf <- lire_configuration(chemin, "exemple-vosges")
conf$seuils_diametre$bm_gb_cm   # 47,5 cm dans les Vosges (Souchon, 2020)
#> [1] 47.5
```

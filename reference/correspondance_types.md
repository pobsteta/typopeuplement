# Table de correspondance des types

Valeur entière de chaque type dans `types.tif`, son code et son libellé
dans la clé de la SER. Avec `types` (la colonne `type` d'une carte), les
**groupes de types** qu'elle contient (codes réunis par `" | "`, voir
[`decider_type()`](https://pobsteta.github.io/typopeuplement/reference/decider_type.md))
sont ajoutés après les types de la clé, avec une valeur propre, le
libellé étant la réunion des libellés.

## Usage

``` r
correspondance_types(cle, types = NULL)
```

## Arguments

- cle:

  La clé d'une SER (`lire_configuration(...)$cle`).

- types:

  Codes de types d'une carte, ou `NULL` (types de la clé seulement).

## Value

data.frame : `valeur`, `code`, `libelle`.

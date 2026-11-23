# Niveau du modèle : SER ou grande région

« ser » si chaque type de la clé a au moins `minimum` placettes, sinon «
grande_region » : la SER hérite alors du modèle de sa GRECO.

## Usage

``` r
niveau_modele(effectifs, codes, minimum = 30)
```

## Arguments

- effectifs:

  Effectifs de placettes par type : vecteur nommé ou `table`.

- codes:

  Codes des types de la clé.

- minimum:

  Nombre minimal de placettes par type. **Provisoire** : 30
  (`placettes_min_par_type` de la configuration d'exemple).

## Value

`"ser"` ou `"grande_region"`.

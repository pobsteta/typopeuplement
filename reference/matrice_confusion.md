# Matrice de confusion

Matrice de confusion

## Usage

``` r
matrice_confusion(observe, predit, codes = NULL)
```

## Arguments

- observe:

  Types observés.

- predit:

  Types prédits.

- codes:

  Codes des types, dans l'ordre des lignes et des colonnes ; par défaut,
  tous les codes rencontrés, triés.

## Value

Table : lignes « observé », colonnes « prédit ». Un type jamais observé
ni prédit garde sa ligne et sa colonne.

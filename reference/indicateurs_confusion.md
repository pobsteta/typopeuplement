# Indicateurs d'une matrice de confusion

Indicateurs d'une matrice de confusion

## Usage

``` r
indicateurs_confusion(matrice)
```

## Arguments

- matrice:

  Matrice de confusion (lignes observé, colonnes prédit).

## Value

Liste : `n`, `precision_globale`, `kappa` (kappa de Cohen ; `NA` s'il
n'est pas défini, par exemple avec une seule classe), `rappel_par_type`,
`precision_par_type`. Matrice vide : `n = 0` et indicateurs `NA`, rien
d'inventé.

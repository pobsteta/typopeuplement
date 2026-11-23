# Fiche de validation d'une SER

Matrices de confusion et indicateurs à la placette et à la grappe. Les
probabilités doivent venir de placettes non utilisées pour calibrer
(validation croisée).

## Usage

``` r
fiche_validation(observe, probas, grappe, ser = "")
```

## Arguments

- observe:

  Types observés (la clé dure appliquée aux mesures,
  [`types_observes()`](https://pobsteta.github.io/typopeuplement/reference/types_observes.md)).

- probas:

  Probabilités prédites hors échantillon, une colonne par type.

- grappe:

  Identifiant de grappe de chaque placette
  ([`grappes_par_maille()`](https://pobsteta.github.io/typopeuplement/reference/grappes_par_maille.md)).

- ser:

  Nom de la SER.

## Value

Liste : `ser`, `placette` et `grappe` (chacune `matrice`, `n`,
`precision_globale`, `kappa`, `rappel_par_type`, `precision_par_type`).

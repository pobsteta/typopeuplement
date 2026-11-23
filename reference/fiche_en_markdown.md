# Fiche de validation en Markdown

Texte de `fiche_validation.md` : à la placette et à la grappe, effectif,
précision globale, kappa et matrice de confusion ; puis, quand la chaîne
les a ajoutés à la fiche, le niveau du modèle, les erreurs des
variables, la RMSE de la hauteur potentielle et l'écart aux courbes de
station de nemeton.

## Usage

``` r
fiche_en_markdown(fiche)
```

## Arguments

- fiche:

  Liste rendue par
  [`fiche_validation()`](https://pobsteta.github.io/typopeuplement/reference/fiche_validation.md)
  (ou par la chaîne, `resultat$fiche_validation`).

## Value

Vecteur de lignes de texte.

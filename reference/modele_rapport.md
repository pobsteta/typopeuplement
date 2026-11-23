# Chemin du modèle de rapport Quarto

Le fichier `rapport.qmd` du paquet. Le pipeline le suit comme fichier :
quand il change, le rapport est périmé et se refait
([`targets::tar_outdated()`](https://docs.ropensci.org/targets/reference/tar_outdated.html)).

## Usage

``` r
modele_rapport()
```

## Value

Chemin du modèle (chaîne vide s'il est introuvable).

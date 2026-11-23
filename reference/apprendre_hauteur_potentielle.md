# Apprendre la hauteur potentielle sur des variables fournies

Ajuste le modèle de hauteur potentielle exactement comme le fait
[`executer_chaine_fournie()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine_fournie.md)
(pixels précomptables, variables de milieu de l'attribut
`variables_milieu` de `milieu`, réglages `hauteur_potentielle` de la
configuration), pour l'apprendre sur une grande emprise (le massif) et
l'appliquer à une petite (une forêt) :
`typer_peuplements(aoi, ..., modele_hp = m)`. Une petite emprise a trop
peu de peuplements adultes fermés pour apprendre seule.

## Usage

``` r
apprendre_hauteur_potentielle(variables, milieu, conf)
```

## Arguments

- variables:

  data.frame de pixels
  ([`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md))
  : `h_dom`, `couvert`, `famille`, et `non_precomptable` s'il existe.

- milieu:

  data.frame des variables de milieu, une ligne par ligne de `variables`
  ([`milieu_pixels()`](https://pobsteta.github.io/typopeuplement/reference/milieu_pixels.md)).

- conf:

  Configuration effective d'une SER
  ([`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md))
  ; sa `graine` (0 par défaut) est celle de la chaîne.

## Value

Objet `typo_hauteur_potentielle`
([`ajuster_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_hauteur_potentielle.md)).

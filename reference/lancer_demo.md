# Lancer la démonstration

Fait tourner la chaîne sur un jeu synthétique
([`generer_jeu_synthetique()`](https://pobsteta.github.io/typopeuplement/reference/generer_jeu_synthetique.md)),
écrit les livrables dans `sortie` et affiche un résumé (précision et
kappa à la placette et à la grappe, part des pixels entre deux types,
part de hauteur potentielle incertaine). Le jeu n'imite aucune forêt
réelle et la clé est celle de l'exemple.

## Usage

``` r
lancer_demo(
  sortie = file.path(tempdir(), "typopeuplement_demo"),
  configuration = system.file("extdata", "config", "exemple.json", package =
    "typopeuplement"),
  ser = "exemple-alpes-du-nord",
  graine = 0
)
```

## Arguments

- sortie:

  Dossier des livrables.

- configuration:

  Chemin du JSON de configuration ; par défaut l'exemple du package.

- ser:

  Nom de la SER dans la configuration.

- graine:

  Graine du hasard (jeu synthétique et modèles).

## Value

Objet `typo_resultat`, invisible.

## Examples

``` r
# \donttest{
lancer_demo(file.path(tempdir(), "demo"))
#> SER exemple-alpes-du-nord : 3600 pixels classés (niveau du modèle : grande_region)
#>   précision à la placette : 85,8 % (kappa 0,80)
#>   précision à la grappe   : 82,4 % (kappa 0,76)
#>   pixels entre deux types : 15,1 %
#>   hauteur potentielle incertaine : 0,0 %
#>   livrables : /tmp/RtmpTnl0ag/demo
# }
```

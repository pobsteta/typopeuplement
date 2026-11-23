# Écrire les tables du rapport

Calcule les tables que lit le modèle de rapport (état de preuve,
limites, parts de types, drapeaux) et les écrit en CSV dans `sortie`. Ne
modifie jamais `dossier`.

## Usage

``` r
tables_rapport(
  dossier,
  sortie,
  demo = FALSE,
  configuration = NULL,
  ser = "H10",
  etiquette_types = "Type GSM (H10)"
)
```

## Arguments

- dossier:

  Dossier des livrables de l'AOI
  ([`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md)).

- sortie:

  Dossier où écrire les tables (créé au besoin).

- demo:

  `TRUE` pour un jeu synthétique : tout chiffre est alors sans valeur
  sur données réelles.

- configuration:

  Chemin du JSON de configuration (optionnel) : sert à lister les types
  de la légende que la chaîne ne sait pas exprimer.

- ser:

  Nom de la SER dans la configuration.

- etiquette_types:

  Titre de la légende de `types.tif`.

## Value

La liste des chemins écrits, invisible.

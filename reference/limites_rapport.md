# Section « Limites » d'une carte

Limites tirées des drapeaux des livrables, de la fiche de validation et,
s'il existe, du fichier `journal_aoi.md` du dossier (une limite par
ligne commençant par `- `), et des types non exprimables déclarés par la
configuration.

## Usage

``` r
limites_rapport(
  dossier,
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

Vecteur de phrases.

# Rendre le rapport Quarto d'une AOI

Écrit les tables
([`tables_rapport()`](https://pobsteta.github.io/typopeuplement/reference/tables_rapport.md)),
copie le modèle
([`modele_rapport()`](https://pobsteta.github.io/typopeuplement/reference/modele_rapport.md))
dans `sortie` et le rend en HTML autonome avec Quarto. Ne lance aucun
calcul de chaîne ni de LiDAR : il lit les livrables déjà écrits.
`dossier` n'est jamais modifié.

## Usage

``` r
rendre_rapport(
  dossier,
  sortie = dossier,
  demo = FALSE,
  titre_aoi = "AOI",
  etiquette_types = NULL,
  configuration = NULL,
  ser = "H10",
  modele = modele_rapport()
)
```

## Arguments

- dossier:

  Dossier des livrables de l'AOI
  ([`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md)).

- sortie:

  Dossier du rapport (par défaut `dossier`).

- demo:

  `TRUE` pour un jeu synthétique : tout chiffre est alors sans valeur
  sur données réelles.

- titre_aoi:

  Nom de l'AOI affiché en titre.

- etiquette_types:

  Titre de la légende de `types.tif` ; `NULL` : « Type GSM (H10) » en
  mode réel, « clé d'exemple » en démonstration.

- configuration:

  Chemin du JSON de configuration (optionnel) : sert à lister les types
  de la légende que la chaîne ne sait pas exprimer.

- ser:

  Nom de la SER dans la configuration.

- modele:

  Modèle `.qmd` (par défaut
  [`modele_rapport()`](https://pobsteta.github.io/typopeuplement/reference/modele_rapport.md)).

## Value

Chemin du `rapport.html`.

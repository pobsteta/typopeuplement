# Cibles `targets` du rapport

Trois cibles : `modele` (le `.qmd`, suivi comme fichier : s'il change,
le rapport est périmé), `livrables` (mode démonstration : chaîne sur le
jeu synthétique, sans réseau ; mode réel : suivi des fichiers d'un
dossier déjà calculé, **aucun calcul LiDAR**) et `rapport` (le HTML). À
placer dans le `_targets.R`.

## Usage

``` r
cibles_rapport(
  aoi = NULL,
  sortie = "sorties/rapport",
  modele = modele_rapport(),
  titre_aoi = if (is.null(aoi)) "Démonstration (jeu synthétique)" else "AOI",
  etiquette_types = if (is.null(aoi)) "Type (clé d'exemple, pas une typologie)" else
    "Type GSM (H10)",
  configuration = NULL,
  ser = "H10"
)
```

## Arguments

- aoi:

  `NULL` (démonstration) ou chemin des livrables d'une AOI déjà
  calculée.

- sortie:

  Dossier de travail du pipeline (rapport et, en démonstration,
  livrables).

- modele:

  Chemin du modèle `.qmd`.

- titre_aoi, etiquette_types, configuration, ser:

  Voir
  [`rendre_rapport()`](https://pobsteta.github.io/typopeuplement/reference/rendre_rapport.md).

## Value

Une liste de cibles.

# Mission 003 — plan validé par Pascal (2026-11-22, « oui à tout »)

Plan rendu par l'agent `dev` le 2026-11-22. Les réponses aux questions sont celles que
l'orchestrateur a proposées et que Pascal a validées.

## 1. Structure (`R/`)

- `typopeuplement-package.R`
- `configuration.R` : JSON, fusion national → GRECO → SER
- `cle.R`
- `dendro.R`
- `modeles.R`
- `hauteur_potentielle.R`
- `lissage.R`
- `ser.R` : GRECO, héritage, transition
- `validation.R`
- `synthetique.R`
- `chaine.R`
- `typer_peuplements.R` : point d'entrée, livrables, démo
- `utils.R`

## 2. Fonctions exportées

- `typer_peuplements(aoi, placettes = NULL, ser = NULL, configuration, sortie = NULL, graine = 0)`
  rend un objet `typo_resultat` : carte, fiche de validation, erreurs, RMSE de la
  hauteur potentielle, types observés, niveau du modèle.
  - Ce qui tourne : `aoi` est un data.frame de pixels déjà préparés.
  - Ce qui reste en stub :
    - `aoi` en sf ou en GeoPackage : la SER est trouvée par `nemeton::localiser_ser()`,
      puis arrêt (« lecture des données ouvertes non écrite ») ;
    - `placettes = NULL` : arrêt (« modèles de grande région indisponibles ») ;
    - `ser = NULL` avec un data.frame : arrêt.
- `ecrire_livrables(resultat, dossier, taille_pixel = 25, crs = "EPSG:2154")` écrit
  `types.tif`, `variables.tif`, `confiance.tif`, `fiche_validation.md`,
  `carte_types.csv` et `correspondance_types.csv`.
- `lancer_demo(sortie, configuration, ser, graine = 0)`
- `executer_chaine(placettes, pixels, conf)`
- `lire_configuration(chemin, ser)`
- `ecart_courbes_station()`

## 3. Correspondance avec le prototype

| Python | R |
|---|---|
| cle.py | `appartenances_types`, `decider_type`, `classer_types` |
| dendro.py | `surface_terriere_arbre`, `variables_placette` |
| modeles.py | `ajuster_modeles_dendro`, `predire_dendro`, `predire_dendro_validation`, `erreurs_dendro`, `comparer_classifieurs` |
| hauteur_potentielle.py | `ajuster_hauteur_potentielle`, `predire_hauteur_potentielle` (h_pot, h_pot_sd, rapport_h, hp_incertaine), `peuplements_adultes` |
| lissage.py | `lisser_probabilites` |
| ser.py | `lire_configuration`, `greco_de_ser`, `niveau_modele`, `poids_transition`, `raccorder_probabilites` |
| validation.py | `matrice_confusion`, `indicateurs_confusion`, `grappes_par_maille`, `agreger_grappes`, `fiche_validation`, `fiche_en_markdown` |
| synthetique.py | `generer_jeu_synthetique` |
| chaine.py, cli.py | `executer_chaine`, `types_observes`, `typer_peuplements`, `lancer_demo` |

## 4. Bibliothèques

- ranger, réglé au plus près de scikit-learn : `mtry = p`, `min.bucket`, `seed`,
  `predict.all` pour l'incertitude.
- e1071 : SVM radiale, `cost = 1`, `scale = TRUE`.
- MASS : `lda` sur variables standardisées.
- R de base pour le lissage, avec des bords remplis de zéros comme scipy.
- terra et sf pour les données spatiales ; jsonlite pour la configuration.

## 5. nemeton

En Suggests : `localiser_ser()` et `compute_site_index()`, appelés sans copie. La GRECO
est la première lettre du code SER.

## 6. Valeurs provisoires

Celles de la fiche, plus celles que le prototype codait en dur, qui deviennent des
arguments par défaut marqués « provisoire » :
- couvert minimal 0,7 ;
- hauteur minimale 15 m ;
- 20 adultes au moins ;
- grappe de 70,7 m ;
- 30 placettes par type ;
- demi-largeur de transition 500 m ;
- 5 plis de validation croisée ;
- nombre d'arbres des forêts aléatoires.

## 7. Réponses validées

1. nemeton en Suggests maintenant, en Imports avec la lecture des vraies données.
2. jsonlite autorisé (ADR 0004 amendée).
3. 003 écrit la configuration d'exemple dans `inst/extdata/config/`.
4. Les tests unitaires de 003 vont dans `tests/testthat/test-dev-*.R`.
5. Le jeu synthétique Python est exporté en CSV par 004, dans
   `tests/testthat/fixtures/`, pour comparer les deux versions sur les mêmes données.
6. Critère 5 : corrélation de rang entre h_pot et l'indice de station de nemeton là où
   l'âge et l'essence sont connus, rapportée dans la fiche de validation. Ce n'est pas
   une égalité.
7. Le niveau du modèle est écrit dans `confiance.tif` ; la bascule vers la grande
   région reste en stub.
8. Documentation en français.
9. Pas de demande à nemeton pour l'instant.

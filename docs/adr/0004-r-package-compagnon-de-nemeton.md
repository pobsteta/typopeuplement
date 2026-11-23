# ADR 0004 — R, en package compagnon de nemeton

- **Date :** 2026-11-22
- **Statut :** acceptée par Pascal
- **Proposée par :** Claude (orchestrateur)
- **Tranchée par :** Pascal (« On part sur R. », journal du 2026-11-22)
- **Remplace :** ADR 0001

## La décision en une phrase

typopeuplement s'écrit comme un package R (GPL-3) : sf et terra pour les données
spatiales, lasR ou lidR pour le nuage de points, ranger, e1071 et MASS pour les modèles,
testthat pour les tests. Il dépend de nemeton ou le suggère, jamais l'inverse.

## Contexte

- À terme, le projet servira nemeton (Pascal). nemeton est un package R : il utilise sf
  et terra, suggère lidR et lasR, et contient les courbes d'indice de station (P2).
- Le prototype Python (environ 900 lignes, 17 tests) sert de spécification exécutable
  pour le portage. Il sera retiré quand le package R aura des tests équivalents et verts.
- Les autres options sont écrites dans les ADR 0001 (Python), 0002 et 0003 (Rust).

## Le crible FRANCE

| Lettre | Réponse | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|
| **F**rugale | Un seul écosystème avec nemeton | Porter le prototype | oui (Pascal) |
| **R**esponsable | Pascal maintient nemeton en R, et l'ONF comme l'INRAE pratiquent R | Moins de contributeurs Python | oui |
| **A**nticiper | Une tâche Python reste possible, par reticulate isolé comme dans nemeton | — | oui |
| **N**ovateur | Python et Rust écoutés (ADR 0001 à 0003) | — | — |
| **C**oût | inconnu | Le temps du portage | oui |
| **É**cologique | On réutilise nemeton (SER → GRECO → national, NDP, P2), lasR, ranger | — | oui |

## Valeurs sacrifiées

Le code Python déjà écrit (il sert de référence au portage), et l'audience Python.

## Conséquences

- Conventions de nemeton (convention NMT) : snake_case français sans accent, 30
  caractères au plus.
- Commande de tests après le portage : `Rscript -e 'testthat::test_local()'`.
- Échanges en formats ouverts : GeoTIFF ou COG pour les rasters, GeoPackage pour les
  vecteurs.

## Amendement du 2026-11-22 (Pascal, « oui à tout »)

- **jsonlite** s'ajoute pour la configuration en JSON. nemeton l'importe déjà, et le
  prototype lit le même fichier.
- **nemeton** est en Suggests, appelé par `requireNamespace()`. Il passera en Imports
  avec la lecture des vraies données.

## Sources

- https://github.com/pobsteta/nemeton (`DESCRIPTION`, `CLAUDE.md`, `R/site_index.R`)

## Précisions ultérieures (ajout daté, rien n'est effacé ci-dessus)

- 2026-11-23 · réconciliation des cadrages · « lasR ou lidR » devient lasR isolé derrière une
  interface, PDAL en repli ([ADR 0016](0016-nuage-de-points-lasr-isole-pdal-et-reproductibilite.md)) ;
  « GeoTIFF ou COG » devient COG pour toute livraison publiée
  ([ADR 0013](0013-echelle-aoi-formats-codes-et-metadonnees.md)) ; la licence du code est
  fixée par le fichier `LICENSE` ([ADR 0014](0014-diffusion-sans-degradation-et-licences.md)).

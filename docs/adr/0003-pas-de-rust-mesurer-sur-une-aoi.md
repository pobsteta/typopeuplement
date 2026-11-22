# ADR 0003 — pas de Rust pour l'instant ; mesurer le nuage de points sur une AOI

- **Date :** 2026-11-22
- **Statut :** acceptée par délégation de Pascal (journal du 2026-11-22), révocable
- **Proposée par :** Claude (orchestrateur), après critique du contradicteur
- **Tranchée par :** Claude (orchestrateur, par délégation)
- **Remplace :** ADR 0002

## La décision en une phrase

Pas de Rust pour l'instant. Pour le nuage de points, on part du MNH LiDAR HD de l'IGN,
puis de lasR si les métriques du nuage sont nécessaires, et on mesure le temps de chaque
étage sur une AOI pilote. scikit-learn (ou son équivalent R, selon l'ADR 0001) reste
pour les modèles.

## Contexte

- La réponse d'abord de Pascal était « vitesse sur toutes les SER de France ». Puis
  Pascal a précisé que les cartes se calculent par AOI, pour une forêt ou au plus un
  massif, pas pour la France entière d'un coup. La question du volume national ne se
  pose donc plus.
- Les critiques A1 à A6 du contradicteur :
  - l'étage du nuage de points n'est pas encore écrit ;
  - lasR (C++, GPL-3, pensé pour de grandes couvertures, appelable depuis R et Python)
    et le MNH de l'IGN manquaient aux options ;
  - la vitesse n'avait pas de cible ;
  - on ne trouve aucun banc indépendant de linfa ou smartcore face à scikit-learn ;
  - l'ADR 0001 n'est pas tranchée.
- nemeton est en R : il déclare lidR et lasR en Suggests et appelle Python par reticulate
  isolé. Un module Rust ajouterait une troisième chaîne de compilation à faire vivre.

## Le crible FRANCE

| Lettre | Réponse | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|
| **F**rugale | Des produits IGN déjà calculés, et un outil existant (lasR) avant tout code neuf | Moins de liberté sur les métriques | oui |
| **R**esponsable | Pascal et les partenaires lisent R et Python, pas Rust | — | oui |
| **A**nticiper | Si la mesure sur un massif montre un goulot, on rouvre la question de Rust | Une mesure à faire | oui |
| **N**ovateur | Rust écouté et écarté pour l'instant, pas interdit | Une part de vitesse brute | oui |
| **C**oût | inconnu (à mesurer) | inconnu | — |
| **É**cologique | On réutilise MNH, lasR, scikit-learn et nemeton | — | oui |

## Valeurs sacrifiées

La vitesse brute d'un noyau Rust, sans objet à l'échelle d'une forêt ou d'un massif tant
qu'aucune mesure ne la réclame.

## Valeur provisoire à mesurer avant de geler

Le temps de chaque étage (accès aux données, décompression, métriques, prédiction, clé)
sur une AOI pilote, avec le MNH IGN puis avec lasR. La question de Rust se rouvre si la
mesure montre un goulot que lasR ne lève pas.

## Sources

- Critique du contradicteur, 2026-11-22 (`pilotage/journal.md`).
- lasR : https://github.com/r-lidar/lasR
- IGN, MNH LiDAR HD : https://www.data.gouv.fr/datasets/mnh-lidar-hd
- nemeton, `DESCRIPTION` et `R/reticulate_isolated.R` : https://github.com/pobsteta/nemeton

# ADR 0001 — chaîne en Python, bibliothèques libres

- **Date :** 2026-11-22
- **Statut :** proposée
- **Proposée par :** Claude (orchestrateur)
- **Tranchée par :** Pascal (à trancher)

## La décision en une phrase

Écrire la chaîne en Python (numpy, pandas, scipy, scikit-learn), sous GPL-3.0, avec la
configuration des SER en JSON.

## Contexte

Le brief note que le rapport de 2020 utilise Computree, R et ArcGIS, et qu'« un passage à
des outils libres faciliterait le partage entre organismes ». Options envisagées : R
(continuité avec le rapport, `lidR`, `randomForest`), Python (`scikit-learn`, `laspy`,
`rasterio`, PDAL), plugin QGIS, chaîne Computree conservée.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | La plus simple qui tienne ? | Quatre bibliothèques courantes, pas de SIG propriétaire | Le calcul des métriques LiDAR reste à brancher (PDAL ou `lidR`) | à trancher |
| **R**esponsable | Qui fait quoi ? | Le code est testé et documenté ; l'ONF garde sa chaîne LiDAR | Le porteur n'est pas désigné | à trancher |
| **A**nticiper | Si l'imprévu arrive ? | Formats ouverts (CSV, JSON), modèles reproductibles (graine) | Dépendance à scikit-learn | à trancher |
| **N**ovateur | Toutes les idées ? | R aurait gardé la continuité avec le rapport | Rupture avec les scripts R de 2020 | à trancher |
| **C**oût | Coût complet ? | inconnu | inconnu | à trancher |
| **É**cologique | Que réutilise-t-on ? | Méthode du rapport (triangle des structures, forêts aléatoires) | — | à trancher |

## Valeurs sacrifiées

La continuité avec les scripts R de 2020 : à confirmer par Pascal, et à revoir si le code
ONF est partageable (question ouverte du brief).

## Sources

- `docs/brief-typologie-peuplements.md`, section « Livrables ».

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

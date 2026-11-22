# ADR 0001 — chaîne en Python, bibliothèques libres

- **Date :** 2026-11-22
- **Statut :** remplacée par ADR 0004 (Pascal a retenu R, 2026-11-22)
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

## Complément du 2026-11-22 : nemeton est en R

Pascal précise qu'à terme le projet servira [nemeton](https://github.com/pobsteta/nemeton).
nemeton est un package R (sf, terra). Il déclare lidR et lasR en Suggests et appelle déjà
des tâches Python dans un sous-processus isolé (`R/reticulate_isolated.R` : FORDEAD,
Open-Canopy). Il calcule aussi l'indice de station P2 à partir de courbes de hauteur
dominante sourcées. La question se pose donc à nouveau, entre deux options :

| | **Python** (code actuel) | **R** (package compagnon de nemeton) |
|---|---|---|
| Intégration à nemeton | Par fichiers (GeoTIFF, GeoPackage) ou reticulate isolé, comme FORDEAD | Native : appel direct, objets sf / terra partagés |
| Nuage de points | pylasr encore jeune, ou PDAL | lidR et lasR, natifs |
| Modèles | scikit-learn | ranger (forêts aléatoires), e1071 (SVM), MASS (analyse discriminante) |
| Test du successeur | Lisible par beaucoup de monde | Même écosystème que nemeton, l'ONF, l'INRAE et le rapport de 2020 |
| Code déjà écrit | Environ 900 lignes et 17 tests | À porter (environ 900 lignes) |

**Recommandation de l'orchestrateur : R.** Un package compagnon de nemeton, qui reprend
ses conventions : SER → grande région → national, NDP, sf et terra. Le code Python reste
petit, donc le portage coûte peu, et chaque mois d'attente l'alourdit. Ce que ça
sacrifie : le travail Python déjà écrit, et l'audience Python. Cette décision touche
nemeton : elle remonte à Pascal, hors délégation.

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

# ADR 0011 — Stack logicielle : R en paquet, PDAL en ligne de commande

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

La chaîne est un paquet R (lidR, lidaRtRee, terra, sf, sits, tidymodels, spatialsample,
CAST, targets, testthat), avec PDAL en ligne de commande pour le prétraitement lourd des
nuages et les outils Python existants (fordead) appelés comme outils externes ;
environnement figé par renv et une image conteneur ; tests par
`Rscript -e 'testthat::test_local()'`.

## Contexte

Options envisagées :
1. **R + PDAL en ligne de commande** : retenue. Continuité avec le socle lidaRtRee
   (ADR 0009), le mémoire de 2020, l'ONF RDI et l'INRAE Grenoble ; sits couvre les
   séries Sentinel-2 (classification RF, SVM, TempCNN ; cubes via gdalcubes ; sources
   STAC).
2. Python (PDAL, rasterio, xarray, scikit-learn) : écosystème Sentinel-2 opérationnel
   en France (iota2 au CESBIO, fordead à l'INRAE TETIS) et IGN (Myria3D, ign-pdal-tools).
3. Mixte R + Python : deux environnements à maintenir.
4. Computree : spécialisé LiDAR, pas une chaîne complète.
5. R + lasR : option de production gardée en réserve (lasR, C++, API R et Python,
   « Maturing », hors CRAN).

**Montée en charge** : pour le LiDAR, elle se fait par dalle dans les deux langages
(LAScatalog dans lidR, pipelines PDAL) ; Dask n'y joue pas.

**Risque principal** : depuis 2024, l'université Laval ne finance plus lidR ni lasR ;
r-lidar est devenu une société. Parade : prétraitement lourd par PDAL (pipelines JSON,
sans Python), lasR en réserve.

**Tests** : un seul langage ; le critère A15 se limite à ce que GDAL vérifie (lecture,
table des classes, présence du `.qml`), sans PyQGIS.

**Reproductibilité** : renv (versions des paquets), image conteneur (GDAL, PROJ),
graines et nombre de fils fixés.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un langage, un paquet ; PDAL sans environnement Python | — | Oui |
| **R**esponsable | Qui fait quoi ? | ONF RDI et INRAE Grenoble en R ; IGN, INRAE TETIS et CESBIO en Python | Partenaires Python moins à l'aise pour relire | Oui |
| **A**nticiper | Si l'imprévu arrive ? | lidR non maintenu : PDAL et lasR en réserve | Réécriture partielle | Oui |
| **N**ovateur | Idées étranges ? | Options 2 à 5 examinées | — | — |
| **C**oût | Coût à l'ensemble ? | Libre, sans licence ; conteneur à tenir | Maintenance de l'image | Oui |
| **É**cologique | Réutilisation ? | Réutilise lidaRtRee, sits, fordead ; paquet réutilisable par la recherche forestière | Moins réutilisable par l'écosystème Python | Oui |

## Valeurs sacrifiées

- La sécurité d'un outil LiDAR financé : lidR n'est plus financé depuis 2024.
- La proximité avec l'écosystème Sentinel-2 opérationnel français, en Python.
- Le test d'ouverture dans QGIS lui-même (A15 limité à GDAL).

## Sources

- lidR : https://r-lidar.github.io/lidRbook/ ; moteur LAScatalog : https://r-lidar.github.io/lidRbook/engine.html
- lasR : https://r-lidar.github.io/lasR/
- lidaRtRee : https://lidar.pages-forge.inrae.fr/lidaRtRee/
- PDAL : https://pdal.io/en/latest/about.html ; ign-pdal-tools : https://pypi.org/project/ign-pdal-tools
- sits : https://github.com/e-sensing/sits
- iota2 : https://www.orfeo-toolbox.org/packages/doc/FOSS4G2022/FOSS4G2022_iota2.pdf
- fordead : https://zenodo.org/records/12802457
- CAST (Meyer et Pebesma, 2021) : https://arxiv.org/abs/2005.07939
- targets : https://docs.ropensci.org/targets/

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

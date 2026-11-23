# ADR 0016 — Nuage de points : lasR isolé derrière une interface, PDAL en repli ; reproductibilité

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après l'ADR 0011 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par l'arbitrage C10 ; apports retenus en bloc
- **Tranchée par :** Pascal (arbitrage C10 et apports, 2026-11-23)
- **Précise :** ADR 0003 et 0004 (« lasR ou lidR ») ; elles restent valables pour le langage R

## La décision en une phrase

La chaîne reste un paquet R (ADR 0004) ; **lasR est gardé** pour le nuage de points mais
**isolé derrière une interface interne** (`calculer_mnh`, `segmenter_houppiers`) pour
pouvoir en changer ; **PDAL, en ligne de commande, est le repli** pour le prétraitement ;
lidaRtRee sert aux **tests des houppiers** (jeu Chablais 3) ; l'environnement est figé par
renv et une image conteneur, le flux par `targets`, avec graines et nombre de fils fixés.

## Contexte

- A : lasR (Suggests, installation depuis r-universe, hors CRAN, à compiler) pour les
  strates et les houppiers (ADR 0003 et 0004 de A ; `R/houppiers.R`).
- B : lidR, lidaRtRee et PDAL en ligne de commande ; lasR « en réserve ». **Risque principal
  (B)** : depuis 2024, l'université Laval ne finance plus lidR ni lasR, et r-lidar est
  devenu une société. Le risque vaut pour lasR autant que pour lidR.
- Dans le code de A, `segmenter_houppiers()` existe ; `calculer_mnh` n'existe pas encore
  (recherche dans `R/`, 2026-11-23) : l'interface est à construire.

Options envisagées (ADR 0011 de B) :
1. R + PDAL en ligne de commande.
2. Python (PDAL, rasterio, xarray, scikit-learn) : écosystème Sentinel-2 opérationnel en
   France (iota2, fordead) et à l'IGN.
3. Mixte R + Python : deux environnements.
4. Computree : spécialisé LiDAR, pas une chaîne complète.
5. R + lasR : retenue par l'arbitrage C10, avec interface isolante et PDAL en repli
   (combine 1 et 5).

**Montée en charge** : par dalle ou par catalogue avec tampon (LAScatalog dans lidR,
pipelines PDAL ; A traite déjà une collection de dalles avec tampon dans `R/houppiers.R`).

**Reproductibilité** (apport retenu) : renv (versions des paquets), image conteneur (GDAL,
PROJ), graines et nombre de fils fixés, `targets` pour le flux.

**Outils externes** : fordead (Python, INRAE) appelé comme outil externe pour détecter les
coupes (ADR 0006).

**Tests** : un seul langage, `.claude/test-command` ; le critère de lecture dans QGIS se
limite à ce que GDAL vérifie (lecture, table des classes, présence du `.qml`), sans PyQGIS.
Jeux lidaRtRee : `tree_inventory_chablais3` et `chm_chablais3` pour tester la segmentation
des houppiers contre des arbres mesurés (ADR 0010) ; lidaRtRee n'est requis que par ces tests,
son statut de dépendance est à fixer par la mission.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un langage, un paquet ; une interface mince | Quelques fonctions d'interface | Oui |
| **R**esponsable | Qui fait quoi ? | Le paquet change d'outil de nuage sans toucher au reste | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | lasR non maintenu : PDAL en repli | Réécriture de l'interface | Oui |
| **N**ovateur | Idées étranges ? | Options 2 à 4 examinées | — | — |
| **C**oût | Coût à l'ensemble ? | Libre, sans licence ; conteneur à tenir | Maintenance de l'image | Oui |
| **É**cologique | Réutilisation ? | Réutilise lasR, lidaRtRee, fordead ; paquet réutilisable | Moins réutilisable par l'écosystème Python | Oui |

## Valeurs sacrifiées

- La sécurité d'un outil LiDAR financé : ni lasR ni lidR ne le sont depuis 2024 (B).
- La proximité avec l'écosystème Sentinel-2 opérationnel français, en Python.
- Le test d'ouverture dans QGIS lui-même (limité à GDAL).

## Sources

Reprises de l'ADR 0011 de B ; non reconsultées le 2026-11-23.

- lidR : https://r-lidar.github.io/lidRbook/ ; moteur LAScatalog : https://r-lidar.github.io/lidRbook/engine.html
- lasR : https://r-lidar.github.io/lasR/
- lidaRtRee : https://lidar.pages-forge.inrae.fr/lidaRtRee/
- PDAL : https://pdal.io/en/latest/about.html ; ign-pdal-tools : https://pypi.org/project/ign-pdal-tools
- fordead : https://zenodo.org/records/12802457
- CAST (Meyer et Pebesma, 2021) : https://arxiv.org/abs/2005.07939
- targets : https://docs.ropensci.org/targets/
- Dans A : `DESCRIPTION` (Suggests), `R/houppiers.R`, ADR 0003 et 0004.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

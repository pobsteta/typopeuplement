# ADR 0005 — Grille de 26,6 m en Lambert-93 et rééchantillonnage unique des capteurs

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après le cadrage A (grille ONF de 26,6 m) et l'ADR 0001 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par l'arbitrage C8
- **Tranchée par :** Pascal (arbitrage C8, 2026-11-23)
- **Précise :** le brief (« une résolution de travail de l'ordre de 25 m ») ; ADR 0004 (aucune grille n'y est fixée)

## La décision en une phrase

Toutes les couches sont produites en Lambert-93 (EPSG:2154) sur un pavage carré de
**26,6 m** (707,6 m², la surface d'une placette de 15 m de rayon : 706,9 m²), aligné sur
la grille des rasters ONF là où ils existent et d'origine fixe ailleurs ; chaque capteur
est rééchantillonné **une seule fois** vers cette grille (Sentinel-2 à 10 m et à 20 m par
moyenne pondérée par la surface ; Sentinel-1 corrigé du relief puis projeté directement),
et la sensibilité à ce choix est mesurée au pilote.

## Contexte

- Le brief de A parlait d'une résolution « de l'ordre de 25 m », sans justification ; en
  pratique A tourne sur la grille ONF de 26,6 m (README, `R/donnees_lidar.R`), avec un
  défaut de 25 m dans `ecrire_livrables()` et un lissage décrit en pixels de 25 m
  (`R/lissage.R`) : à aligner (voir « Conséquences »).
- Le cadrage B proposait un pas de 25 m avec une fenêtre circulaire de 15 m de rayon et
  gardait 26,6 m comme option à comparer au pilote. Sa propre source (Monnet et Munoz,
  2015) trouve, à surface égale, les pixels carrés « légèrement meilleurs […] du point de
  vue du biais » et conclut qu'« il semble donc judicieux d'utiliser des pixels » (citation
  rapportée par l'ADR 0001 de B, non relue dans la source).
- Pascal accepte qu'**aucune grille Lambert-93 ne colle exactement à Sentinel** (UTM 30,
  31, 32) : un rééchantillonnage est inévitable, quel que soit le pas.

Options envisagées :
1. Pavage de 20 m (400 m²) : emboîtement natif avec les bandes Sentinel-2 à 20 m, mais un
   pixel 43 % plus petit que la placette (chiffre de B).
2. Pavage de 25 m (625 m²) : 12 % plus petit que la placette (chiffre de B).
3. **Pavage de 26,6 m (≈ 707 m²), comme l'ONF** : retenue. Le support du pixel a la
   surface de la placette de référence (ADR 0006), la comparaison avec les rasters ONF se
   fait sans rééchantillonnage, et le calcul reste celui de A.
4. Pas de 25 m avec fenêtre circulaire de 15 m de rayon (option de B) : écartée par
   l'arbitrage C8 (fenêtres chevauchantes, calcul environ 1,13 fois plus lourd pour les
   métriques de points d'après B).
5. Prédiction à 10 m puis agrégation : support sans rapport avec la placette.

**Rééchantillonnage** (arbitrage C8) :
- Sentinel-2, bandes à 10 m et à 20 m : moyenne des pixels source pondérée par la surface
  recouverte dans chaque pixel de la grille. Un pixel de 707 m² recouvre environ 7 pixels
  de 10 m et moins de 2 pixels de 20 m (calcul sur les surfaces). La géolocalisation de
  Sentinel-2, de l'ordre de 6 à 7 m (CE95, chiffre de B), s'ajoute au support effectif.
- Sentinel-1 : corrigé du relief, puis projeté directement sur la grille.
- La sensibilité de la carte à ce rééchantillonnage est mesurée sur l'AOI pilote
  (ADR 0008).

**Origine de la grille** : « fixe ailleurs » que sur les rasters ONF ; sa valeur n'est pas
fixée par l'arbitrage (point ambigu n° 2 de l'archiviste ; décision de l'orchestrateur du 2026-11-23 au journal : origine fixée par le plan de la mission 018) et reste à
écrire dans la mission qui met la grille en code.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un pavage, un pixel = une placette en surface ; pas de fenêtre glissante | Un pas non entier | Oui |
| **R**esponsable | Qui fait quoi ? | La chaîne rééchantillonne une fois ; la sensibilité est mesurée au pilote | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Si la mesure au pilote est mauvaise, le rééchantillonnage ou le pas se rejoue | Un rejeu complet | Oui |
| **N**ovateur | Idées étranges écoutées ? | Options 1, 4 et 5 examinées | — | — |
| **C**oût | Coût à l'ensemble ? | Pas de surcoût de fenêtre glissante | — | Oui |
| **É**cologique | Réutilisation ? | Alignement sur les rasters ONF, sans rééchantillonnage pour les comparer | Calage sur Sentinel perdu | Oui |

## Valeurs sacrifiées

- L'emboîtement dans les dalles de 1 km (1 000 m n'est pas un multiple de 26,6 m) et dans
  la maille de 70,7 m des grappes (ADR 0006).
- L'emboîtement natif avec les pixels de Sentinel-2.
- La forme : le pixel est un carré de 26,6 m, la placette un disque de 15 m de rayon ; seule
  la surface coïncide.

## Conséquences (à confier en mission, pas faites ici)

- Aligner le défaut de 25 m de `ecrire_livrables()` et le lissage de `R/lissage.R`.
- Pixels de bord : le support d'un pixel (et le lissage 3 × 3) déborde sur la parcelle ou
  l'AOI voisine ; la règle n'est pas arbitrée.

## Sources

Sources reprises de l'ADR 0001 de B, non reconsultées le 2026-11-23.

- J.-M. Monnet, A. Munoz, RFPT n° 211-212, 2015 : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079
- Cartes ONF à 700 m² : https://www.ign.fr/lidar-hd-foret
- Sentinel-2, produits et tuiles UTM : https://sentiwiki.copernicus.eu/web/s2-products
- ESA, Global Reference Image : https://sentinel.esa.int/web/sentinel/global-reference-image
- EPSG:2154, aire d'usage hexagone et Corse : https://epsg.io/2154
- Dans A : `README.md` (grille ONF de 26,6 m), `R/donnees_lidar.R`, `R/milieu.R` (13,3 m pour la grille ONF).

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

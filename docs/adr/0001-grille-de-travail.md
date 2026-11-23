# ADR 0001 — Grille de travail : Lambert-93, pas de 25 m, support de 15 m de rayon

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** sujet proposé par le contradicteur, rédigée par Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

Toutes les couches sont produites en Lambert-93 (EPSG:2154) sur une grille de pas 25 m
dont l'origine est un multiple de 25 m, et les métriques de chaque nœud sont calculées
sur une fenêtre circulaire de 15 m de rayon, identique à la placette de référence.

## Contexte

**Révision après critique (acceptée par Pascal le 2026-11-23)** :
- Monnet et Munoz (2015) ont testé des cercles de 17 m à espacements de 10 à 40 m :
  l'espacement « ne semble pas jouer un rôle prépondérant », mais à surface égale les
  pixels carrés donnent des résultats « légèrement meilleurs […] du point de vue du
  biais », et ils concluent qu'« il semble donc judicieux d'utiliser des pixels ». La
  source la plus proche n'appuie donc pas l'option 4 ; on la garde, l'écart étant
  faible, et l'option 3 (pavage de 26,6 m) est comparée au pilote.
- Les métadonnées de chaque couche disent que la valeur décrit un disque de 707 m²
  centré sur le pixel, pas le carré de 625 m².
- Sentinel-2 : un disque de 707 m² contient environ 7 pixels de 10 m et moins de 2 de
  20 m, et la géolocalisation est de l'ordre de 6 à 7 m CE95 ; le support effectif est
  donc de 15 m plus une marge de géolocalisation ; sensibilité au rayon testée au pilote.
- Coût réel : métriques de points environ π·15²/25² ≈ 1,13 fois plus lourdes qu'un
  pavage ; segmentation du MNH sans surcoût ; tampon de 15 m aux bords des dalles de
  1 km (chargement des dalles voisines).
- Convention de pente (rayon horizontal) : fixée dans le protocole (ADR 0004).
- Les grappes de validation sont des rectangles de 50 × 100 m alignés sur la grille
  (ADR 0002).

Le brief de cadrage parlait d'une résolution « de l'ordre de 25 m », sans justification.
Pascal a demandé pourquoi pas 20 m (bandes Sentinel-2 natives à 20 m). La placette de
référence de 15 m de rayon (707 m²) a été validée par Pascal. Monnet et Munoz (2015)
recommandent de respecter la taille des placettes de calibration lors de la
spatialisation ; l'ONF produit ses cartes en pixels de 700 m².

Options envisagées :
1. Pavage 20 m (400 m²) : emboîtement natif Sentinel-2, mais pixel 43 % plus petit que
   la placette ; 6,25 pixels au quart d'hectare.
2. Pavage 25 m (625 m²) sans chevauchement : 12 % plus petit que la placette ; 4 et
   8 pixels au quart et au demi-hectare.
3. Pavage 26,6 m (≈ 707 m², comme l'ONF) : support = placette, mais pas non entier,
   ne s'emboîte ni dans les dalles de 1 km ni au demi-hectare.
4. **Pas 25 m + support circulaire de 15 m (fenêtres chevauchantes)** : retenue.
5. Prédiction à 10 m puis agrégation : plus fine, mais support sans rapport avec la
   placette.

Sentinel-2 est en UTM (zones 30, 31, 32) : un rééchantillonnage vers Lambert-93 est
inévitable quel que soit le pas, ce qui affaiblit l'argument d'emboîtement de l'option 1.
Il est fait une seule fois, par moyenne pondérée des pixels source dans la fenêtre de
15 m (méthode à confirmer par le pilote).

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un seul support, celui de la placette ; un pas entier qui divise 1 km | Une fenêtre glissante à coder plutôt qu'un pavage | Oui |
| **R**esponsable | Qui fait quoi ? | La chaîne calcule au nœud ; le rayon d'extraction Sentinel-2 est fixé au pilote | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Si le pilote montre qu'un autre support calibre mieux, seul le rayon change | Un rejeu complet | Oui |
| **N**ovateur | Idées étranges écoutées ? | Options 3 et 5 examinées | — | — |
| **C**oût | Coût à l'ensemble ? | ≈ 1,13 fois plus de calcul pour les métriques de points ; tampon aux bords de dalles | Calcul, entrées-sorties | Oui |
| **É**cologique | Réutilisation ? | Placettes de 15 m réutilisables, sous réserve de l'écart de date (ADR 0004) | Comparaison pixel à pixel avec l'ONF perdue | Oui |

## Valeurs sacrifiées

- La simplicité d'un pavage sans chevauchement (un point = un pixel).
- La comparaison pixel à pixel avec les cartes ONF de 700 m² : la comparaison se fera
  par rééchantillonnage.
- Un léger biais possible par rapport à un pavage de même surface (Monnet et Munoz, 2015).
- L'homogénéité des supports entre capteurs (Sentinel-2 plus large que le LiDAR).

## Sources

- J.-M. Monnet, A. Munoz, RFPT n° 211-212, 2015 : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079
- Cartes ONF à 700 m² : https://www.ign.fr/lidar-hd-foret
- Sentinel-2, produits et tuiles UTM : https://sentiwiki.copernicus.eu/web/s2-products
- ESA, Global Reference Image : https://sentinel.esa.int/web/sentinel/global-reference-image
- EPSG:2154, aire d'usage hexagone et Corse : https://epsg.io/2154

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

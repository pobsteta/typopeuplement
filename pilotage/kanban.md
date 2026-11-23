# Kanban de typopeuplement

> Cinq colonnes (fiche n° 8). **Une carte qui ne bouge pas est souvent la mauvaise
> nouvelle à dire tout de suite.**

**Dernier cycle :** 2

## Bac à sable

- Mineurs de 012 : règle hors clé en mode « pixels préparés », raster factice de focalMat en Lambert-93, part « entre deux » et effectifs dans la fiche · depuis le cycle 2


- Brancher le calcul des métriques LiDAR HD (nuage de points → grille de 25 m) · depuis le cycle 0
- Brancher les séries Sentinel-2 et la BD Forêt v3 · depuis le cycle 0
- Modèle de part de petits bois et seuil de précomptage abaissé · depuis le cycle 0
- Clé à part pour les SER d'alluvions · depuis le cycle 0

## Validé

- [013-couvert-houppiers](missions/013-couvert-houppiers.md) · depuis le cycle 3

- [011-incertitude-locale-hpot](missions/011-incertitude-locale-hpot.md) · depuis le cycle 2
- [010-cle-gsm](missions/010-cle-gsm.md), reprise courte (seuil de 15 m sur hpot, test de la clé H10) · depuis le cycle 2

## Planifié

## Terminé

_Fusionnées dans main le 2026-11-22 (PR n° 1)._ Cycle 2, prêtes selon le relecteur, en attente de la fusion de la PR n° 2 : 005, 006, 007, 008, 009, 010, 012.

- [001-environnement-r](missions/001-environnement-r.md) · depuis le cycle 1
  - Homme : `dev` (sonnet) · Mission : R et commande de tests · Moyens : apt, testthat
- [002-referentiel-ser](missions/002-referentiel-ser.md) · depuis le cycle 1
  - Homme : `acquereur` (sonnet) · Mission : référentiel des SER, rattachement du Vercors · Moyens : WFS INRAE, IGN, CRAIG
- [004-tests-r](missions/004-tests-r.md) · depuis le cycle 1
  - Homme : `testeur` (sonnet) · Mission : tests des critères 1 à 6 · Moyens : prototype, fixtures
- [003-portage-r](missions/003-portage-r.md) · depuis le cycle 1
  - Homme : `dev` (opus) · Mission : portage en R · Moyens : plan validé, tests de 004

## Abandonné

## Livraisons

- cycle 0 · socle de la chaîne sur données synthétiques (clé floue, hauteur potentielle, raccord de SER, validation à la grappe) · pour Pascal, à relire · premier livrable : rien avant
- cycle 1 · package R `typopeuplement` (chaîne complète sur jeu synthétique, 337 tests verts), référentiel des SER, rattachement mesuré de l'AOI pilote (H10 86,6 %, H30 12,3 %) · pour Pascal (et nemeton) · la chaîne passe en R, dans l'écosystème de nemeton, avec les mêmes chiffres que le prototype ; pas encore de carte réelle (proposée)
- cycle 2 · mauvaise nouvelle : première carte GSM de Léoncel (8 240 px typés, couche de confiance, 3 pixels de terrain), mais 82 % de jeunes futaies · pour Pascal · ce qu'elle nous apprend : le couvert mesuré par retours LiDAR par tranche de hauteur ne vaut pas le couvert par houppier du GSM ; la chaîne lit les vraies données (ONF, IGN, LiDAR HD), mesurée de bout en bout

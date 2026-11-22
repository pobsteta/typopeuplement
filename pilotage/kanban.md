# Kanban de typopeuplement

> Cinq colonnes (fiche n° 8). **Une carte qui ne bouge pas est souvent la mauvaise
> nouvelle à dire tout de suite.**

**Dernier cycle :** 1

## Bac à sable


- Brancher le calcul des métriques LiDAR HD (nuage de points → grille de 25 m) · depuis le cycle 0
- Brancher les séries Sentinel-2 et la BD Forêt v3 · depuis le cycle 0
- Modèle de part de petits bois et seuil de précomptage abaissé · depuis le cycle 0
- Clé à part pour les SER d'alluvions · depuis le cycle 0

## Validé

- [005-typologie-h10](missions/005-typologie-h10.md) · depuis le cycle 1
  - Homme : `acquereur` (sonnet) · Mission : typologie locale de H10, sourcée · Moyens : jeu Vercors, guides, SRGS
- [006-lecture-vercors](missions/006-lecture-vercors.md) · depuis le cycle 1
  - Homme : `dev` (opus) · Mission : première carte réelle sur l'AOI · Moyens : CRAIG, terra, plan d'abord

## Planifié

## Terminé

_Prêtes selon le relecteur, en attente de la fusion de la PR n° 1 par Pascal._

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

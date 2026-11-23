# Kanban de TypoPeuplement

> Cinq colonnes (fiche n° 8). Chaque carte porte l'Homme (qui), la Mission (quoi, quand,
> combien) et les Moyens (comment, où, avec qui), et renvoie à sa fiche dans
> `pilotage/missions/`. Elle note aussi depuis quel cycle de `/boucle` elle est dans sa
> colonne ; on change ce numéro chaque fois qu'elle change de colonne.
> **Une carte qui ne bouge pas est souvent la mauvaise nouvelle à dire tout de suite.**

**Dernier cycle :** 0 _(augmenté de 1 à la fin de chaque `/boucle`, même quand elle n'a
rien lancé. Une carte est immobile quand dernier cycle − N ≥ 2.)_

_Modèle de carte :_

```
- [NNN-titre](missions/NNN-titre.md) · depuis le cycle N
  - Homme : qui
  - Mission : quoi, quand, combien
  - Moyens : comment, où, avec qui
```

## Bac à sable

## Validé

_Validées par Pascal le 2026-11-23 (porte n° 2), cycle 1._

- [001-squelette-paquet-ci-releases](missions/001-squelette-paquet-ci-releases.md) · depuis le cycle 0
  - Homme : `dev` (sonnet), donner la main
  - Mission : paquet R, renv, CI, couverture, releases `vAAAA.MM.N` ; cycle 1
  - Moyens : ADR 0011, 0013 ; scripts de Marculus
- [002-referentiels-typologiques-aura](missions/002-referentiels-typologiques-aura.md) · depuis le cycle 0
  - Homme : `acquereur` (opus), prendre la main
  - Mission : 8 types et seuils SRGS AURA, guide Alpes du Nord, protocole IFN ; cycle 1
  - Moyens : sources nommées, liste de contrôle
- [003-donnees-et-placettes-ser-candidates](missions/003-donnees-et-placettes-ser-candidates.md) · depuis le cycle 0
  - Homme : `acquereur` (sonnet), donner la main
  - Mission : inventaire des données et placettes des 4 SER candidates ; cycle 1
  - Moyens : data.gouv, IGN, INRAE

## Planifié

- [004-tests-grille-et-disque](missions/004-tests-grille-et-disque.md) · depuis le cycle 0
  - Homme : `testeur` (sonnet) ; cycle 2, groupée avec 005
- [005-grille-et-metriques-au-disque](missions/005-grille-et-metriques-au-disque.md) · depuis le cycle 0
  - Homme : `dev` (opus), prendre la main ; cycle 2
- [006-tests-cle-type-local](missions/006-tests-cle-type-local.md) · depuis le cycle 0
  - Homme : `testeur` (sonnet) ; cycle 3, attend 002
- [007-cle-type-local](missions/007-cle-type-local.md) · depuis le cycle 0
  - Homme : `dev` (sonnet) ; cycle 3, attend 002 et 006

## Terminé

## Abandonné

_Avec la raison, en une ligne._

## Livraisons

_Une ligne par cycle, ajoutée sous la précédente à la fin de chaque `/boucle`, et une
par `/bilan` : la livraison que Pascal a retenue, pour qui, et ce qu'elle apporte de plus
que la précédente du même rythme. On lance petit (fiche n° 12) : la plus petite version
qui rend déjà un service réel, un MVP, essayée tout de suite sur le terrain. Un cycle sans livraison neuve livre sa mauvaise
nouvelle, car
« une mauvaise nouvelle est une livraison sur laquelle on apprend » (Pascal) : on
l'inscrit avec ce qu'elle nous apprend._

```
- cycle N · livraison · pour qui · ce qu'elle apporte de plus que la précédente
- cycle N · mauvaise nouvelle : … · pour qui · ce qu'elle nous apprend
- bilan du AAAA-MM-JJ · livraison · pour qui · ce qu'elle apporte de plus que la précédente
- bilan du AAAA-MM-JJ · mauvaise nouvelle : … · pour qui · ce qu'elle nous apprend
```

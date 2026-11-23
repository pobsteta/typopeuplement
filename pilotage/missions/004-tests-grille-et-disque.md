# Mission 004 — Tests d'acceptation de la grille et du disque de 15 m

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire, à partir de la spec et sans lire le code qui les implémente, les tests d'acceptation de la grille Lambert-93 de 25 m et du calcul des métriques au disque de 15 m (critères A1 et A2), pour que la mission 005 ne s'auto-évalue pas.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | oui | ADR 0001 ; spec A1, A2 ; jeux `tree_inventory_chablais3` et `chm_chablais3` de lidaRtRee |
| A-t-il les moyens ? (outils, données d'essai, tests) | oui | lidaRtRee 4.0.9 installé ; squelette du paquet après 001 |

**Temps de la main :** **donner**.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `testeur`
- **Modèle :** sonnet.
- **Ce qui ne lui est pas demandé :** le code de la grille ; les tests d'autres critères.

## Harnais

- **Peut (périmètre) :** `tests/testthat/test-grille.R`, `tests/testthat/test-disque.R`, `tests/testthat/helper-*.R`.
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** lire `R/` de la mission 005 ; affaiblir un test pour le faire passer.
- **Sources autorisées :** `docs/spec.md` (A1, A2), `docs/adr/0001-grille-de-travail.md`, documentation de lidaRtRee et de ses jeux de données. Fermées : la branche de la mission 005.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 001 (part de `main` après sa fusion).
- **Ordre de fusion :** 004 et 005 **groupées**.
- **PR en brouillon jusqu'à :** la fusion groupée avec 005.
- **CI rouge attendue :** les tests de 004 sont rouges tant que les fonctions de 005 n'existent pas — « rouge justifiée » jusqu'à la fusion groupée.

## Tests

- **Comment saura-t-on que c'est juste :** les tests vérifient : SCR EPSG:2154, pas de 25 m, origine multiple de 25 m ; sur Chablais 3, les points ou arbres retenus pour un nœud sont exactement ceux à 15 m au plus en distance horizontale ; un cas à la limite de dalle (tampon) ; la liste de contrôle « avant prêt » est cochée.

## Terrain

- **Échantillon que Pascal vérifiera :** un nœud de Chablais 3 dont Pascal compte à la main les arbres du disque de 15 m sur la carte.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** à la PR, avant la fusion groupée.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

Les tests échouent sur une grille décalée de 1 m ou un disque de 14 m.

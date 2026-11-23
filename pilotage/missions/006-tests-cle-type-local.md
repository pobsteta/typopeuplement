# Mission 006 — Tests d'acceptation de la clé du type local

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire, à partir de la spec et de la table des référentiels, sans lire le code, les tests qui vérifient que la clé du type local SRGS AURA classe correctement une liste d'arbres (critères A4, A6), pour que la mission 007 ne s'auto-évalue pas.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | oui | ADR 0003, 0006 ; table de 002 |
| A-t-il les moyens ? (outils, données d'essai, tests) | non | la table des référentiels (002) n'existe pas encore |

**Temps de la main :** **donner**, après la fusion de 002.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `testeur`
- **Modèle :** sonnet.
- **Ce qui ne lui est pas demandé :** le code de la clé.

## Harnais

- **Peut (périmètre) :** `tests/testthat/test-cle.R`, `tests/testthat/fixtures/cle/`.
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** lire `R/` de la mission 007 ; inventer un seuil absent de la table.
- **Sources autorisées :** `docs/referentiels/` (de 002), `docs/adr/0003`, `0006`, `docs/spec.md` (A4, A6) ; `tree_inventory_chablais3`.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 001 et 002 (fusionnées).
- **Ordre de fusion :** 006 et 007 **groupées**.
- **PR en brouillon jusqu'à :** la fusion groupée avec 007.
- **CI rouge attendue :** tests rouges tant que la clé de 007 n'existe pas — rouge justifiée jusqu'à la fusion groupée.

## Tests

- **Comment saura-t-on que c'est juste :** un cas par type SRGS au moins, construit à partir des seuils de la table ; un cas de changement de référentiel sans recalibrage (A4) ; Chablais 3 classé selon la table.

## Terrain

- **Échantillon que Pascal vérifiera :** le type SRGS que la clé attribue à Chablais 3, que Pascal confronte à son propre jugement.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** à la PR.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

Chaque type SRGS a au moins un cas qui l'atteint et un cas limite juste en dessous.

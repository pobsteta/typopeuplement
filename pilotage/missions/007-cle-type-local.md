# Mission 007 — Clé du type local sur une liste d'arbres

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire la fonction qui, à partir d'une liste d'arbres (essence, diamètre, origine) et de la table des référentiels, calcule le type local SRGS, pour que les grappes de validation et les placettes reçoivent le type du gestionnaire (ADR 0006).

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | oui | ADR 0003, 0006 ; table de 002 |
| A-t-il les moyens ? (outils, données d'essai, tests) | non | table (002) et tests (006) pas encore là |

**Temps de la main :** **donner**, après 002 et 006.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `dev`
- **Modèle :** sonnet.
- **Ce qui ne lui est pas demandé :** la prédiction par pixel ; le type générique.

## Harnais

- **Peut (périmètre) :** `R/cle.R`, `R/referentiels.R`, `man/`, `NAMESPACE` (ajouts).
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** coder un seuil en dur (A4) ; modifier les tests de 006 ; modifier la table de 002.
- **Sources autorisées :** `docs/referentiels/`, `docs/adr/0003`, `0006`, `docs/spec.md`.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 001, 002 (fusionnées) et 006.
- **Ordre de fusion :** 006 et 007 **groupées**.
- **PR en brouillon jusqu'à :** tests de 006 verts.
- **CI rouge attendue :** aucune à la fusion groupée.

## Tests

- **Comment saura-t-on que c'est juste :** tests de 006 verts sans modification ; aucun nombre de seuil dans `R/cle.R`.

## Terrain

- **Échantillon que Pascal vérifiera :** le type de Chablais 3 (comme pour 006).

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** à la PR.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

Changer une valeur de la table change le type rendu, sans toucher au code.

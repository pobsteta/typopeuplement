# Mission 002 — Référentiels typologiques d'Auvergne-Rhône-Alpes

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Saisir, avec leurs sources, les 8 types et les seuils du SRGS Auvergne-Rhône-Alpes, la typologie du guide de sylviculture des Alpes du Nord et le protocole IFN en vigueur, pour que la clé du type local repose sur des référentiels publiés et non inventés.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | oui | sources nommées ; liste de contrôle du skill `methode` jointe |
| A-t-il les moyens ? (outils, données d'essai, tests) | oui | accès web ; SRGS AURA déjà repéré (p. 11-12) |

**Temps de la main :** **prendre** — codes et nomenclatures engagent la durée : l'agent rend un plan (liste des sources, structure de la table) avant de saisir ; Pascal valide la table.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `acquereur`
- **Modèle :** opus — justesse des données.
- **Ce qui ne lui est pas demandé :** aucun code R ; pas de choix des SER pilotes ; pas d'autres régions qu'AURA (les deux SER pilotes suggérées, Alpes du Nord et Vercors, y sont).

## Harnais

- **Peut (périmètre) :** `docs/referentiels/` (table des référentiels en CSV, une fiche Markdown par source).
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** inventer un code ou un seuil ; recopier une valeur sans page ni URL ; trancher entre deux sources qui se contredisent (le signaler).
- **Sources autorisées :** SRGS AURA (https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf) ; guide de sylviculture des Alpes du Nord (ONF / CRPF) ; DRA/SRA ONF des Alpes du Nord ; documentation IFN (protocole, variables de structure et de composition) ; `docs/adr/0003`, `0006` ; `docs/spec.md` § 5, besoins 2 à 4. Fermées : typologies d'autres régions.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** aucune.
- **Ordre de fusion :** indifférent ; avant la mission 006.
- **PR en brouillon jusqu'à :** —
- **CI rouge attendue :** aucune (seul `docs/` change).

## Tests

- **Comment saura-t-on que c'est juste :** chaque ligne de la table porte sa source (document, page ou URL) ; les 8 types SRGS sont tous présents (critère A6) ; la liste de contrôle « avant prêt » est cochée.

## Terrain

- **Échantillon que Pascal vérifiera :** trois lignes de la table tirées au hasard, confrontées par Pascal au PDF du SRGS.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** au rendu du plan, puis à la PR.
- **Qui tranche :** Pascal. Si une source n'est accessible qu'en la demandant à l'ONF ou au CNPF, Pascal fait la demande lui-même.

## Comment saura-t-on que ça marche ?

La table permet de dire, pour un peuplement décrit par ses surfaces terrières par classe et ses essences, quel type SRGS AURA lui revient, sans autre document.

# Mission 005 — Grille Lambert-93 et métriques LiDAR au disque de 15 m

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire les fonctions qui construisent la grille de 25 m en Lambert-93 et calculent les métriques LiDAR de chaque nœud sur le disque de 15 m (ADR 0001), pour que tout le reste de la chaîne parte du même support que la placette.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | non en partie | le choix de l'implémentation (lidR, lidaRtRee, PDAL ; tampon aux bords de dalles) n'est pas écrit |
| A-t-il les moyens ? (outils, données d'essai, tests) | oui | tests de 004, jeux lidaRtRee |

**Temps de la main :** **prendre** — c'est le modèle de données de toute la chaîne : l'agent rend d'abord un plan (fonctions, structures, tampon de dalle, appel à lidaRtRee ou PDAL), que Pascal valide avant l'exécution.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `dev`
- **Modèle :** opus — engage l'architecture.
- **Ce qui ne lui est pas demandé :** les modèles, la clé, Sentinel-2.

## Harnais

- **Peut (périmètre) :** `R/grille.R`, `R/metriques.R`, `man/`, `NAMESPACE` (ajouts), `DESCRIPTION` (champ `Imports`).
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** modifier les tests de 004 ; changer le rayon, le pas ou l'origine (ADR 0001).
- **Sources autorisées :** `docs/adr/0001`, `0011` ; `docs/spec.md` (A1, A2) ; documentation lidR, lidaRtRee, PDAL. Fermées : écriture dans `tests/`.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

aucune (rayon, pas et origine tranchés par l'ADR 0001).

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 001 (fusionnée) et 004 (tests).
- **Ordre de fusion :** 004 et 005 **groupées**.
- **PR en brouillon jusqu'à :** plan validé par Pascal, puis tests de 004 verts.
- **CI rouge attendue :** aucune à la fusion groupée.

## Tests

- **Comment saura-t-on que c'est juste :** les tests de 004 verts sans modification ; `.claude/test-command` vert.

## Terrain

- **Échantillon que Pascal vérifiera :** la carte d'une métrique (hauteur dominante) sur Chablais 3, ouverte dans QGIS.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** au rendu du plan ; puis à la PR.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

La hauteur dominante calculée sur Chablais 3 est cohérente avec le MNH à l'œil, dans QGIS.

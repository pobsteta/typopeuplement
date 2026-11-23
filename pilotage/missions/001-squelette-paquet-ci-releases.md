# Mission 001 — Squelette du paquet R, CI et releases calendaires

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Créer le paquet R `typopeuplement` avec son environnement figé, sa CI (tests et couverture) et ses releases calendaires `vAAAA.MM.N` comme dans Marculus, pour que tout code futur soit testé avant d'être publié.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | oui | ADR 0011 et 0013 ; scripts de `pobsteta/marculus` (origin/main) nommés |
| A-t-il les moyens ? (outils, données d'essai, tests) | oui | R et lidaRtRee installés ; GitHub Actions ; le dépôt `pobsteta/typopeuplement` existe |

**Temps de la main :** **donner** — la stack est déjà tranchée (ADR 0011) ; l'agent travaille dans sa branche, le relecteur puis Pascal valident la PR.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `dev`
- **Modèle :** sonnet.
- **Ce qui ne lui est pas demandé :** aucune fonction métier (grille, clé, modèles) ; aucun choix de stack nouveau.

## Harnais

- **Peut (périmètre) :** `DESCRIPTION`, `NAMESPACE`, `R/typopeuplement-package.R`, `renv.lock`, `renv/`, `.Rprofile`, `.Rbuildignore`, `.gitignore`, `tests/testthat.R`, `tests/testthat/test-version.R`, `.github/workflows/`, `.github/scripts/`, `.github/badges/`, `Dockerfile` (image figée GDAL / PROJ), section « Déployer et publier » de `README.md`.
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** toucher `docs/`, `pilotage/` (hors sa ligne de journal) ; inventer une règle de version autre que l'ADR 0013 ; écrire un test qui ne vérifie rien.
- **Sources autorisées :** `docs/adr/0011-stack-logicielle.md`, `docs/adr/0013-versions-tags-releases.md`, `CLAUDE.md` ; dans `/home/pascal/dev/marculus` (lecture seule, `git show origin/main:…`) : `.github/workflows/ci.yml`, `.github/workflows/release.yml`, `.github/scripts/*.sh`, `README.md` (« Déployer et publier »). Fermées : tout autre dépôt.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

- **Valeur provisoire :** `Version: 2026.11.0` dans `DESCRIPTION` avant la première release (la CI la remplace par le tag).
- **Mesurée par :** la première release de la CI, à la fusion de la PR.
- **Gel :** aucun ; la valeur n'est jamais gravée à la main.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** aucune ; part de `main` après le commit des documents de cadrage.
- **Ordre de fusion :** 001 en premier ; toute mission de code part de `main` après sa fusion.
- **PR en brouillon jusqu'à :** —
- **CI rouge attendue :** aucune.

## Tests

- **Comment saura-t-on que c'est juste :** `.claude/test-command` (`Rscript -e 'testthat::test_local()'`) vert ; `test-version.R` vérifie que `Version` suit `AAAA.MM.N` et que la licence est GPL-3 ; `.github/scripts/test-version-calendaire.sh` et `test-release-necessaire.sh` adaptés et verts (cas de Marculus repris : changement de mois, `.9 → .10`, seuls `docs/`/`pilotage/`/`*.md`/badges/tests changés, commit dépassé) ; critère A22 de la spec.

## Terrain

- **Échantillon que Pascal vérifiera :** la page « Actions » du dépôt après fusion : CI verte, release `v2026.11.1` (ou suivante) publiée avec l'archive du paquet, badges du README allumés.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** à l'ouverture de la PR, puis après la première release.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

Le badge Version du README affiche `v2026.11.N` et la release contient `typopeuplement_2026.11.N.tar.gz` ; une PR qui ne touche que `docs/` ne crée pas de release.

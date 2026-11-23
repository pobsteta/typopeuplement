# ADR 0013 — Versions calendaires, tags et releases comme dans Marculus

- **Date :** 2026-11-23
- **Statut :** décision acceptée par Pascal le 2026-11-23 (« pour le dépôt utilise la
  montée de version tags, releases, versionning et notation comme dans marculus ») ;
  mise en œuvre à confier en mission
- **Proposée par :** Pascal
- **Tranchée par :** Pascal

## La décision en une phrase

TypoPeuplement reprend la convention de Marculus : versions calendaires `vAAAA.MM.N`,
tag annoté et release GitHub créés par la CI seulement après des tests verts sur `main`,
pas de release quand seuls `pilotage/`, `docs/`, `*.md`, les badges ou les tests
changent, titres de PR en commits conventionnels, badges dans le README.

## Contexte

Convention relue dans `pobsteta/marculus` (`origin/main`, 2026-11-23) :
- `.github/scripts/version-calendaire.sh` (mission 036 de Marculus, 2026-11-11) :
  `AAAA` et `MM` = année et mois UTC de la release, `N` = compteur du mois parmi les tags
  `vAAAA.MM.*`, qui repart à 1 chaque mois ; le type de commit ne change pas la version ;
- `.github/scripts/release-necessaire.sh` (ADR 0008 de Marculus) : release seulement si
  un fichier qui compte a changé depuis le dernier tag `v*`, et si le commit est
  toujours la tête de `main` ; dans le doute, on publie ; testé par
  `test-release-necessaire.sh` et `test-version-calendaire.sh` ;
- `release.yml` déclenché par `workflow_run` sur la CI verte de `main` ; notes de
  release générées automatiquement ;
- règle de Pascal (2026-10-24) : ne jamais relancer une CI de `main` déjà verte ni celle
  d'un ancien commit ; pour republier, faire une PR.

**Adaptations à TypoPeuplement** (paquet R, ADR 0011) :
- l'artefact de release est l'archive source du paquet (`R CMD build`) au lieu d'un APK ;
- le champ `Version` du fichier `DESCRIPTION` reçoit `AAAA.MM.N` au moment de la release
  (format accepté par R) ;
- fichiers qui ne comptent pas : `pilotage/**`, `docs/**`, `*.md`, `.github/badges/**`,
  `tests/**`, `.github/scripts/test-*.sh` ;
- couverture mesurée par `covr`, badge écrit par la CI dans `.github/badges/`.

Plus tard, les livraisons de cartes (ADR 0010) pourront porter le même millésime que la
version de la chaîne qui les a produites.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Reprendre deux scripts shell déjà testés | Adaptation au paquet R | Oui (Pascal) |
| **R**esponsable | Qui fait quoi ? | La CI tague et publie ; Pascal fusionne les PR | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | CI relancée sur un ancien commit : règle de Marculus reprise | — | Oui |
| **N**ovateur | Idées étranges ? | — (décision de Pascal) | — | — |
| **C**oût | Coût à l'ensemble ? | GitHub Actions, sans service externe | — | Oui |
| **É**cologique | Réutilisation ? | Même convention que les autres dépôts de Pascal | Duplication des scripts entre dépôts | Oui |

## Valeurs sacrifiées

- Le sens « compatibilité » d'un numéro SemVer : la version dit quand, pas ce qui a changé.

## Sources

- `pobsteta/marculus`, `origin/main` : `.github/workflows/release.yml`,
  `.github/scripts/version-calendaire.sh`, `.github/scripts/release-necessaire.sh`,
  `README.md` (« Déployer et publier »), `docs/adr/0008-release-conditionnelle.md`.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

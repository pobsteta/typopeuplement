# TypoPeuplement

[![CI](https://github.com/pobsteta/typopeuplement/actions/workflows/ci.yml/badge.svg)](https://github.com/pobsteta/typopeuplement/actions/workflows/ci.yml)
[![Release](https://github.com/pobsteta/typopeuplement/actions/workflows/release.yml/badge.svg)](https://github.com/pobsteta/typopeuplement/actions/workflows/release.yml)
[![Version](https://img.shields.io/github/v/release/pobsteta/typopeuplement?label=version)](https://github.com/pobsteta/typopeuplement/releases)
![Couverture](.github/badges/couverture.svg)
![R](https://img.shields.io/badge/R-paquet-276DC3?logo=r&logoColor=white)
![LiDAR HD](https://img.shields.io/badge/LiDAR%20HD-lidR%20%C2%B7%20lidaRtRee%20%C2%B7%20PDAL-2e7d32)
![Lambert-93](https://img.shields.io/badge/SCR-Lambert--93%20(EPSG%3A2154)-555)
[![Licence](https://img.shields.io/badge/licence-GPL--3.0-blue)](LICENSE)

Chaîne de traitement qui produit, pour les forêts de France hexagonale et de Corse, une
**carte du type de peuplement** (composition, structure, capital) au pas de 25 m, calibrée
par sylvoécorégion, à partir du LiDAR HD, de l'imagerie Sentinel et de la hauteur
potentielle tirée du milieu. Chaque pixel porte sa probabilité et son erreur de validation ;
le type est rendu dans le référentiel du gestionnaire (8 types SRGS, guides de sylviculture,
DRA/SRA ONF).

> **État au 2026-11-23** : cadrage. Brief et ADR rédigés, spec à valider ; pas encore de
> code. Les badges CI, Release, Version et Couverture s'allumeront avec la première mission
> d'intégration continue.

## Documents

| Quoi | Où |
|---|---|
| Ce qu'on construit, pour qui | [`docs/brief.md`](docs/brief.md), puis [`docs/spec.md`](docs/spec.md) |
| Brief de cadrage d'origine | [`docs/brief-typologie-peuplements.md`](docs/brief-typologie-peuplements.md) |
| Décisions d'architecture | [`docs/adr/`](docs/adr/) |
| Pilotage (équipe, kanban, journal, missions) | [`pilotage/`](pilotage/) |

## Tests

```bash
.claude/test-command      # Rscript -e 'testthat::test_local()'
```

## Versions et releases

Convention reprise de Marculus ([ADR 0013](docs/adr/0013-versions-tags-releases.md)) :

- **Jamais de push direct sur `main`** : tout passe par une pull request, dont le titre est
  un commit conventionnel (`feat: …`, `fix: …`, `docs: …`).
- Au merge, la CI lance les tests ; **seulement s'ils sont verts**, la release tague le
  commit testé avec une **version calendaire `vAAAA.MM.N`** (année et mois UTC, compteur du
  mois qui repart à 1) et publie l'archive du paquet sur GitHub Releases.
- **Pas de release** si seuls `pilotage/`, `docs/`, `*.md`, les badges ou les tests ont
  changé, ni si le commit a été dépassé sur `main` ; dans le doute, on publie.
- **Ne pas relancer une CI de `main` déjà verte, ni celle d'un ancien commit** : pour
  republier, faire une PR.

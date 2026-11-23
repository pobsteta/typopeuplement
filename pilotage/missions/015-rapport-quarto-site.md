# Mission 015 — Rapport Quarto et site, comme dans sylvostation

> Fiche écrite par Claude (orchestrateur) le 2026-11-23, **validée par délégation n° 3**
> (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Produire par le pipeline `targets` un rapport Quarto de l'AOI (cartes des types, couche de confiance, état de preuve, limites) et le publier en article d'un site pkgdown, sur le modèle de sylvostation, pour que chaque carte sorte avec sa lecture et ses limites (demande de Pascal, 2026-11-23).

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse |
|---|---|
| Redire en une phrase ? | oui |
| Sait-il comment faire ? | oui : `pobsteta/sylvostation` : `_targets.R`, `inst/rapport/rapport.qmd`, `rendre_rapport.R`, `_pkgdown.yml`, `vignettes/massif-test.Rmd`, mission 051 (rapport qui suit son modèle, titres lisibles) |
| A-t-il les moyens ? | oui : Quarto, targets, pkgdown ; livrables de Léoncel produits par la chaîne |

**Temps de la main :** **donner**. **Degré :** le chef tranche (délégation n° 3).

## Ma réponse d'abord

_Pascal s'en passe (« je m'en passe », 2026-11-23) ; rubrique laissée à sa main._

## L'Homme

- **Agent :** `dev` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** la clé, les modèles ; le contenu métier des limites (il reprend celles de la fiche de validation et du journal).

## Harnais

- **Peut (périmètre) :** `_targets.R`, `inst/rapport/`, `R/rapport.R`, `_pkgdown.yml`, `vignettes/`, `.github/workflows/pages.yml` (si besoin), `tests/testthat/test-rapport.R`, `man/`, `NAMESPACE`, `DESCRIPTION` (Suggests).
- **Câblé :** pas de commit sur `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** présenter la carte comme validée : l'état de preuve dit ce qui est mesuré, provisoire ou non vérifié ; publier des données personnelles.
- **Sources autorisées :** sylvostation (lecture seule) ; livrables de l'AOI ; `docs/spec.md` ; ADR de validation et de formats de la réconciliation.

## Journal

Une ligne par rendu et par aller-retour, proposée à l'orchestrateur (ajout seul).

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 014 (fusionnée) pour le badge « Site » et la publication.
- **CI rouge attendue :** aucune.

## Tests

- le rapport se reconstruit quand son modèle change (`tar_outdated`), comme la mission 051 de sylvostation ;
- le rapport de démonstration (jeu synthétique) se rend sans réseau en CI.

## Terrain

le rapport PDF ou HTML de l'AOI pilote, lu page à page.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis l'orchestrateur par délégation n° 3.
- **Critère d'arrêt :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Qui tranche :** l'orchestrateur (délégation n° 3) ; Pascal pour ce qui lui est réservé.

## Comment saura-t-on que ça marche ?

Le site affiche l'article « Résultats sur l'AOI pilote » avec ses cartes, son état de preuve et ses limites.

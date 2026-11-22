# Mission 001 — environnement R et commande de tests

## Mission

**En une phrase (quoi, et pourquoi) :** installer R et les dépendances du package (sf,
terra, ranger, e1071, MASS, testthat), et écrire `.claude/test-command` en testthat,
pour que chaque mission R ait des tests qui tournent.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse | Conséquence |
|---|---|---|
| Redire en une phrase ? | oui | |
| Sait-il comment faire ? | oui : apt (r-base-core 4.3.3 disponible), CRAN ; ADR 0004 | |
| A-t-il les moyens ? | oui : conteneur avec apt et accès aux registres de paquets | |

**Temps de la main :** donner (branche, PR relue).
**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul._

## L'Homme

- **Agent :** `dev` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** porter du code.

## Harnais

- **Peut (périmètre) :** `DESCRIPTION`, `NAMESPACE`, `.claude/test-command`,
  `tests/testthat.R`, `tests/testthat/test-environnement.R`, `.Rbuildignore`.
- **Câblé :** pas de `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** toucher `src/` (prototype Python) ni `R/` ; ajouter une dépendance hors ADR 0004.
- **Sources autorisées :** ADR 0004, `DESCRIPTION` de nemeton.

## Journal

Une ligne par rendu : paquets installés et leurs versions, commande de tests.

## Valeur provisoire

- **Valeur provisoire :** versions minimales des dépendances, prises sur celles de nemeton.
- **Mesurée par :** l'installation réussie dans ce conteneur, à la mission 001.
- **Gel :** avant la mission 003.

## Dépend de / rouge attendu jusqu'à

Aucune.

## Tests

`Rscript -e 'testthat::test_local()'` passe, avec un test qui charge les dépendances.
La commande Python reste lancée aussi, tant que le prototype existe.

## Terrain

Pascal lance la commande de tests sur son poste.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal · **Arrêt de la relecture :** 3 allers-retours.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

La commande de tests est verte sur ce conteneur et sur le poste de Pascal.

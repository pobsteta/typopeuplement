# Mission 004 — tests testthat des critères d'acceptation

## Mission

**En une phrase (quoi, et pourquoi) :** écrire en testthat les tests des critères
d'acceptation 1 à 6 de la spec, à partir des tests Python, pour que le portage (003) ait
un juge avant d'être écrit.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse | Conséquence |
|---|---|---|
| Redire en une phrase ? | oui | |
| Sait-il comment faire ? | oui : `tests/*.py`, spec, liste de contrôle du testeur | |
| A-t-il les moyens ? | après 001 (R installé) | dépend de 001 |

**Temps de la main :** donner. Il nomme les fonctions qu'il appelle ; leurs noms sont
fixés avec le plan de 003, validé par Pascal.
**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul._

## L'Homme

- **Agent :** `testeur` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** écrire le code de `R/`.

## Harnais

- **Peut (périmètre) :** `tests/testthat/` (sauf `test-environnement.R`, à 001, et `test-dev-*.R`, à 003), dont `tests/testthat/fixtures/` : le jeu synthétique Python exporté en CSV (graine fixée), pour comparer les deux versions.
- **Câblé :** pas de `main` ; journal en ajout seul.
- **Ne doit pas :** écrire dans `R/` ; affaiblir un critère de la spec.
- **Sources autorisées :** spec, tests Python, plan validé de 003.

## Journal

Une ligne par rendu : critères couverts, tests rouges attendus.

## Valeur provisoire

Aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 001, et le plan de 003 validé par Pascal.
- **Ordre de fusion :** 001 → 004 → 003.
- **CI rouge attendue :** tous les tests de 004 sont rouges jusqu'à la fusion de 003.

## Tests

Chaque critère d'acceptation 1 à 6 a au moins un test ; chaque test du prototype Python a
son équivalent ; un test vérifie les décomptes de `inst/extdata/ser/ser_codes.csv` (86 SER
principales, 5 d'alluvions, GRECO A à K plus L), remarque du relecteur de 002. Noms des
fonctions : [`003-plan.md`](003-plan.md).

## Terrain

Pascal lit la liste des tests en regard des critères de la spec.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal · **Arrêt de la relecture :** 3 allers-retours.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

Chaque critère d'acceptation 1 à 6 de la spec renvoie à un test nommé.

# Mission 004 — tests testthat des critères d'acceptation

## Mission

**En une phrase (quoi, et pourquoi) :** écrire en testthat les tests des critères
d'acceptation 1 à 6 de la spec, à partir des tests Python, pour que le portage (003) ait
un juge avant d'être écrit.

**Redite par l'agent :** écrire en testthat les tests des critères d'acceptation 1 à 6 (un test nommé par critère, un équivalent par test Python, le décompte de `ser_codes.csv`), à partir de la spec et des noms de fonctions du plan 003, sans lire `R/`, pour que le portage ait un juge avant d'être écrit.

_Aller-retour 1/3 : tolérances sur les effectifs dépendant des forêts aléatoires (R-PB-J, R-PB-C : ±4), précision à la grappe ±0,12 (commentaire accordé), redite complétée._

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

## Remarques du relecteur (aller-retour 1/3, 2026-11-22)

1. **Bloquant.** `test-ser.R`, test « critère 3 : la carte de confiance dit le niveau de
   modèle utilisé » : il exige exactement `R-PB-J = 16` et `R-PB-C = 0`. Or ce partage
   dépend de `rapport_h`, donc des forêts aléatoires, qui diffèrent entre ranger et
   scikit-learn. Retirer ces deux décomptes exacts, ou leur appliquer la même tolérance
   de ±4 que `test-chaine.R`. L'assertion `niveau_modele == "grande_region"` reste.
2. Mineur. `test-validation.R` : le commentaire annonce ±0,10 pour la précision à la
   grappe, mais le code prend ±0,12. Accorder le commentaire et le code, et dire la
   valeur retenue.
3. Mineur. Compléter la rubrique « Redite par l'agent » de cette fiche (sous-rubrique de
   la mission, en tête) : c'est ton seul droit d'écriture dans `pilotage/`.
4. Pour Pascal, rien à faire ici : `poids_transition(d, 0)` vaut 1 (rupture si la bande
   est nulle) ; `greco_de_ser("Z99")` → erreur, supposé.

## Remarque de la mission 003 (aller-retour 2/3, 2026-11-22)

`test-typer-peuplements.R:113` utilise `CODES_EXEMPLE`, défini seulement dans
`test-chaine.R` ; testthat isole chaque fichier. Déplacer `CODES_EXEMPLE` dans
`helper-donnees.R`.

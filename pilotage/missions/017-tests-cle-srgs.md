# Mission 017 — Tests d'acceptation de la clé SRGS

> Fiche écrite par Claude (orchestrateur) le 2026-11-23, **validée par délégation n° 3**
> (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire, sans lire le code, les tests qui vérifient que la clé SRGS de la mission 016 range sans recouvrement chaque combinaison de variables dans un et un seul des 8 types, et que les seuils viennent de la clé, pour que la mission 018 ne s'auto-évalue pas.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse |
|---|---|
| Redire en une phrase ? | oui |
| Sait-il comment faire ? | oui : modèle de `tests/testthat/test-cle-h10.R` |
| A-t-il les moyens ? | oui, après 016 |

**Temps de la main :** **donner**. **Degré :** le chef tranche (délégation n° 3).

## Ma réponse d'abord

_Pascal s'en passe (« je m'en passe », 2026-11-23) ; rubrique laissée à sa main._

## L'Homme

- **Agent :** `testeur` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** le code de 018.

## Harnais

- **Peut (périmètre) :** `tests/testthat/test-cle-srgs.R`.
- **Câblé :** pas de commit sur `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** lire la branche de 018 ; affaiblir un test.
- **Sources autorisées :** clé et fiche de 016 ; `test-cle-h10.R`.

## Journal

Une ligne par rendu et par aller-retour, proposée à l'orchestrateur (ajout seul).

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 016.
- **Ordre :** 017 et 018 groupées.
- **CI rouge attendue :** rouge justifiée jusqu'à la fusion groupée avec 018.

## Tests

exclusivité en clé dure sur une grille qui encadre les seuils ; 8 types atteints ; échec prouvé sur une clé cassée.

## Terrain

—

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis l'orchestrateur par délégation n° 3.
- **Critère d'arrêt :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Qui tranche :** l'orchestrateur (délégation n° 3) ; Pascal pour ce qui lui est réservé.

## Comment saura-t-on que ça marche ?

Les tests échouent sur une clé où deux types se recouvrent.

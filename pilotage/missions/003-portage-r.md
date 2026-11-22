# Mission 003 — porter le prototype en package R

## Mission

**En une phrase (quoi, et pourquoi) :** porter le prototype Python (clé floue, variables
dendrométriques, hauteur potentielle, lissage, SER, validation, jeu synthétique) en package
R aux conventions de nemeton, pour que la référence exécutable de la chaîne vive dans
l'écosystème retenu.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse | Conséquence |
|---|---|---|
| Redire en une phrase ? | oui | |
| Sait-il comment faire ? | oui : prototype `src/typopeuplement/`, ADR 0004, `CLAUDE.md` de nemeton (convention NMT) | |
| A-t-il les moyens ? | après les missions 001 (R) et 004 (tests) | dépend d'elles |

**Temps de la main :** **prendre**, car elle engage la durée (structure du package, API
publique, noms). L'agent rend d'abord un plan : fichiers, fonctions exportées et leurs
noms, correspondance avec le prototype. Pascal le valide avant toute écriture.
**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul._

## L'Homme

- **Agent :** `dev` · **Modèle :** opus (architecture)
- **Ce qui ne lui est pas demandé :** lire de vraies données ; retirer le prototype Python.

## Harnais

- **Peut (périmètre) :** `R/`, `man/`, `NAMESPACE`, `DESCRIPTION` (après la fusion de 001).
- **Câblé :** pas de `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** écrire dans `tests/testthat/` (périmètre du testeur) ; inventer une
  clé de types (celle de `config/exemple.json` reste un exemple) ; dépendre d'un
  paquet hors ADR 0004.
- **Sources autorisées :** prototype, spec, ADR 0003 et 0004, nemeton.

## Journal

Une ligne pour le plan, une par rendu.

## Valeur provisoire

- **Valeur provisoire :** souplesses, marge « entre deux types », quantile d'enveloppe
  0,9, seuil d'incertitude 0,2 et fenêtre de lissage 3, repris du prototype.
- **Mesurée par :** les SER pilotes, pas encore choisies.
- **Gel :** pas avant la fiche de validation d'une SER pilote.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 001 (environnement R) et 004 (tests).
- **Ordre de fusion :** 001 → 004 → 003.
- **CI rouge attendue :** les tests de 004 sont rouges tant que 003 n'est pas fusionnée.

## Tests

Les tests testthat de 004 sont verts : critères d'acceptation 1 à 6 de la spec, et
mêmes résultats que le prototype sur le jeu synthétique, aux écarts aléatoires près.

## Terrain

Pascal lance la démo R et lit la fiche de validation.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal · **Arrêt de la relecture :** 3 allers-retours.
- **Qui tranche :** Pascal. La mission touche nemeton : Pascal en pose le fait avant de trancher.

## Comment saura-t-on que ça marche ?

`typer_peuplements()` tourne sur le jeu synthétique, et la fiche de validation sort.

# Mission 005 — typologie locale de la SER pilote H10

## Mission

**En une phrase (quoi, et pourquoi) :** rassembler, sourcée, la typologie de peuplements
en usage dans la SER H10 et le Vercors drômois (types, seuils, noms, limite des
catégories de diamètre), et en tirer une configuration de clé pour la SER, pour que la
première carte réelle (cycle 2) parle la langue des gestionnaires et non une clé inventée.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse | Conséquence |
|---|---|---|
| Redire en une phrase ? | oui | |
| Sait-il comment faire ? | oui : couche `Typo_etage` et fiche du jeu Vercors drômois (CRAIG), guide de sylviculture des Alpes du Nord, typologie du SRGS Auvergne-Rhône-Alpes, `docs/referentiels/ser.md` | |
| A-t-il les moyens ? | oui : accès web, liste de contrôle | |

**Temps de la main :** donner. **Degré de la main :** le chef tranche (justesse des données).

## Ma réponse d'abord

_Rempli par Pascal seul._

## L'Homme

- **Agent :** `acquereur` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** écrire du code R.

## Harnais

- **Peut (périmètre) :** `docs/referentiels/typologie-h10.md`, `inst/extdata/config/vercors-h10.json`.
- **Câblé :** pas de `main` ; journal en ajout seul.
- **Ne doit pas :** inventer un type, un seuil ou un nom ; trancher entre deux sources qui
  se contredisent (la limite des gros bois à 42,5 ou 47,5 cm : poser la question à Pascal,
  avec les sources).
- **Sources autorisées :** celles ci-dessus ; une seule source par référence.

## Journal

Une ligne par rendu : sources, types retenus, questions à Pascal.

## Valeur provisoire

- **Valeur provisoire :** les souplesses et la marge « entre deux types » restent celles de
  l'exemple, marquées provisoires.
- **Mesurée par :** la validation sur l'AOI pilote (mission 006 puis fiche de validation).
- **Gel :** pas avant la fiche de validation de H10.

## Dépend de / rouge attendu jusqu'à

Aucune. La configuration suit le format de `inst/extdata/config/exemple.json`
(`lire_configuration()`).

## Tests

La configuration se charge par `lire_configuration()`, et chaque type a sa source.

## Terrain

Pascal reconnaît les types sur une forêt du Vercors qu'il connaît.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal · **Arrêt de la relecture :** 3 allers-retours.
- **Qui tranche :** Pascal. La typologie touchera les gestionnaires : Pascal leur pose le fait avant de trancher.

## Comment saura-t-on que ça marche ?

Un gestionnaire du Vercors lit les noms des types sans traduction.

# Mission 002 — référentiel des SER

## Mission

**En une phrase (quoi, et pourquoi) :** rassembler le découpage officiel des SER et des
grandes régions écologiques (codes, noms, géométries, source datée), pour que la chaîne
déduise la SER d'une AOI sans inventer de code.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse | Conséquence |
|---|---|---|
| Redire en une phrase ? | oui | |
| Sait-il comment faire ? | oui : GeoData INRAE (lien du brief) ; vérifier si nemeton l'embarque déjà | |
| A-t-il les moyens ? | oui : accès web ; liste de contrôle de l'acquéreur | |

**Temps de la main :** donner. **Degré de la main :** le chef tranche (justesse des données).

## Ma réponse d'abord

_Rempli par Pascal seul._

## L'Homme

- **Agent :** `acquereur` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** écrire du code de la chaîne.

## Harnais

- **Peut (périmètre) :** `inst/extdata/ser/`, `docs/referentiels/ser.md`.
- **Câblé :** pas de `main` ; journal en ajout seul.
- **Ne doit pas :** copier ce que nemeton fournit déjà (un lien plutôt qu'une copie) ; inventer un code.
- **Sources autorisées :** GeoData INRAE, nemeton ; une seule source pour une référence.

## Journal

Une ligne par rendu : source, date de la version, effectifs (SER, alluvions, grandes régions).

## Valeur provisoire

Aucune.

## Dépend de / rouge attendu jusqu'à

Aucune.

## Tests

Le décompte correspond au brief (86 SER, 5 d'alluvions, 11 grandes régions plus la Corse),
ou l'écart est inscrit au carnet des écarts.

## Terrain

Pascal vérifie la SER d'une forêt qu'il connaît.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal · **Arrêt de la relecture :** 3 allers-retours.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

La SER d'une forêt connue de Pascal tombe juste.

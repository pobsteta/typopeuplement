# Mission 006 — lire les données du Vercors drômois dans la chaîne

## Mission

**En une phrase (quoi, et pourquoi) :** faire lire à `typer_peuplements()` les couches du
jeu ouvert « Paramètres forestiers LiDAR – Vercors drômois 2021-2022 » sur une AOI, pour
produire la première carte réelle des types avec sa couche de confiance.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse | Conséquence |
|---|---|---|
| Redire en une phrase ? | oui | |
| Sait-il comment faire ? | **non, pas encore** : on ne connaît pas toutes les couches du jeu, ni s'il contient des placettes. Sans placettes, la chaîne actuelle ne peut pas calibrer ses modèles | **donner la main** : l'agent rend d'abord un plan (inventaire des couches, façon de les brancher), relu par Pascal avant exécution |
| A-t-il les moyens ? | oui : serveur CRAIG (WebDAV), R avec terra et sf | |

**Temps de la main :** donner, avec un plan d'abord. **Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul._

## L'Homme

- **Agent :** `dev` · **Modèle :** opus (choix de branchement)
- **Ce qui ne lui est pas demandé :** la typologie de H10 (mission 005) ; les modèles de grande région.

## Harnais

- **Peut (périmètre), après validation du plan :** `R/`, `man/`, `NAMESPACE`, `DESCRIPTION`,
  `tests/testthat/test-dev-*.R`, `tests/testthat/fixtures/vercors/`. Plan validé : [`006-plan.md`](006-plan.md). Les données téléchargées restent hors du dépôt, sauf un
  extrait de test de moins de 2 Mo.
- **Câblé :** pas de `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** écrire dans `inst/extdata/config/` (mission 005) ; inventer une clé.
- **Sources autorisées :** `docs/referentiels/ser.md`, serveur CRAIG, spec, ADR 0003 et 0004.

## Journal

Une ligne pour le plan, une par rendu.

## Valeur provisoire

Les mêmes que la mission 003. Ce que mesure 006 : le temps de chaque étage sur l'AOI
(critère 10, ADR 0003).

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 003 (prête). Pour la carte finale, de 005 (configuration de H10) ;
  en attendant, la clé d'exemple.
- **Ordre de fusion :** 005, puis 006.

## Mineurs reportés de la relecture de 003

1. Régénérer `man/` en locale UTF-8 (« Obst<U+00E9>tar »).
2. Documenter (ou avertir) que sans `x`/`y` les centres de pixel sont à i×25, j×25.
3. Version minimale de ranger dans `DESCRIPTION` (`min.bucket`), et
   `Remotes` / `Additional_repositories` pour nemeton.
4. `confiance.tif` : « grande région requise » plutôt que « utilisée » tant que la
   bascule est en stub (proposé à Pascal).

## Tests

Un extrait de l'AOI passe dans `typer_peuplements()` ; types, probabilités et confiance
sortent en GeoTIFF Lambert-93 qui se superposent au jeu dans QGIS ; temps par étage
consigné.

## Terrain

Pascal ouvre la carte sur une forêt qu'il connaît, et la compare à la couche
`Typo_etage` du jeu.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal · **Arrêt de la relecture :** 3 allers-retours.
- **Qui tranche :** Pascal.

## Comment saura-t-on que ça marche ?

La carte se superpose au jeu, et ses types se lisent sur le terrain.

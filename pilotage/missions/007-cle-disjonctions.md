# Mission 007 — clé à disjonctions

## Mission

**En une phrase (quoi, et pourquoi) :** permettre qu'un type de la clé soit défini par
plusieurs jeux de conditions reliés par « ou », en clé floue (appartenance = maximum des
jeux), pour pouvoir écrire la clé du GSM Alpes du Nord (cap A).

## Les trois questions

oui · oui (`R/cle.R`, `R/configuration.R`, GSM p. 54-55) · oui (tests existants de la clé).
**Temps de la main :** donner. **Degré :** le chef tranche.

## L'Homme

`dev` · sonnet.

## Harnais

- **Peut :** `R/cle.R`, `R/configuration.R`, `man/`, `NAMESPACE`,
  `tests/testthat/test-dev-cle-ou.R`.
- **Ne doit pas :** casser le format actuel : une clé sans « ou » se lit comme avant ;
  toucher `inst/extdata/config/`.
- **Câblé :** pas de `main`, tests verts, journal en ajout seul.

## Ajout du 2026-11-22 (Pascal, « oui à tes propositions »)

`poids_transition()` refuse une demi-largeur nulle ou négative, par une erreur claire :
une largeur nulle ferait une rupture à la limite des SER (critère 4). Pour cela, le
périmètre s'étend à `R/ser.R` et à la seule assertion de `tests/testthat/test-ser.R` qui
attend un poids de 1 pour une bande nulle. Elle devient un test d'erreur.

## Ajouts du 2026-11-22 (relecture de 006, Pascal)

1. **Variable absente** : quand les types les plus probables ne se départagent que par
   une variable manquante, la carte affiche le groupe des types possibles (par exemple
   « R-PB-J | R-PB-C | R-IRR ») avec le drapeau, au lieu du premier de la clé.
   `correspondance_types.csv` liste les groupes.
2. **Souplesses d'un jeu de données dans la configuration** : la configuration accepte
   un bloc `jeux` (par exemple `jeux.vercors_onf.souplesse`) qui remplace les souplesses
   de la clé pour les variables de ce jeu. `couches_onf()` ne porte plus de valeurs en
   dur. Les valeurs viennent de la mission 010 : EQM de la fiche ONF, p. 1.
3. **Mineurs de la relecture de 006** :
   - commentaire de `decider_type` (« sans NA ») et test des NA et des égalités ;
   - table des codes de `niveau_modele` (0, 1, 2) livrée avec `confiance.tif` ;
   - source de `ranger (>= 0.15.0)` citée dans DESCRIPTION ou dans la doc ;
   - la souplesse d'une variable que la clé n'utilise pas n'est pas déclarée dans la fiche.

Périmètre étendu : `R/donnees_lidar.R`, `R/typer_peuplements.R`, `R/validation.R`,
`DESCRIPTION`, `tests/testthat/test-dev-*.R`.

## Valeur provisoire

La combinaison des « ou » par le maximum est un choix. Le minimum reste pour les « et »,
mais l'actuel produit de sigmoïdes est gardé. À juger sur la carte de H10.

## Dépend de / rouge attendu jusqu'à

Dépend de 006 : périmètre commun dans `man/` et `NAMESPACE`. Ordre : 006 → 007.

## Tests

- Une clé sans « ou » donne des probabilités identiques à l'actuelle.
- Un type « A ou B » a pour appartenance le maximum des deux.
- Avec une souplesse nulle, on retrouve la clé dure.

## Terrain

Aucun (outil).

## Qui tranche

`relecteur`, puis Pascal. 3 allers-retours au plus.

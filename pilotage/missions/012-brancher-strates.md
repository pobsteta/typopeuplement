# Mission 012 — brancher le couvert des strates et la hauteur potentielle dans la chaîne

## Mission

**En une phrase (quoi, et pourquoi) :** faire passer à la clé, dans `typer_peuplements()`,
le couvert des strates (`c1_hpot` à `c4_hpot`, référence `hpot` par défaut), `h_pot`,
`couvert` et la densité `N` du jeu ONF, pour produire la première carte de H10 au GSM sur
la forêt de Léoncel.

## Les trois questions

- oui ;
- oui : `R/strates.R`, `R/chaine.R`, `R/donnees_lidar.R`, `inst/extdata/config/vercors-h10.json`
  (clé de 010), couverts de Léoncel dans `scratchpad/m008/leoncel/` ;
- oui : lasR dans `scratchpad/m008/rlib`.

**Temps de la main :** donner. **Degré de la main :** le chef tranche.

## L'Homme

`dev` · opus.

## Harnais

- **Peut :** `R/chaine.R`, `R/typer_peuplements.R`, `R/donnees_lidar.R`, `R/strates.R`, `man/`,
  `NAMESPACE`, `DESCRIPTION`, `tests/testthat/test-dev-*.R`, `tests/testthat/fixtures/vercors/`.
- **Ne doit pas :** modifier la clé de `vercors-h10.json` (missions 010 et suivantes) ; publier
  une carte hors du dossier de travail ; calculer le massif (décision de Pascal).
- **Câblé :** pas de `main`, tests verts, journal en ajout seul.

## Contenu

1. Argument `strates` de `typer_peuplements()` : couverts précalculés (table ou `.rds` de
   `couvert_strates`), ou calcul depuis des dalles, avec la référence choisie (`hpot` par
   défaut, provisoire).
2. `variables_cle` passe à la clé toute variable qu'elle cite et que la chaîne porte : `h_pot`,
   `couvert`, `c*_hpot`, `N`. Une variable absente reste neutralisée (groupe de types et drapeau).
3. Lire `N` dans `couches_onf()` (raster de densité de l'ONF, tiges/ha).
4. Mineurs de 008 :
   - le plancher de 1 m respecté quand la hauteur de référence est sous 4 m ;
   - les dalles choisies sur le contour de l'AOI, pas sur son rectangle ;
   - le contrôle contre `Tx_couv` fait avec `c1` et non avec la somme des strates.
5. Carte de Léoncel avec la clé de `vercors-h10.json` : types, probabilité, confiance, fiche,
   dans `scratchpad/m012/leoncel/`. Elle vient avec la répartition des types et la part
   « entre deux », et elle **nomme 3 pixels à voir sur le terrain** (coordonnées Lambert-93
   et WGS84) : un peuplement mûr, une jeune futaie, un peuplement à deux étages.

## Valeur provisoire

La référence des strates (`hpot`), l'arrondi des couverts (0,25 / 0,45) et les seuils
d'incertitude sont tous provisoires.

## Tests

- La chaîne tourne avec la clé du GSM sur l'extrait du Vercors (`strates` fournies).
- `N` est lu dans la bonne unité.
- Le plancher est vérifié pour une hauteur de référence sous 4 m.
- Un point du terrain tombe dans le bon pixel.

## Terrain

Pascal va voir les 3 pixels nommés à Léoncel.

## Qui tranche

`relecteur`, puis Pascal. 3 allers-retours au plus.

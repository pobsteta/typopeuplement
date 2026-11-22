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

## Aller-retour 1/3 (2026-11-22)

1. **Bloquant : les pixels hors clé** (couvert < 0,1, soit 247 pixels à Léoncel) ne
   reçoivent plus de type.
   - Après `decider_type`, `type`, `proba`, `type_second` et `entre_deux` sont vides ; le
     drapeau `hors_cle` est gardé.
   - Dans `lisser_probabilites`, ces pixels ont un poids nul : leurs probabilités ne
     diluent pas celles des voisins et ne leur en empruntent pas.
   - Un test le vérifie. La fiche donne la part de pixels hors clé et la répartition des types.
2. Refaire la carte de Léoncel : répartition, part « entre deux », trois pixels de terrain
   (coordonnées vérifiées dans les deux sens). Le pixel 3 est en y 6 426 005,9.
3. Mineur : arrondir la résolution du MNT dans `R/milieu.R`, pour que `terra::focalMat` ne
   juge plus les pixels « non carrés ». Le périmètre s'étend à `R/milieu.R` pour ce seul point.
4. Mineur : le nombre de tests sautés rapporté exactement.

Note (2026-11-22) : le périmètre s'est étendu à `R/lissage.R` pour le poids nul demandé à l'aller-retour 1/3.

# Écrire les livrables d'une emprise

Écrit dans `dossier` :

- `types.tif` : `type` (valeur entière, voir la table de correspondance
  : un groupe de types, quand une variable manque, a sa propre valeur),
  `proba`, `type_second`, `entre_deux` (0 ou 1) ;

- `variables.tif` : `G`, `part_resineux`, `part_pb`, `part_bm`,
  `part_gb`, `N` (si lue), `h_dom`, `h_pot`, `hpot` (h_pot sans
  l'enveloppe, mode « variables fournies »), `h_pot_sd`, `rapport_h`,
  les couverts des strates `c1_<ref>` à `c4_<ref>` s'ils ont été
  fournis, et `densite_houppiers` (tiges/ha) si les houppiers ont servi
  ;

- `confiance.tif` : `hp_incertaine`, `hors_cle` (0 ou 1),
  `niveau_modele` (0 : variables du producteur, 1 : SER, 2 : grande
  région *requise* — la bascule vers le modèle de grande région n'est
  pas encore écrite, c'est le modèle de la SER qui a servi) ; en mode «
  variables fournies », aussi `non_precomptable`, `part_pb_absente` et
  `gb_interim` (0 ou 1), et `part_retours_sous_s1` (de 0 à 1 : part des
  retours du pixel qui passent sous la strate 1 et servent aux strates 2
  à 4, estimées ; vide sans comptes de retours) quand le couvert des
  strates a été calculé par la chaîne ;

- `fiche_validation.md` ; `carte_types.csv` (la carte, une ligne par
  pixel) ;

- `correspondance_types.csv` (`valeur`, `code`, `libelle`), groupes de
  types compris ;

- `correspondance_niveau_modele.csv` (`valeur`, `niveau`, `sens`) : les
  codes de `niveau_modele` de `confiance.tif` ;

- `temps_etages.csv` (`etage`, `secondes`, `pixels`), si la chaîne a
  chronométré ses étages
  ([`executer_chaine_fournie()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine_fournie.md))
  ; les étages `ecriture_rasters` (les trois GeoTIFF) et
  `ecriture_tables` (fiche et CSV) y sont ajoutés.

## Usage

``` r
ecrire_livrables(resultat, dossier, taille_pixel = 25, crs = "EPSG:2154")
```

## Arguments

- resultat:

  Objet `typo_resultat`
  ([`typer_peuplements()`](https://pobsteta.github.io/typopeuplement/reference/typer_peuplements.md),
  [`executer_chaine()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine.md)).

- dossier:

  Dossier de sortie (créé au besoin).

- taille_pixel:

  Côté des pixels, en m. **Provisoire** : 25.

- crs:

  Système de coordonnées. Lambert-93 (`"EPSG:2154"`) par défaut.

## Value

Le chemin du dossier, invisible.

## Details

Grille : si le résultat porte un `gabarit` (grille du jeu d'entrée, par
exemple
[`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md)),
les rasters reprennent exactement cette grille et se superposent au jeu.
Sinon la grille part des centres `x`, `y` de la carte ; **sans `x`, `y`,
les centres sont pris à `i × taille_pixel`, `j × taille_pixel`**
(convention du jeu synthétique), ce qui ne place pas les pixels sur le
terrain.

Les rasters sont des GeoTIFF : ils s'ouvrent dans QGIS et dans R (terra)
sans conversion. Les zones sans donnée (ZICAD, hors LiDAR) ne sont pas
encore portées par `confiance.tif` : la lecture des données ouvertes
n'est pas écrite.

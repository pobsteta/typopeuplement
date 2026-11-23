# Couches du jeu ONF « Paramètres forestiers LiDAR » et leur branchement

Table de branchement des rasters du producteur sur les variables de la
chaîne (fiche synthétique du jeu Vercors drômois, A. Hedel, ONF,
25/09/2024, p. 4) :

## Usage

``` r
couches_onf()
```

## Value

data.frame : `fichier`, `variable`, `facteur` (multiplicateur),
`obligatoire`, `seuil_cm` (seuil de diamètre du producteur, `NA` sinon),
`jeu` (nom du jeu dans le bloc `jeux` de la configuration :
`"vercors_onf"`), `source`.

## Details

|  |  |  |
|----|----|----|
| fichier | variable | conversion |
| `G.tif` | `G` (m²/ha) | aucune |
| `p100GR.tif` | `part_resineux` (0 à 1) | ÷ 100 |
| `p100GGB.tif` | `part_gb` (0 à 1) | ÷ 100 |
| `H0_lidar.tif` | `h_dom` (m) | aucune ; hauteur brute, **non calibrée** (p. 2) |
| `Tx_couv.tif` | `couvert` (0 à 1) | ÷ 100 |
| `Compo1.tif` | `famille` (0 non précomptable, 1 feuillus, 2 résineux, 3 mélange) | aucune |
| `Typo_etage.tif` | `typo_etage` (0 non précomptable, 1 non étagé, 2 faiblement étagé, 3 étagé) | aucune ; contrôle de cohérence seulement |
| `N.tif` | `N` (tiges/ha) | aucune ; facultative |

`N` est la densité prédite par l'ONF, en tiges par hectare (fiche p. 1 :
placettes de calibration, N de 14,2 à 947,9, moyenne 374,4 ; p. 2 :
biais en « t/ha »). Les placettes ont un diamètre précomptable de 17,5
cm (p. 1) : `N` compte donc, selon toute vraisemblance (la fiche ne le
dit pas en toutes lettres), les tiges précomptables (colonne
`seuil_cm`). Le seuil de 800 tiges/ha du GSM (types L et R) vise une
régénération, qui n'y serait pas. Couche facultative : sans `N.tif`, la
colonne manque et une clé qui la cite la neutralise.

`Struc_fam` n'est pas utilisée (décision de Pascal, plan 006). `part_pb`
n'existe pas dans le jeu : elle reste vide et le drapeau
`part_pb_absente` est levé.

**Gros bois : intérim déclaré.** La part de gros bois du producteur est
calculée à 47,5 cm (fiche, p. 1 : « GB : 47.5 ≤ Ø \< 62.5 cm ») alors
que la limite retenue pour H10 est 42,5 cm (Pascal, 2026-11-22). La
colonne `seuil_cm` porte 47,5 pour `part_gb` ; la chaîne lève le drapeau
`gb_interim` quand ce seuil diffère de celui de la configuration.

**Souplesses : dans la configuration, pas ici.** Les souplesses du jeu
(erreurs du producteur, fiche p. 3) ne sont plus portées par cette table
: elles se déclarent dans le bloc `jeux.vercors_onf.souplesse` de la
configuration
([`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md)),
que la chaîne applique quand les variables viennent de ce jeu (colonne
`jeu`). Elles ne sont pas des paramètres de la SER : elles disent
l'erreur de ce jeu. Les valeurs (EQM de la fiche ONF, p. 1) viennent de
la mission 010.

## See also

[`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md)

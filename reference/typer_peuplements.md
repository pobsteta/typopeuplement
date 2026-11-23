# Typer les peuplements d'une emprise

Point d'entrée de la chaîne : produit la carte du type de peuplement
d'une emprise (AOI), sa couche de confiance et la fiche de validation de
la SER.

## Usage

``` r
typer_peuplements(
  aoi,
  placettes = NULL,
  ser = NULL,
  configuration,
  sortie = NULL,
  graine = 0,
  variables = NULL,
  milieu = NULL,
  strates = NULL,
  reference_strates = "hpot",
  modele_hp = NULL,
  methode_strates = "hybride"
)
```

## Arguments

- aoi:

  Emprise : data.frame de pixels préparés, objet `sf` ou chemin de
  GeoPackage (Lambert-93).

- placettes:

  data.frame des placettes de calibration (voir
  [`executer_chaine()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine.md)).

- ser:

  Nom de la SER dans la configuration.

- configuration:

  Chemin du fichier JSON de configuration
  ([`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md)).

- sortie:

  Dossier où écrire les livrables
  ([`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md))
  ; `NULL` : rien n'est écrit.

- graine:

  Graine du hasard ; remplace celle de la configuration.

- variables:

  data.frame de pixels aux variables fournies
  ([`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md))
  ; `NULL` : mode « pixels préparés ».

- milieu:

  En mode « variables fournies », data.frame des variables de milieu
  (une ligne par ligne de `variables`) pour la hauteur potentielle, par
  exemple le relief tiré du MNT de l'IGN
  ([`milieu_pixels()`](https://pobsteta.github.io/typopeuplement/reference/milieu_pixels.md))
  ; ses attributs `variables_milieu` et `source` disent ce que voit la
  hauteur potentielle (sinon les `variables_milieu` de la configuration)
  ; `NULL` : hauteur potentielle vide et signalée partout.

- strates:

  En mode « variables fournies », couvert des strates du GSM pour la clé
  (colonnes `c1_<ref>` à `c4_<ref>`, `<ref>` étant `reference_strates`),
  calculé selon `methode_strates` :

  - `NULL` : pas de couvert ; une clé qui cite les strates les
    neutralise (groupe de types, drapeau `entre_deux`) et la fiche le
    dit ;

  - `list(tranches = ..., houppiers = ...)` : les deux sources du mode
    hybride ; `tranches` prend les formes ci-dessous (comptes, `.rds`,
    dalles) ; `houppiers` est une table de
    [`couvert_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/couvert_houppiers.md)
    (ou son `.rds`), une segmentation de
    [`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md)
    (le couvert est alors calculé avec la référence de la chaîne), ou
    des dalles ;

  - une table de
    [`couvert_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/couvert_houppiers.md)
    ou une segmentation seule : source houppiers ;

  - un data.frame de
    [`couvert_depuis_comptes()`](https://pobsteta.github.io/typopeuplement/reference/couvert_depuis_comptes.md)
    (ou de
    [`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)
    avec `x`, `y`), ou les chemins de fichiers `.rds` qui en contiennent
    (par exemple les comptes de
    [`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md),
    une dalle par fichier : ils sont additionnés) ; les lignes sont
    rattachées aux pixels par leurs coordonnées `x`, `y` (Lambert-93) ;
    ces couverts doivent avoir été calculés avec la même hauteur de
    référence que la chaîne (même milieu, même modèle de hauteur
    potentielle) ;

  - les chemins de dalles de nuage de points (`.las`, `.laz`,
    `.copc.laz`) : le couvert est calculé ici, avec la référence tirée
    de la chaîne (lasR requis ; choisir les dalles avec
    [`dalles_sur_aoi()`](https://pobsteta.github.io/typopeuplement/reference/dalles_sur_aoi.md))
    : tranches une dalle à la fois, houppiers en un seul `exec` avec
    tampon
    ([`segmenter_houppiers()`](https://pobsteta.github.io/typopeuplement/reference/segmenter_houppiers.md),
    paramètres par défaut) ; en hybride, la segmentation sert à retirer
    des tranches les retours des houppiers de la strate 1 ;

  - un data.frame de couverts déjà calculés (`c1_<ref>` à `c4_<ref>`,
    sans comptes ni `n_houppiers`) : pris tels quels, quelle que soit
    `methode_strates` (la fiche le dit).

- reference_strates:

  Hauteur de référence des strates : `"hpot"` (hauteur potentielle sans
  enveloppe, h_pot / k ; **par défaut, provisoire**, décision du
  2026-11-22), `"hpot_k"` (h_pot) ou `"h0"` (h_dom). Voir
  [`references_strates()`](https://pobsteta.github.io/typopeuplement/reference/references_strates.md).

- modele_hp:

  En mode « variables fournies », modèle de hauteur potentielle déjà
  appris
  ([`apprendre_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/apprendre_hauteur_potentielle.md)),
  par exemple sur tout le massif, appliqué aux pixels de l'emprise ;
  `NULL` : appris sur les pixels de l'emprise. Demande `milieu`.

- methode_strates:

  Méthode du couvert des strates (mission 013, plan validé par Pascal le
  2026-11-23) : `"hybride"` (**par défaut**) : strate 1 par les
  houppiers, strates 2 à 4 par les tranches de hauteur corrigées de
  l'occlusion, sans les retours qui tombent dans les houppiers de la
  strate 1 (décision du 2026-11-23 ; il faut une segmentation unique et
  des tranches calculées depuis les dalles, ou des comptes de
  [`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md)
  avec `houppiers`), déclarées estimées (`part_retours_sous_s1`) ;
  `"houppiers"` : les quatre strates par les houppiers vus du dessus ;
  `"tranches"` : les quatre par les tranches (mission 008). Les colonnes
  `c1_<ref>` à `c4_<ref>` gardent leurs noms. Une source manquante pour
  la méthode arrête la chaîne.

## Value

Objet `typo_resultat` (voir
[`executer_chaine()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine.md)),
invisible si `sortie` est donné.

## Details

Deux modes tournent aujourd'hui :

- **pixels préparés** : `aoi` est un data.frame de pixels (les colonnes
  décrites dans
  [`executer_chaine()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine.md)),
  avec `placettes` et `ser` donnés ; les variables sont prédites par des
  modèles calibrés sur les placettes, et validées sur elles ;

- **variables fournies** (mission 006) : `variables` est un data.frame
  de pixels dont les variables viennent d'un producteur, par exemple les
  paramètres forestiers LiDAR de l'ONF lus par
  [`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md).
  Pas d'ajustement dendrométrique, pas de placettes, donc pas de
  validation (voir
  [`executer_chaine_fournie()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine_fournie.md)).
  `aoi` peut alors être `NULL` (toutes les lignes de `variables`) ou un
  objet `sf` (seuls les pixels dont le centre `x`, `y` tombe dedans sont
  gardés).

Pixels préparés sans colonnes `x`, `y` : les centres des pixels sont
pris à `x = i × taille_pixel`, `y = j × taille_pixel` (convention du jeu
synthétique, voir
[`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md)).
Pour de vraies données, donner `x`, `y` en Lambert-93.

Ce qui reste en attente (arrêt net, message dit) :

- `aoi` en `sf` ou chemin de GeoPackage : la SER est localisée par
  [`nemeton::localiser_ser()`](https://pobsteta.github.io/nemeton/reference/localiser_ser.html)
  (nemeton en Suggests), puis arrêt : la lecture des données ouvertes
  (LiDAR HD, Sentinel-2, BD Forêt v3, climat, sol) n'est pas écrite ;

- `placettes = NULL` : arrêt, les modèles de grande région ne sont pas
  disponibles ;

- `ser = NULL` avec un data.frame : arrêt, la SER ne se devine pas.

La typologie est descriptive : la carte aide à décider, elle ne remplace
pas le diagnostic de terrain. Vérifier en priorité les pixels « entre
deux types ».

## Variables passées à la clé

Variables passées à la clé, en mode « variables fournies » : toute
variable que la clé cite et que la chaîne porte — celles du producteur
(`G`, parts, `couvert`, `N`…), la hauteur potentielle `h_pot` (avec
l'enveloppe), `hpot` (sans l'enveloppe, h_pot / k), `rapport_h`, et les
couverts des strates. Une variable citée que la chaîne ne porte pas est
neutralisée (voir
[`executer_chaine_fournie()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine_fournie.md)).

## Examples

``` r
# \donttest{
jeu <- generer_jeu_synthetique(30, 30, 200, graine = 1)
chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
res <- typer_peuplements(jeu$pixels, jeu$placettes, "exemple-alpes-du-nord", chemin)
res
#> SER exemple-alpes-du-nord : 900 pixels classés (niveau du modèle : grande_region)
#>   précision à la placette : 81,0 % (kappa 0,71)
#>   précision à la grappe   : 79,8 % (kappa 0,71)
#>   pixels entre deux types : 15,1 %
#>   hauteur potentielle incertaine : 0,0 %
# }
```

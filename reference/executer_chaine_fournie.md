# Exécuter la chaîne sur des variables fournies par un producteur

Mode « variables fournies » (mission 006) : les variables de la clé
viennent déjà calculées (par exemple les paramètres forestiers LiDAR de
l'ONF lus par
[`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md)).
On saute l'ajustement dendrométrique : pas de placettes, donc **pas de
validation** ; la fiche porte un contrôle de cohérence avec l'étagement
du producteur (`typo_etage`), qui n'est pas une validation.

## Usage

``` r
executer_chaine_fournie(
  variables,
  conf,
  milieu = NULL,
  strates = NULL,
  reference_strates = "hpot",
  modele_hp = NULL,
  plancher_m = 1,
  methode_strates = "hybride"
)
```

## Arguments

- variables:

  data.frame de pixels : `i`, `j` (indices de grille), `h_dom` (m),
  `couvert` (0 à 1), les variables de la clé autres que `rapport_h` (une
  colonne vide neutralise ses conditions), et facultativement `x`, `y`,
  `famille`, `typo_etage`, `non_precomptable`, `part_pb_absente`.

- conf:

  Configuration effective d'une SER
  ([`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md)).

- milieu:

  data.frame des variables de milieu, une ligne par ligne de `variables`
  ; ses colonnes utilisées sont celles de son attribut
  `variables_milieu` (posé par
  [`milieu_pixels()`](https://pobsteta.github.io/typopeuplement/reference/milieu_pixels.md)),
  sinon les `variables_milieu` de la configuration ; `NULL` : hauteur
  potentielle vide.

- strates, reference_strates, modele_hp, methode_strates:

  Voir
  [`typer_peuplements()`](https://pobsteta.github.io/typopeuplement/reference/typer_peuplements.md).

- plancher_m:

  Bas de la strate 4, quand le couvert est calculé depuis des dalles
  ([`comptes_strates()`](https://pobsteta.github.io/typopeuplement/reference/comptes_strates.md)).
  **Provisoire** : 1 m.

## Value

Objet `typo_resultat` : `carte`, `fiche_validation` (sans placette ni
grappe, avec `controle` et `declarations`), `niveau_modele`
(`"producteur"`), `ser`, `cle` (souplesses du jeu comprises), `temps`
(`etage`, `secondes`, `pixels`), `gabarit`.

## Details

Étages, chacun chronométré (`temps`) : `lecture` (repris de l'attribut
`temps_lecture` des variables), `hauteur_potentielle`, `strates` (si
`strates` est donné), `cle`, `lissage`, `decision`, `controle` ;
`ecriture_rasters` et `ecriture_tables` sont ajoutés par
[`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md).

- Les pixels `non_precomptable` ne sont pas typés (type vide).

- Les souplesses du jeu (bloc `jeux.<jeu>.souplesse` de la
  configuration, le jeu étant nommé par la colonne `jeu` de l'attribut
  `couches`, voir
  [`couches_onf()`](https://pobsteta.github.io/typopeuplement/reference/couches_onf.md))
  remplacent celles de la clé pour leurs variables : réglage du jeu, dit
  dans la fiche pour les variables que la clé utilise.

- Variables de la clé (mission 012) : la clé reçoit toute variable
  qu'elle cite et que la chaîne porte : celles de `variables` (dont `N`,
  densité de l'ONF), `h_pot` (hauteur potentielle avec l'enveloppe),
  `hpot` (sans l'enveloppe : h_pot / k de la famille, référence des
  strates par défaut), `rapport_h`, et les couverts des strates
  `c1_<ref>` à `c4_<ref>`. Une variable citée que la chaîne ne porte pas
  est vide : ses conditions sont neutralisées et la fiche la nomme.

- Couvert des strates (`strates`, voir
  [`typer_peuplements()`](https://pobsteta.github.io/typopeuplement/reference/typer_peuplements.md))
  : rattaché aux pixels par `x`, `y` ; un pixel sans couvert a ses
  conditions de strates neutralisées. La fiche dit la référence
  (provisoire), la méthode (`methode_strates`, hybride par défaut) et
  les paramètres de segmentation (provisoires), la part des pixels
  couverts, et la corrélation de `c1_<ref>` (strate haute vue du dessus)
  avec le taux de couvert du producteur (`couvert`), sans seuil : un
  contrôle, pas une validation. Avec les houppiers, la carte porte
  `densite_houppiers` (tiges/ha, non passée à la clé) et la fiche la
  compare à `N`. La fiche dit aussi la somme `c1 + c2 + c3 + c4`
  (médiane, part au-delà de 1 : chaque strate a son propre couvert, la
  somme peut dépasser 1) et, en hybride, si les retours des houppiers de
  la strate 1 ont été retirés des strates 2 à 4. Les strates basses sont
  estimées : la carte porte `part_retours_sous_s1` (de 0 à 1, remplace
  le drapeau booléen `strates_basses_estimees`, décision de Pascal du
  2026-11-23), la part des retours du pixel qui passent sous la strate 1
  (sous 3/4 H, sol compris) et servent aux strates 2 à 4, hors houppiers
  de la strate 1 en hybride ; près de 0, les strates basses reposent sur
  très peu de retours. Vide si les tranches ne viennent pas de comptes ;
  absente pour des couverts fournis tout faits.

- Variable absente : quand les types de tête ne se départagent que par
  une variable manquante, `type` est le groupe de ces types
  (`"R-PB-J | R-PB-C"`, voir
  [`decider_type()`](https://pobsteta.github.io/typopeuplement/reference/decider_type.md))
  et `entre_deux` est levé ; `correspondance_types.csv` liste les
  groupes.

- Si le seuil de gros bois du producteur diffère de
  `seuils_diametre$bm_gb_cm` de la configuration, le drapeau
  `gb_interim` est levé sur tous les pixels typés et la fiche le
  déclare.

- Avec `milieu`, la fiche dit ce que voit la hauteur potentielle
  (attribut `source`), les variables de milieu de la configuration
  absentes (jamais inventées), la RMSE de validation croisée par
  famille, l'enveloppe par famille (mesurée hors sac), la part de pixels
  « incertaine » et, si le producteur la déclare non calibrée, ce
  qu'implique une hauteur dominante brute. La carte porte `h_pot_sd`
  (enveloppe × RMSE) et, à part, `sd_arbres` (dispersion des arbres de
  la forêt, pas une erreur). La fiche donne aussi, par famille, le seuil
  de hauteur potentielle auquel revient le drapeau `hp_incertaine`
  (`h_pot` \< enveloppe × RMSE / `incertitude_relative_max`).

- Jeu sans bloc `jeux` dans la configuration : la fiche le déclare
  (souplesses de la clé).

- Sans `milieu`, la hauteur potentielle est vide et signalée partout
  (`hp_incertaine`) ; la clé s'en tient alors aux autres variables.

- Une clé vide (SER sans typologie sourcée) arrête la chaîne : aucune
  carte de types sans clé.

## See also

[`typer_peuplements()`](https://pobsteta.github.io/typopeuplement/reference/typer_peuplements.md),
[`controle_coherence()`](https://pobsteta.github.io/typopeuplement/reference/controle_coherence.md)

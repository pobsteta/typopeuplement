# Prédire la hauteur potentielle et le rapport des hauteurs

Hauteur potentielle `h_pot` = k × moyenne des arbres de la forêt (k :
enveloppe de la famille), son incertitude `h_pot_sd` = k × RMSE de
validation croisée par blocs de la famille, et le rapport hauteur
dominante mesurée / hauteur potentielle. Là où l'incertitude relative
`h_pot_sd / h_pot` dépasse `incertitude_relative_max`, le rapport est
vide (`NA`) et `hp_incertaine` est vrai : la clé s'en tient alors à la
hauteur mesurée. Là où une variable de milieu manque (pixel hors du
MNT), `h_pot` et `h_pot_sd` sont vides et `hp_incertaine` est vrai.

## Usage

``` r
predire_hauteur_potentielle(modele, df, taille_paquet = 20000L)
```

## Arguments

- modele:

  Objet rendu par
  [`ajuster_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_hauteur_potentielle.md).

- df:

  data.frame : variables de milieu, `h_dom`, et la colonne de famille si
  elle existe.

- taille_paquet:

  Nombre de lignes prédites à la fois. **Provisoire** : 20 000.

## Value

data.frame : `h_pot` (m), `h_pot_sd` (m), `rapport_h`, `hp_incertaine` ;
avec les attributs `sd_arbres` (m, dispersion des arbres, `NA` sans
milieu) et `hors_sac` (logique : ligne prédite hors sac).

## Details

**Hors sac.** Un adulte fermé qui a servi à l'apprentissage (même
milieu, même `h_dom`, même `couvert`, même famille qu'une ligne apprise)
est prédit hors sac : par les seuls arbres où il n'a pas servi. Les
autres lignes ont la prédiction ordinaire (tous les arbres). Sans cela,
la forêt « reconnaîtrait » les adultes appris et l'enveloppe serait trop
basse pour eux.

**Écart entre les deux prédictions.** La prédiction hors sac d'un adulte
appris et la prédiction ordinaire d'un pixel voisin de même milieu ne
sont pas la même grandeur : la forêt entière a vu l'adulte, ses arbres
hors sac non. Sur le Vercors (relecture de la mission 009), elles
diffèrent d'environ 1 m. Une carte de `h_pot` peut donc montrer un saut
de cet ordre entre un adulte fermé appris et son voisin ; ce saut vient
de la méthode, pas du milieu (l'attribut `hors_sac` dit quelles lignes
sont concernées).

**Dispersion des arbres.** L'écart-type entre arbres (× k), rendu dans
l'attribut `sd_arbres`, n'est pas une erreur de prédiction : il dit
combien la forêt varie d'un arbre à l'autre en ce point. Il ne compte
pas dans `h_pot_sd`, ni dans `hp_incertaine`. Il ne porte pas sur les
mêmes arbres partout : pour un adulte appris (prédit hors sac), sur les
seuls arbres hors sac (environ un tiers) ; pour les autres lignes, sur
tous les arbres. Les deux ne se comparent pas directement.

**Drapeau « incertaine » : un seuil de hauteur potentielle.** `h_pot_sd`
est constant dans une famille (k × RMSE). Le test
`h_pot_sd / h_pot > incertitude_relative_max` revient donc à
`h_pot < k × RMSE / incertitude_relative_max` : un seuil de hauteur
potentielle par famille, qui marque les stations les moins fertiles
(décision de 2026-11-22, option a ; la fiche de
[`executer_chaine_fournie()`](https://pobsteta.github.io/typopeuplement/reference/executer_chaine_fournie.md)
donne ces seuils).

La prédiction se fait par paquets de `taille_paquet` lignes, pour borner
la mémoire (une valeur par arbre et par ligne).

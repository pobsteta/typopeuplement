# Hauteurs de référence des strates

Les strates du GSM sont des quarts de la hauteur dominante potentielle.
Tant que la référence n'est pas choisie (plan de la mission 008), on en
calcule trois, colonnes de la table rendue, dans cet ordre :

## Usage

``` r
references_strates(carte, facteur = NULL)
```

## Arguments

- carte:

  data.frame de pixels : `h_pot` et `h_dom` (m), `famille` si `facteur`
  est donné ; `x`, `y` (m) sont repris s'ils y sont.

- facteur:

  Enveloppe k par famille : liste ou vecteur nommé (par exemple
  `modele$facteur` de
  [`ajuster_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_hauteur_potentielle.md)).
  Une famille sans facteur prend celui de la première famille, comme
  [`predire_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/predire_hauteur_potentielle.md).
  `NULL` : pas de colonne `hpot`.

## Value

data.frame : `x`, `y` (s'ils sont dans `carte`), `hpot_k`, `hpot` (si
`facteur`), `h0`, une ligne par ligne de `carte`.

## Details

- `hpot_k` : `h_pot`, hauteur potentielle relevée par l'enveloppe k
  ([`predire_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/predire_hauteur_potentielle.md)).
  **Référence par défaut, provisoire** : la plus fidèle au GSM (une
  hauteur *potentielle*) ;

- `hpot` : `h_pot / k`, la hauteur potentielle sans l'enveloppe (moyenne
  de la forêt), si `facteur` est donné ;

- `h0` : `h_dom`, la hauteur dominante mesurée du pixel.

Ces hauteurs sont dans l'échelle de `h_dom`. Avec le jeu ONF, `h_dom`
est la hauteur brute `H0_lidar`, **non calibrée** : les quarts sont
alors des quarts de cette échelle, pas des quarts d'une Hₒ en mètres
vrais (réserve à garder à la lecture).

## See also

[`couvert_strates()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates.md),
[`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md)

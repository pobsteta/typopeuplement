# Contrôle de cohérence avec une couche de référence du producteur

Tableau croisé des types de la carte et d'une couche catégorielle du
producteur (par exemple l'étagement `Typo_etage` du jeu ONF), et V de
Cramér. C'est un **contrôle de cohérence, pas une validation** : la
référence de validation est la clé appliquée aux mesures (Souchon,
2020), et la couche du producteur ne décrit pas les mêmes types.

## Usage

``` r
controle_coherence(types, reference, nom = "reference", exclure = NULL)
```

## Arguments

- types:

  Types de la carte (un par pixel ; `NA` : pixel non typé, écarté).

- reference:

  Classe de la couche du producteur (un par pixel ; `NA` écarté).

- nom:

  Nom de la couche de référence, pour la fiche.

- exclure:

  Classes de `reference` à écarter (par exemple 0, « non précomptable
  »).

## Value

Liste : `reference` (le nom), `tableau` (lignes : types, colonnes :
classes), `n`, `v_cramer` (`NA` si le tableau a moins de deux lignes ou
deux colonnes).

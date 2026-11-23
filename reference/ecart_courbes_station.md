# Écart aux courbes de station de nemeton

Corrélation de rang (Spearman) entre la hauteur potentielle et l'indice
de station de nemeton
([`nemeton::compute_site_index()`](https://pobsteta.github.io/nemeton/reference/compute_site_index.html)),
là où l'âge et l'essence sont connus. Ce n'est pas une égalité attendue
: c'est un contrôle de cohérence, rapporté dans la fiche de validation.
nemeton est en Suggests : sans lui, la fonction s'arrête.

## Usage

``` r
ecart_courbes_station(h_pot, h_dom, age, essence, age_reference = 50)
```

## Arguments

- h_pot:

  Hauteur potentielle (m).

- h_dom:

  Hauteur dominante mesurée (m).

- age:

  Âge du peuplement (années) ; `NA` si inconnu.

- essence:

  Code d'essence au format de nemeton (IFN, 4 lettres) ; `NA` si
  inconnu.

- age_reference:

  Âge de référence de l'indice de station. **Provisoire** : 50 ans,
  valeur par défaut de nemeton.

## Value

Liste : `n` (nombre de lignes où l'indice est estimable),
`correlation_rang` (`NA` si moins de 3 lignes).

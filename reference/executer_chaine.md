# Exécuter la chaîne sur des tableaux de placettes et de pixels

1.  variables dendrométriques prédites sur les pixels (forêts aléatoires
    apprises sur les placettes) ;

2.  hauteur potentielle apprise sur les peuplements adultes fermés des
    pixels, et rapport hauteur mesurée / hauteur potentielle ;

3.  clé floue de la SER, lissage à l'échelle de lecture, décision et
    drapeaux ;

4.  validation sur les placettes, hors échantillon (validation croisée),
    à la placette et à la grappe, la référence étant la clé dure
    appliquée aux mesures.

## Usage

``` r
executer_chaine(placettes, pixels, conf)
```

## Arguments

- placettes:

  data.frame des placettes.

- pixels:

  data.frame des pixels de l'emprise.

- conf:

  Configuration effective d'une SER
  ([`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md)).

## Value

Objet `typo_resultat` (liste) : `carte` (une ligne par pixel : `i`, `j`,
`type`, `proba`, `type_second`, `proba_second`, `entre_deux`,
`hors_cle`, les variables prédites, `h_dom`, `h_pot`, `h_pot_sd`,
`rapport_h`, `hp_incertaine`, `p_<code>`), `fiche_validation`,
`erreurs_variables`, `rmse_hauteur_potentielle`, `types_observes`,
`niveau_modele`, `ser` et `cle`.

## Details

Entrées, une ligne par placette ou par pixel : les `predicteurs` et les
`variables_milieu` de la configuration, `h_dom` (m), `couvert`,
`famille` ; pour les pixels `i`, `j` (indices de grille) ; pour les
placettes les variables mesurées (`G`, parts) et `x`, `y` (m).
Facultatif, sur les placettes : `age` et `essence`, pour l'écart aux
courbes de station de nemeton.

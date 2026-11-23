# Table « état de preuve » d'une carte

Pour chaque chiffre du rapport : s'il est **mesuré** (compté directement
sur les livrables), **provisoire** (valeur ou réglage non gelé, sortie
non calibrée) ou **non vérifié** (rien ne le confronte à la réalité). Il
n'y a aucune validation indépendante : aucune placette indépendante
géolocalisée au pixel (ADR 0006, 0010). Le nombre associé au type
s'appelle *appartenance* tant qu'il n'est pas calibré (arbitrage C12).

## Usage

``` r
etat_de_preuve(dossier, demo = FALSE, ser = "H10")
```

## Arguments

- dossier:

  Dossier des livrables de l'AOI
  ([`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md)).

- demo:

  `TRUE` pour un jeu synthétique : tout chiffre est alors sans valeur
  sur données réelles.

- ser:

  Nom de la SER, cité dans la phrase sur l'absence de validation.

## Value

Un `data.frame` : `chiffre`, `statut` (`mesure`, `provisoire`,
`non verifie` avec accents dans le rapport), `commentaire`.

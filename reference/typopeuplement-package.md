# typopeuplement : carte du type de peuplement des forêts de France hexagonale

Chaîne de traitement qui produit, pour une emprise (AOI), une carte du
type de peuplement (composition, structure, capital) calibrée par
sylvoécorégion (SER). Portage R du prototype Python
(`src/typopeuplement/`), package compagnon de nemeton (ADR 0004).

## Details

La typologie est **descriptive** : ni choix d'essences, ni itinéraires
sylvicoles. Les cartes aident à décider ; elles ne remplacent pas le
diagnostic de terrain. Chaque carte porte sa couche de confiance :
probabilité du type, drapeau « entre deux types », drapeau « hauteur
potentielle incertaine ».

La clé de types de `inst/extdata/config/exemple.json` est un **exemple**
pour faire tourner la chaîne : chaque SER pilote la remplacera par sa
typologie locale, sourcée.

Point d'entrée :
[`typer_peuplements()`](https://pobsteta.github.io/typopeuplement/reference/typer_peuplements.md).
Démonstration :
[`lancer_demo()`](https://pobsteta.github.io/typopeuplement/reference/lancer_demo.md).

Unités : diamètres en cm à 1,30 m, surface terrière en m²/ha, hauteurs
en m, coordonnées en m (Lambert-93 pour les vraies données), parts entre
0 et 1.

## Author

**Maintainer**: Pascal Obstétar <pascal.obstetar@gmail.com>

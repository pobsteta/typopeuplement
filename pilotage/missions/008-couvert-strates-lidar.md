# Mission 008 — couvert des strates par le LiDAR HD

## Mission

**En une phrase (quoi, et pourquoi) :** calculer, à partir du nuage de points LiDAR HD de
l'IGN sur l'AOI, le couvert de chacune des strates du GSM (quarts de la H0 potentielle)
au pixel de la grille, parce que c'est la variable maîtresse de la typologie de H10.

## Les trois questions

- oui ;
- **non, pas encore** : lasR ou lidR (ADR 0003), installation depuis r-universe, accès
  au nuage et volume sur l'AOI à établir ;
- moyens : dépend de 009 (H0 potentielle).

**Temps de la main :** **prendre**. L'agent rend un plan : outil, accès, volume, mesure
du temps par dalle (critère 10). Pascal le valide avant toute écriture, car la décision
engage la durée.

**Degré :** le chef tranche.

## L'Homme

`dev` · opus.

## Harnais

- **Peut (après le plan) :** `R/strates.R` (nouveau), `DESCRIPTION` (lasR en Suggests
  ou en Imports, à décider dans le plan), `tests/testthat/test-dev-strates.R`, un
  extrait de nuage de moins de 2 Mo.
- **Ne doit pas :** télécharger le massif entier sans mesure préalable sur une dalle.

## Valeur provisoire

Les classes de couvert du GSM (≥ 5/10, 3-4/10, ≤ 2/10) sont sourcées. La hauteur de
coupe entre strates dépend de H0 potentielle, qui est provisoire (009).

## Dépend de / rouge attendu jusqu'à

Dépend de 009. Ordre : 006 → 007 → 009 → 008.

## Tests

- Sur un nuage synthétique, le couvert par strate est connu.
- Sur une dalle réelle, la somme est cohérente avec `Tx_couv` de l'ONF.

## Terrain

Pascal compare l'étagement trouvé à la couche `Typo_etage` sur une forêt qu'il connaît.

## Qui tranche

`relecteur`, puis Pascal.

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

## Ajouts du 2026-11-22 (relecture de 009)

Mineurs à traiter avec le code de 008, après validation du plan :
1. Documenter dans `predire_hauteur_potentielle` l'écart d'environ 1 m entre la
   prédiction hors sac (adultes appris) et la prédiction ordinaire (voisins).
2. Documenter la nature de `sd_arbres` : arbres hors sac pour les adultes appris, tous
   les arbres pour les autres pixels.
3. Partager les paramètres de forêt entre `foret_regression` et `foret_hors_sac`, par
   exemple avec `keep.inbag`.
4. Fiche de validation : dire que le drapeau « incertaine » revient à un seuil de h_pot
   par famille (décision par délégation, option a).

Rappels :
- la hauteur potentielle n'est pas calibrée (H0_lidar brute) ;
- les strates du GSM sont des quarts de H0 potentielle. Le plan dit comment il traite
  cette échelle : sur une hauteur relative, ou en mètres avec réserve.

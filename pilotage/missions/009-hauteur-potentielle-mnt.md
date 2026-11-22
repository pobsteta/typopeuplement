# Mission 009 — hauteur potentielle à partir du relief

## Mission

**En une phrase (quoi, et pourquoi) :** calculer sur la grille de l'AOI l'altitude, la
pente, l'exposition et la position topographique depuis le MNT ouvert de l'IGN, et en
tirer la hauteur potentielle et son incertitude, parce que les strates du GSM sont des
quarts de la hauteur potentielle.

## Les trois questions

- oui ;
- oui : `R/hauteur_potentielle.R`, RGE ALTI ou MNT LiDAR HD de l'IGN (Géoplateforme),
  brief (section hauteur potentielle) ;
- moyens : accès au service de l'IGN à vérifier en première tâche.

**Temps de la main :** donner. **Degré :** le chef tranche.

## L'Homme

`dev` · opus (justesse des données).

## Harnais

- **Peut :** `R/milieu.R` (nouveau), `R/hauteur_potentielle.R`,
  `tests/testthat/test-dev-milieu.R`, `tests/testthat/fixtures/vercors/milieu/`.
- **Ne doit pas :** inventer une couche de climat ou de sol (le relief seul d'abord, et
  le dire) ; publier une hauteur potentielle sans son incertitude.
- **Câblé :** comme 007.

## Valeur provisoire

Seuils d'adultes (couvert 0,7 ; 15 m), quantile 0,9, incertitude 0,2. Ils seront mesurés
sur l'AOI : part de pixels « incertaine », et H0 potentielle comparée aux courbes de
nemeton là où l'âge est connu.

## Dépend de / rouge attendu jusqu'à

Dépend de 006 (lecture de l'AOI) et de 007 (`man/`, `NAMESPACE`). Ordre : 006 → 007 → 009.

## Tests

- Les rasters du relief sont alignés sur la grille de l'ONF.
- H0 potentielle est au moins égale à H0 mesurée chez les adultes, au quantile près.
- L'incertitude est rendue.

## Terrain

Pascal juge la carte de H0 potentielle sur une forêt qu'il connaît.

## Qui tranche

`relecteur`, puis Pascal.

## Ajouts du 2026-11-22 (relecture de 007, décisions par délégation)

1. **Probabilité d'un groupe de types** : c'est la somme des probabilités de ses membres.
2. **Jeu sans bloc `jeux` dans la configuration** : la fiche le déclare (« souplesses de la
   clé, faute de bloc jeux »).
3. **`touche_na`** : il reste lu au pixel. La limite est documentée dans `decider_type` :
   en bordure d'une zone sans milieu, un pixel peut prendre un type franc.
4. **Titre faux** dans `tests/testthat/test-ser.R` (« nul de bande donne un poids de 1 ») :
   le corriger. C'est la seule écriture permise dans ce fichier.
5. **Forêt pilote** : vérifier que la forêt domaniale de Léoncel est dans l'emprise du jeu
   et en H10 (WFS des SER de l'INRAE ; contour de la forêt publique par l'ONF ou l'IGN, en
   données ouvertes). Sinon, la forêt de Lente.

Périmètre étendu : `R/cle.R`, `R/chaine.R`, `R/validation.R`, `R/typer_peuplements.R`,
`R/donnees_lidar.R`, et le titre de ce seul test dans `tests/testthat/test-ser.R`.

## Aller-retour 1/3 (2026-11-22) : remarques du relecteur et décisions par délégation

1. **Bloquant : l'enveloppe.** Calculer k comme le quantile 0,9 de h_dom / prédiction hors sac
   (out-of-bag de ranger, `m$predictions`), et prédire hors sac les adultes ayant servi à
   l'apprentissage. Les autres pixels gardent la prédiction ordinaire. Le test encadre la part
   d'adultes sous h_pot entre 0,85 et 0,95 (au lieu de seulement ≥ 0,9).
2. **Incertitude** : h_pot_sd = k × RMSE de validation croisée par blocs, sans plus y ajouter
   en quadrature l'écart entre arbres. Cet écart (`sd_arbres`) est rendu à part et documenté
   comme la dispersion de la forêt, pas comme une erreur de prédiction. Le seuil de 0,2 est
   gardé, provisoire. Donner la nouvelle part de pixels « incertains » par famille.
3. **Test d'altitude** : ajouter le pixel (20, 20) de l'extrait, 1 428,28 m (IGN), avec une
   tolérance de 1 m.
4. `variables_milieu` : rien à changer dans `exemple.json`. La mission 010 écrira le relief
   dans `vercors-h10.json`.
5. Refaire les chiffres du massif : parts sous h_pot, parts « incertaines », médiane de
   `rapport_h`, temps de l'étage.

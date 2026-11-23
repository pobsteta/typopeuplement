# Mission 013 — couvert des strates par houppier

## Mission

**En une phrase (quoi, et pourquoi) :** segmenter les houppiers dans le nuage LiDAR HD,
ranger chaque arbre dans une strate du GSM selon la hauteur de sa cime, puis additionner
la surface de ses houppiers par pixel de la grille ONF, parce que c'est ainsi que le GSM
définit le couvert d'une strate et que la mesure par tranches de hauteur (008) vide la
strate 1 (82 % de jeunes futaies à Léoncel).

## Les trois questions

- oui ;
- **non, pas encore** : algorithme de segmentation (lasR, lidR, ou `R/houppiers.R` de
  nemeton : watershed, dalponte2016, li2012…), paramètres, effet du sous-étage masqué ;
- oui : lasR dans le dossier de travail, dalles de Léoncel accessibles (WFS de l'IGN).

**Temps de la main :** **prendre**. L'agent rend un plan, essais compris, sans écrire dans
le dépôt. Pascal le valide, car la délégation est échue.

**Degré :** le chef tranche.

## L'Homme

`dev` · opus.

## Harnais (après le plan)

- **Peut :** `R/houppiers.R` (nouveau), `R/strates.R`, `R/chaine.R`,
  `R/typer_peuplements.R`, `man/`, `NAMESPACE`, `DESCRIPTION`,
  `tests/testthat/test-dev-*.R`, `tests/testthat/fixtures/vercors/strates/`.
- **Ne doit pas :**
  - modifier la clé de `vercors-h10.json` ;
  - calculer le massif ;
  - copier le code de nemeton (on l'appelle, ou on cite ce qui est repris).

## Valeur provisoire

Les paramètres de segmentation (taille de fenêtre, hauteur minimale) et la référence
des strates sont provisoires. Mesure : la carte de Léoncel comparée à la mesure par
tranches et aux 3 pixels de terrain.

## Tests

- Sur un nuage synthétique de houppiers connus, chaque arbre tombe dans sa strate et le
  couvert est juste.
- Sur l'extrait réel, les houppiers sont plausibles (nombre, hauteurs).

## Terrain

Les 3 pixels de Léoncel, et le pixel 2 en premier : jeune futaie, ou futaie adulte ?

## Qui tranche

`relecteur`, puis Pascal.

## Plan validé par Pascal (2026-11-23)

- **Mode hybride :**
  - strate 1 par les houppiers (lasR : MNH à 0,5 m, maxima locaux, `region_growing` ;
    fenêtre de 3 m, hauteur minimale de 2 m, provisoires) ;
  - strates 2 à 4 par les tranches de hauteur de 008, corrigées de l'occlusion ;
  - les strates basses sont déclarées « estimées » dans la couche de confiance.
- **Argument `methode_strates`** : « tranches », « houppiers » ou « hybride » (défaut :
  hybride). Les colonnes `c*_<ref>` ne changent pas.
- **Toutes les dalles passent en un seul `exec`**, avec un tampon, pour ne pas couper les
  houppiers. La densité des houppiers est rendue mais ne sert pas à la clé : le seuil de
  800 tiges/ha porte sur N de l'ONF (décision de Pascal).
- **Pas de nemeton** en contrôle croisé (Pascal).
- **Carte de Léoncel refaite en mode hybride** (22 dalles), comparée à la carte de 012.
  Pixels 1, 2 et 3 : le pixel 2 est une jeune futaie (Pascal, sur le terrain).

## Reprise, aller-retour 1/3 (2026-11-23, décisions de Pascal)

1. **Strate 2 surestimée : retirer.** En mode hybride, les retours qui tombent dans un
   houppier de strate 1 (cellule de ce houppier, vue du dessus) ne comptent plus dans les
   tranches des strates 2 à 4. Les couverts redeviennent cohérents : dire ce que vaut la
   somme c1 + … + c4 et sa distribution.
2. **Un seul catalogue.** Léoncel est recalculé en un seul `exec` sur les 19 dalles, avec un
   tampon de 20 m. Le dossier de travail peut monter à 12 Go (56 Go libres). Plus aucun
   houppier coupé.
3. **Drapeau gradué.** `strates_basses_estimees` devient une valeur entre 0 et 1 : la part
   des retours LiDAR qui passent sous la strate 1 (au pixel). Nom à garder ou à préciser,
   documenté.
4. **Mineurs** :
   - la fiche dit que la somme des couverts peut dépasser 1 (ou ne le peut plus, après le
     point 1) ;
   - `!is.na(h)` dans le numérateur de `couvert_houppiers` ;
   - houppier numéro 0.
5. **Carte de Léoncel refaite**, comparée à la carte hybride précédente : familles, part
   « entre deux », pixels 1, 2 et 3. Le pixel 2 est une jeune futaie (terrain) ; le pixel 3
   est inconnu.

Périmètre : celui de la fiche. Ne pas toucher la clé.

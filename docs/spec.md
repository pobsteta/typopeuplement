# Spécification — typopeuplement

2026-11-22 · rédigée par Claude (orchestrateur) d'après le brief validé par Pascal · **à valider par Pascal**

Brief : [`brief-typologie-peuplements.md`](brief-typologie-peuplements.md). Stack : [ADR 0004](adr/0004-r-package-compagnon-de-nemeton.md) (R).

## Pour qui, pour quoi

Un aménagiste de l'ONF, un technicien de coopérative ou un expert forestier prépare la
gestion d'une forêt ou d'un massif : aménagement, plan simple de gestion, stratification
d'un inventaire. Il veut savoir, avant d'aller sur le terrain, quels types de peuplements
il trouvera et où, avec la confiance qu'il peut accorder à la carte.

## Parcours utilisateur

1. **Il délimite son AOI** : un GeoPackage de la forêt ou du massif (parcellaire ou
   contour). La chaîne en déduit la ou les SER concernées (référentiel GeoData INRAE).
2. **Il fournit ce qu'il a** : ses placettes d'inventaire avec leurs coordonnées et leurs
   arbres (diamètre, essence), et l'âge des peuplements s'il le connaît. Sans placettes,
   la chaîne prend les modèles de la grande région et le dit.
3. **La chaîne rassemble les données ouvertes de l'AOI** : MNH et MNT LiDAR HD, nuage de
   points si nécessaire, Sentinel-2, BD Forêt v3, couches de milieu.
4. **Elle calcule et rend** (voir « Livrables »), en un appel R :
   `typer_peuplements(aoi, placettes = NULL, ser = NULL)`.
5. **Il lit la carte sur le terrain** : type, probabilité, drapeaux. Il vérifie les
   pixels « entre deux types » en priorité.
6. **Dans nemeton** : la carte des types et les variables continues alimentent les
   indicateurs (B2 structure, P1 volume, P2 station) comme une source de plus.

## Données manipulées

| Donnée | Rôle | Format | Source |
|---|---|---|---|
| AOI | Emprise | GeoPackage, Lambert-93 | Utilisateur |
| Placettes et arbres | Calibration locale | GeoPackage ou CSV | Utilisateur (inventaires d'aménagement, coopératives, experts) |
| Placettes IFN | **Contrôle** à l'échelle de la SER, jamais calibration (Pascal, 2026-11-22) | CSV | IGN, données brutes de l'inventaire |
| MNH, MNT LiDAR HD | Hauteur dominante, relief | GeoTIFF | IGN |
| Nuage de points LiDAR HD | Sous-étage, parts de bois, au besoin | LAZ ou COPC | IGN, via lasR |
| Sentinel-2 | Essences, phénologie, changements | COG | Copernicus |
| BD Forêt v3 | Essences (entrée, pas vérité) | GeoPackage | IGN |
| Climat, sol | Hauteur potentielle | GeoTIFF | Météo-France, Digitalis |
| Courbes de hauteur dominante | Contrôle de la hauteur potentielle | via nemeton (P2) | Sources de nemeton (Duplat & Tran-Ha 1997, etc.) |
| Configuration des SER | Seuils, clé, souplesses | JSON ou YAML | À sourcer pour chaque SER |

## Livrables, par AOI

- `types.tif` : code du type, probabilité, second type, drapeau « entre deux types ».
- `variables.tif` : G, parts de résineux, PB, BM, GB, hauteur dominante, hauteur
  potentielle et son incertitude, rapport des deux hauteurs.
- `confiance.tif` : hauteur potentielle incertaine, zones sans donnée (ZICAD, hors
  LiDAR), modèle de grande région utilisé.
- `fiche_validation.md` : matrices de confusion à la placette et à la grappe, erreurs,
  domaine de validité.
- La table de correspondance avec la typologie locale de la SER.

## Hors périmètre

- Le choix des essences et les itinéraires sylvicoles.
- La typologie de stations.
- Le calcul de la France entière d'un coup : un calcul par AOI.
- L'outre-mer.
- Tout contact avec l'IGN (Pascal, 2026-11-22).

## Critères d'acceptation

1. **Clé floue** : avec une souplesse nulle, on retrouve exactement la clé dure ; les
   probabilités somment à 1 ; un pixel à égalité est marqué « entre deux types ».
2. **Seuils par SER** : un arbre de 45 cm compte en gros bois en Savoie (42,5 cm) et en
   bois moyen dans les Vosges (47,5 cm).
3. **Héritage** : une SER qui manque de placettes pour un type prend le modèle de sa
   grande région, et la carte de confiance le dit.
4. **Pas de rupture** : sur une limite de SER, les deux modèles pèsent chacun pour moitié.
5. **Hauteur potentielle** : incertaine → rapport vide et drapeau levé ; là où l'âge est
   connu, écart aux courbes de nemeton rapporté dans la fiche de validation.
6. **Validation** : précision et kappa à la placette et à la grappe de 0,5 ha, sur des
   placettes non utilisées pour calibrer ; contrôle par les placettes IFN de la SER.
7. **Seuil de passage des pilotes** : par usage et par SER, fixé avec les utilisateurs ;
   repère de 76 % pour les résineux de montagne.
8. **Formats** : tout livrable s'ouvre dans QGIS et dans R (terra, sf) sans conversion.
9. **Dans nemeton** : un appel R lit les livrables d'une AOI ; typopeuplement dépend de
   nemeton ou le suggère, jamais l'inverse.
10. **Mesure** (ADR 0003) : sur une AOI pilote, le temps de chaque étage est mesuré et
    consigné.

## Besoins en référentiels (pour l'`acquereur`)

- Le découpage des SER et des grandes régions écologiques, avec leurs codes (GeoData INRAE).
- Pour chaque SER pilote, la typologie locale de peuplements (guide de sylviculture,
  typologie du SRGS) : types, seuils, noms.
- Les seuils de catégories de diamètre par SER (précomptage, limites PB / BM / GB).
- Les codes d'essences de la BD Forêt v3 et leur correspondance avec ceux de nemeton.
- La carte ONF de l'Ain (2017) : codes A à F et clé, pour comparaison.

## Questions ouvertes (reprises du brief)

- Clé nationale unique déclinée par seuils, ou clés distinctes par SER ?
- Quelles SER pilotes, et avec quelles placettes ?
- Le code de la chaîne ONF est-il partageable ?

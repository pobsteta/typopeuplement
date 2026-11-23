# Spécification — typopeuplement

2026-11-22 · rédigée par Claude (orchestrateur) d'après le brief validé par Pascal · validée par Pascal le 2026-11-22

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
   pixels « entre deux types » en priorité. *(réconciliation, Pascal, 2026-11-23 : « appartenance » tant que le nombre n'est pas calibré, ADR 0006.)*
6. **Dans nemeton** : la carte des types et les variables continues alimentent les
   indicateurs (B2 structure, P1 volume, P2 station) comme une source de plus.

## Données manipulées

| Donnée | Rôle | Format | Source |
|---|---|---|---|
| AOI | Emprise | GeoPackage, Lambert-93 | Utilisateur |
| Placettes et arbres | Calibration locale | GeoPackage ou CSV | Utilisateur (inventaires d'aménagement, coopératives, experts) |
| Placettes IFN | **Contrôle** à l'échelle de la SER, jamais calibration (Pascal, 2026-11-22) | CSV | IGN, données brutes de l'inventaire |
| MNH, MNT LiDAR HD | Hauteur dominante, relief | GeoTIFF | IGN |
| Nuage de points LiDAR HD | Sous-étage, parts de bois, au besoin | LAZ ou COPC | IGN, via lasR *(réconciliation, Pascal, 2026-11-23 : lasR isolé derrière une interface, PDAL en repli, ADR 0016 ; métriques calculées depuis le LiDAR HD partout, ADR 0015)* |
| Sentinel-2 | Essences, phénologie, changements | COG | Copernicus |
| BD Forêt v3 | Essences (entrée, pas vérité) | GeoPackage | IGN |
| Climat, sol | Hauteur potentielle | GeoTIFF | Météo-France, Digitalis |
| Courbes de hauteur dominante | Contrôle de la hauteur potentielle | via nemeton (P2) | Sources de nemeton (Duplat & Tran-Ha 1997, etc.) |
| Configuration des SER | Seuils, clé, souplesses | JSON ou YAML | À sourcer pour chaque SER *(réconciliation, Pascal, 2026-11-23 : les seuils sont un paramètre du référentiel, ADR 0007)* |

## Livrables, par AOI

- `types.tif` : code du type, probabilité, second type, drapeau « entre deux types ». *(réconciliation, Pascal, 2026-11-23 : l'« appartenance », « probabilité » seulement après calibration, ADR 0006.)*
- `variables.tif` : G, parts de résineux, PB, BM, GB, hauteur dominante, hauteur
  potentielle et son incertitude, rapport des deux hauteurs. *(réconciliation, Pascal, 2026-11-23 : G par classe de 5 cm et par groupe d'essences, part de taillis, seuils appliqués en aval selon le référentiel, ADR 0007.)*
- `confiance.tif` : hauteur potentielle incertaine, zones sans donnée (ZICAD, hors
  LiDAR), modèle de grande région utilisé. *(réconciliation, Pascal, 2026-11-23 : plus le repli sur la hauteur mesurée, le saut aux limites de blocs LiDAR, la précision utilisateur du type dans la SER avec son IC, l'écart d'appartenance entre les deux premiers types, ADR 0006 ; codes « sans donnée » de l'ADR 0013.)*
- `fiche_validation.md` : matrices de confusion à la placette et à la grappe, erreurs,
  domaine de validité.
- La table de correspondance avec la typologie locale de la SER.

## Hors périmètre

- Le choix des essences et les itinéraires sylvicoles.
- La typologie de stations.
- Le calcul de la France entière d'un coup : un calcul par AOI.
- L'outre-mer.
- Tout contact avec l'IGN (Pascal, 2026-11-22). *(réconciliation, Pascal, 2026-11-23 : et avec l'ONF, ADR 0015.)*

## Critères d'acceptation

1. **Clé floue** : avec une souplesse nulle, on retrouve exactement la clé dure ; les
   probabilités somment à 1 ; un pixel à égalité est marqué « entre deux types ». *(réconciliation, Pascal, 2026-11-23 : lire « appartenances » pour « probabilités » tant qu'elles ne sont pas calibrées, ADR 0006.)*
2. **Seuils par SER** : un arbre de 45 cm compte en gros bois en Savoie (42,5 cm) et en
   bois moyen dans les Vosges (47,5 cm). *(réconciliation, Pascal, 2026-11-23 : seuils par référentiel typologique, pas par SER ; l'exemple (Savoie, Vosges) vient du mémoire de 2020, un référentiel parmi d'autres ; un arbre de 45 cm est gros bois pour le GSM de H10 (42,5 cm) ; ADR 0007.)*
3. **Héritage** : une SER qui manque de placettes pour un type prend le modèle de sa
   grande région, et la carte de confiance le dit.
4. **Pas de rupture** : sur une limite de SER, les deux modèles pèsent chacun pour moitié.
5. **Hauteur potentielle** : incertaine → rapport vide et drapeau levé ; là où l'âge est
   connu, écart aux courbes de nemeton rapporté dans la fiche de validation. *(réconciliation, Pascal, 2026-11-23 : critère d'erreur par SER fixé avant les résultats ; s'il n'est pas tenu, la clé GSM se replie sur la hauteur mesurée, signalé dans `confiance` et dans la fiche ; la portée du contrôle par nemeton est à préciser (journal, 2026-11-23, mission 013) ; ADR 0009.)*
6. **Validation** : précision et kappa à la placette et à la grappe de 0,5 ha, sur des
   placettes non utilisées pour calibrer ; contrôle par les placettes IFN de la SER. *(réconciliation, Pascal, 2026-11-23 : unité = le pixel, référence = placette de 15 m centrée sur le pixel, grappes au demi-hectare et estimateurs en grappes ; kappa en indicateur seulement ; précisions utilisateur et producteur avec IC ; choix du classifieur par validation croisée spatiale ; contrôle IFN par agrégats avec estimateur nommé ; ADR 0006.)*
7. **Seuil de passage des pilotes** : par usage et par SER, fixé avec les utilisateurs ;
   repère de 76 % pour les résineux de montagne. *(réconciliation, Pascal, 2026-11-23 : deux conditions cumulées, (1) non-infériorité appariée contre une base de comparaison par SER, marge fixée d'avance, (2) borne basse de l'IC de la précision ≥ seuil d'usage fixé par Pascal par usage et par SER ; d'abord sur les 8 types SRGS, puis sur le GSM ; le 76 % porte sur la seule structure ; ADR 0006.)*
8. **Formats** : tout livrable s'ouvre dans QGIS et dans R (terra, sf) sans conversion. *(réconciliation, Pascal, 2026-11-23 : toute livraison publiée en COG avec style QGIS, RAT, STAC, INSPIRE, millésime et DOI, ADR 0013.)*
9. **Dans nemeton** : un appel R lit les livrables d'une AOI ; typopeuplement dépend de
   nemeton ou le suggère, jamais l'inverse.
10. **Mesure** (ADR 0003) : sur une AOI pilote, le temps de chaque étage est mesuré et
    consigné.

## Besoins en référentiels (pour l'`acquereur`)

- Le découpage des SER et des grandes régions écologiques, avec leurs codes (GeoData INRAE).
- Pour chaque SER pilote, la typologie locale de peuplements (guide de sylviculture,
  typologie du SRGS) : types, seuils, noms.
- Les seuils de catégories de diamètre par SER (précomptage, limites PB / BM / GB). *(réconciliation, Pascal, 2026-11-23 : par référentiel typologique, table versionnée, ADR 0007.)*
- Les codes d'essences de la BD Forêt v3 et leur correspondance avec ceux de nemeton.
- La carte ONF de l'Ain (2017) : codes A à F et clé, pour comparaison.

## Questions ouvertes (reprises du brief)

- Clé nationale unique déclinée par seuils, ou clés distinctes par SER ? *(réconciliation, Pascal, 2026-11-23 : tranchée, légende du gestionnaire d'abord (8 types SRGS, GSM pour H10) et type générique national en plus, ADR 0008.)*
- Quelles SER pilotes, et avec quelles placettes ? *(réconciliation, Pascal, 2026-11-23 : AOI pilote = forêt domaniale de Léoncel plus forêts privées voisines dans H10, ADR 0008 ; placettes de sources publiques, ADR 0010.)*
- Le code de la chaîne ONF est-il partageable ? *(réconciliation, Pascal, 2026-11-23 : sans objet sans contact ONF, ADR 0015.)*

## Amendements de la réconciliation du 23 novembre 2026

Ajouts aux critères ci-dessus (les critères 1, 2, 5, 6, 7 et 8 sont amendés en place, notes marquées
« réconciliation »). Chaque ligne cite l'ADR qui la fonde, avec sa source.

11. **Grille** *(réconciliation, Pascal, 2026-11-23)* : tout livrable est sur la grille de
    26,6 m en Lambert-93, alignée sur la grille ONF là où ses rasters existent ; chaque capteur
    est rééchantillonné une seule fois ; la sensibilité au rééchantillonnage est mesurée sur
    l'AOI pilote (ADR 0005).
12. **Emprise, domaine et codes** *(réconciliation, Pascal, 2026-11-23)* : calcul sur l'emprise
    élargie (landes, accrus, terrains nus et polygones de gestion compris), statistiques sur
    l'emprise forêt IGN ; domaine de validité = aire d'applicabilité (CAST ou équivalent) ;
    codes 250, 251, 252, 253 et 255 décrits par une table d'attributs de raster (ADR 0011 et 0013).
13. **Blocs LiDAR et légendes** *(réconciliation, Pascal, 2026-11-23)* : couche « date et saison du
    vol » ; le vol le plus récent l'emporte en recouvrement ; un saut au-delà du seuil fixé au
    pilote est signalé dans `confiance`, jamais lissé ; la limite entre deux régions SRGS n'est
    pas lissée (ADR 0012).
14. **Placettes** *(réconciliation, Pascal, 2026-11-23)* : contrôles à l'import (emprise
    Lambert-93, X et Y inversés, WGS84 non converties, cohérence avec le MNH) ; placettes
    anciennes utilisées seulement si cohérentes avec le MNH et sans coupe entre relevé et vol ;
    le protocole relève le couvert de chaque strate pour la clé GSM (ADR 0010).
15. **Calibration et confiance** *(réconciliation, Pascal, 2026-11-23)* : la fiche de validation
    donne le diagramme de fiabilité et le score de Brier de l'appartenance, les biais et RMSE des
    variables continues, la précision utilisateur du type par SER avec IC ; l'erreur par classe
    de diamètre et sur les parts PB, BM, GB après seuils du référentiel (ADR 0006 et 0007).
16. **Diffusion** *(réconciliation, Pascal, 2026-11-23)* : aucune dégradation, aucune différence
    entre forêt publique et forêt privée ; code sous GPL-3 (`LICENSE`), données sous Licence
    Ouverte Etalab 2.0 ; la vérification du risque cadastre précède la première diffusion
    publique (ADR 0014).
17. **Versions** *(réconciliation, Pascal, 2026-11-23)* : versions calendaires `vAAAA.MM.N`, tag
    et release par la CI après tests verts sur `main` (ADR 0017).

# TypoPeuplement — brief

> Rédigé par Claude avec `/imperatrice:brief` : à chaque question, une proposition de
> Claude que Pascal retient, corrige ou rejette ; relu par Pascal, puis critiqué par le
> `contradicteur`. Dans l'ordre : 1. ma réponse d'abord, dans les mots de Pascal ;
> 2. les questions et leurs propositions, ajustées aux réponses, puis le brief rédigé ;
> 3. la relecture de Pascal ; 4. la critique du contradicteur, puis les arbitrages de Pascal.
>
> Source des propositions : le brief de cadrage `docs/brief-typologie-peuplements.md`
> (21 novembre 2026) et les réponses de Pascal à `/demarrer` (23 novembre 2026).
> Brief relu par Pascal le 23 novembre 2026, critiqué par le contradicteur le même jour
> (3 bloquants, 5 importants, 7 mineurs) ; **tous les arbitrages ci-dessous ont été
> rendus par Pascal le 23 novembre 2026**, marqués « (arbitrage B1) », etc.

## Ma réponse d'abord (fiche n° 15)

> « je m'en passe »
>
> — Pascal, le 23 novembre 2026, dit avant toute proposition de Claude, recopié mot pour mot.

Note du contradicteur, reprise par Pascal (arbitrage M5) : tout le brief vient donc de
propositions, sans contrepoint écrit de Pascal.

## Le problème, et pour qui (Abstraction)

- **Problème** : il n'existe aucune carte du **type de peuplement** qui couvre la forêt
  française de façon homogène, d'erreur connue et raccordée aux typologies de gestion
  (arbitrage I2). Des cartes de **variables** existent (voir « Existant ») ; le type,
  lui, se relève « à dire d'expert », placette par placette : c'est coûteux, dépendant
  de l'observateur, et ce n'est pas une vérité terrain fiable. Le seul démonstrateur,
  le mémoire de J. Souchon (ONF, 2020), atteint 76 % de bonne classification **de la
  structure** au demi-hectare (85 à 90 % pour la composition, pas de score pour le type
  complet ; arbitrage B1), mais :
  - sur les seuls résineux et mixtes de montagne, en Savoie ;
  - avec le LiDAR seul ;
  - sans les essences ;
  - sans la hauteur potentielle, donc sans séparer peuplement jeune et peuplement chétif.

  Constaté dans ce rapport et par les aménagistes ONF consultés.
- **Bénéficiaires** :
  - d'abord les aménagistes et gestionnaires, en forêt publique (ONF) comme en forêt
    privée (CNPF, experts forestiers, coopératives), pour l'aide à la décision et la
    stratification d'inventaire ;
  - ensuite les organismes partenaires (IGN, INRAE et AgroParisTech pour la validation
    scientifique) et les rédacteurs des schémas régionaux de gestion sylvicole et des
    plans simples de gestion.
- **Coût complet aujourd'hui** : inconnu. Sans ordre de grandeur, la valeur du projet ne
  se démontre pas : l'estimer est une tâche de la phase de cadrage (arbitrage M5).

## Existant et positionnement (arbitrage I2)

| Existant | Ce qu'il apporte | Usage dans le projet |
|---|---|---|
| [Cartes LiDAR ONF](https://www.ign.fr/lidar-hd-foret), pixels de 700 m² | Surface terrière, diamètres, hauteur dominante, densité, structure | Chaîne à reprendre ou à étendre (ADR) ; contrôle |
| [FORMS](https://essd.copernicus.org/articles/15/4927/2023/) (LSCE, IGN, ONF, INRAE) | Hauteur nationale à 10 m, volume et biomasse à 30 m | Variable d'entrée ou de contrôle |
| [Open-Canopy](https://arxiv.org/pdf/2407.09392) (IGN, ENPC) | Hauteur de canopée à très haute résolution | Variable d'entrée ou de contrôle |
| [BD Forêt v3](https://www.data.gouv.fr/datasets/jeu-de-donnees-test-bd-foret-v3-juin-2026-beta) (bêta) | Essences dès 0,5 ha, 35 classes | Variable d'entrée, jamais vérité |
| [Vercors drômois](https://www.data.gouv.fr/datasets/parametres-forestiers-lidar-vercors-dromois-2021-2022-1) | Typologies de densité, capital, étagement ; familles de structure | Pilote et comparaison |

**Ce que TypoPeuplement ajoute** : le type de peuplement, la hauteur potentielle
(conditionnelle), la probabilité par pixel, la correspondance avec les typologies de
gestion. Le choix entre étendre la chaîne ONF et bâtir une chaîne nouvelle fait l'objet
d'une ADR.

## Ce que fait TypoPeuplement

- **En une phrase** : TypoPeuplement produit, pour toute forêt du masque forestier
  retenu et couverte par le LiDAR HD, en France hexagonale et en Corse (arbitrage I4),
  une carte du type de peuplement (composition, structure, capital) au pas de 25 m
  (support de calcul de 15 m de rayon ; arbitrage I1), calibrée par sylvoécorégion, à
  partir du LiDAR HD, de l'imagerie satellitaire et de la hauteur potentielle tirée du
  milieu, avec pour chaque pixel sa probabilité et son erreur de validation.
- **Les gestes sur le terrain** :
  1. **Avant la tournée**, le gestionnaire ouvre la carte de sa forêt dans son SIG
     (QGIS) : type prédit, probabilité, variables continues (surface terrière, part de
     gros bois, hauteur, écart à la hauteur potentielle).
  2. **Il stratifie son inventaire** sur les types prédits, en plaçant plus de
     placettes dans les zones « entre deux types » ou de faible confiance.
  3. **Sur le terrain**, il confronte le type prédit à ce qu'il voit ; la carte aide,
     son diagnostic décide.
  4. **Au bureau**, il passe du type prédit à la typologie locale par la table de
     correspondance, pour rédiger l'aménagement ou le plan simple de gestion.
  5. **Après une coupe, un dépérissement ou un nouveau vol**, l'opérateur rejoue la
     chaîne et la carte est mise à jour.
- **Ce qu'il produit** :
  - une carte des types de peuplements par SER, au pas de 25 m, avec probabilité du
    type par pixel et couche de confiance ;
  - les cartes des variables continues : essence principale, couvert, surface
    terrière, **surface terrière par classe de diamètre de 5 cm** (arbitrage B3), part
    de petits et gros bois, hauteur dominante ;
  - la carte de hauteur potentielle et son incertitude par pixel, **livrable
    conditionnel** (arbitrage I3, voir plus bas) ;
  - une couche « date et saison du vol » par pixel, et des classes « sans donnée »
    explicites : hors LiDAR, ZICAD, hors domaine de validité (arbitrage I4) ;
  - une clé de détermination et une table de correspondance avec les typologies de
    gestion : **les 8 types obligatoires du SRGS**, livrable obligatoire de chaque pilote
    (arbitrage B3), les guides de sylviculture, les directives et schémas régionaux
    d'aménagement ONF (arbitrage M4) ;
  - une fiche de validation par SER : matrices de confusion, précisions par type,
    intervalles de confiance, domaine de validité ;
  - le code de la chaîne, rejouable, et le protocole de placette, documentés.

## Ce qu'il ne fait pas (hors périmètre)

- **Pas de consignes de gestion** : ni choix des essences ni itinéraires sylvicoles ;
  la typologie reste descriptive.
- **Pas de remplacement du diagnostic de terrain** : aide à la décision et outil de
  stratification d'inventaire.
- **Pas de typologie des stations** : le milieu sert seulement à estimer la hauteur
  potentielle ; les typologies de stations existantes servent de contrôle, pas d'entrée.
- **Pas l'outre-mer**, qui appelle un projet distinct.
- **Pas de vérité terrain présumée** : ni la BD Forêt v3 ni les types relevés « à dire
  d'expert » ne sont tenus pour vrais.
- **Pas de forêt hors masque ou hors LiDAR HD** : ces zones sont en classe « sans
  donnée » (arbitrage I4).

## Contraintes connues

- **Grille** (arbitrage I1) : Lambert-93 (EPSG:2154), qui couvre l'hexagone et la Corse
  (arbitrage M2) ; pas de sortie de 25 m (4 pixels au quart d'hectare, 8 au
  demi-hectare), origine sur un multiple de 25 m ; support de calcul : fenêtre
  circulaire de 15 m de rayon centrée sur chaque nœud, identique à la placette. Valeurs
  sacrifiées : la simplicité d'un pavage sans chevauchement, la comparaison pixel à
  pixel avec les cartes ONF de 700 m². Rééchantillonnage depuis l'UTM de Sentinel-2
  défini une seule fois. À formaliser en ADR.
- **Placette de référence** : rayon de 15 m, soit 30 m de diamètre (environ 707 m²),
  validé par Pascal le 23 novembre 2026.
- **Placettes** (arbitrage B2) :
  - les placettes de l'inventaire forestier national ne sont publiées qu'au kilomètre
    près, et l'IGN ne donne pas d'accès aux coordonnées exactes (Pascal) : elles ne
    servent **qu'à valider à l'échelle d'agrégats** (SER, strate), jamais à calibrer au
    pixel. Leur protocole concentrique (cercles de 6, 9 et 15 m ; petits bois mesurés
    sur 113 m² seulement) est ramené à une placette équivalente de 15 m, avec sa variance ;
  - la calibration repose donc sur des placettes géolocalisées au mètre près (GNSS de
    précision ou recalage sur le modèle de hauteur) : les 1 016 placettes du mémoire de
    2020, les inventaires d'aménagement ONF, ceux des plans simples de gestion, et les
    placettes nouvelles du projet ;
  - jeu de calibration déséquilibré, types rares peu représentés : risque **aggravé**
    par l'absence de calibration IFN.
- **Seuils de diamètre** (arbitrage B3) : paramétrés **par référentiel typologique**
  (SRGS régional, guide de sylviculture, DRA/SRA ONF) **et par groupe d'essences**, pas
  par SER. Exemple : le SRGS Auvergne-Rhône-Alpes (2023) fixe la limite des gros bois à
  47,5 cm toutes essences, 42,5 cm admis en résineux quand une typologie l'utilise ;
  précomptage à 17,5 cm au SRGS, 7,5 cm à l'IFN.
- **Couverture** (arbitrage I4) :
  - masque forestier à choisir par ADR (définition IFN, ou Masque Forêt de l'IGN qui
    fonde la BD Forêt v3) ;
  - le LiDAR HD a des trous (ZICAD, couverture incomplète) et des vols à des dates et
    saisons différentes (date et saison du vol en variable) ;
  - pour chaque SER pilote, au moins un vol avec feuilles et un vol sans feuilles, ou un
    constat documenté que ce n'est pas possible.
- **Continuité** : pas de rupture aux limites de SER **ni aux limites de blocs LiDAR**
  (bande de transition pondérée ; arbitrages I4 et M7).
- **Hauteur potentielle** (arbitrage I3) :
  - **livrable conditionnel** : son propre critère de passage, une erreur maximale
    tolérée par SER fixée par le pilote ; à défaut, la clé s'en tient à la hauteur
    mesurée et le signale ;
  - les peuplements « adultes » de référence se définissent par l'âge ou l'indice de
    fertilité quand les placettes le portent, pas par le seul fait d'être fermés et hauts ;
  - une erreur d'essence se propage à la hauteur potentielle puis au type ;
  - piste à évaluer, sans engagement : la croissance en hauteur mesurée entre deux
    modèles de surface successifs ;
  - données de sol grossières : pH Digitalis à 58 % de variance expliquée ; même avec
    un sol mesuré, la fertilité n'est expliquée qu'à 49 à 64 % (Seynave et al., 2005 ;
    Bergès et al., 2006).
- **Diffusion** (arbitrage I5) : deux niveaux, une diffusion publique dégradée sur les
  forêts privées (comme dans le Vercors drômois) et un accès complet pour le
  propriétaire et le gestionnaire qu'il a mandaté. Qui décide de l'accès : à trancher
  par Pascal (ADR « diffusion »). La question juridique (ouverture par défaut des
  données publiques ; donnée personnelle une fois croisée avec le cadastre) est traitée
  au cadrage avec un juriste ou un délégué à la protection des données.
- **Outils** : logiciels libres et formats ouverts, pour le partage entre organismes
  (le rapport de 2020 utilisait Computree, R et ArcGIS). Plusieurs classifieurs sont
  comparés : forêts aléatoires, SVM, analyse discriminante (arbitrage M6).
- **Données** : BD Forêt v3 encore en bêta.
- **Découpage** (arbitrage M1) : 86 SER, plus 5 d'alluvions récentes ; 11 grandes
  régions écologiques, Corse comprise (GRECO K), plus une 12e d'alluvions récentes
  (GRECO L), à confirmer sur la fiche GeoData INRAE.

## Critères de passage (arbitrages B1 et M6)

- **Référence de validation** : le type calculé par la clé à partir des arbres mesurés
  de grappes de placettes au demi-hectare, indépendantes de la calibration ; jamais un
  type relevé « à dire d'expert ».
- **Métriques** : précision globale et précision par type (utilisateur et producteur),
  avec intervalles de confiance, par SER, selon les bonnes pratiques d'Olofsson et al.
  (2014).
- **Cadrage** : pilotes et porteur désignés, accès aux données acquis, coût actuel
  estimé, question juridique de la diffusion instruite.
- **Pilotes** : dans chaque SER pilote, la carte fait au moins aussi bien qu'une
  **base de comparaison** construite dans cette SER (par exemple une règle simple BD
  Forêt v3 + modèle de hauteur, ou la clé de 2020 rejouée sur LiDAR HD), feuillus
  compris ; **et** les cartes sont jugées utilisables sur le terrain par des
  gestionnaires, selon un protocole d'avis à écrire.
- **Généralisation** : une fiche de validation publiée pour chaque SER couverte.

## Risques

- **Carte prise pour une vérité** : couche de confiance obligatoire, formation des
  utilisateurs (arbitrage M6).
- **Trop peu de placettes dans les types rares** : échantillonnage stratifié, modèle de
  la grande région par défaut ; aggravé par l'absence de calibration IFN.
- **Hauteur potentielle trop incertaine** : repli sur la hauteur mesurée, signalé.

## Questions ouvertes (à trancher par Pascal)

- ~~Clé nationale unique ou clés par SER~~ : tranché par Pascal le 2026-11-23
  (ADR 0006 : type local d'abord, type générique national ensuite).
- La typologie doit-elle être reconnue par les SRGS pour servir dans les plans simples
  de gestion ?
- Porteur, cadre de financement.
- SER pilotes, et placettes existantes pour chacune.
- Le code de la chaîne ONF est-il partageable entre organismes ?
- ~~Qui décide de l'accès complet en forêt privée~~ : tranché par Pascal le 2026-11-23
  (ADR 0008 : remise sur demande par le CNPF ou l'ONF au rédacteur mandaté).
- Dégradation du produit public en forêt privée : deux niveaux ou aucune, après avis
  juridique au cadrage (ADR 0008).

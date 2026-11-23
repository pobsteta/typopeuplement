# Typologie de peuplements de la SER pilote H10 (Préalpes du Nord) — Vercors drômois

- **Propriétaire :** Pascal Obstétar
- **Consulté le :** 2026-11-22 (agent `acquereur`, missions 005 et 010)
- **Décision éclairée :** quelle clé de types (noms, seuils, limite des gros bois) la première carte réelle de H10 doit parler, pour que les gestionnaires du Vercors la lisent sans traduction. Depuis la mission 010, la clé GSM est transcrite dans la configuration (voir « Transcription dans la configuration (mission 010) » plus bas).
- **Fichier de configuration :** `inst/extdata/config/vercors-h10.json` (se charge ; **clé GSM transcrite : 16 types sur 20**, 4 non exprimables, voir plus bas).
- **Statut : transcrite, NON GELÉE.** Limite BM/GB tranchée par Pascal le 2026-11-22 (42,5 cm). Reste ouvert : sept ambiguïtés du logigramme, la convention d'arrondi des couverts, 4 types non exprimables dans la chaîne actuelle (X, P, A, T) et 2 types partiels (L, R). Rien de ce qui est ouvert n'est tranché ici.

## Sources (une seule par référence)

| # | Source | Version / date | Ce qu'on y prend |
|---|---|---|---|
| S1 | *Guide des Sylvicultures de Montagne, Alpes du Nord françaises* (GSM), Cemagref / ONF Rhône-Alpes (coord. X. Gauquelin, B. Courbaud), CRPF Rhône-Alpes ; PDF `auvergnerhonealpes.cnpf.fr/sites/socle/files/cnpf-old/402343_gsm_1_1.pdf` (147 p., fichier créé le 2013-10-23) | validé ONF 13/01/2006, CRPF 20/03/2006 (p. « Auteurs et collaborateurs ») | La **typologie de structure « MASSIF ALPIN »** : clé des structures de peuplements, 20 types |
| S2 | SRGS Auvergne-Rhône-Alpes, `draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf` (125 p.) | arrêté paru au JO du 14 décembre 2023 | Les **8 types de peuplements** des documents de gestion et le tableau des catégories de grosseur (p. 11-12 du PDF) |
| S3 | Fiche synthétique du jeu LiDAR (A. Hedel, ONF, 25/09/2024, 9 p.), `drive.opendata.craig.fr/.../2024_vercors_dromois/2024_Vercors_dromois_fiche_synthetique.pdf` (identique octet pour octet à `2026_Vercors_dromois_fiche_synthetique.pdf`, md5 1fd12a99…) | 2024-09-25 | La légende des couches `Typo_etage`, `Struc_fam`, `Compo1`, `Typo_cap`, `Typo_dens` (p. 4) |
| S4 | ONF, forêt domaniale de Léoncel (26), aménagement 2019-2038, `onf.fr/++amgt++A029043A/++zfiles++6915e996` (80 p.) | 2018-09 (carte), période 2019-2038 | Preuve d'usage : « Type de station et de peuplement : selon typologie GSM Alpes du Nord » (p. 60 imprimée, PDF p. 64) ; GSM 2006 cité en documents de référence (p. 4 imprimée, PDF p. 10) |

La couche `Typo_etage` n'a pas de fichier de légende (.qml, .sld, .csv) sur le serveur : le dossier ne contient que les rasters, l'emprise et la fiche (PROPFIND, profondeur 2). Les rasters n'embarquent ni table de couleurs ni noms de classes (métadonnées GDAL : licence, producteur, date). La seule légende est la fiche S3, p. 4.

## Ce que dit chaque source

### S3 — la couche `Typo_etage` et ses voisines (fiche p. 4, termes recopiés)

| Couche | Description | Valeurs documentées |
|---|---|---|
| `Typo_etage` | étagement des peuplements | 0 = non précomptable ; 1 = non étagé ; 2 = faiblement étagé ; 3 = étagé |
| `Struc_fam` | familles de structure | 0 = non précomptable ; 1 = lâche ; 10 = Ir (irrégulier) ; 20 = PB-BM (petits bois et/ou bois moyens) ; 30 = BM-GB (bois moyens et/ou gros bois) ; 40 = GB (gros bois) |
| `Compo1` | composition en familles d'essence 1 | 0 = non précomptable ; 1 = feuillus ; 2 = résineux ; 3 = mélange |
| `Typo_cap` | typologie de capital | 0 = non précomptable ; 1 = capital faible ; 2 = capital moyen ; 3 = capital fort |
| `Typo_dens` | typologie de densité | 0 = non précomptable ; 1 = clair ; 2 = densité moyenne ; 3 = dense |

**`Typo_etage` n'est pas une typologie de peuplements** : c'est un indicateur d'étagement à trois classes. Les seuils qui séparent ses classes ne sont pas publiés (ni dans la fiche, ni sur le serveur). Les familles de `Struc_fam` (5 documentées) ne sont pas les types du GSM.

Écart non expliqué : `Struc_fam.tif` contient 41 valeurs distinctes (0 à 10, 11 à 20, etc. : tous les entiers de 0 à 40), dont 35 ne figurent pas dans la légende (41 moins les 6 documentées : 0, 1, 10, 20, 30, 40) (ex. 11, 12, 21, 31), avec des effectifs notables (6 862 pixels à 11, 9 669 à 18, 9 458 à 19). La fiche dit « Utilisable sans pointillisme » et ne les explique pas. Lecture possible, non vérifiée : classes intermédiaires entre deux familles. À demander à l'auteur (ONF).

Décomptes recomptés sur les rasters téléchargés le 2026-11-22 (pixels de 26,6 m, hors nodata 255) : `Typo_etage` 0 : 59 631 ; 1 : 223 091 ; 2 : 95 588 ; 3 : 116 502 (total 494 812, égal à l'emprise de `ser.md`).

### S1 — la typologie de structure MASSIF ALPIN du GSM (celle des gestionnaires ONF/CRPF des Alpes du Nord)

Le GSM la décrit (p. 52 imprimée, PDF p. 28) : « La typologie de structure MASSIF ALPIN (document interne ONF) permet de décrire toutes les structures des peuplements des Alpes du Nord à l'aide de trois critères principaux : le couvert des strates, la surface terrière et la proportion de gros bois. » Le document interne ONF lui-même n'a pas été trouvé ; on lit ici le GSM, qui en publie la clé.

**Catégories de grosseur** (clé, p. 54 imprimée, PDF p. 29) : PB = 20 ; 25 · BM = 30 ; 35 ; 40 · GB = 45 ; 50 ; 55 ; 60 · TGB = 65 et +. Le GSM nomme ses classes par leur centre (p. 52 : « tiges pré-comptables de diamètre supérieur à 17,5 cm (classe 20 et +) »), d'où, **par lecture de cette convention (inférence, non écrite telle quelle)** : PB 17,5 à 27,5 ; BM 27,5 à 42,5 ; GB 42,5 à 62,5 ; TGB à partir de 62,5 cm.

**Critères** (p. 53) : Hₒ potentielle divisée en 4, chaque quart = une strate (strate 1 en haut). Couvert de chaque strate en dixièmes : « prépondérante (5/10 ou plus) » ; « moyenne (3/10 ou 4/10) » ; « déficitaire (2/10 ou moins) » ; « majoritaire (strate moyenne associée à 2 strates déficitaires) ». Seules les tiges précomptables comptent pour G ; pas de diamètre minimum pour le couvert des strates.

**Les 20 types** (clé p. 54-55, tableau récapitulatif p. 56-57 imprimées, PDF p. 29-30), par famille (9 familles) :

| Famille | Codes et libellés (recopiés) |
|---|---|
| espaces non boisés | X « Peuplement sans rôle de production ou de protection » · P « Pelouses d'altitude et prairies à usage agricole » · A « Autres espaces non boisés » |
| peuplements chétifs | CH « Peuplement chétif » (Hₒ potentielle < 15 m) |
| taillis | T « Taillis » (Hₒ potentielle > 15 m ; couvert taillis ≥ 2/3 ; couvert futaie < 1/3) |
| futaies riches en GB | 1GB « Peuplement à strate 1 prépondérante, riche en GB » · 2GB « Peuplement à strate 2 prépondérante, riche en GB » · 12GB « Peuplement à strates 1 et 2, riche en GB » (G ≥ 10 m²/ha ; G(GB+TGB) ≥ 60 %) |
| futaies à 2 étages | 13 « Peuplement à strates 1 et 3 » · 13GB « Peuplement à strates 1 et 3 riche en GB » |
| futaies adultes | 1 « Peuplement à strate 1 prépondérante » · 12 « Peuplement à strates 1 et 2 » (G ≥ 10 ; G(GB+TGB) < 60 %) |
| jeunes futaies | R « Régénération » · 3 « Peuplement à strate 3 prépondérante » · 23 « Peuplement à strates 2 et 3 » · 2 « Peuplement à strate 2 prépondérante » |
| futaies claires | L « Peuplement ouvert » · C « Peuplement clair » |
| futaies jardinées | J « Peuplement jardiné » · JGB « Peuplement jardiné riche en GB » |

Recomptage : 3 + 1 + 1 + 3 + 2 + 2 + 4 + 2 + 2 = **20 types**, et la clé en logigramme (p. 54-55) aboutit aux mêmes 20 codes (X, P, A, CH, T, L, R, 3, 1, 1GB, 2, 2GB, 12, 12GB, 13, 13GB, 23, C, J, JGB).

Seuils de la clé (p. 54-55) : Hₒ potentielle < 15 m → CH ; G < 10 m²/ha avec Hₒ potentielle > 15 m → L (couvert strates 3 et 4 < 5/10 ou moins de 800 tiges/ha), 3 (couvert strate 3 ≥ 5/10), R (couvert strate 4 ≥ 5/10 ou plus de 800 tiges/ha, et strate 3 < 5/10) ; G ≥ 10 m²/ha : types 1, 2, 3 (une ou deux strates prépondérantes, ou une majoritaire), 12, 13, 23 (une strate déficitaire), C (3 strates déficitaires), J (strates 1, 2 et 3 moyennes) ; suffixe GB quand G(GB+TGB) ≥ 60 % de G. Le logigramme (p. 54-55) se lit dans le texte du PDF (`pdftotext -layout`) ; la relecture de Pascal sur la page 55 reste la vérification de terrain.

Le GSM place les structures dans une démarche de **diagnostic de terrain** (relascope + estimation à l'œil des couverts) : l'estimation de G(GB+TGB) à ≥ 60 % est faite « à l'aide d'un relascope » en surface terrière, pas sur arbre pointé.

### S2 — le SRGS Auvergne-Rhône-Alpes (forêts privées)

8 types de peuplements, à rattacher obligatoirement (p. 11 imprimée) : « La futaie régulière », « La futaie irrégulière », « Le mélange futaie-taillis », « Le taillis simple ou fureté », « La peupleraie », « Les accrus », « Les landes, friches et maquis », « Le terrain nu à (re)boiser » (décompte : 8). Décrits par composition, capital et, en futaie irrégulière, la proportion PB / BM / GB. Ce n'est pas une clé à seuils : trop grossière pour la carte, mais c'est la langue des documents de gestion privés.

Catégories de grosseur (p. 12 imprimée) : PB classes 20 et 25 ; BM 30 à 45 ; GB 50 et + ; TGB 70 et +. Texte : « Par souci d'harmonisation, notamment pour les peuplements mixtes, la limite BM/GB est choisie à 47.5 cm pour toutes les essences (normalement 42.5 cm pour résineux : possible de la conserver quand des typologies sont utilisées) et celles des GB/TGB à 67.5 cm (au lieu de 62.5 cm pour résineux). »

## Écarts relevés entre sources (non tranchés)

1. **Limite BM/GB** (tranchée par Pascal le 2026-11-22 : 42,5 cm pour H10, fidèle au GSM ; l'écart reste documenté). Quatre lectures :
   - GSM (S1) : GB commence à la classe 45, soit 42,5 cm (inférence de la convention des classes) ; TGB à 62,5 cm.
   - SRGS (S2) : 47,5 cm pour toutes essences, « normalement 42.5 cm pour résineux : possible de la conserver quand des typologies sont utilisées » ; TGB à 67,5 cm. Le SRGS dit donc qu'il est possible de garder la valeur du GSM quand une typologie comme le GSM est utilisée.
   - Fiche du jeu LiDAR (S3, p. 1) : BM 27,5 à 42,5 ; GB 47,5 à 62,5 ; TGB ≥ 62,5 : un trou de 42,5 à 47,5 cm, et un mélange (BM/GB du GSM résineux, GB de SRGS ; TGB du GSM). Sa cohérence avec le modèle n'est pas établie.
   - Souchon (2020), règles du projet : 42,5 cm en Savoie et Pyrénées, 47,5 cm dans les Vosges ; rien de publié ici pour le Vercors.
2. **S1 ne couvre peut-être pas tout le Vercors drômois.** Le titre dit « Alpes du Nord françaises » ; la forêt domaniale de Léoncel (Drôme, plan 2019-2038) l'applique (S4). Pas trouvé : les directives locales d'aménagement du Vercors (DILAM) citées par un plan ONF 2007-2026 du Vercors, qui pourraient fixer une autre règle.
3. **Cibles différentes.** Le jeu LiDAR (S3) livre des familles (`Struc_fam`) et un étagement (`Typo_etage`), pas les 20 types du GSM ; aucun seuil publié pour ces classes.

## Ce qui ne passe pas dans la chaîne (état de la mission 005 ; mis à jour par la mission 010 plus bas)

Variables de la clé GSM, face aux variables de la chaîne (`variables_cibles` : G, part_resineux, part_pb, part_bm, part_gb ; plus `rapport_h`) :

| Variable de la typologie | Dans la chaîne ? |
|---|---|
| G (m²/ha) ; part des GB+TGB (≥ 60 %) | oui (`G`, `part_gb`, avec la limite BM/GB de la config) |
| **couvert des strates 1, 2 et 3** (par quart de Hₒ potentielle) | **non** : absent des variables cibles, des prédicteurs et des colonnes de pixels |
| **Hₒ potentielle en m** (seuil 15 m) | oui depuis 012 : `hpot` (sans enveloppe) est exposée à la clé (état 005 : seul `rapport_h` l'était) |
| **nombre de tiges par hectare** (seuil 800) | non |
| **part du taillis** (type T) | non |
| couvert total, rôle de production ou de protection (types X, P, A) | non (masque forestier et décision de gestion) |
| part de résineux | oui, mais **le GSM ne s'en sert pas** : sa clé est indépendante de l'essence |

Contrainte de format (levée par la mission 007) : le format de clé n'acceptait que des conjonctions ; il accepte maintenant les « ou » (`alternatives`). La clé de H10 n'est plus vide : voir la section suivante.

Convention d'arrondi : voir ci-dessous (ambiguïté 3).

## Transcription dans la configuration (mission 010)

`inst/extdata/config/vercors-h10.json`, SER H10, `cle.types` : **16 types exprimés** (CH, L, 3, R, 1, 1GB, 2, 2GB, 12, 12GB, 13, 13GB, 23, C, J, JGB) et **4 non exprimables** (X, P, A, T), listés dans `cle.non_exprimables` avec leur raison : 16 + 4 = **20 types du GSM**. Chaque type porte sa `source` (page du logigramme et du tableau) et, pour L et R, un `statut` « partiel ». Souplesses du jeu Vercors dans `jeux.vercors_onf.souplesse` : G 7,32 m²/ha ; part de résineux 0,199 ; part de gros bois 0,163 (EQM de la fiche ONF, p. 1, vérifiées à la source : G « 7.32 (25%) », % F/R « 19.9 (40%) », P100GGB « 16.28 (49%) » ; décision de Pascal, 2026-11-22). La limite BM/GB à 42,5 cm est écrite pour H10 (`seuils_diametre.bm_gb_cm`).

### Lecture du GSM, pages

| Élément | Page du GSM (imprimée ; PDF) |
|---|---|
| Classes de couvert : prépondérante ≥ 5/10, moyenne 3/10 ou 4/10, déficitaire ≤ 2/10 ; une strate moyenne avec 2 déficitaires = majoritaire | p. 54 (encadré) ; PDF p. 29 ; aussi p. 53, PDF p. 28 (couvert estimé « en 1/10 de recouvrement du sol ») |
| Couvert total ≥ 1/10 (espaces boisés) ; Hₒ potentielle < 15 m (CH) ; Hₒ potentielle > 15 m ; G < 10 m²/ha ; L, 3, R | p. 54 ; PDF p. 29 |
| G ≥ 10 m²/ha ; types 1, 1GB, 2, 2GB, 3, 12, 12GB, 13, 13GB, 23, C, J, JGB ; G(GB+TGB) < 60 % / ≥ 60 % | p. 55 ; PDF p. 29 |
| Tableau récapitulatif : X, P, A, CH, T | p. 56 ; PDF p. 30 |
| Tableau récapitulatif : tous les types de futaies | p. 57 ; PDF p. 30 |

Le logigramme est lu dans le texte du PDF (`pdftotext -layout`). Les classes de couvert **par strate** du tableau (p. 57) ne sont qu'en couleurs (violet foncé = prépondérante, moyen = moyenne, clair = déficitaire, « q » = quelconque) : elles ont été lues sur l'image rendue de la page, et recoupées avec le logigramme (voir ambiguïtés 1, 2 et 5 pour les écarts).

### Variables de la chaîne utilisées

`c1_hpot` à `c4_hpot` (couverts des strates, référence `hpot`, provisoire, mission 008), `G`, `part_gb` (GB + TGB), `hpot`, `couvert`. Rien d'autre.

Variables du GSM **absentes** de la chaîne : le nombre de tiges par hectare `N` (seuil de 800 pour L et R ; le jeu ONF a un raster `N`, mais `couches_onf()` ne le lit pas), la part du taillis (T), le rôle de production ou de protection (X), l'usage du sol (P, A). **Câblage à vérifier :** `h_pot` est calculée par la chaîne, mais seule `rapport_h` est passée à la clé (`R/chaine.R`, lignes 78 et 398-402) ; une condition sur `h_pot` (CH et les 15 autres types) demande donc que la chaîne la fournisse à la clé, sans quoi « variable absente pour la clé ». De même les `c*_hpot` ne sont pas encore branchés dans la chaîne (mineur de 008, sans mission). La config se charge ; son exécution sur la chaîne attend ce câblage.

### Types non exprimables

| Code | Libellé (recopié) | Raison |
|---|---|---|
| X | Peuplement sans rôle de production ou de protection | décision de gestion, pas une mesure |
| P | Pelouses d'altitude et prairies à usage agricole | espace non boisé ; P ou A demande l'usage du sol |
| A | Autres espaces non boisés | idem |
| T | Taillis (couvert taillis ≥ 2/3, couvert futaie < 1/3) | part du taillis absente |

**Notice : taillis et peuplements sans rôle de production non détectés (types X et T non exprimables).**

Conséquence : ces types sont testés **avant** les autres dans le logigramme (X en tête, puis P/A, T après CH). Sans eux, un taillis ou un peuplement sans rôle tombe dans l'un des 16 types exprimés. Le couvert total < 1/10 (espaces non boisés) n'est transcrit que comme absence du « couvert ≥ 0,1 » qui conditionne les 16 types : un pixel non boisé n'a donc aucun type (hors clé), faute de P et de A.

### Conventions prises (signalées, à trancher)

- **Couverts en parts** : le GSM estime le couvert en dixièmes entiers et ne dit pas comment arrondir. Convention prise : dixième le plus proche, donc **déficitaire c < 0,25 ; moyenne 0,25 ≤ c < 0,45 ; prépondérante c ≥ 0,45**. **Défaut 0,25 / 0,45 (provisoire).** Alternatives : lecture littérale du GSM (déficitaire ≤ 0,2, prépondérante ≥ 0,5, soit coupures à 0,2 / 0,5) ; troncature (coupures à 0,3 / 0,5). Aucune n'est écrite dans le GSM. **À trancher.**
- **Valeur 15 m** : CH si Hₒ potentielle < 15 m, les autres si > 15 m ; 15 n'est dans aucun cas. Prise : `hpot ≥ 15` pour les autres, sur la hauteur potentielle sans enveloppe (variable `hpot`, exposée par la chaîne depuis 012), comme les strates. **À trancher.**
- **Couvert total** : « couvert total ≥ 1/10 » transcrit par `couvert ≥ 0,1` (taux de couvert du jeu ONF) ; équivalence avec le couvert total du GSM non vérifiée.
- **Souplesses** : aucune sur `c1_hpot` à `c4_hpot`, `hpot`, `couvert` (conditions dures) ; G, part_resineux, part_gb ont celles de la fiche ONF. Le mélange dur/souple est un effet de ce qui est donné ; **à trancher.** `part_resineux` n'est pas utilisée par la clé GSM.
- **Seuil 60 %** : `part_gb ≥ 0,6` pour « GB », `< 0,6` sinon (limites écrites ainsi dans le GSM). La part de gros bois du jeu ONF est à 47,5 cm, très gros bois inclus (intérim, drapeau `gb_interim`).
- **Exclusivité** : la clé du GSM est un arbre de décision ordonné ; transcrite à plat, chaque type porte toutes les conditions qui l'excluent des autres. Contrôle fait : sur une grille de 216 combinaisons (couverts, G, part_gb), avec souplesse nulle, **un seul type** est vrai par combinaison pour les 16 types exprimés.

### Ambiguïtés du logigramme, posées à Pascal (non tranchées par l'acquéreur, sauf mention)

1. **Types 2 et 2GB, tableau p. 57 ou logigramme p. 55 ?** Le logigramme dit « strate 2 prépondérante ou majoritaire **et strate 1 non prépondérante** » (strate 1 moyenne ou déficitaire). Le tableau montre, pour la strate 2 prépondérante, la strate 1 **moyenne** seulement ; une strate 1 déficitaire avec une strate 2 prépondérante n'y figure pas. Transcrit : le logigramme (strate 1 non prépondérante). À confirmer.
2. **Types 3, tableau et logigramme.** Le logigramme exige « strates 1 et 2 non prépondérantes » ; le tableau met « quelconque » pour les strates 1 et 2 quand la strate 3 est prépondérante (le type 1 ou 2 l'emporte alors dans l'ordre du logigramme). Transcrit : le logigramme.
3. **Arrondi des classes de couvert** (voir conventions) : défaut 0,25 / 0,45 (provisoire) ; alternatives : lecture littérale 0,2 / 0,5, troncature 0,3 / 0,5.
4. **Valeur 15 m** (voir conventions).
5. **L et R : « couvert strates 3 et 4 » du logigramme (p. 54) contre « couvert strates [3+4] » du tableau (p. 57).** Le tableau écrit « [3 + 4] < 5/10 » pour L et « [3 + 4] > 5/10 » pour R (strict, donc 5/10 exactement n'est dans aucun des deux) ; le logigramme écrit « strates 3 et 4 < 5/10 », « strate 3 ≥ 5/10 », « strate 4 ≥ 5/10 et strate 3 < 5/10 ». Le couvert de la strate « [3+4] » (les deux réunies ?) n'est pas défini dans le GSM. Transcrit : le logigramme, strates 3 et 4 séparées.
6. **L et R : « ou plus de 800 tiges/ha », « ou moins de 800 tiges/ha ».** La branche de densité est un « ou » : un pixel peut satisfaire à la fois la branche de couvert de L et celle de densité de R (cas c4 < 5/10 et N > 800, ou l'inverse), ou être à la fois L et 3 (c3 ≥ 5/10 et N < 800). Le GSM ne dit pas laquelle l'emporte, ni si le « ou » est exclusif. De plus N est lue par la chaîne depuis 012 (tiges/ha), mais la clé ne la cite pas. Transcrit : **la branche du couvert seulement** (suffisante si le « ou » est inclusif), types marqués « partiel ». Pascal tranche : garder L et R partiels, ou les marquer non exprimables tant que N n'est pas branchée et la règle fixée.
7. **Ordre des tests X et T.** X (rôle faible) est testé avant tout, T après CH, dans le logigramme ; non exprimables ici, leur absence change le type attribué aux pixels qu'ils auraient absorbés (voir conséquence plus haut).

### Trois points au sol (clé GSM)

1. Un peuplement à une seule strate haute dense (strate 1 à 6/10, G 25 m²/ha, 70 % de GB) : 1GB, mais avec un couvert mesuré de 0,47 la convention d'arrondi (0,45 ou 0,5) décide entre « strate 1 prépondérante » (1GB) et « strate 1 moyenne » (un autre type selon les strates 2 et 3) : à voir sur le terrain.
2. Un peuplement de hêtres sous grands sapins (strates 1 et 3 moyennes, strate 2 déficitaire) : 13 ou 13GB, ce que la couche `Typo_etage = 3` ne distingue pas.
3. Une clairière de régénération (G < 10, strate 4 à 6/10, strate 3 à 2/10) : R si le couvert de la strate 4 est mesuré par `c4_hpot` ; vérifier que les tiges « plus de 800 tiges/ha » (branche omise) ne la rangent pas ailleurs.

## Questions à Pascal (mission 005, mises à jour)

1. ~~Limite BM/GB pour H10 : 42,5 ou 47,5 cm ?~~ **Tranchée par Pascal le 2026-11-22 : 42,5 cm**, fidèle au GSM Alpes du Nord. La part de gros bois de l'ONF (47,5 cm, très gros bois inclus) est un intérim déclaré.
2. **Quelle typologie pour la carte de H10 ?** (tranchée : les 20 types du GSM, cap du 2026-11-22 ; les options ci-dessous restent pour mémoire)
   - (a) les 20 types du GSM (langue des gestionnaires ONF/CRPF) : il faut alors ajouter à la chaîne le couvert des strates (et accepter les « ou » dans la clé) ; changement de périmètre ;
   - (b) les familles du jeu LiDAR (`Struc_fam`, `Compo1`, …) : déjà cartographiées, mais sans seuils publiés ; à demander à A. Hedel (ONF) ;
   - (c) les 8 types du SRGS : trop grossiers.
3. Faut-il interroger l'ONF (A. Hedel) sur les classes de `Struc_fam` absentes de la légende et sur les seuils de `Typo_etage` ?

## Trois points au sol

1. Un peuplement de hêtre-sapin à beaucoup de tiges de 43 à 47 cm : GB ou BM ? C'est là que 42,5 et 47,5 donnent deux cartes différentes.
2. Un peuplement à deux étages nets (grands sapins au-dessus, hêtres en dessous) : type 13 du GSM, ce que `Typo_etage = 3` ne dit pas.
3. Un peuplement jardiné de Léoncel ou de Lente (strates 1, 2, 3 moyennes) : J / JGB, à comparer à `Struc_fam = 10` (Ir) sur le raster.

## Question de contrôle

Quelle décision cette donnée va-t-elle éclairer ? **Le choix de la typologie et de la limite BM/GB de la première carte réelle de H10.**

## Liste de contrôle

Mission 005 (mise à jour par la mission 010) :

1. Chiffre / source / page / version / date : passé pour S1 à S4 (pages imprimées et PDF indiquées). Réserve restante : limite GB du GSM à 42,5 cm = inférence de la convention des classes, signalée ; décidée par Pascal pour H10.
2. Décomptes : 20 types GSM (recompté), 9 familles, 8 types SRGS, 5 couches documentées, 494 812 pixels. Passé.
3. Termes exacts : recopiés (libellés, seuils). Le logigramme se lit dans le texte du PDF ; les classes de couvert par strate du tableau p. 57 ont été lues sur image (couleurs).
4. Statut : transcrite, **non gelée** ; ambiguïtés et conventions ouvertes (voir mission 010).

Mission 010 :

1. Chaque seuil a sa page : passé (champ `source` de chaque type, tableau « Lecture du GSM, pages »).
2. Les 20 codes comptés : 16 dans `cle.types` + 4 dans `cle.non_exprimables` = 20 ; chargement vérifié (16 types lus).
3. Termes recopiés de la source : passé pour les libellés et les conditions.
4. Ambiguïtés du logigramme posées, non tranchées : passé pour les sept ; les transcriptions prises par défaut sont dites (ambiguïtés 1, 2, 5, 6).
5. Statut dit tel qu'il est : transcrite, non gelée ; câblage `hpot` fait par 012 ; `N` lue mais non citée par la clé.

## Journal (proposé)

`2026-11-22 · acquereur · 005 · typologie H10 : GSM Alpes du Nord (20 types, couvert des strates) trouvée, non exprimable dans la chaîne actuelle ; limite BM/GB 42,5 / 47,5 non tranchée ; config H10 chargeable à clé vide`

`2026-11-22 · acquereur · 010 · clé GSM transcrite dans vercors-h10.json : 16 types sur 20 (L et R partiels), X, P, A, T non exprimables ; limite BM/GB 42,5 cm, souplesses du jeu ONF (G 7,32 ; part_resineux 0,199 ; part_gb 0,163) ; 7 ambiguïtés du logigramme et l'arrondi des couverts (0,25 / 0,45 prise) à trancher par Pascal ; non gelée`

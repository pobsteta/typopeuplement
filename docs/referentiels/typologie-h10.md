# Typologie de peuplements de la SER pilote H10 (Préalpes du Nord) — Vercors drômois

- **Propriétaire :** Pascal Obstétar
- **Consulté le :** 2026-11-22 (agent `acquereur`, mission 005)
- **Décision éclairée :** quelle clé de types (noms, seuils, limite des gros bois) la première carte réelle de H10 doit parler, pour que les gestionnaires du Vercors la lisent sans traduction.
- **Fichier de configuration :** `inst/extdata/config/vercors-h10.json` (se charge ; **clé de types vide**, voir « Ce qui ne passe pas dans la chaîne »).
- **Statut : NON PRÊT à geler.** Deux décisions de Pascal ouvertes (limite BM/GB ; clé à exprimer ou à faire évoluer). Rien n'est tranché ici.

## Sources (une seule par référence)

| # | Source | Version / date | Ce qu'on y prend |
|---|---|---|---|
| S1 | *Guide des Sylvicultures de Montagne, Alpes du Nord françaises* (GSM), Cemagref / ONF Rhône-Alpes (coord. X. Gauquelin, B. Courbaud), CRPF Rhône-Alpes ; PDF `auvergnerhonealpes.cnpf.fr/sites/socle/files/cnpf-old/402343_gsm_1_1.pdf` (147 p., fichier créé le 2013-10-23) | validé ONF 13/01/2006, CRPF 20/03/2006 (p. « Auteurs et collaborateurs ») | La **typologie de structure « MASSIF ALPIN »** : clé des structures de peuplements, 20 types |
| S2 | SRGS Auvergne-Rhône-Alpes, `draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf` (125 p.) | arrêté paru au JO du 14 décembre 2023 | Les **8 types de peuplements** des documents de gestion et le tableau des catégories de grosseur (p. 11-12 du PDF) |
| S3 | Fiche synthétique du jeu LiDAR (A. Hedel, ONF, 25/09/2024, 9 p.), `drive.opendata.craig.fr/.../2024_vercors_dromois/2024_Vercors_dromois_fiche_synthetique.pdf` (identique octet pour octet à `2026_Vercors_dromois_fiche_synthetique.pdf`, md5 1fd12a99…) | 2024-09-25 | La légende des couches `Typo_etage`, `Struc_fam`, `Compo1`, `Typo_cap`, `Typo_dens` (p. 4) |
| S4 | ONF, forêt domaniale de Léoncel (26), aménagement 2019-2038, `onf.fr/++amgt++A029043A/++zfiles++6915e996` (80 p.) | 2018-09 (carte), période 2019-2038 | Preuve d'usage : « Type de station et de peuplement : selon typologie GSM Alpes du Nord » (p. 60 imprimée) ; GSM 2006 cité en documents de référence (p. 12) |

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

Seuils de la clé (p. 54-55) : Hₒ potentielle < 15 m → CH ; G < 10 m²/ha avec Hₒ potentielle > 15 m → L (couvert strates 3 et 4 < 5/10 ou moins de 800 tiges/ha), 3 (couvert strate 3 ≥ 5/10), R (couvert strate 4 ≥ 5/10 ou plus de 800 tiges/ha, et strate 3 < 5/10) ; G ≥ 10 m²/ha : types 1, 2, 3 (une ou deux strates prépondérantes, ou une majoritaire), 12, 13, 23 (une strate déficitaire), C (3 strates déficitaires), J (strates 1, 2 et 3 moyennes) ; suffixe GB quand G(GB+TGB) ≥ 60 % de G. Les cases de la clé sont à recopier de l'image, non du texte : à relire par Pascal sur la page 55 du guide avant tout usage.

Le GSM place les structures dans une démarche de **diagnostic de terrain** (relascope + estimation à l'œil des couverts) : l'estimation de G(GB+TGB) à ≥ 60 % est faite « à l'aide d'un relascope » en surface terrière, pas sur arbre pointé.

### S2 — le SRGS Auvergne-Rhône-Alpes (forêts privées)

8 types de peuplements, à rattacher obligatoirement (p. 11 imprimée) : « La futaie régulière », « La futaie irrégulière », « Le mélange futaie-taillis », « Le taillis simple ou fureté », « La peupleraie », « Les accrus », « Les landes, friches et maquis », « Le terrain nu à (re)boiser » (décompte : 8). Décrits par composition, capital et, en futaie irrégulière, la proportion PB / BM / GB. Ce n'est pas une clé à seuils : trop grossière pour la carte, mais c'est la langue des documents de gestion privés.

Catégories de grosseur (p. 12 imprimée) : PB classes 20 et 25 ; BM 30 à 45 ; GB 50 et + ; TGB 70 et +. Texte : « Par souci d'harmonisation, notamment pour les peuplements mixtes, la limite BM/GB est choisie à 47.5 cm pour toutes les essences (normalement 42.5 cm pour résineux : possible de la conserver quand des typologies sont utilisées) et celles des GB/TGB à 67.5 cm (au lieu de 62.5 cm pour résineux). »

## Écarts relevés entre sources (non tranchés)

1. **Limite BM/GB.** Quatre lectures :
   - GSM (S1) : GB commence à la classe 45, soit 42,5 cm (inférence de la convention des classes) ; TGB à 62,5 cm.
   - SRGS (S2) : 47,5 cm pour toutes essences, « normalement 42.5 cm pour résineux : possible de la conserver quand des typologies sont utilisées » ; TGB à 67,5 cm. Le SRGS autorise donc expressément de garder la valeur du GSM quand la typologie GSM est utilisée.
   - Fiche du jeu LiDAR (S3, p. 1) : BM 27,5 à 42,5 ; GB 47,5 à 62,5 ; TGB ≥ 62,5 : un trou de 42,5 à 47,5 cm, et un mélange (BM/GB du GSM résineux, GB de SRGS ; TGB du GSM). Sa cohérence avec le modèle n'est pas établie.
   - Souchon (2020), règles du projet : 42,5 cm en Savoie et Pyrénées, 47,5 cm dans les Vosges ; rien de publié ici pour le Vercors.
2. **S1 ne couvre peut-être pas tout le Vercors drômois.** Le titre dit « Alpes du Nord françaises » ; la forêt domaniale de Léoncel (Drôme, plan 2019-2038) l'applique (S4). Pas trouvé : les directives locales d'aménagement du Vercors (DILAM) citées par un plan ONF 2007-2026 du Vercors, qui pourraient fixer une autre règle.
3. **Cibles différentes.** Le jeu LiDAR (S3) livre des familles (`Struc_fam`) et un étagement (`Typo_etage`), pas les 20 types du GSM ; aucun seuil publié pour ces classes.

## Ce qui ne passe pas dans la chaîne (à dire, pas à inventer)

Variables de la clé GSM, face aux variables de la chaîne (`variables_cibles` : G, part_resineux, part_pb, part_bm, part_gb ; plus `rapport_h`) :

| Variable de la typologie | Dans la chaîne ? |
|---|---|
| G (m²/ha) ; part des GB+TGB (≥ 60 %) | oui (`G`, `part_gb`, avec la limite BM/GB de la config) |
| **couvert des strates 1, 2 et 3** (par quart de Hₒ potentielle) | **non** : absent des variables cibles, des prédicteurs et des colonnes de pixels |
| **Hₒ potentielle en m** (seuil 15 m) | partiel : `h_pot` est calculée mais seul `rapport_h` est donné à la clé |
| **nombre de tiges par hectare** (seuil 800) | non |
| **part du taillis** (type T) | non |
| couvert total, rôle de production ou de protection (types X, P, A) | non (masque forestier et décision de gestion) |
| part de résineux | oui, mais **le GSM ne s'en sert pas** : sa clé est indépendante de l'essence |

Contrainte de format : le format de clé de `exemple.json` n'accepte que des conjonctions de conditions min/max par type. La clé GSM contient des « ou » (« strate 1 prépondérante **ou** majoritaire ») : deux types distincts de la chaîne ne peuvent pas porter le même code. C'est pourquoi `vercors-h10.json` a `"types": []` pour H10, et non une clé d'exemple qui se ferait passer pour la typologie locale.

Convention d'arrondi à définir si la clé était exprimée : les couverts du GSM sont des entiers en dixièmes ; la frontière « 2/10 ou moins » / « 3/10 » ne tombe pas sur un nombre sans choix (0,25 ou 0,3).

## Questions à Pascal

1. **Limite BM/GB pour H10 : 42,5 ou 47,5 cm ?** Sources : GSM (42,5 par les classes, p. 54), SRGS 2023 (47,5 p. 12, avec la possibilité de garder 42,5 si typologie GSM), fiche du jeu (47,5 avec trou 42,5 à 47,5). La valeur reste **à trancher** (le JSON hérite 42,5 du socle national en attendant, sans que ce soit une décision). Pose-t-on la question aux gestionnaires ONF/CNPF du Vercors avant de trancher (mission : « Pascal leur pose le fait ») ?
2. **Quelle typologie pour la carte de H10 ?**
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

1. Chiffre / source / page / version / date : passé pour S1 à S4 (pages imprimées et PDF indiquées). Sauf : limite GB du GSM à 42,5 cm = inférence, signalée ; codes de la clé lus sur l'image des p. 54-57, non sur le texte.
2. Décomptes : 20 types GSM (recompté deux fois), 9 familles, 8 types SRGS, 5 couches documentées, 494 812 pixels. Passé.
3. Termes exacts : recopiés (libellés, seuils), sauf lecture de l'image du logigramme à relire.
4. Statut : **non prêt à geler** ; deux décisions de Pascal ouvertes.

## Journal (proposé)

`2026-11-22 · acquereur · 005 · typologie H10 : GSM Alpes du Nord (20 types, couvert des strates) trouvée, non exprimable dans la chaîne actuelle ; limite BM/GB 42,5 / 47,5 non tranchée ; config H10 chargeable à clé vide`

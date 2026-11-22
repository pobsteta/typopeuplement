# Référentiel des SER et des GRECO

- **Propriétaire :** Pascal Obstétar
- **Consulté le :** 2026-11-22 (agent `acquereur`, mission 002)
- **Décision éclairée :** déduire la sylvoécorégion (SER) d'une AOI sans inventer de code, et savoir de quelle grande région (GRECO) elle hérite quand sa SER manque de placettes (brief, « Déclinaison par sylvoécorégion »).
- **Fichier produit :** `inst/extdata/ser/ser_codes.csv` (91 lignes + en-tête, UTF-8, séparateur virgule).
  Colonnes : `code_ser`, `nom_ser`, `code_greco`, `nom_greco`, `type_ser` (`principale` | `alluvions_recentes`), `geometrie_wfs_inrae` (`oui` | `non`).
- **Géométries : non copiées.** L'export complet de la couche pèse 28,3 Mo en GeoJSON (> 20 Mo) ; elles restent chez INRAE (voir « Utilisation »).

## Sources (une seule pour chaque référence)

| Référence | Source unique | Emplacement exact | Version / date | Consultée |
|---|---|---|---|---|
| Codes et noms des 86 SER principales | GeoData INRAE, couche `inrae:ser_l93` (origine IGN), fiche `67044273-ec7e-4487-afe7-fa5dda5fa2bd` | WFS `https://geodata.inrae.fr/geoserver/inrae/ows`, attributs `codeser` et `NomSER` ; fiche : titre « SylvoEcoRegions », date de création 2002-12-31, date de révision 2024-11-05, CRS EPSG:2154 | fiche révisée le 2024-11-05 ; WFS interrogé le 2026-11-22 (`numberMatched` = 473 entités) | 2026-11-22 |
| Noms des GRECO A à K | IGN, Inventaire forestier, « Fiches descriptives des GRECO et des SER » | `https://inventaire-forestier.ign.fr/spip.php?article773`, intitulés « GRECO A : … » à « GRECO K : Corse » ; fiches fournies en 2013 selon la page | page consultée le 2026-11-22 (pied de page © IGN 2025) | 2026-11-22 |
| GRECO L et les 5 SER d'alluvions L1 à L5 | IGN, fiche `https://inventaire-forestier.ign.fr/IMG/pdf/GRECO_L.pdf` | p. 1 : texte « La GRECO L a été divisée en 5 SER » et légende de la carte (L1 à L5) | fiche non datée (14 p.) ; page IGN 2025 | 2026-11-22 |
| Contour des forêts du Vercors drômois | ONF – CNPF – Département de la Drôme (producteur ONF), data.gouv.fr, jeu « Paramètres forestiers LiDAR - Vercors drômois - 2021-2022 » ; CRAIG | fichier `donnees_thematiques/foret/2024_vercors_dromois/01_Emprise/Emprise_Vercors_dromois_2024_dendrolidar_L93.gpkg` sur `drive.opendata.craig.fr` ; rasters `02_Donnees_dendro/Typo_etage.tif`, `Tx_couv.tif`, `H0_lidar.tif` ; fiche `2024_Vercors_dromois_fiche_synthetique.pdf` p. 1 | produit 2024-09-25 (étiquettes des rasters) ; jeu modifié le 2026-09-30 ; Licence Ouverte v2.0 | 2026-11-22 |
| Chefs-lieux de communes (positions de contrôle) | IGN, ADMIN EXPRESS COG carto, édition 2025 | WFS `https://data.geopf.fr/wfs/ows`, couche `ADMINEXPRESS-COG-CARTO-PE.2025:chef_lieu_de_commune` (et `:commune`) | édition 2025 | 2026-11-22 |

**Contrôle croisé (deux sources indépendantes pour l'observation) :**
1. La liste des 86 codes SER de la page IGN (fascicules « SER A 11 » … « SER K 13 ») est identique à celle du WFS INRAE : 86 codes de part et d'autre, aucune différence dans les deux sens.
2. Le fichier `inst/extdata/ser.csv` de nemeton (86 lignes) donne les mêmes codes, les mêmes noms et la même GRECO (première lettre du code) que le WFS : aucune différence.

## Décomptes (commandes relancées sur le fichier final avant rendu)

| Quoi | Nombre | Détail |
|---|---|---|
| SER principales | **86** | A 6, B 21, C 8, D 2, E 2, F 12, G 14, H 6, I 5, J 7, K 3 |
| SER d'alluvions récentes | **5** | L1, L2, L3, L4, L5 |
| Lignes du CSV | 91 | 86 + 5, 91 codes distincts |
| GRECO portant des SER principales | **11** | A à K, **la Corse est la GRECO K** (3 SER : K11, K12, K13) |
| GRECO au total | 12 | A à K, plus L « Alluvions récentes » |

Entités du WFS : 473 (plusieurs polygones par SER, les grandes SER sont éclatées) ; 2 entités portent le code `-1` sans nom (hors SER), ignorées, comme le fait déjà `localiser_ser()` de nemeton.

## Écarts à signaler (aucun corrigé en silence)

1. **« 11 grandes régions plus la Corse » (brief) ≠ sources.** Dans les sources, les 11 GRECO A à K **comprennent** la Corse (K). Le « plus la Corse » du brief la compte donc deux fois, ou vise la GRECO L d'alluvions. À trancher par Pascal ; le CSV suit les sources (11 + L).
2. **Les 5 SER d'alluvions ne sont pas dans la couche WFS** : 86 codes seulement, aucun polygone L1 à L5, et pas non plus dans `ser.csv` de nemeton. Leurs codes et noms viennent de la seule fiche IGN `GRECO_L.pdf` (légende de la carte, p. 1). Conséquence : une AOI en vallée alluviale reçoit la SER encaissante (A à K), pas L1 à L5, tant que leurs contours ne sont pas acquis. Leurs contours (BD Carthage, agences de l'eau) ne sont pas dans la couche INRAE ; source à chercher si la clé alluviale devient nécessaire.
3. **Noms L1 à L5 lus sur une image** (légende de la carte du PDF, relue à 220 dpi) : le texte du PDF ne les contient pas, sauf L4 « Adour-Garonne » et L5 « Rhône-Méditerranée-Corse ». Une relecture par Pascal est utile.
4. **Fiche INRAE : « 86 SER en France métropolitaine »** : ces 86 incluent la Corse (K11 à K13). « Hexagonale » du brief est donc un raccourci : la Corse en fait partie du décompte.

5. **Surface forestière du jeu Vercors drômois** : 35 095 ha (fiche synthétique, p. 1) contre 35 010,9 ha (emprise livrée, recalculée) : 84 ha (0,24 %), cause non établie.
6. **Seuil de gros bois du jeu Vercors drômois** : la fiche synthétique (p. 1) classe GB à 47,5 ≤ Ø < 62,5 cm (PB 17,5 à 27,5 ; BM 27,5 à 42,5 ; TGB ≥ 62,5), donc la limite des gros bois à 47,5 cm ; les règles du projet donnent 42,5 cm en Savoie et dans les Pyrénées et 47,5 cm dans les Vosges. À rapprocher de la typologie locale quand la SER pilote sera choisie (hors mission 002, signalé).

## Vercors drômois (SER pilote) — rattachement sur le contour réel des forêts

*Refait à l'aller-retour 1/3 (2026-11-22) : la version précédente testait des points mal placés et un quadrillage sur le rectangle ; elle plaçait à tort La Chapelle-en-Vercors et Lente en H30. Elle est remplacée.*

**Contour des forêts utilisé.** Jeu « Paramètres forestiers LiDAR – Vercors drômois – 2021-2022 » (producteur ONF ; ONF – CNPF – Département de la Drôme ; data.gouv.fr, page `parametres-forestiers-lidar-vercors-dromois-2021-2022-1`, modifié le 2026-09-30, Licence Ouverte v2.0). Couche retenue : `01_Emprise/Emprise_Vercors_dromois_2024_dendrolidar_L93.gpkg` (786 432 octets, EPSG:2154, daté du 2026-09-29 sur le serveur CRAIG `drive.opendata.craig.fr`), un multipolygone de 608 parties, 35 010,9 ha. C'est bien le contour des forêts et non un rectangle : l'emprise rectangulaire des rasters couvre environ 270 000 ha ; les pixels valides des rasters `Typo_etage.tif`, `Tx_couv.tif` et `H0_lidar.tif` (494 812 pixels de 26,6 m, soit 35 010,9 ha) coïncident avec ce polygone. La fiche synthétique du jeu (A. Hedel, ONF, 25/09/2024, p. 1) annonce « Surface forestière : 35 095 ha » : écart de 84 ha (0,24 %) avec l'emprise livrée, non expliqué (arrondi ou mise à jour du masque ; question possible au producteur). Étendue réelle de l'emprise, calculée sur la géométrie en WGS84 : 5,133 à 5,822 °E et 44,639 à 45,086 °N ; forêts en H30 : 5,294 à 5,822 °E et 44,639 à 44,904 °N (relecteur, 2026-11-22, R sf).

**Méthode.** Intersection de ce contour avec les polygones de `inrae:ser_l93` (requête WFS par emprise, EPSG:2154, 7 entités renvoyées, consultée le 2026-11-22), surfaces calculées en Lambert-93. Seconde méthode indépendante pour le même chiffre : attribution de la SER à chacun des 494 812 pixels valides du raster `Typo_etage.tif` (centre du pixel). Les scripts et téléchargements sont hors dépôt (dossier de travail de la session).

**Part de surface de chaque SER dans les forêts du jeu (35 010,9 ha) :**

| SER | Nom | Surface (ha), intersection | Part | Contrôle par pixels (ha) |
|---|---|---|---|---|
| **H10** | Préalpes du Nord | 30 311,8 | 86,58 % | 30 316,8 (86,59 %) |
| **H30** | Alpes externes du Sud | 4 290,6 | 12,25 % | 4 290,0 (12,25 %) |
| J22 | Plaines et collines rhodaniennes et languedociennes | 404,5 | 1,16 % | 403,8 (1,15 %) |
| C52 | Plaines et piémonts alpins | 4,0 | 0,01 % | 0,4 |
| H41 | Alpes intermédiaires du Sud | 0,1 | 0,00 % | 0 |
| | **Total** | **35 010,9** | 100 % | |

**Des forêts du jeu tombent-elles en H30 ? Oui : 4 290,6 ha, 12,25 %.** Elles sont toutes dans le sud du massif (5,28 à 5,83 °E ; 44,65 à 44,89 °N) ; la commune portant l'essentiel est Lus-la-Croix-Haute (4 221,1 ha de forêt du jeu en H30, chef-lieu 44,6654 N ; 5,7052 E, en H30). Le nord et le centre du Vercors drômois (plateaux de Vassieux, Saint-Agnan, La Chapelle, Bouvante, Léoncel) sont en **H10**. Les 404,5 ha en J22 sont en bordure de la plaine de Valence (surtout Hostun, 379,9 ha). GRECO : H pour H10, H30, H41 ; C pour C52 ; J pour J22. La GRECO n'est donc pas unique non plus (H : 86,6 + 12,3 + 0,0 = 98,8 %).

**Positions de contrôle (WGS84, source : IGN ADMIN EXPRESS COG carto 2025, couche `chef_lieu_de_commune`, WFS data.geopf.fr, consultée le 2026-11-22 ; SER : WFS INRAE) :**

| Lieu | Latitude N ; longitude E | SER | Nom |
|---|---|---|---|
| La Chapelle-en-Vercors (chef-lieu) | 44,9683 ; 5,4161 | **H10** | Préalpes du Nord |
| Vassieux-en-Vercors (chef-lieu) | 44,8954 ; 5,3711 | **H10** | Préalpes du Nord |
| Saint-Agnan-en-Vercors (chef-lieu) | 44,9356 ; 5,4307 | **H10** | Préalpes du Nord |
| Lus-la-Croix-Haute (chef-lieu) | 44,6654 ; 5,7052 | **H30** | Alpes externes du Sud |

Erreur de la version précédente : les coordonnées données pour La Chapelle-en-Vercors (44,7456 N ; 5,3639 E) et pour « Lente » (44,70 N ; 5,40 E) ne correspondent pas à ces lieux (La Chapelle est à 44,9683 N ; 5,4161 E, soit environ 25 km plus au nord) ; les deux étaient en H30 et sont en réalité en H10. Les coordonnées de Vassieux et de Saint-Agnan sont remplacées par celles des chefs-lieux IGN ; elles restent en H10.

**Contrôle croisé avec nemeton** (`inst/extdata/communes_ser.csv`, SER à plus forte part par commune) : sur les 41 communes touchées par les forêts du jeu, la SER de plus grande surface de forêt est la même que celle de nemeton pour 30 communes ; elle diffère pour 11 communes, toutes marginales (de 0,02 à 55,9 ha de forêt du jeu chacune : Châtelus, Chamaloc, Saint-Julien-en-Quint, Peyrus, Rochefort-Samson, Barbières, Romeyer, Châteaudouble, Saint-Vincent-la-Commanderie, Dévoluy, Choranche). Cause : nemeton attribue une SER à la commune entière (mode commune), le WFS découpe au polygone. Au total 109,0 ha de forêt du jeu (0,31 %) sont dans une SER autre que celle que nemeton donnerait à leur commune. Pour les forêts de ce massif, **le polygone fait foi** ; le rattachement par commune est un repli.

**Pour Pascal (décision de périmètre, non tranchée ici) :** le massif est à 86,6 % en H10 et à 12,3 % en H30. Faut-il ouvrir la SER pilote sur H10 seule, sur H10 et H30, ou sur la GRECO H ? La question est reprise ci-dessous.

## Utilisation par typopeuplement

- **Table des codes** : lire `inst/extdata/ser/ser_codes.csv` ; c'est la seule table de codes du projet, ne pas la recopier ailleurs. Les paramètres par SER vont dans `config/*.json`, indexés par `code_ser`.
- **Déduire la SER d'une AOI** : appeler la couche WFS INRAE, sans copie locale des contours :
  `https://geodata.inrae.fr/geoserver/inrae/ows?service=WFS&version=2.0.0&request=GetFeature&typeNames=inrae:ser_l93&outputFormat=application/json&srsName=EPSG:2154&BBOX=xmin,ymin,xmax,ymax,urn:ogc:def:crs:EPSG::2154`
  (attributs `codeser`, `NomSER` ; ignorer `codeser == "-1"` ; une SER peut avoir plusieurs entités ; une AOI à cheval prend la SER de plus grande intersection).
- **Lien avec nemeton** (`/home/user/pobsteta/nemeton`, version `2026.11.37.9000`, commit `b8f6f09`, 2026-11-22), lu sans copie des contours :
  - `R/localiser_ser.R`, fonction exportée `localiser_ser(units, ser_layer = NULL, colonne = "ser", timeout = 60L)` : interroge le même WFS (`.SER_WFS`, couche `inrae:ser_l93`, relevé 2026-10-01 selon le code), plus grande intersection par unité, ignore `-1`. Elle renvoie le code SER, `NA` si hors SER ou réseau absent.
  - `inst/extdata/ser.csv` (colonnes `code;nom;greco`, 86 lignes), produit par `data-raw/build_ifn_tarifs_schaeffer.R` : mêmes 86 codes que ce référentiel, sans les alluvions L1 à L5 ni le nom des GRECO.
  - `inst/extdata/communes_ser.csv` (41 550 lignes, `insee;nom;departement;ser;part;greco`) : rattachement commune vers SER, non repris ici.
  - Comment typopeuplement l'utilise : même appel WFS et même règle de plus grande intersection, côté R (package compagnon de nemeton, ADR 0004), en appelant `nemeton::localiser_ser()` quand nemeton est installé ; `ser_codes.csv` fournit les noms et la GRECO de repli. Les contours (28,3 Mo, géométries de l'ensemble) ne sont pas versionnés ici. Si un travail hors ligne est voulu, GeoPackage à produire depuis le WFS (format ouvert) et à tenir hors du dépôt.

## Décisions (2026-11-22)

1. **Copie ou lien pour les 86 lignes de nemeton** : on garde la copie (`ser_codes.csv`, avec L1 à L5 et les noms des GRECO). Décision de Pascal (« garde la copie »).
2. **SER pilote du Vercors drômois** : H10, avec H30 pour voisine. Décision de l'orchestrateur, par délégation de Pascal (journal) ; la bande de transition traite J22, C52 et H41.
3. **« 11 grandes régions plus la Corse »** (écart 1 ci-dessus) : à trancher par Pascal.
4. **Limite des gros bois du jeu** (écart 6) : la fiche du jeu donne BM à 27,5–42,5 cm et GB à 47,5–62,5 cm, ce qui laisse un trou de 42,5 à 47,5 cm (relecteur). La limite de 47,5 cm n'est donc pas établie. À traiter à la mission de typologie locale de H10, avec Pascal ou le producteur.

## Limites

- Le WFS est un service distant : disponibilité et version des contours non garanties ; la fiche INRAE ne donne pas de numéro de version, seulement la date de révision 2024-11-05.
- Je n'ai pas lu les fascicules de chaque SER ; ils décrivent le milieu, pas les typologies de peuplement (qui viennent des guides de sylviculture locaux, hors mission).
- Droits : la fiche INRAE indique « No conditions apply to access and use » (champ INSPIRE) et « Source : IGN » ; la licence précise n'est pas nommée, à confirmer avant diffusion de la carte.

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

## Vercors drômois (SER pilote)

**Il n'y a pas une SER unique.** Le massif (jeu de données ONF – CNPF – Département de la Drôme, 35 095 ha, emprise 5,1244 à 5,842 °E et 44,6369 à 45,0927 °N, data.gouv.fr, modifié le 2026-09-30) est à cheval sur deux SER de la **GRECO H : Alpes** :

| Point testé (WGS84) | SER | Nom |
|---|---|---|
| Vassieux-en-Vercors (44,8939 N ; 5,3639 E) | **H10** | Préalpes du Nord |
| Saint-Agnan-en-Vercors (44,9167 N ; 5,3833 E) | **H10** | Préalpes du Nord |
| La Chapelle-en-Vercors (44,7456 N ; 5,3639 E) | **H30** | Alpes externes du Sud |
| Lente (44,7000 N ; 5,4000 E) | **H30** | Alpes externes du Sud |

Méthode : requête WFS `INTERSECTS(the_geom, POINT(x y))` sur `inrae:ser_l93`, coordonnées converties en Lambert-93 (formule vérifiée sur Paris : 652 469 ; 6 862 035). Un quadrillage de 30 points sur l'emprise du jeu donne H10 au nord-ouest, H30 au sud, H41 et H21 en marge est : la limite H10/H30 passe vers 44,85 à 44,9 °N. Ce quadrillage porte sur l'emprise rectangulaire, pas sur le contour des forêts : la part de surface de chaque SER dans les 35 095 ha n'est pas calculée.

Rattachement par défaut proposé à Pascal : **H10, Préalpes du Nord** pour le Vercors drômois du nord (plateaux de Vassieux, Saint-Agnan), **H30, Alpes externes du Sud** pour le sud (La Chapelle, Lente). La GRECO est H dans les deux cas : c'est le niveau de repli commun. Choix du périmètre de la SER pilote : **à Pascal**.

## Utilisation par typopeuplement

- **Table des codes** : lire `inst/extdata/ser/ser_codes.csv` ; c'est la seule table de codes du projet, ne pas la recopier ailleurs. Les paramètres par SER vont dans `config/*.json`, indexés par `code_ser`.
- **Déduire la SER d'une AOI** : appeler la couche WFS INRAE, sans copie locale des contours :
  `https://geodata.inrae.fr/geoserver/inrae/ows?service=WFS&version=2.0.0&request=GetFeature&typeNames=inrae:ser_l93&outputFormat=application/json&srsName=EPSG:2154&BBOX=xmin,ymin,xmax,ymax,urn:ogc:def:crs:EPSG::2154`
  (attributs `codeser`, `NomSER` ; ignorer `codeser == "-1"` ; une SER peut avoir plusieurs entités ; une AOI à cheval prend la SER de plus grande intersection).
- **Lien avec nemeton** (`/home/user/pobsteta/nemeton`, version `2026.11.37.9000`, commit `b8f6f09`, 2026-11-22), lu sans copie des contours :
  - `R/localiser_ser.R`, fonction exportée `localiser_ser(units, ser_layer = NULL, colonne = "ser", timeout = 60L)` : interroge le même WFS (`.SER_WFS`, couche `inrae:ser_l93`, relevé 2026-10-01 selon le code), plus grande intersection par unité, ignore `-1`. Elle renvoie le code SER, `NA` si hors SER ou réseau absent.
  - `inst/extdata/ser.csv` (colonnes `code;nom;greco`, 86 lignes), produit par `data-raw/build_ifn_tarifs_schaeffer.R` : mêmes 86 codes que ce référentiel, sans les alluvions L1 à L5 ni le nom des GRECO.
  - `inst/extdata/communes_ser.csv` (41 550 lignes, `insee;nom;departement;ser;part;greco`) : rattachement commune vers SER, non repris ici.
  - Comment typopeuplement l'utilise : même appel WFS et même règle de plus grande intersection, côté Python (pas de dépendance à R) ; `ser_codes.csv` fournit les noms et la GRECO de repli. Les contours (28,3 Mo, géométries de l'ensemble) ne sont pas versionnés ici. Si un travail hors ligne est voulu, GeoPackage à produire depuis le WFS (format ouvert) et à tenir hors du dépôt.

## Limites

- Le WFS est un service distant : disponibilité et version des contours non garanties ; la fiche INRAE ne donne pas de numéro de version, seulement la date de révision 2024-11-05.
- Je n'ai pas lu les fascicules de chaque SER ; ils décrivent le milieu, pas les typologies de peuplement (qui viennent des guides de sylviculture locaux, hors mission).
- Droits : la fiche INRAE indique « No conditions apply to access and use » (champ INSPIRE) et « Source : IGN » ; la licence précise n'est pas nommée, à confirmer avant diffusion de la carte.

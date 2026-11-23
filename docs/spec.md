# TypoPeuplement — spécification

> Rédigée par Claude (orchestrateur) le 23 novembre 2026 à partir du brief validé
> (`docs/brief.md`), révisée le même jour après la critique du contradicteur et les ADR
> 0001 à 0013 tranchées par Pascal. **À valider par Pascal** (porte n° 1). Le brief reste
> la source du problème, du périmètre et des contraintes ; la spec les rend testables et
> renvoie aux ADR plutôt que de les recopier.
>
> Statut : **validée par Pascal le 2026-11-23** (porte n° 1).

**Priorité** (Pascal, 2026-11-23) : d'abord la justesse du type du référentiel du
gestionnaire (SRGS, guide, DRA/SRA) à l'échelle de sa parcelle ; ensuite le type générique
national au demi-hectare (ADR 0006).

## 1. Les utilisateurs et leurs parcours

### 1.1 Le gestionnaire (aménagiste ONF, technicien CNPF, expert, coopérative)

| Étape | Ce qu'il fait | Ce que le produit doit lui donner |
|---|---|---|
| P1. Ouvrir | Charge dans QGIS (ou QField hors réseau) les couches de sa forêt | Des COG en Lambert-93 avec leur style `.qml` et leur table de classes (ADR 0010) |
| P2. Lire | Identifie un pixel | Type local, type générique, probabilité (ou score), deuxième type, variables continues, écart à la hauteur potentielle s'il existe, date et saison du vol, code « sans donnée » le cas échéant ; la mention que la valeur décrit un disque de 707 m² centré sur le pixel |
| P3. Stratifier | Fournit le polygone de sa forêt ou de ses parcelles | Une **synthèse par polygone** (surfaces par type local, variables moyennes) avec un estimateur nommé et une règle des bordures ; la couche `confiance` pour sur-échantillonner les zones incertaines |
| P4. Vérifier | Confronte la carte au terrain | La fiche de validation de la SER, l'aire d'applicabilité |
| P5. Rédiger | Utilise le type local dans son aménagement ou son PSG | Le type déjà exprimé dans son référentiel (8 types SRGS au minimum) |

### 1.2 L'opérateur de la chaîne

| Étape | Ce qu'il fait | Ce que le produit doit lui donner |
|---|---|---|
| O1. Préparer | Déclare une SER, ses sources, ses placettes, ses référentiels | Un fichier de configuration par SER, versionné ; la table des référentiels (ADR 0003) ; aucun seuil codé en dur |
| O2. Contrôler | Importe les placettes | Le contrôle à l'import et le contrôle contre le MNH LiDAR HD (ADR 0004) |
| O3. Calibrer | Lance métriques, entraînement, validation | Une commande unique (`targets`), rejouable dans l'environnement figé (ADR 0011) ; la fiche de validation produite automatiquement |
| O4. Produire | Lance la prédiction sur la SER | Les couches et leurs métadonnées STAC et INSPIRE, au millésime `vAAAA.MM.N` (ADR 0010, 0013) |
| O5. Mettre à jour | Après une détection de coupe ou de dépérissement (fordead ou équivalent), ou un nouveau vol | Un rejeu limité aux zones concernées et un nouveau millésime ; l'ancien reste immuable |

## 2. Les données manipulées

### 2.1 Entrées

| Donnée | Rôle | Référence |
|---|---|---|
| Nuage de points LiDAR HD (IGN) | Métriques de structure, MNT, MNH | Prétraitement PDAL (ADR 0011) ; date et saison du vol conservées |
| Sentinel-2 (séries) | Essences, phénologie | UTM rééchantillonné une fois ; support effectif > 15 m (ADR 0001) |
| Sentinel-1 | Feuillus, taillis (piste) | Brief de cadrage, priorité 2 |
| BD Forêt v3, FORMS, Open-Canopy, cartes ONF | Variables d'entrée ou de contrôle | ADR 0009 ; jamais vérité |
| Carte de fertilité ONF, modèles d'indice de fertilité IFN, couches de milieu | Hauteur potentielle | ADR 0007, conditionnelle |
| SER et GRECO | Unité de calibration | À confirmer (GRECO K, L) |
| Masque Forêt IGN + landes, accrus, terrains nus + polygones de gestion | Emprise de calcul | ADR 0005 |
| Couche des forêts publiques | Règle de diffusion | ADR 0008 ; source à vérifier |
| ZICAD | Code 252 | ADR 0010 |
| Placettes de calibration | Arbres mesurés, au mètre près | ADR 0004 |
| Grappes de validation | Inventaire en plein 50 × 100 m + bande de 15 m | ADR 0002 |
| Placettes IFN | Validation d'agrégats seulement | ADR 0002, 0004 |
| Table des référentiels | Seuils, groupes d'essences, clés | ADR 0003, livrable |

### 2.2 La placette et la grappe

**Placette** (ADR 0004) : protocole ONF de 15 m de rayon mesuré à l'horizontale ; centre
au GNSS de précision ; date ; pour chaque arbre précomptable : essence, diamètre à 1,30 m,
**position (distance et azimut, obligatoire pour les placettes nouvelles)**, origine
(franc-pied ou rejet), état (vivant, mort, chablis), hauteur sur un échantillon ; perches
sur une partie des placettes ; relevé de sol sommaire dans les pilotes.

**Grappe de validation** (ADR 0002) : rectangle de 50 × 100 m aligné sur la grille, plus
une bande de 15 m, inventorié en plein avec les mêmes attributs ; le disque de chacun des
8 pixels est recalculé.

### 2.3 Sorties, par SER

| Couche | Contenu par pixel de 25 m |
|---|---|
| `type_local` | Type du référentiel du gestionnaire (8 types SRGS au minimum) |
| `type_generique` | Type générique national |
| `type_proba` | Probabilité du type (ou `score` si non calibrée), deuxième type et sa probabilité |
| `variables` | Essence principale, couvert, surface terrière, **surface terrière par classe de 5 cm × groupe d'essences**, part de taillis, parts PB/BM/GB par référentiel, hauteur dominante |
| `hpot` (conditionnelle) | Hauteur potentielle, incertitude, écart à la hauteur potentielle |
| `vol` | Date et saison du vol LiDAR |
| `confiance` | Précision utilisateur du type prédit dans la SER (avec IC) ; écart entre les deux premières probabilités ; signalement des sauts aux limites de blocs LiDAR (ADR 0012) |
| `codes` | Codes « sans donnée » 250 à 253 et 255 (ADR 0010) |

Plus, par SER : la clé, la table des référentiels, la fiche de validation, la
configuration, la version de la chaîne. Formats, métadonnées, dépôt : ADR 0010. Licences
et accès : ADR 0008.

## 3. Hors périmètre

Voir `docs/brief.md`, rubrique « Ce qu'il ne fait pas ».

## 4. Critères d'acceptation

Chaque critère est vérifiable par un test automatique (T) ou par un contrôle humain (H).

**Grille et géométrie** (ADR 0001)
- A1 (T). Toute couche est en EPSG:2154, au pas de 25 m, origine multiple de 25 m.
- A2 (T). Les métriques LiDAR d'un nœud sont calculées sur les points situés à 15 m au
  plus (distance horizontale) de ce nœud, et sur eux seuls ; vérifié sur le jeu
  `tree_inventory_chablais3` / `chm_chablais3` de lidaRtRee.
- A3 (T). Un pixel hors emprise, hors LiDAR, en ZICAD ou hors domaine porte son code
  (250 à 253), jamais un type.

**Paramétrage** (ADR 0003)
- A4 (T). Changer de référentiel typologique dans la configuration change le type sans
  recalibrer les modèles.
- A5 (T). Si la méthode retenue ne garantit pas l'additivité, la somme des surfaces
  terrières par classe égale la surface terrière totale prédite à la tolérance fixée au
  pilote.
- A6 (T). La table des référentiels couvre les 8 types SRGS de la région de chaque SER
  pilote.

**Placettes** (ADR 0004)
- A7 (T). Une placette hors de l'emprise Lambert-93 de sa SER, aux X et Y inversés ou en
  WGS84 non converti est rejetée à l'import avec un message.
- A8 (T). Une placette ancienne incohérente avec le MNH LiDAR HD, ou touchée par une coupe
  détectée, n'entre pas dans la calibration.
- A9 (T). Les placettes IFN n'entrent jamais dans la calibration.

**Validation** (ADR 0002)
- A10 (T). Aucune grappe de validation n'est à moins de la distance minimale fixée d'une
  placette de calibration.
- A11 (T). La fiche de validation d'une SER contient, pour le type local puis le type
  générique : matrice de confusion, précision globale et par type (utilisateur,
  producteur) avec IC, au pixel, au demi-hectare et à la parcelle ; biais et RMSE de chaque
  variable continue ; erreur sur les parts PB/BM/GB après seuils ; diagramme de fiabilité
  et score de Brier ; comparaison des proportions de types aux estimations IFN.
- A12 (T). Le choix du modèle se fait par validation croisée spatiale.
- A13 (H). Dans chaque SER pilote, le test de non-infériorité apparié (marge Δ fixée avant
  les résultats) montre la carte au moins aussi bonne que la base de comparaison, sur le
  type local, feuillus compris.
- A14 (H). Les cartes sont jugées utilisables par des gestionnaires selon le protocole
  d'avis (livrable du cadrage, avec son seuil).
- A15 (H). La clé est relue par le CNPF et l'ONF sur des cas types.

**Hauteur potentielle** (ADR 0007)
- A16 (T). Si l'erreur de la hauteur potentielle dépasse le seuil de la SER, `hpot` n'est
  pas produite, la clé utilise la hauteur mesurée et la fiche le signale.

**Continuité** (ADR 0012)
- A17 (T). Sur un profil perpendiculaire à une limite de SER, aucun saut de probabilité
  au-delà du seuil fixé ; à une limite de région SRGS, le changement de légende est permis.
- A18 (T). À une limite de blocs LiDAR, un saut au-delà du seuil est signalé dans
  `confiance`.

**Domaine** (ADR 0005)
- A19 (T). Un pixel hors de l'aire d'applicabilité porte le code 253.

**Rejouabilité et versions** (ADR 0010, 0011, 0013)
- A20 (T). Deux exécutions sur les mêmes entrées, la même configuration et le même
  environnement figé donnent des sorties identiques.
- A21 (T). Toute sortie porte la version `vAAAA.MM.N` de la chaîne et le millésime de
  chaque source, dans ses métadonnées STAC et INSPIRE.
- A22 (T). Une release n'est publiée qu'après des tests verts sur `main`, et pas quand
  seuls `pilotage/`, `docs/`, `*.md`, les badges ou les tests changent (scripts testés).

**Usage** (ADR 0010)
- A23 (T). Chaque couche se lit par GDAL, porte sa table de classes et est accompagnée de
  son `.qml`.
- A24 (H). Les couches et leurs styles s'ouvrent dans QField sur le terrain.
- A25 (T). La synthèse par polygone donne les surfaces par type local et les variables
  moyennes, avec l'estimateur et la règle des bordures nommés.

**Diffusion** (ADR 0008)
- A26 (T). Si la dégradation est maintenue après l'avis juridique, le produit public est
  dégradé sur les forêts privées selon la règle retenue, et le produit complet n'en sort
  pas.

## 5. Besoins en référentiels (à confier à l'`acquereur`)

1. SER et GRECO à jour (GeoData INRAE, IGN) ; GRECO K (Corse) et L (alluvions).
2. Protocole IFN en vigueur : cercles, seuils, classes, cercle de 25 m, âge ou indice de
   fertilité ; variables IFN de structure et de composition (pour le type générique).
3. SRGS des régions des SER pilotes : 8 types, seuils, précomptage, origine des tiges.
4. Guides de sylviculture et DRA/SRA ONF des SER pilotes.
5. Masque Forêt v1 (diffusion, licence, millésime, Corse) ; source des landes, accrus et
   terrains nus (BD Topo, OCS GE).
6. Couche des forêts publiques : source, licence.
7. LiDAR HD : couverture, dates et saisons de vol, ZICAD.
8. Cartes existantes (ONF 700 m² et sa carte de fertilité, FORMS, Open-Canopy, Vercors
   drômois) : contenu, licence, millésime, accès ; résolution de dégradation du Vercors.
9. Placettes par SER pilote candidate : mémoire 2020, inventaires ONF et PSG,
   Observatoires forestiers ONF ; format, GNSS, droits.
10. Tuiles Sentinel-2 couvrant l'hexagone et la Corse (zones UTM).
11. Licences du décret 2017-638 (Légifrance) ; applicabilité d'INSPIRE.
12. Maltamo et Gobakken (2014) sur les distributions de diamètres ; Seynave et al. (2005)
    et Bergès et al. (2006), à relire.

## 6. Questions ouvertes

Voir `docs/brief.md`, rubrique « Questions ouvertes ».

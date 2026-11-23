# TypoPeuplement — consignes de l'orchestrateur

TypoPeuplement produit, pour toute forêt de France hexagonale et de Corse, une carte du
type de peuplement (composition, structure, capital) au pas de 25 m (support de calcul
de 15 m de rayon), calibrée par sylvoécorégion. Les sources sont le LiDAR HD, l'imagerie satellitaire et la hauteur
potentielle tirée du milieu, et chaque pixel porte sa probabilité et son erreur de
validation. Il est développé par une équipe d'agents IA selon **la méthode de
l'Impératrice** de Pascal Obstétar, apportée par le plugin `imperatrice` (méthode :
skill `imperatrice:methode`).

**Pour qui.** D'abord les aménagistes et gestionnaires, en forêt publique (ONF) comme
en forêt privée (CNPF, experts forestiers, coopératives), comme aide à la décision et
pour stratifier les inventaires. Ensuite les organismes partenaires (IGN, INRAE et
AgroParisTech pour la validation scientifique) et les rédacteurs des schémas régionaux
de gestion sylvicole et des plans simples de gestion.

## Ton rôle

Dans ce dépôt, la session principale est **l'orchestrateur**. Tu tiens l'étape
d'**Accompagnement** : confier, suivre, dire. **Pascal garde les rênes, la décision et
l'effort.**

- Tu ne codes pas toi-même les missions que tu confies : tu les prépares, tu les confies
  aux agents du plugin, tu suis, tu intègres.
- Les sous-agents ne peuvent pas lancer d'autres sous-agents : **toute délégation passe
  par toi.**
- Tu ne tranches jamais une question de sens, de périmètre ou de valeur : tu la prépares
  et tu la poses à Pascal. **L'IA propose, Pascal tranche et assume.** Les agents servent
  à tous les niveaux, jamais au pivot : l'IA donne la main, elle ne la prend pas, et ce
  n'est pas à elle de la rendre.
- Seule exception : la **délégation** que Pascal écrit dans `pilotage/equipe.md`. Dans sa
  portée, tu tranches à sa place, tu inscris chaque décision au journal et tu la lui dis
  (skill `imperatrice:methode`, « La délégation »). Elle ne couvre jamais : sa réponse
  d'abord, rendre la main, ce qui touche l'extérieur et ne se défait pas.

## Les sources de vérité

| Information | Source unique |
|---|---|
| La méthode, les agents, les commandes, les gabarits | plugin `imperatrice` |
| Ce qu'on construit, pour qui | `docs/brief.md` puis `docs/spec.md` |
| Le brief de cadrage d'origine (21 novembre 2026) | `docs/brief-typologie-peuplements.md`, source de `docs/brief.md` |
| Les décisions d'architecture | `docs/adr/NNNN-titre.md` |
| L'équipe validée, le plafond humain, la délégation | `pilotage/equipe.md` |
| Les missions | `pilotage/missions/NNN-titre.md` |
| L'avancement | `pilotage/kanban.md` |
| La mémoire du projet | `pilotage/journal.md` — **ajout seul, on n'efface jamais** |

Un lien plutôt qu'une copie. Si une information existe à deux endroits, l'un des deux est faux.

## Le déroulé

`/imperatrice:brief` (porte n° 1 : Pascal valide brief et spec) → `/imperatrice:mission`
(porte n° 2 : Pascal valide l'équipe) → `/imperatrice:boucle` (porte n° 3 : Pascal valide
chaque PR vers `main`) → `/imperatrice:bilan`.

## Règles métier du projet

Retenues par Pascal le 2026-11-23. Les détails et liens sont dans
`docs/brief-typologie-peuplements.md` (section « Sources »).

- **Découpage territorial** : 86 sylvoécorégions (SER) plus 5 SER d'alluvions récentes ;
  11 grandes régions écologiques (GRECO), Corse comprise (GRECO K), plus une 12e
  d'alluvions récentes (GRECO L), à confirmer sur la fiche
  ([GeoData INRAE](https://geodata.inrae.fr/geonetwork/srv/api/records/67044273-ec7e-4487-afe7-fa5dda5fa2bd)).
  Les SER d'alluvions demandent une clé à part.
- **Typologie de départ** : triangle des structures et clé du mémoire de J. Souchon
  (AgroParisTech / ONF, 2020) ; guide de sylviculture Alpes du Nord (types 1, 2, 3).
- **Référentiels de gestion à raccorder** : les 8 types obligatoires des SRGS pour les
  plans simples de gestion (futaie régulière, futaie irrégulière, mélange futaie-taillis,
  taillis, peupleraie, accrus, landes, terrain nu ; [SRGS AURA 2023, p. 11-12](https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf)),
  les guides de sylviculture, les directives et schémas régionaux d'aménagement ONF.
- **Seuils de diamètre, par référentiel typologique et groupe d'essences, jamais par
  SER** (Pascal, 2026-11-23) : aucun seuil codé en dur. Exemples : SRGS AURA 2023,
  limite BM/GB à 47,5 cm toutes essences, 42,5 cm admis en résineux quand une typologie
  l'utilise ; mémoire 2020 : 42,5 cm en Savoie et Pyrénées, 47,5 cm dans les Vosges ;
  précomptage 17,5 cm (classe 20) au SRGS, 7,5 cm à l'IFN. La chaîne prédit la surface
  terrière par classe de diamètre de 5 cm ; les seuils s'appliquent en aval.
- **Données d'entrée** :
  - LiDAR HD IGN, au moins 10 impulsions/m² ;
  - BD Forêt v3 (bêta, 35 classes, maille de 0,5 ha), utilisée **en variable d'entrée,
    jamais comme vérité** ;
  - placettes de l'inventaire forestier national : coordonnées publiques au kilomètre,
    pas d'accès aux coordonnées exactes ; **validation d'agrégats seulement, jamais de
    calibration au pixel** (Pascal, 2026-11-23). Protocole concentrique 6 / 9 / 15 m ;
  - placettes de calibration : géolocalisées au mètre près (GNSS ou recalage sur MNH) ;
  - couches de milieu Digitalis (pH : 58 % de variance expliquée seulement) ;
  - Sentinel-1 et Sentinel-2.
- **Conventions de test** :
  - grille : pas de sortie de 25 m (4 pixels au quart d'hectare, 8 au demi-hectare),
    support de calcul circulaire de 15 m de rayon centré sur chaque nœud, origine en
    Lambert-93 sur un multiple de 25 m (retenu par Pascal le 2026-11-23, ADR à rédiger) ;
  - placette de référence : rayon de 15 m, soit 30 m de diamètre (≈ 707 m²), validé
    par Pascal le 2026-11-23 ;
  - validation sur des grappes de placettes indépendantes, par type et par SER, jamais
    sur les placettes de calibration ;
  - référence de validation : le type calculé par la clé sur les arbres mesurés de
    grappes au demi-hectare, jamais un type « à dire d'expert » ;
  - métriques : précision globale et par type (utilisateur, producteur) avec intervalles
    de confiance, par SER (Olofsson et al., 2014) ; la carte doit faire au moins aussi
    bien qu'une base de comparaison construite par SER. Le 76 % du rapport 2020 porte
    sur la seule structure : ce n'est pas le seuil du projet.
- **Système de coordonnées** : Lambert-93 (EPSG:2154), hexagone et Corse (fermé le
  2026-11-23). Sentinel-2 (UTM 30, 31, 32) est rééchantillonné une seule fois, selon
  l'ADR de la grille.
- **Sans donnée** : classes explicites hors LiDAR, ZICAD, hors domaine de validité.

## Règles techniques communes

- **Pas de code sans tests.** Commande de tests : `.claude/test-command`.
- **Formats ouverts, logiciels libres** de préférence (test du successeur).
- **Jamais de push direct sur `main`.** Tout passe par une PR.

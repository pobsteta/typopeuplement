# typopeuplement — consignes de l'orchestrateur

typopeuplement est une chaîne de traitement qui produit, pour les forêts de France
hexagonale et de Corse, une carte du type de peuplement (composition, structure, capital) calibrée
par sylvoécorégion (SER). Le projet est développé par une équipe d'agents IA selon
**la méthode de l'Impératrice** de Pascal Obstétar, apportée par le plugin `imperatrice`
(méthode : skill `imperatrice:methode`).

## Ton rôle

Dans ce dépôt, la session principale est **l'orchestrateur**. Tu tiens l'étape
d'**Accompagnement** : confier, suivre, dire. **Pascal garde les rênes, la décision et
l'effort.**

- Tu ne tranches jamais une question de sens, de périmètre ou de valeur : tu la prépares
  et tu la poses à Pascal. **L'IA propose, Pascal tranche et assume.**
- Seule exception : la **délégation** que Pascal écrit dans `pilotage/equipe.md`. Elle ne
  couvre jamais : sa réponse d'abord, rendre la main, ce qui touche l'extérieur et ne se
  défait pas.

## Les sources de vérité

| Information | Source unique |
|---|---|
| La méthode, les agents, les commandes, les gabarits | plugin `imperatrice` |
| Ce qu'on construit, pour qui | `docs/brief-typologie-peuplements.md` (puis `docs/spec.md`) |
| Les décisions d'architecture | `docs/adr/NNNN-titre.md` |
| L'équipe validée, le plafond humain, la délégation | `pilotage/equipe.md` |
| L'avancement | `pilotage/kanban.md` |
| La mémoire du projet | `pilotage/journal.md` — **ajout seul, on n'efface jamais** |
| Les paramètres par référentiel typologique et par SER (seuils, clé, souplesses) | `config/*.json` (seuils : par référentiel, ADR 0007) |
| Qui décide quoi parmi les ADR 0005 à 0017 (réconciliation des cadrages, 2026-11-23) | `docs/adr/README.md` |
| La licence | `LICENSE` (GPL-3 pour le code ; données : ADR 0014) |

## Règles métier du projet

- **La typologie est descriptive** : ni choix d'essences, ni itinéraires sylvicoles. Les
  cartes aident à décider ; elles ne remplacent pas le diagnostic de terrain.
- **Ne jamais inventer une clé de types.** Les types, leurs seuils et leurs noms viennent
  de la typologie locale de chaque SER (guide de sylviculture, typologie du SRGS),
  sourcée. La clé de `config/exemple.json` est un exemple pour faire tourner la chaîne.
- **Seuils par référentiel typologique, pas par SER** (réconciliation, Pascal, 2026-11-23,
  arbitrage C1 ; [ADR 0007](docs/adr/0007-seuils-par-referentiel-et-surface-terriere-par-classe.md)) :
  les modèles prédisent la surface terrière par classe de 5 cm et par groupe d'essences,
  le seuil est un paramètre du référentiel. Pour H10, GSM Alpes du Nord : 42,5 cm toutes
  essences (Pascal, 2026-11-22). « 42,5 cm seulement en résineux » ne vaut que pour le
  SRGS AURA, s'il est livré en plus. (Le mémoire de Souchon, 2020, donne 42,5 cm en Savoie
  et dans les Pyrénées, 47,5 cm dans les Vosges : un référentiel parmi d'autres.)
- **Légendes** (arbitrages C2 et C3 ; [ADR 0008](docs/adr/0008-legendes-srgs-gsm-et-type-generique.md)) :
  priorité aux forêts privées, donc les **8 types SRGS** d'abord et validés en premier ;
  la typologie de structure du Guide des sylvicultures de montagne Alpes du Nord (GSM,
  `docs/referentiels/typologie-h10.md`) en second pour H10 ; un type générique national
  en plus. La hauteur potentielle est un critère de la clé GSM, un simple attribut du type
  générique ; si son modèle échoue à son critère, la clé GSM se replie sur la hauteur
  mesurée et le dit ([ADR 0009](docs/adr/0009-hauteur-potentielle.md)).
- **AOI pilote** (réconciliation, Pascal, 2026-11-23) : la forêt domaniale de Léoncel
  (contrôle par la carte GSM de l'aménagement) plus les forêts privées voisines dans H10
  (légende SRGS, usage PSG) ; la mission 006 en tient compte (ADR 0008).
- **Grille** : 26,6 m en Lambert-93, alignée sur la grille ONF là où ses rasters existent,
  rééchantillonnage unique des capteurs
  ([ADR 0005](docs/adr/0005-grille-de-26-6-m-et-reechantillonnage.md)).
- **La référence de validation est la clé appliquée aux mesures**, pas le type relevé à
  dire d'expert (Souchon, 2020).
- **Chaque carte porte sa couche de confiance** : drapeaux de A (« entre deux types »,
  « hauteur potentielle incertaine », repli sur la hauteur mesurée, saut aux limites de
  blocs LiDAR), précision utilisateur du type prédit dans la SER avec son intervalle de
  confiance, écart d'appartenance entre les deux premiers types (C13). Le nombre associé
  au type s'appelle **appartenance** tant qu'il n'est pas calibré ; « probabilité »
  seulement après calibration (C12).
- **Valider** (arbitrages C5, C6, C11 ; [ADR 0006](docs/adr/0006-validation-reference-critere-et-confiance.md)) :
  unité = le pixel, référence = placette de 15 m centrée sur le centre du pixel, évaluée
  par grappes de placettes au demi-hectare ; passage = non-infériorité appariée contre
  une base par SER **et** borne basse de l'IC de la précision ≥ seuil d'usage fixé par
  Pascal ; kappa en indicateur seulement ; validation croisée spatiale pour choisir le
  classifieur.
- **Placettes** : sources publiques, aucun contact ONF, couvert des strates relevé pour la
  clé GSM ([ADR 0010](docs/adr/0010-placettes-sources-et-protocole.md)).
- **Échelle et diffusion** : un calcul par AOI, la SER puis le national par assemblage
  d'AOI ([ADR 0013](docs/adr/0013-echelle-aoi-formats-codes-et-metadonnees.md)) ; aucune
  différence entre forêt publique et forêt privée, sans dégradation, risque cadastre à
  vérifier avant la première diffusion publique
  ([ADR 0014](docs/adr/0014-diffusion-sans-degradation-et-licences.md)).
- **Le milieu sert à la hauteur potentielle**, pas à une typologie de stations.
- SER : référentiel GeoData INRAE (86 SER, Corse comprise, plus 5 d'alluvions récentes ;
  11 grandes régions écologiques A à K, Corse = K, plus L pour les alluvions ;
  `docs/referentiels/ser.md`).
- Un code SER hors du référentiel est une erreur, pas une valeur manquante.
- La bande de transition entre SER a une largeur strictement positive : une largeur
  nulle ferait une rupture (critère 4, [ADR 0012](docs/adr/0012-continuite-aux-limites.md)).
- Unités : diamètres en cm à 1,30 m, surface terrière en m²/ha, hauteurs en m,
  coordonnées en m (Lambert-93 pour les vraies données), parts entre 0 et 1.

## Règles techniques communes

- **Pas de code sans tests.** Commande de tests : `.claude/test-command`.
- **Formats ouverts, logiciels libres** : R (sf, terra, ranger, e1071, MASS, jsonlite), ADR 0004.
  Le prototype Python (`src/`) ne sert plus que de référence de comparaison.
- **Nuage de points** : lasR isolé derrière une interface interne, PDAL en repli ; renv,
  conteneur et `targets` pour la reproductibilité
  ([ADR 0016](docs/adr/0016-nuage-de-points-lasr-isole-pdal-et-reproductibilite.md)).
- **Versions** : calendaires `vAAAA.MM.N`, tags et releases par la CI, comme Marculus
  ([ADR 0017](docs/adr/0017-versions-calendaires-tags-et-releases.md)). Licence du code :
  GPL-3 (`LICENSE`).
- **Jamais de push direct sur `main`.** Tout passe par une PR.

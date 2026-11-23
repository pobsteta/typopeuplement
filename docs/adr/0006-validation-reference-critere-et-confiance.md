# ADR 0006 — Validation : référence, unité, critère de passage, calibration et confiance

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après le cadrage A et l'ADR 0002 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par les arbitrages C5, C6, C11, C12 et C13
- **Tranchée par :** Pascal (arbitrages C5, C6, C11, C12, C13, 2026-11-23)
- **Précise :** spec, critères 1 (probabilités), 6 et 7 ; brief, objectif 4 et critère de passage de la phase « Pilotes »

## La décision en une phrase

L'unité d'évaluation est le **pixel**, comparé au type que la clé donne sur les mesures
d'une placette de 15 m centrée sur le centre du pixel, évalué par grappes de placettes
au demi-hectare ; la carte passe si **deux conditions sont réunies** (non-infériorité
appariée contre une base de comparaison par SER, et borne basse de l'intervalle de
confiance de la précision au moins égale au seuil d'usage fixé par Pascal) ; le kappa
n'est qu'un indicateur ; le classifieur est choisi par validation croisée spatiale ; le
nombre associé au type s'appelle « appartenance » tant qu'il n'est pas calibré ; la
couche de confiance cumule les drapeaux de A et la précision utilisateur du type prédit.

## Contexte

Le 76 % du mémoire de 2020 porte sur la seule structure ; le brief refuse toute vérité
« à dire d'expert » (la référence est la clé appliquée aux mesures, déjà acquise dans A) ;
l'« erreur par pixel » du brief (objectif 4) n'était pas définie.

### Unité et référence (arbitrage C6)

- **Unité** : le pixel (option (a) de B, retenue), seul choix qui donne un contenu à
  l'erreur par pixel.
- **Référence** : la placette de 15 m de rayon dont le centre est le centre du pixel, ce
  que la grille de 26,6 m rend exact en surface (ADR 0005). La clé est appliquée aux
  mesures de la placette ; avec la clé GSM, cela demande les couverts des strates
  (protocole : ADR 0010).
- **Grappes** : les grappes de placettes au demi-hectare de A sont gardées (maille
  carrée de 70,7 m, valeur provisoire de `grappes_par_maille()`, `R/validation.R`) ;
  les estimateurs sont ceux du sondage en grappes (Stehman et Wickham, 2011, cités par B).
- **Inventaire en plein de 50 × 100 m** (proposé par B) : abandonné, gardé en option pour
  les seuls tests de houppiers.
- **Parcelle** : le type local est aussi validé à la parcelle, à partir d'un polygone
  fourni par l'utilisateur, avec un estimateur et une règle des bordures nommés.
- **Non arbitré** : le plan de sondage des placettes nouvelles (B : aléatoire stratifié
  **Décidé le 2026-11-23 par l'orchestrateur, délégation n° 3** : plan aléatoire stratifié par type prédit (Olofsson et al., 2014) pour toute campagne de placettes nouvelles. Une placette dont le centre n'est pas au centre d'un pixel est rattachée au pixel qui la contient si son centre est à 2 m au plus du centre du pixel ; au-delà, ses métriques sont recalculées sur le disque de 15 m centré sur elle (tolérance provisoire, à mesurer au pilote). La hauteur potentielle de référence d'une placette est celle du pixel de la carte qui la contient, déclarée « modélisée » dans la fiche.
  par type prédit, Olofsson et al., 2014) et les effectifs par type.

### Critère de passage (arbitrage C5)

Deux conditions **cumulées**, d'abord sur les 8 types SRGS, puis sur le GSM (ADR 0008) :
1. **Non-infériorité appariée** (Foody, 2009, cité par B) contre une **base de comparaison
   par SER**, écrite avant les résultats (B : par exemple la règle BD Forêt v3 + MNH, ou
   la clé de 2020 rejouée sur LiDAR HD), avec une marge Δ fixée d'avance ; sous-test
   sur les grappes feuillues (B).
2. **Borne basse de l'intervalle de confiance de la précision ≥ seuil d'usage**, fixé par
   Pascal, par usage et par SER (condition de A, qui y mettait « les utilisateurs »).

Les précisions utilisateur et producteur, par type et par SER, sont rendues avec leurs
intervalles de confiance (B). **Le kappa est un indicateur seulement**, jamais un critère.
Le 76 % de 2020 est un repère historique sur la seule structure, pas le seuil du projet.

### Second niveau : agrégats de l'IFN

Les proportions de types par SER de la carte sont comparées aux estimations de
l'IFN, avec un estimateur nommé (les données brutes ne donnent pas les poids de
post-stratification ; B). Les placettes IFN ne servent jamais à calibrer (ADR 0010).

### Indépendance et validation croisée spatiale (arbitrage C11)

Le choix du classifieur et des modèles se fait sur un score de **validation croisée
spatiale** (Ploton et al., 2020, cités par B) : au minimum des plis par grappe, de
préférence des blocs spatiaux selon la portée de l'autocorrélation (`spatialsample` ou
`CAST`). Distance minimale entre une grappe de validation et la placette de calibration
la plus proche (B). Conséquence : les chiffres de A obtenus avec des plis mélangés (journal,
2026-11-22, mission 003) sont à recalculer ; ils sont probablement optimistes.

### Appartenance, puis probabilité (arbitrage C12)

La clé floue et le drapeau « entre deux types » de A sont gardés. Le nombre produit par
la clé (produits de sigmoïdes normalisés, `R/cle.R`) s'appelle **« appartenance »** tant
qu'il n'est pas calibré. La fiche de validation donne la **calibration mesurée**
(diagramme de fiabilité, score de Brier). On l'appelle **« probabilité »** seulement après
calibration (régression isotone, par exemple).

### Couche de confiance (arbitrage C13)

Cumul de trois familles :
- les **drapeaux de A** (entre deux types ; hauteur potentielle incertaine ; niveau du
  modèle ; hors clé ; strates basses estimées), plus le repli sur la hauteur mesurée
  (ADR 0008, 0009) et le saut aux limites de blocs LiDAR (ADR 0012) ;
- la **précision utilisateur du type prédit dans la SER**, avec son intervalle de
  confiance (B) ;
- l'**écart d'appartenance entre les deux premiers types**.

### Autres règles reprises de B

- Écart maximal entre vol LiDAR et relevé fixé ; grappe exclue si une coupe ou un
  dépérissement est détecté entre les deux (fordead ou équivalent).
- Biais et RMSE de chaque variable continue dans la fiche de validation.
- La clé est relue par le CNPF seul, sur des cas types ; le contact est pris par Pascal
  (ADR 0008).

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un pixel, une placette, des grappes déjà dans A ; pas d'inventaire en plein | Placettes centrées sur des centres de pixel | Oui |
| **R**esponsable | Qui fait quoi ? | Pascal fixe le seuil d'usage ; la chaîne mesure ; validation par une autre équipe que la calibration si possible | Organisation | À organiser |
| **A**nticiper | Si l'imprévu arrive ? | Base de comparaison et marge écrites avant les résultats ; clé relue par le CNPF | Temps de relecture | Oui |
| **N**ovateur | Idées étranges écoutées ? | Unité « bloc », kappa, inventaire en plein examinés | — | — |
| **C**oût | Coût à l'ensemble ? | Terrain : placettes centrées et couverts des strates à relever ; calcul des blocs spatiaux | À chiffrer | Oui (Pascal) |
| **É**cologique | Réutilisation ? | Mêmes grappes pour pixel, demi-hectare et parcelle ; calibration réutilisable | — | Oui |

## Valeurs sacrifiées

- La comparabilité directe avec le chiffre de 2020 et avec les résultats de A en plis mélangés.
- Le kappa comme chiffre de synthèse.
- Le mot « probabilité » avant calibration.
- La simplicité d'un seul critère : deux conditions à tenir en même temps.

## Sources

Reprises de l'ADR 0002 de B, non reconsultées le 2026-11-23.

- Olofsson et al., Remote Sensing of Environment 148, 2014, p. 42-57, DOI 10.1016/j.rse.2014.02.015
- Stehman S.V., Wickham J.D., Remote Sensing of Environment 115(12), 2011, p. 3044-3055
- Foody G.M., Remote Sensing of Environment 113(8), 2009, p. 1658-1663, DOI 10.1016/j.rse.2009.03.014
- Ploton P. et al., Nature Communications 11, 4540, 2020, DOI 10.1038/s41467-020-18321-y
- Meyer H., Pebesma E., CAST : https://arxiv.org/abs/2005.07939
- fordead : https://zenodo.org/records/12802457
- Données brutes IFN : https://www.data.gouv.fr/datasets/donnees-brutes-de-l-inventaire-forestier
- Dans A : `R/validation.R`, `R/cle.R`, `R/modeles.R` (plis mélangés), journal du 2026-11-22.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0012 — Continuité aux limites de SER et de blocs LiDAR ; légendes SRGS non lissées

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après l'ADR 0012 du cadrage B (`docs/cadrage`, commit 7b714f1) et `poids_transition()` de A ; apports retenus en bloc
- **Tranchée par :** Pascal (apports, 2026-11-23)
- **Précise :** CLAUDE.md et spec, critère 4 (bande de transition) ; brief, risque « LiDAR HD acquis à des dates et saisons différentes »

## La décision en une phrase

Aux limites de SER, les modèles sont pondérés par la distance dans une **bande de transition
de largeur strictement positive** ; aux limites de blocs LiDAR, la date et la saison du vol
sont des variables, le vol le plus récent l'emporte en recouvrement, et un saut au-delà du
seuil est **signalé dans la couche de confiance, jamais lissé** ; la limite entre deux
régions SRGS change la légende et **n'est pas lissée**.

## Contexte

A a déjà la bande de transition (`poids_transition()` de `R/ser.R`, demi-largeur de 500 m,
**valeur provisoire** ; critère 4 de la spec : sur une limite, chaque modèle pèse pour
moitié) et le principe « largeur nulle interdite » (CLAUDE.md). A n'a pas de règle pour les
blocs LiDAR (risque seulement écrit dans le brief, non codé).

Options envisagées (B) :
1. **Bande de transition pondérée (SER) + signalement (blocs LiDAR)** : retenue.
2. Modèle national unique, SER ou GRECO en variable : aucune limite par construction, mais
   contredit la calibration par SER ; gardée en option si les bandes se révèlent fragiles.
3. Aucun lissage, signalement seul : laisse des ruptures visibles aux limites de SER.

Règles :
- **SER** : bande de part et d'autre de la limite, largeur fixée au pilote ; pondération
  linéaire selon la distance ; une SER qui hérite du modèle de sa GRECO n'a pas de limite
  interne à cette GRECO.
- **Rupture légitime** : la limite entre deux régions SRGS change la légende du type local ;
  elle n'est pas lissée. Seuls les modèles sont lissés, pas les légendes.
- **Blocs LiDAR** : couche « date et saison du vol » par pixel ; en recouvrement, vol le plus
  récent ; test du saut des variables prédites entre deux bandes de part et d'autre de la
  limite ; au-delà du seuil, signalement dans la couche de confiance (ADR 0006).
- **Critère** : profil perpendiculaire à chaque limite ; saut maximal fixé au pilote, un
  seuil pour les SER, un autre pour les blocs.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Une pondération linéaire, un test de saut | Deux modèles à appliquer dans la bande | Oui |
| **R**esponsable | Qui fait quoi ? | La chaîne lisse et signale ; l'opérateur fixe largeur et seuils au pilote | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Bandes fragiles : option 2 en réserve | Recalibration | Oui |
| **N**ovateur | Idées étranges ? | Modèle national unique examiné | — | — |
| **C**oût | Coût à l'ensemble ? | Double prédiction dans les bandes | Calcul modeste | Oui |
| **É**cologique | Réutilisation ? | Cartes d'AOI contiguës assemblables sans couture visible au national (ADR 0013) | — | Oui |

## Valeurs sacrifiées

- L'exactitude locale dans la bande, où deux modèles sont mélangés.
- L'aspect lisse de la carte aux limites de blocs : elle montre ses défauts plutôt que de
  les cacher.

## Sources

Reprises de l'ADR 0012 de B ; non reconsultées le 2026-11-23.

- Couverture et dates de vol LiDAR HD : https://www.data.gouv.fr/datasets/carte-du-lidar-hd-de-lign-par-commune-date-du-vol-et-couverture-en-france
- Dans A : `R/ser.R` (`poids_transition()`), CLAUDE.md, spec critère 4.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

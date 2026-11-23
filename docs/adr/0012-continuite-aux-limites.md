# ADR 0012 — Continuité aux limites de SER et de blocs LiDAR

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23
- **Proposée par :** sujet proposé par le contradicteur (critique des ADR, S2), rédigée par Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

Aux limites de SER, les probabilités sont la moyenne des deux modèles pondérée par la
distance dans une bande de transition ; aux limites de blocs LiDAR, la date et la saison
du vol sont des variables, le vol le plus récent l'emporte en recouvrement, et un saut
au-delà du seuil est signalé dans la couche `confiance`, jamais lissé.

## Contexte

Le brief exige l'absence de rupture aux limites de SER et de blocs LiDAR (arbitrages I4
et M7) ; les critères A5 et A14 de la spec renvoyaient à une ADR qui n'existait pas.

Options envisagées :
1. **Bande de transition pondérée (SER) + signalement (blocs LiDAR)** : retenue.
2. Modèle national unique, SER ou GRECO en variable : aucune limite par construction,
   mais contredit la calibration par SER du brief ; gardée comme option à comparer si
   les bandes se révèlent fragiles.
3. Aucun lissage, signalement seul : laisse des ruptures visibles aux limites de SER.

Règles :
- **SER** : bande de part et d'autre de la limite, largeur fixée au pilote ; pondération
  linéaire selon la distance ; une SER qui hérite du modèle de sa GRECO n'a pas de limite
  interne à cette GRECO.
- **Rupture légitime** : la limite entre deux régions SRGS change la légende du type
  local ; elle n'est pas lissée. Seuls les modèles sont lissés, pas les légendes.
- **Blocs LiDAR** : date et saison du vol en variables ; en recouvrement, vol le plus
  récent ; test du saut des variables prédites entre deux bandes de part et d'autre de la
  limite ; au-delà du seuil, signalement dans `confiance`.
- **Critère A14** : profil perpendiculaire à chaque limite ; saut maximal fixé au pilote,
  un seuil pour les SER, un autre pour les blocs.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Une pondération linéaire, un test de saut | Deux modèles à appliquer dans la bande | Oui |
| **R**esponsable | Qui fait quoi ? | La chaîne lisse et signale ; l'opérateur fixe largeur et seuils au pilote | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Bandes fragiles : option 2 en réserve | Recalibration | Oui |
| **N**ovateur | Idées étranges ? | Modèle national unique examiné | — | — |
| **C**oût | Coût à l'ensemble ? | Double prédiction dans les bandes | Calcul modeste | Oui |
| **É**cologique | Réutilisation ? | Carte nationale sans couture, réutilisable d'un seul tenant | — | Oui |

## Valeurs sacrifiées

- L'exactitude locale dans la bande, où deux modèles sont mélangés.
- L'aspect lisse de la carte aux limites de blocs : elle montre ses défauts plutôt que de
  les cacher.

## Sources

- `docs/brief.md`, contraintes « Continuité » (arbitrages I4, M7).
- Couverture et dates de vol LiDAR HD : https://www.data.gouv.fr/datasets/carte-du-lidar-hd-de-lign-par-commune-date-du-vol-et-couverture-en-france

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

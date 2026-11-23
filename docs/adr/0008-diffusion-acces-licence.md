# ADR 0008 — Diffusion : licences, accès complet, dégradation à instruire

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** Claude (orchestrateur), d'après le contradicteur
- **Tranchée par :** Pascal

## La décision en une phrase

Le code est sous GPL-3.0 et les données publiques sous Licence Ouverte Etalab 2.0 ; le
produit complet est remis sur demande, sans service d'authentification, par le CNPF
(forêt privée) ou l'ONF (forêt publique) au rédacteur du document de gestion mandaté par
le propriétaire ; la dégradation du produit public en forêt privée est instruite par un
juriste au cadrage, entre deux niveaux et aucune dégradation.

## Contexte

- **Licence du code** : le socle est sous GPL (lidaRtRee et lidR GPL-3, terra GPL ≥ 3,
  CAST GPL ≥ 2 ; `packageDescription()`, 2026-11-23) ; Marculus est sous GPL-3.0. La GPL
  figure, à notre connaissance, parmi les licences à réciprocité de la liste du décret
  n° 2017-638 (art. D. 323-2-1 CRPA) : à confirmer sur Légifrance.
- **Licence des données** : Licence Ouverte Etalab 2.0, comme le MNH LiDAR HD et la BD
  Forêt v3 dont elles dérivent.
- **Accès complet** : options envisagées : service d'authentification (suppose le
  cadastre nominatif, d'accès restreint, et un service à tenir) ; **remise sur demande par
  le CNPF ou l'ONF au rédacteur mandaté** (retenue : le CNPF connaît déjà les titulaires de
  PSG) ; accès libre pour tous (option « pas de dégradation »).
- **Dégradation** : les données d'entrée sont déjà ouvertes sur les forêts privées (MNH
  LiDAR HD à 50 cm) ; dégrader le produit ne protège que l'interprétation (type, capital).
  Le juriste instruit au cadrage : (A) deux niveaux, orientation retenue par Pascal en I5 ;
  (B) aucune dégradation ; ainsi que l'ouverture par défaut des données publiques et la
  qualification de donnée personnelle une fois croisée avec le cadastre. Résolution
  utilisée dans le Vercors : à demander au CRAIG ou à l'ONF.
- **Prérequis** : une couche des forêts publiques (où dégrader ; source et licence à
  vérifier par l'`acquereur`) ; règle des pixels de bord, dont le disque de 15 m déborde
  sur la parcelle voisine (Monnet et Munoz, 2015, p. 101).
- **Canal** : dépôt pérenne avec DOI, signalé sur data.gouv.fr (ADR 0010).

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Pas de service d'accès ; remise par les organismes existants | Délai de remise | Oui |
| **R**esponsable | Qui fait quoi ? | CNPF (privé) et ONF (public) remettent ; le juriste instruit | Accord de ces organismes à obtenir | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Fuite du produit complet : limitée à des remises tracées | — | Oui |
| **N**ovateur | Idées étranges ? | Option « pas de dégradation » instruite | — | — |
| **C**oût | Coût à l'ensemble ? | Pas de service à tenir ; avis juridique au cadrage | Avis juridique | Oui |
| **É**cologique | Réutilisation ? | Licences ouvertes, compatibles avec le socle et les sources | — | Oui |

## Valeurs sacrifiées

- L'ouverture par défaut des données publiques, si la dégradation est maintenue.
- L'égalité d'accès entre propriétaires et tiers, si la dégradation est maintenue.
- La commodité d'un accès en libre-service pour le gestionnaire.

## Sources

- Licence Ouverte Etalab 2.0 : https://www.etalab.gouv.fr/wp-content/uploads/2017/04/ETALAB-Licence-Ouverte-v2.0.pdf
- Licences réglementaires : https://www.data.gouv.fr/licences
- MNH LiDAR HD : https://www.data.gouv.fr/datasets/mnh-lidar-hd
- BD Forêt v3 : https://www.data.gouv.fr/datasets/jeu-de-donnees-test-bd-foret-v3-juin-2026-beta
- Vercors drômois : https://www.data.gouv.fr/datasets/parametres-forestiers-lidar-vercors-dromois-2021-2022-1
- Monnet et Munoz, RFPT n° 211-212, 2015 : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

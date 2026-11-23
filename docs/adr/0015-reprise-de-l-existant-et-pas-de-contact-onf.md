# ADR 0015 — Reprise de l'existant : chaîne propre, pas de contact ONF, rasters ONF en contrôle

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après l'ADR 0009 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par les arbitrages C9, C10 et C14
- **Tranchée par :** Pascal (arbitrages C9, C10 et C14, 2026-11-23)
- **Précise :** README de A (mode « variables fournies » : rasters ONF en entrée) ; journal du 2026-11-22 (« pas de contact ONF »)

## La décision en une phrase

Le projet tient sa propre chaîne libre, calculée **depuis le LiDAR HD brut partout** ; les
rasters ONF servent de **contrôle** ; il n'y a **aucun contact ONF** (la demande de
placettes ONF est abandonnée) ; FORMS, Open-Canopy et la BD Forêt v3 restent des variables
d'entrée ou de contrôle.

## Contexte

Deux questions distinctes (B) :
1. **Placettes ONF** : ~40 sites calibrés depuis 2007, selon B. Arbitrage C9 : demande
   abandonnée (ADR 0010).
2. **Code ONF** : en 2015, métriques par LASManager (logiciel maison), segmentation sous
   ArcGIS 10.0 (propriétaire), modèles sous R (Monnet et Munoz, 2015, p. 95-96, rapportés
   par B) ; chaîne actuelle non vérifiée. La question « le code de la chaîne ONF est-il
   partageable ? » du brief reste ouverte et sans objet sans contact ONF.

Positions de départ :
- A prenait les rasters ONF du Vercors comme **entrée** de la chaîne (mode « variables
  fournies »).
- B voulait une chaîne nouvelle sur socle lidaRtRee, les cartes ONF en **contrôle** seulement
  (support de 700 m² « différent », couverture à vérifier).

**Arbitrages** :
- **C9** : « pas de contact ONF » maintenu ; rasters ONF en entrée là où ils sont complets
  (public) ; en forêt privée (rasters dégradés), métriques calculées depuis le LiDAR HD brut
  — la mission 008 de A (couvert des strates par le LiDAR HD) devient prioritaire.
- **C14** (postérieur dans l'ordre de la liste, plus général) : métriques calculées depuis
  le LiDAR HD **partout**, rasters ONF **en contrôle**, pour une qualité égale partout.
  Cette ADR suit C14 ; l'articulation avec la formule de C9 « en entrée là où ils sont
  complets » est **tranchée** : C14 l'emporte, les rasters ONF servent de contrôle partout (décision de l'orchestrateur par délégation n° 3, journal du 2026-11-23).
- **C10** : lasR gardé, isolé derrière une interface (ADR 0016) ; lidaRtRee sert aux tests
  des houppiers et non de socle, contrairement à B.

Options envisagées (ADR 0009 de B) :
1. Étendre la chaîne ONF : héritage probable d'un logiciel maison et d'un logiciel
   propriétaire ; suppose un contact ONF : écartée.
2. Chaîne nouvelle sans socle : refait tout.
3. Cartes ONF en variables d'entrée seulement : support de 700 m² différent, couverture
   à vérifier (écartée par C14).
4. **Chaîne nouvelle libre, rasters ONF en contrôle** : retenue.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Une seule chaîne, la même partout | Calcul du nuage de points sur toute l'AOI | Oui |
| **R**esponsable | Qui fait quoi ? | Le projet tient sa chaîne ; aucun accord extérieur requis | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Rasters ONF indisponibles : sans effet sur la chaîne | — | Oui |
| **N**ovateur | Idées étranges ? | Option 3 examinée puis écartée | — | — |
| **C**oût | Coût à l'ensemble ? | Calcul LiDAR complet ; développement plus long que l'extension ONF | Temps de calcul et de développement (mission 008) | Oui |
| **É**cologique | Réutilisation ? | Chaîne libre ; ne réutilise pas le code ONF | — | Oui |

## Valeurs sacrifiées

- La vitesse de départ qu'offraient les rasters ONF en entrée.
- La possibilité de partager le code ONF.
- L'accès aux placettes ONF.

## Sources

Reprises de l'ADR 0009 de B ; non reconsultées le 2026-11-23.

- Monnet et Munoz, RFPT n° 211-212, 2015, p. 95-96 : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079
- lidaRtRee : https://lidar.pages-forge.inrae.fr/lidaRtRee/
- Cartes ONF (couverture à vérifier) : https://www.ign.fr/lidar-hd-foret
- FORMS : https://essd.copernicus.org/articles/15/4927/2023/ ; Open-Canopy : https://arxiv.org/pdf/2407.09392
- Dans A : `README.md` (mode « variables fournies »), `pilotage/missions/008-couvert-strates-lidar.md`.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

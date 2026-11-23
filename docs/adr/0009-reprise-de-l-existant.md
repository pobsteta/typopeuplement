# ADR 0009 — Reprise de l'existant : placettes ONF à instruire, chaîne nouvelle sur socle lidaRtRee

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** Claude (orchestrateur), d'après le contradicteur
- **Tranchée par :** Pascal

## La décision en une phrase

Le projet bâtit une chaîne nouvelle et libre sur le socle lidaRtRee (INRAE), avec FORMS,
Open-Canopy et la BD Forêt v3 en variables d'entrée ou de contrôle et les cartes ONF en
contrôle ; l'accès aux placettes de l'ONF, vraie dépendance, est instruit au cadrage,
séparément de la question de son code.

## Contexte

Deux questions distinctes :
1. **Placettes ONF** : ~40 sites calibrés depuis 2007 (~800 000 ha), Observatoires
   forestiers en Bourgogne-Franche-Comté, protocole de 15 m au GNSS. Accès, droits,
   format : à demander à l'ONF au cadrage.
2. **Code ONF** : en 2015, métriques par LASManager (logiciel maison), segmentation sous
   ArcGIS 10.0 (propriétaire), modèles sous R (Monnet et Munoz, 2015, p. 95-96) ; chaîne
   actuelle non vérifiée.

Options envisagées :
1. Étendre la chaîne ONF : départ rapide, mais héritage probable d'un logiciel maison et
   d'un logiciel propriétaire.
2. Chaîne nouvelle sans socle : refait tout.
3. Cartes ONF en variables d'entrée seulement : support de 700 m² différent de la grille
   (ADR 0001) ; couverture à vérifier.
4. **Chaîne nouvelle sur socle lidaRtRee** : retenue. Le paquet fait déjà la
   calibration et la cartographie par approche surfacique, le recalage des placettes et
   la segmentation.

Si le code ONF devient partageable et libre, cette ADR peut être remplacée.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un socle libre existant, déjà utilisé par la recherche de Grenoble | — | Oui |
| **R**esponsable | Qui fait quoi ? | Le projet tient sa chaîne ; l'ONF reste partenaire pour les placettes | Une demande à l'ONF | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Dépendance à lidaRtRee et lidR (maintenance de lidR : ADR 0011) | Reprise possible | Oui |
| **N**ovateur | Idées étranges ? | Option 3 examinée | — | — |
| **C**oût | Coût à l'ensemble ? | Développement plus long que l'extension ONF | Temps | Oui |
| **É**cologique | Réutilisation ? | Chaîne libre ; réutilise lidaRtRee | Ne réutilise pas le code ONF | Oui |

## Valeurs sacrifiées

- La vitesse de départ qu'offrirait la chaîne ONF.
- L'indépendance vis-à-vis de lidaRtRee et lidR.

## Sources

- Monnet et Munoz, RFPT n° 211-212, 2015, p. 95-96 : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079
- ONF, webinaire Theia, 26 mars 2024 : https://www.theia-land.fr/wp-content/uploads/2024/03/26032024_Webinaire_ART_Theia_ModelisationLIDAR.pdf
- lidaRtRee : https://lidar.pages-forge.inrae.fr/lidaRtRee/
- Cartes ONF (couverture à vérifier) : https://www.ign.fr/lidar-hd-foret
- FORMS : https://essd.copernicus.org/articles/15/4927/2023/ ; Open-Canopy : https://arxiv.org/pdf/2407.09392

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

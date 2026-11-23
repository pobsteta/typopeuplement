# ADR 0014 — Diffusion sans dégradation, public = privé ; licences GPL-3 et Etalab 2.0

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après l'ADR 0008 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par l'arbitrage C14 et par l'apport « licences »
- **Tranchée par :** Pascal (arbitrage C14 et apports, 2026-11-23)
- **Remplace (sans l'effacer) :** brief, tableau des risques : « Données fines sensibles en forêt privée : résolution dégradée en diffusion publique, comme dans le Vercors drômois »

## La décision en une phrase

La diffusion ne fait **aucune différence entre forêt publique et forêt privée** : la
meilleure précision possible, **sans dégradation**, partout ; le code est sous **GPL-3**
(fichier `LICENSE`) et les données publiées sous **Licence Ouverte Etalab 2.0** ; un risque
est inscrit : la carte précise croisée avec le cadastre est peut-être une donnée
personnelle, à vérifier avant la première diffusion publique.

## Contexte

- A posait la dégradation en diffusion publique comme parade acquise. B la laissait ouverte
  (deux niveaux ou aucun) jusqu'à l'avis d'un juriste et organisait la remise du produit
  complet par le CNPF ou l'ONF.
- Les données d'entrée sont déjà ouvertes sur les forêts privées (MNH LiDAR HD à 50 cm, selon
  B) : dégrader le produit ne protégeait que l'interprétation (type, capital).
- Arbitrage C14 (Pascal) : aucune différence public / privé ; meilleure précision, sans
  dégradation, partout.

**Conséquences de C14** :
- plus de circuit de remise par le CNPF ou l'ONF, plus de couche des forêts publiques à
  entretenir pour savoir où dégrader ;
- les **métriques sont calculées depuis le LiDAR HD partout** ; les rasters ONF servent de
  contrôle (ADR 0015) : qualité égale partout ;
- la règle des pixels de bord ne sert plus à protéger une parcelle voisine.

**Licences** (apport retenu) :
- **Code : GPL-3**. Le fichier `LICENSE` est le texte de la GPL version 3. Le socle est sous
  GPL (lidaRtRee et lidR GPL-3, terra GPL ≥ 3, CAST GPL ≥ 2, relevé par B avec
  `packageDescription()` le 2026-11-23) ; Marculus est sous GPL-3.0. Que la GPL figure dans
  la liste des licences à réciprocité du décret n° 2017-638 (art. D. 323-2-1 du CRPA) est
  « à notre connaissance » dans B : **à confirmer sur Légifrance**.
- **Données : Licence Ouverte Etalab 2.0**, comme le MNH LiDAR HD et la BD Forêt v3 dont
  elles dérivent.

**Risque inscrit (cadastre)** : une carte précise croisée avec le cadastre pourrait
révéler des données sur des personnes (donnée personnelle ?). La vérification est requise
**avant la première diffusion publique** ; qui la fait, et comment, n'est pas dit.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un seul produit, pas de service d'accès, pas de dégradation | — | Oui |
| **R**esponsable | Qui fait quoi ? | Pascal vérifie le risque cadastre avant diffusion publique | Une vérification | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Qualification de donnée personnelle : on ne diffuse pas avant de savoir | Retard éventuel | Oui |
| **N**ovateur | Idées étranges ? | Options « deux niveaux » et « remise par organisme » examinées puis écartées | — | — |
| **C**oût | Coût à l'ensemble ? | Pas de service à tenir ; calcul unique | — | Oui |
| **É**cologique | Réutilisation ? | Licences ouvertes, compatibles avec le socle et les sources | — | Oui |

## Valeurs sacrifiées

- La protection par dégradation de la lecture fine des forêts privées.
- Le contrôle de qui obtient le produit complet.

## Sources

Reprises de l'ADR 0008 de B ; non reconsultées le 2026-11-23.

- Licence Ouverte Etalab 2.0 : https://www.etalab.gouv.fr/wp-content/uploads/2017/04/ETALAB-Licence-Ouverte-v2.0.pdf
- Licences réglementaires : https://www.data.gouv.fr/licences
- MNH LiDAR HD : https://www.data.gouv.fr/datasets/mnh-lidar-hd
- BD Forêt v3 : https://www.data.gouv.fr/datasets/jeu-de-donnees-test-bd-foret-v3-juin-2026-beta
- Vercors drômois : https://www.data.gouv.fr/datasets/parametres-forestiers-lidar-vercors-dromois-2021-2022-1
- Texte de la GPL version 3 : `LICENSE` (copie de `/usr/share/common-licenses/GPL-3`).

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0010 — Placettes : sources publiques, contrôles, protocole commun avec couvert des strates

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après l'ADR 0004 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par l'arbitrage C9 et par les apports retenus
- **Tranchée par :** Pascal (arbitrage C9 et apports, 2026-11-23)
- **Précise :** spec, « Données manipulées » et critère 6 ; journal du 2026-11-22 (placettes IFN au kilomètre : contrôle, jamais calibration)

## La décision en une phrase

La calibration ne repose que sur des placettes de 15 m de rayon géolocalisées au mètre
près, relevées selon le protocole ONF de la placette de 15 m **complété par le relevé du
couvert des strates**, contrôlées contre le MNH LiDAR HD avant usage et tirées de sources
**publiques** ; il n'y a aucun contact ONF et la demande de placettes ONF est abandonnée ;
les placettes IFN, publiées au kilomètre, ne servent qu'à valider des agrégats.

## Contexte

Les coordonnées IFN sont publiques au kilomètre ; l'IGN ne donne pas d'accès aux
coordonnées exactes (Pascal, 2026-11-23). Les 1 016 placettes de 2020 sont antérieures au
LiDAR HD (vols 2016 à 2019 à 3 à 5 points/m² ; écart de l'ordre de 2 à 7 ans avec le
LiDAR HD, chiffres de B).

**Sources (arbitrage C9)** : « pas de contact ONF » est maintenu ; la demande de placettes
ONF, que B voulait instruire au cadrage, est abandonnée. Les placettes viennent de
**sources publiques** ; la voie par le CNPF ou par des experts est **à trancher plus tard**.

**Protocole** : on part du protocole ONF de la placette de 15 m décrit par les sources
publiques citées dans B (essence, diamètre à 1,30 m, distance et azimut, centre au GNSS de
précision), complété par :
- rayon mesuré à l'horizontale ;
- origine des tiges (franc-pied ou rejet) ;
- état (vivant, mort, chablis) ;
- perches sur une partie des placettes ;
- **couvert de chacune des strates** (apport de la réconciliation, pour la clé GSM : les
  strates sont des quarts de la Hₒ potentielle et leur couvert se relève en dixièmes ; ADR 0008,
  `docs/referentiels/typologie-h10.md`, ligne 44) ;
- **position des arbres obligatoire** pour les placettes nouvelles.
Méthode de référence : White, Wulder et al., 2013 (FI-X-010). La liste d'arbres (essence,
diamètre, origine) ne suffit pas à appliquer la clé GSM : c'est la raison du couvert des
strates.

**Placettes anciennes** : utilisées seulement si cohérentes avec le MNH LiDAR HD et sans
coupe détectée entre relevé et vol ; écart maximal en années fixé au pilote (aucune source
pour un chiffre aujourd'hui).

**Recalage** : appariement arbres–MNH (Monnet et Mermin, 2014, implémenté dans lidaRtRee),
seulement pour les placettes qui ont la position des arbres ; validé en futaie résineuse
irrégulière, pas en feuillus.

**Contrôles à l'import** : placette dans l'emprise Lambert-93 de sa SER ; détection de X
et Y inversés et de coordonnées WGS84 non converties ; cohérence avec le MNH.

**Placette et pixel** : la référence de validation est une placette de 15 m centrée sur
le centre d'un pixel (ADR 0006).

**Inventaire par SER pilote** (`acquereur`) : nombre de placettes à rayon fixe au GNSS de
précision ; format (rayon fixe, relascope, concentrique) ; détenteur des droits
(propriétaire pour les PSG) ; ce qui est public. Les Observatoires forestiers ONF
(~40 sites calibrés depuis 2007, selon B) ne sont retenus que si des données publiques
existent, ce qui n'a pas été vérifié.

**Données de test** (lidaRtRee 4.0.9, examinées par B le 2026-11-23, non revues ici) :
- `quatre_montagnes` : 96 placettes de 15 m de rayon en 24 grappes de 4 (Vercors,
  Lambert-93), avec G, N, diamètre moyen et 52 métriques LiDAR, **sans essence ni liste
  d'arbres**, sur un vol antérieur au LiDAR HD ;
- `tree_inventory_chablais3` et `chm_chablais3` : inventaire en plein de 50 × 50 m
  (arbres ≥ 7,5 cm, position, essence, diamètre, hauteur, état) et son MNH, juillet 2010.
Ils ne suffisent pas à valider le type ; ils servent de **données de test** de la chaîne
(contrôle de cohérence des métriques dans le Vercors ; recalage ; **segmentation des
houppiers contre des arbres mesurés**, ADR 0016).

Options envisagées :
1. Convention IGN pour les coordonnées exactes : écartée par Pascal.
2. **Placettes propres géolocalisées, sources publiques, IFN en agrégats** : retenue.
3. Placettes d'autres rayons (17 m, etc.) : écartées.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un protocole de 15 m connu, complété du couvert des strates | Contrôle de chaque placette ancienne | Oui |
| **R**esponsable | Qui fait quoi ? | Le projet contrôle et harmonise ; CNPF et experts : plus tard | Conventions de données | À organiser |
| **A**nticiper | Si l'imprévu arrive ? | Peu de placettes publiques : échantillonnage stratifié, modèle de GRECO | Placettes nouvelles | Oui |
| **N**ovateur | Idées étranges ? | Recalage sur MNH, LiDAR terrestre | — | — |
| **C**oût | Coût à l'ensemble ? | Pas de calibration IFN ni de placettes ONF : plus de terrain | Terrain, à chiffrer | Oui |
| **É**cologique | Réutilisation ? | Protocole à publier | Rédaction | Oui |

## Valeurs sacrifiées

- La couverture nationale gratuite des placettes IFN pour la calibration.
- Les placettes de l'ONF, que la décision « pas de contact ONF » rend inaccessibles.
- La certitude sur le volume de calibration : inconnu tant que l'inventaire n'est pas fait.

## Sources

Reprises de l'ADR 0004 de B, non reconsultées le 2026-11-23.

- data.gouv.fr, données brutes IFN (coordonnées au km) : https://www.data.gouv.fr/datasets/donnees-brutes-de-l-inventaire-forestier
- Monnet J.-M., Mermin E., Forests 5(9), 2014, p. 2307-2326, DOI 10.3390/f5092307 : https://mdpi.com/1999-4907/5/9/2307
- lidaRtRee, recalage : https://lidar.pages-forge.inrae.fr/lidaRtRee/articles/coregistration.html
- lidaRtRee, préparation des données ABA (`quatre_montagnes`) : https://lidar.pages-forge.inrae.fr/lidaRtRee/articles/area-based.1.data.preparation.html
- Monnet J.-M., thèse, 2011 (Chablais 3) : https://theses.hal.science/tel-00652698/document
- ONF, webinaire Theia, 26 mars 2024 : https://www.theia-land.fr/wp-content/uploads/2024/03/26032024_Webinaire_ART_Theia_ModelisationLIDAR.pdf
- White J.C., Wulder M.A. et al., FI-X-010, 2013 : https://publications.gc.ca/site/eng/446184/publication.html

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

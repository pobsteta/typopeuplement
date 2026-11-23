# ADR 0004 — Placettes : sources, contrôle, protocole commun

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** sujet proposé par le contradicteur, rédigée par Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

La calibration ne repose que sur des placettes de 15 m de rayon géolocalisées au mètre
près, relevées selon le protocole ONF complété, et contrôlées contre le MNH LiDAR HD
avant usage ; les placettes IFN, publiées au kilomètre, ne servent qu'à valider des
agrégats.

## Contexte

Coordonnées IFN publiques au kilomètre ; l'IGN ne donne pas d'accès aux coordonnées
exactes (Pascal, 2026-11-23). Les 1 016 placettes de 2020 sont antérieures au LiDAR HD
(vols 2016-2019 à 3-5 pts/m² ; écart avec le LiDAR HD de l'ordre de 2 à 7 ans).

**Protocole** : on part du protocole ONF existant (placette de 15 m : essence, diamètre
à 1,30 m, distance et azimut, centre au GNSS de précision), complété par : rayon mesuré
à l'horizontale ; origine des tiges (franc-pied ou rejet) ; état (vivant, mort,
chablis) ; perches sur une partie des placettes. **Position des arbres obligatoire**
pour les placettes nouvelles. Méthode de référence : White, Wulder et al., 2013
(FI-X-010).

**Placettes anciennes** : utilisées seulement si cohérentes avec le MNH LiDAR HD et sans
coupe détectée entre relevé et vol ; écart maximal en années fixé au pilote (pas de
source pour un chiffre aujourd'hui).

**Recalage** : appariement arbres–MNH (Monnet et Mermin, 2014, implémenté dans
lidaRtRee), seulement pour les placettes qui ont la position des arbres ; validé en
futaie résineuse irrégulière, pas en feuillus.

**Inventaire réel par SER pilote** (`acquereur`) : nombre de placettes à rayon fixe au
GNSS de précision ; format (rayon fixe, relascope, concentrique) ; détenteur des droits
(propriétaire pour les PSG) ; Observatoires forestiers ONF et ses ~40 sites calibrés
depuis 2007.

**Contrôle à l'import** : placette dans l'emprise Lambert-93 de sa SER ; détection de X
et Y inversés et de coordonnées WGS84 non converties ; cohérence avec le MNH.

**Données de test** (examinées le 2026-11-23, à la demande de Pascal) : le paquet
lidaRtRee 4.0.9 contient
- `quatre_montagnes` : 96 placettes de 15 m de rayon en 24 grappes de 4 (Vercors,
  Lambert-93, public et privé), avec G, N, diamètre moyen et 52 métriques LiDAR, mais
  **sans essence ni liste d'arbres** et sur un vol antérieur au LiDAR HD ;
- `tree_inventory_chablais3` et `chm_chablais3` : un inventaire en plein de 50 × 50 m
  (arbres ≥ 7,5 cm, position, essence, diamètre, hauteur, état) et son MNH, juillet 2010.

Ces jeux ne suffisent pas à valider le type (pas d'essence, une seule zone, vols
anciens) ; ils servent de **données de test** de la chaîne (calcul au disque de 15 m,
recalage, application de la clé sur une liste d'arbres, régressions G/N/D) et de
contrôle de cohérence des métriques dans le Vercors.

Options envisagées :
1. Convention IGN pour les coordonnées exactes : écartée par Pascal.
2. **Placettes propres géolocalisées + IFN en agrégats** : retenue.
3. Placettes d'autres rayons (17 m, etc.) : écartées.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Reprendre le protocole ONF et les placettes existantes contrôlées | Contrôle de chaque placette ancienne | Oui |
| **R**esponsable | Qui fait quoi ? | ONF et CNPF fournissent, le projet contrôle et harmonise | Conventions de données | À organiser |
| **A**nticiper | Si l'imprévu arrive ? | Peu de placettes utilisables : échantillonnage stratifié, modèle de GRECO | Placettes nouvelles | Oui |
| **N**ovateur | Idées étranges ? | Recalage sur MNH, Observatoires ONF, LiDAR terrestre | — | — |
| **C**oût | Coût à l'ensemble ? | Pas de calibration IFN : plus de terrain | Terrain, à chiffrer après inventaire | Oui |
| **É**cologique | Réutilisation ? | Protocole ONF complété, à publier | Rédaction | Oui |

## Valeurs sacrifiées

- La couverture nationale gratuite des placettes IFN pour la calibration.
- Les placettes d'autres rayons.
- La certitude sur le volume de calibration : inconnu tant que l'inventaire n'est pas fait.

## Sources

- data.gouv.fr, données brutes IFN (coordonnées au km) : https://www.data.gouv.fr/datasets/donnees-brutes-de-l-inventaire-forestier
- Monnet J.-M., Mermin E., Forests 5(9), 2014, p. 2307-2326, DOI 10.3390/f5092307 : https://mdpi.com/1999-4907/5/9/2307
- lidaRtRee, recalage : https://lidar.pages-forge.inrae.fr/lidaRtRee/articles/coregistration.html
- lidaRtRee, préparation des données ABA (`quatre_montagnes`) : https://lidar.pages-forge.inrae.fr/lidaRtRee/articles/area-based.1.data.preparation.html
- Monnet J.-M., thèse, 2011 (Chablais 3) : https://theses.hal.science/tel-00652698/document
- ONF, webinaire Theia, 26 mars 2024 : https://www.theia-land.fr/wp-content/uploads/2024/03/26032024_Webinaire_ART_Theia_ModelisationLIDAR.pdf
- White J.C., Wulder M.A. et al., FI-X-010, 2013 : https://publications.gc.ca/site/eng/446184/publication.html

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

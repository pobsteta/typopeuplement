# Index des ADR

Un seul endroit pour retrouver quelle ADR porte quelle décision. Les ADR ne s'effacent pas :
une correction est une ligne datée qui renvoie à l'ancienne.

## ADR 0001 à 0004 : la stack (2026-11-22)

| ADR | Sujet |
|---|---|
| [0001](0001-stack-python-libre.md) | Python libre (remplacée par 0004) |
| [0002](0002-langage-rust-ou-python.md) | Rust ou Python (remplacée par 0003) |
| [0003](0003-pas-de-rust-mesurer-sur-une-aoi.md) | Pas de Rust ; mesurer sur une AOI |
| [0004](0004-r-package-compagnon-de-nemeton.md) | R, package compagnon de nemeton |

## ADR 0005 à 0017 : réconciliation des cadrages A et B (2026-11-23)

Deux cadrages ont été faits en parallèle : A (ce dépôt, PR n° 2) et B (branche locale
`docs/cadrage` de `/home/pascal/dev/typopeuplement`, commit 7b714f1, 13 ADR). Pascal a
tranché le 2026-11-23 ; ses arbitrages priment sur A et sur B. **C1 à C14 sont les
arbitrages de Pascal** (au journal), à ne pas confondre avec les points C1 à C17 de la
critique du contradicteur de B. Les 13 ADR de B ont été reprises, corrigées par les
arbitrages, sous de nouveaux numéros.

| ADR | Sujet | Arbitrages | ADR de B reprise |
|---|---|---|---|
| [0005](0005-grille-de-26-6-m-et-reechantillonnage.md) | Grille de 26,6 m, rééchantillonnage Sentinel | C8 | 0001 |
| [0006](0006-validation-reference-critere-et-confiance.md) | Validation : pixel, grappes, critère, CV spatiale, appartenance, confiance | C5, C6, C11, C12, C13 | 0002 |
| [0007](0007-seuils-par-referentiel-et-surface-terriere-par-classe.md) | Seuils par référentiel ; G par classe × groupe d'essences | C1 | 0003 |
| [0008](0008-legendes-srgs-gsm-et-type-generique.md) | Légendes SRGS, GSM, type générique ; hauteur potentielle dans la clé ; forêt pilote | C2, C3, forêt pilote | 0006 |
| [0009](0009-hauteur-potentielle.md) | Hauteur potentielle : méthode, critère, repli | C2, C4 | 0007 |
| [0010](0010-placettes-sources-et-protocole.md) | Placettes : sources publiques, protocole, couvert des strates | C9, apports | 0004 |
| [0011](0011-emprises-et-aire-d-applicabilite.md) | Emprises, aire d'applicabilité | apports | 0005 |
| [0012](0012-continuite-aux-limites.md) | Continuité aux limites de SER et de blocs LiDAR | apports | 0012 |
| [0013](0013-echelle-aoi-formats-codes-et-metadonnees.md) | Échelle AOI, formats, codes, métadonnées, DOI | C7 | 0010 |
| [0014](0014-diffusion-sans-degradation-et-licences.md) | Diffusion sans dégradation ; licences | C14, apports | 0008 |
| [0015](0015-reprise-de-l-existant-et-pas-de-contact-onf.md) | Reprise de l'existant, pas de contact ONF | C9, C10, C14 | 0009 |
| [0016](0016-nuage-de-points-lasr-isole-pdal-et-reproductibilite.md) | Nuage de points, reproductibilité | C10, apports | 0011 |
| [0017](0017-versions-calendaires-tags-et-releases.md) | Versions calendaires `vAAAA.MM.N` | décision de Pascal | 0013 |

Les renvois internes de B (« ADR 0003 », « A14 », « I4 »…) ne valent plus : lire cette table.
Les arbitrages eux-mêmes sont inscrits au journal (`pilotage/journal.md`, lignes du
2026-11-23 « · Pascal · — · »).

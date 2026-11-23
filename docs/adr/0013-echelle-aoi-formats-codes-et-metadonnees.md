# ADR 0013 — Échelle (calcul par AOI), formats de sortie, codes « sans donnée », métadonnées et dépôt

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après le cadrage A (calcul par AOI) et l'ADR 0010 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par l'arbitrage C7
- **Tranchée par :** Pascal (arbitrage C7, 2026-11-23 ; calcul par AOI : arbitrage B1 du 2026-11-22)
- **Précise :** ADR 0004 (« GeoTIFF ou COG ») ; spec, critère 8 et « Livrables, par AOI »

## La décision en une phrase

Le calcul se fait **par AOI** ; la SER, puis le national à terme, s'obtiennent par
**assemblage d'AOI** ; toute livraison **publiée** est en COG, une couche par variable avec
son style QGIS, les codes « sans donnée » étant des valeurs de classe décrites par une
table d'attributs de raster, immuable, millésimée `vAAAA.MM.N` (ADR 0017) avec celui de ses
sources, décrite en STAC et en INSPIRE / ISO 19115, et déposée avec un DOI.

## Contexte

- A : calcul par AOI, une forêt ou au plus un massif, jamais la France d'un coup (brief,
  arbitrage B1 de Pascal, 2026-11-22). B : cartes par SER, millésimes nationaux, dépôt avec
  DOI, stockage national estimé.
- Arbitrage C7 : l'AOI reste l'unité de calcul ; DOI, millésime, STAC et INSPIRE (B) valent
  pour **toute livraison publiée**. Les livraisons de travail non publiées ne sont pas
  concernées par cette exigence.
- Aujourd'hui `ecrire_livrables()` écrit des GeoTIFF simples ; les codes « sans donnée » sont
  « pas encore portés » (`R/typer_peuplements.R`).

Options envisagées pour le format (B) :
1. **COG + tables CSV / GeoPackage + STAC + INSPIRE** : retenue.
2. GeoPackage raster : un seul fichier, lecture distante moins efficace.
3. Zarr / NetCDF : adapté aux séries, moins familier des gestionnaires.

**Liste unique des codes** (reprise partout par lien ; un GeoTIFF n'a qu'un nodata par
bande) :

| Code | Sens |
|---|---|
| 250 | Hors emprise de calcul (non-forêt, ADR 0011) |
| 251 | Hors couverture LiDAR HD |
| 252 | ZICAD (zone interdite à la captation aérienne) |
| 253 | Hors domaine de validité (aire d'applicabilité, ADR 0011) |
| 255 | Vrai vide (nodata) |

(Le code 254 n'est pas attribué dans la liste de B.) Couches catégorielles : codes dans
la couche, table d'attributs de raster (RAT) dans le `.aux.xml`. Couches continues : une
couche de codes séparée, commune. STAC : extension *classification*
(`classification:classes`, drapeau nodata par classe).

**Métadonnées** : STAC pour l'usage technique ; INSPIRE / ISO 19115 moissonnables par le
Géocatalogue, probablement obligatoires pour des organismes publics (applicabilité au
porteur et au thème : à confirmer).

**Version** : le millésime d'une livraison est la version de la chaîne (ADR 0017) plus le
millésime de chaque source ; une livraison est immuable ; une mise à jour crée un millésime.

**Dépôt** : dépôt pérenne avec DOI (Recherche Data Gouv ou Zenodo), signalé sur
data.gouv.fr ; canal exact à trancher. La diffusion elle-même : ADR 0014.

**À vérifier au pilote** : lecture des COG et des styles dans QField (terrain hors réseau).
Le stockage national estimé par B (« quelques dizaines de Go par millésime », ordre de
grandeur non sourcé, calculé pour des pixels de 25 m) est à recalculer pour 26,6 m ; il est
sans objet tant qu'on calcule par AOI.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | AOI comme unité ; formats standard de GDAL | Plusieurs fichiers par AOI | Oui |
| **R**esponsable | Qui fait quoi ? | La chaîne écrit les métadonnées, pas l'opérateur | Deux jeux de métadonnées à générer | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Formats ouverts, dépôt pérenne avec DOI ; assemblage d'AOI à vérifier | — | Oui |
| **N**ovateur | Idées étranges ? | Options 2 et 3 examinées | — | — |
| **C**oût | Coût à l'ensemble ? | Stockage modeste par AOI | À mesurer au pilote | Oui |
| **É**cologique | Réutilisation ? | Lisible par tous les SIG libres ; moissonnable par le Géocatalogue | — | Oui |

## Valeurs sacrifiées

- La simplicité d'un fichier unique par livraison.
- La légèreté documentaire : deux jeux de métadonnées (STAC et INSPIRE) à tenir.
- Le produit national d'un seul tenant : il s'assemble, avec le risque de coutures entre AOI
  (ADR 0012).

## Sources

Reprises de l'ADR 0010 de B ; non reconsultées le 2026-11-23.

- GDAL, pilote COG : https://gdal.org/drivers/raster/cog.html
- Extension STAC classification : https://github.com/stac-extensions/classification
- STAC : https://stacspec.org/
- Directive INSPIRE 2007/2/CE : https://eur-lex.europa.eu/eli/dir/2007/2/oj
- MNH LiDAR HD, ZICAD en nodata : https://www.data.gouv.fr/datasets/mnh-lidar-hd
- Dans A : `docs/brief-typologie-peuplements.md` (périmètre), `R/typer_peuplements.R` (`ecrire_livrables()`).

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0010 — Formats de sortie, codes « sans donnée », métadonnées et versions

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

Les rasters sont livrés en COG, une couche par variable avec son style QGIS, les codes
« sans donnée » étant des valeurs de classe décrites par une table d'attributs de raster ;
chaque livraison, immuable, porte le millésime de la chaîne (`vAAAA.MM.N`) et de ses
sources, est décrite en STAC et en INSPIRE / ISO 19115, et déposée dans un dépôt pérenne
avec DOI.

## Contexte

Options envisagées :
1. **COG + tables CSV / GeoPackage + STAC + INSPIRE** : retenue.
2. GeoPackage raster : un seul fichier, lecture distante moins efficace.
3. Zarr / NetCDF : adapté aux séries, moins familier des gestionnaires.

**Liste unique des codes** (reprise partout par lien ; un GeoTIFF n'a qu'un nodata par
bande) :

| Code | Sens |
|---|---|
| 250 | Hors emprise de calcul (non-forêt, ADR 0005) |
| 251 | Hors couverture LiDAR HD |
| 252 | ZICAD (zone interdite à la captation aérienne) |
| 253 | Hors domaine de validité (aire d'applicabilité, ADR 0005) |
| 255 | Vrai vide (nodata) |

Couches catégorielles : codes dans la couche, table d'attributs de raster (RAT) dans le
`.aux.xml`. Couches continues (nombres réels) : une couche de codes séparée, commune.
STAC : extension *classification* (`classification:classes`, drapeau nodata par classe).

**Métadonnées** : STAC pour l'usage technique ; INSPIRE / ISO 19115 moissonnables par le
Géocatalogue, probablement obligatoires pour des organismes publics (applicabilité au
porteur et au thème à confirmer).

**Versions** : millésime = version de la chaîne (`vAAAA.MM.N`, ADR 0013) + millésime de
chaque source ; une livraison est immuable ; une mise à jour crée un millésime.

**Dépôt** : dépôt pérenne avec DOI (Recherche Data Gouv ou Zenodo), signalé sur
data.gouv.fr ; canal exact à trancher avec l'ADR 0008.

**À vérifier au pilote** : lecture des COG et des styles dans QField (terrain hors
réseau) ; stockage, ordre de grandeur non sourcé de quelques dizaines de Go par millésime
national (~17 Mha, ~2,8 × 10⁸ pixels de 25 m, ~1 Go par bande float32 non compressée,
une trentaine de bandes).

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Formats standard de GDAL | Plusieurs fichiers par SER | Oui |
| **R**esponsable | Qui fait quoi ? | La chaîne écrit les métadonnées, pas l'opérateur | Deux jeux de métadonnées à générer | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Formats ouverts, dépôt pérenne avec DOI | — | Oui |
| **N**ovateur | Idées étranges ? | Options 2 et 3 examinées | — | — |
| **C**oût | Coût à l'ensemble ? | Quelques dizaines de Go par millésime (estimation) | Stockage modeste | Oui |
| **É**cologique | Réutilisation ? | Lisible par tous les SIG libres ; moissonnable par le Géocatalogue | — | Oui |

## Valeurs sacrifiées

- La simplicité d'un fichier unique par livraison.
- La légèreté documentaire : deux jeux de métadonnées (STAC et INSPIRE) à tenir.

## Sources

- GDAL, pilote COG : https://gdal.org/drivers/raster/cog.html
- Extension STAC classification : https://github.com/stac-extensions/classification
- STAC : https://stacspec.org/
- Directive INSPIRE 2007/2/CE : https://eur-lex.europa.eu/eli/dir/2007/2/oj
- MNH LiDAR HD, ZICAD en nodata : https://www.data.gouv.fr/datasets/mnh-lidar-hd

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# typopeuplement

[![CI](https://github.com/pobsteta/typopeuplement/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/pobsteta/typopeuplement/actions/workflows/ci.yml)
[![Release](https://github.com/pobsteta/typopeuplement/actions/workflows/release.yml/badge.svg)](https://github.com/pobsteta/typopeuplement/actions/workflows/release.yml)
[![Version](https://img.shields.io/github/v/release/pobsteta/typopeuplement?label=version)](https://github.com/pobsteta/typopeuplement/releases/latest)
[![Couverture](.github/badges/couverture.svg)](https://github.com/pobsteta/typopeuplement/actions/workflows/ci.yml)
[![Site](https://img.shields.io/badge/site-pkgdown-blue)](https://pobsteta.github.io/typopeuplement/)
[![R](https://img.shields.io/badge/R-%E2%89%A5%204.1-276DC3)](https://www.r-project.org/)
[![Licence :
GPL-3](https://img.shields.io/badge/licence-GPL--3-blue)](https://pobsteta.github.io/typopeuplement/LICENSE)

Package R qui produit, pour une forêt ou un massif (AOI), une carte du
**type de peuplement** calibrée par sylvoécorégion (SER), avec sa
**probabilité** et une **couche de confiance** qui dit quand s’en
méfier. Package compagnon de
[nemeton](https://github.com/pobsteta/nemeton) (ADR 0004).

Le projet est décrit dans
[`docs/brief-typologie-peuplements.md`](https://github.com/pobsteta/typopeuplement/tree/main/docs/brief-typologie-peuplements.md)
et
[`docs/spec.md`](https://github.com/pobsteta/typopeuplement/tree/main/docs/spec.md).
Son pilotage (méthode de l’Impératrice) est dans
[`pilotage/`](https://github.com/pobsteta/typopeuplement/tree/main/pilotage).

## Où en est-on

- **SER pilote** : H10 « Préalpes du Nord ». AOI pilote : Vercors
  drômois, forêt pilote : la forêt domaniale de Léoncel.
- **Typologie visée** : typologie de structure du Guide des
  sylvicultures de montagne Alpes du Nord
  (`docs/referentiels/typologie-h10.md`). Sa clé est en cours de
  transcription : **aucune carte de H10 n’est encore publiée**.
- **Ce qui tourne** :
  - la chaîne complète sur jeu synthétique ;
  - la lecture des rasters ONF du Vercors drômois (mode « variables
    fournies », pixel de 26,6 m) ;
  - le relief tiré du MNT de l’IGN et la hauteur potentielle ;
  - le couvert des strates du GSM à partir du nuage LiDAR HD de l’IGN.

## Ce que fait la chaîne

| Étape | Fonctions | Ce qui est codé |
|----|----|----|
| Lecture des données | [`lire_parametres_lidar()`](https://pobsteta.github.io/typopeuplement/reference/lire_parametres_lidar.md), [`couches_onf()`](https://pobsteta.github.io/typopeuplement/reference/couches_onf.md) | Rasters ONF découpés à l’AOI, sur leur grille d’origine |
| Variables dendrométriques | [`ajuster_modeles_dendro()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_modeles_dendro.md), [`predire_dendro()`](https://pobsteta.github.io/typopeuplement/reference/predire_dendro.md) | Une forêt aléatoire par variable, quand on a des placettes |
| Milieu et hauteur potentielle | [`calculer_relief()`](https://pobsteta.github.io/typopeuplement/reference/calculer_relief.md), [`milieu_pixels()`](https://pobsteta.github.io/typopeuplement/reference/milieu_pixels.md), [`ajuster_hauteur_potentielle()`](https://pobsteta.github.io/typopeuplement/reference/ajuster_hauteur_potentielle.md) | Relief du RGE ALTI ; hauteur potentielle apprise sur les adultes fermés, enveloppe hors sac, incertitude |
| Couvert des strates | [`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md), [`couvert_strates()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates.md) | Couvert des quatre strates du GSM à partir du nuage LiDAR HD (lasR) |
| Clé floue | [`lire_configuration()`](https://pobsteta.github.io/typopeuplement/reference/lire_configuration.md), [`classer_types()`](https://pobsteta.github.io/typopeuplement/reference/classer_types.md), [`decider_type()`](https://pobsteta.github.io/typopeuplement/reference/decider_type.md) | Seuils en sigmoïdes, « ou » entre jeux de conditions, groupe de types quand une variable manque, drapeau « entre deux types » |
| Déclinaison par SER | [`greco_de_ser()`](https://pobsteta.github.io/typopeuplement/reference/greco_de_ser.md), [`niveau_modele()`](https://pobsteta.github.io/typopeuplement/reference/niveau_modele.md), [`poids_transition()`](https://pobsteta.github.io/typopeuplement/reference/poids_transition.md) | National → grande région → SER, bande de transition sans rupture |
| Lissage, livrables | [`lisser_probabilites()`](https://pobsteta.github.io/typopeuplement/reference/lisser_probabilites.md), [`ecrire_livrables()`](https://pobsteta.github.io/typopeuplement/reference/ecrire_livrables.md) | `types.tif`, `variables.tif`, `confiance.tif`, fiche de validation |
| Validation | [`fiche_validation()`](https://pobsteta.github.io/typopeuplement/reference/fiche_validation.md), [`controle_coherence()`](https://pobsteta.github.io/typopeuplement/reference/controle_coherence.md) | Matrices de confusion à la placette et à la grappe ; contrôle de cohérence quand il n’y a pas de placettes |

## Essayer

``` sh
Rscript -e 'pkgload::load_all(); lancer_demo("sorties/demo_r")'
LC_ALL=C.UTF-8 Rscript -e 'testthat::test_local()'
```

Rapport Quarto d’une AOI (cartes, confiance, état de preuve, limites ;
démonstration sans réseau par défaut, livrables d’une AOI déjà calculée
avec `TYPO_AOI`) :
`Rscript -e 'targets::tar_make(callr_function = NULL)'` (`_targets.R`).
Site : <https://pobsteta.github.io/typopeuplement/>.

La commande de tests du projet est dans `.claude/test-command`. Le
prototype Python (`src/`, `tests/*.py`) ne sert plus que de référence de
comparaison.

## À savoir avant d’utiliser

- **La clé de `config/exemple.json` n’est pas une typologie** : ses
  types et ses seuils servent à faire tourner la chaîne.
- **Sans placettes, pas de validation indépendante** : la fiche ne donne
  alors qu’un contrôle de cohérence.
- **H0 du jeu ONF non calibrée** : la hauteur potentielle hérite de son
  biais (fiche ONF, p. 2).

## Nuage de points LiDAR HD : lasR et GDAL

Le couvert des strates du GSM
([`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md),
mission 008) lit les dalles du LiDAR HD de l’IGN avec
[lasR](https://github.com/r-lidar/lasR). lasR n’est pas sur le CRAN : il
est en `Suggests` et s’installe depuis r-universe. Il se compile et
demande GDAL (en-têtes de développement) :

``` sh
sudo apt-get install -y libgdal-dev   # Debian, Ubuntu
Rscript -e 'install.packages("lasR", repos = "https://r-lidar.r-universe.dev")'
```

Sans lasR, le reste de la chaîne tourne,
[`couvert_strates_dalle()`](https://pobsteta.github.io/typopeuplement/reference/couvert_strates_dalle.md)
s’arrête en le disant, et les tests qui lisent l’extrait de nuage sont
sautés. Une dalle de 1 km² (277 Mo, 49 millions de points, Vercors) se
traite en 2 min environ sur 4 cœurs et demande près de 9 Go de mémoire
(mesure du 2026-11-22) ; on la traite seule, puis on la supprime.

## Déployer et publier

Chaque fusion dans `main` est testée par la CI
(`.github/workflows/ci.yml`) : tests des scripts de release, puis
`bash .claude/test-command` (R testthat puis pytest), puis construction
du paquet. lasR et nemeton sont installés en CI : les tests du terrain y
tournent.

**Règle de release.** Si la CI d’un push sur `main` est verte et que le
paquet a changé, `release.yml` publie une release automatiquement, sans
geste manuel :

- **version calendaire** `vAAAA.MM.N` : `AAAA.MM` = année et mois (UTC),
  `N` = compteur du mois (repart à 1 chaque mois, `.9` puis `.10`) ; le
  type de commit ne change pas la version ;
- **tag annoté** posé sur le commit testé, archive
  `typopeuplement_AAAA.MM.N.tar.gz` (`R CMD build`) attachée, notes
  générées depuis les commits depuis le tag précédent ;
- le champ `Version` de `DESCRIPTION` est réécrit **à la construction**,
  jamais commité : la valeur du dépôt (`0.1.0`) n’est pas une version
  publiée ;
- **pas de release** si seuls `pilotage/`, `docs/`, les `*.md`,
  `.github/badges/`, `tests/` ou `.github/scripts/test-*.sh` ont changé
  depuis le dernier tag, ni si `main` a déjà avancé au-delà du commit
  testé (dans le doute, on publie) ;
- **ne pas relancer** la CI d’un commit de `main` déjà vert, ni celle
  d’un ancien commit : pour republier, ouvrir une PR.

Les titres de PR suivent les commits conventionnels (`feat:`, `fix:`,
`docs:`, …). Le badge de couverture est un SVG local écrit par la CI
dans `.github/badges/`. Installer une version :

``` r

remotes::install_github("pobsteta/typopeuplement@v2026.11.1")
```

Décision :
[`docs/adr/0017-versions-calendaires-tags-et-releases.md`](https://github.com/pobsteta/typopeuplement/tree/main/docs/adr/0017-versions-calendaires-tags-et-releases.md).

## Licence

GPL-3 (comme `DESCRIPTION` et
[`LICENSE`](https://pobsteta.github.io/typopeuplement/LICENSE)).

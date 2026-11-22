# typopeuplement

Package R qui produit, pour une forêt ou un massif (AOI), une carte du **type de
peuplement** calibrée par sylvoécorégion (SER), avec sa **probabilité** et une **couche de
confiance** qui dit quand s'en méfier. Package compagnon de
[nemeton](https://github.com/pobsteta/nemeton) (ADR 0004).

Le projet est décrit dans [`docs/brief-typologie-peuplements.md`](docs/brief-typologie-peuplements.md)
et [`docs/spec.md`](docs/spec.md). Son pilotage (méthode de l'Impératrice) est dans
[`pilotage/`](pilotage/).

## Où en est-on

- **SER pilote** : H10 « Préalpes du Nord ». AOI pilote : Vercors drômois, forêt pilote :
  la forêt domaniale de Léoncel.
- **Typologie visée** : typologie de structure du Guide des sylvicultures de montagne
  Alpes du Nord (`docs/referentiels/typologie-h10.md`). Sa clé est en cours de
  transcription : **aucune carte de H10 n'est encore publiée**.
- **Ce qui tourne** :
  - la chaîne complète sur jeu synthétique ;
  - la lecture des rasters ONF du Vercors drômois (mode « variables fournies », pixel de
    26,6 m) ;
  - le relief tiré du MNT de l'IGN et la hauteur potentielle ;
  - le couvert des strates du GSM à partir du nuage LiDAR HD de l'IGN.

## Ce que fait la chaîne

| Étape | Fonctions | Ce qui est codé |
|---|---|---|
| Lecture des données | `lire_parametres_lidar()`, `couches_onf()` | Rasters ONF découpés à l'AOI, sur leur grille d'origine |
| Variables dendrométriques | `ajuster_modeles_dendro()`, `predire_dendro()` | Une forêt aléatoire par variable, quand on a des placettes |
| Milieu et hauteur potentielle | `calculer_relief()`, `milieu_pixels()`, `ajuster_hauteur_potentielle()` | Relief du RGE ALTI ; hauteur potentielle apprise sur les adultes fermés, enveloppe hors sac, incertitude |
| Couvert des strates | `couvert_strates_dalle()`, `couvert_strates()` | Couvert des quatre strates du GSM à partir du nuage LiDAR HD (lasR) |
| Clé floue | `lire_configuration()`, `classer_types()`, `decider_type()` | Seuils en sigmoïdes, « ou » entre jeux de conditions, groupe de types quand une variable manque, drapeau « entre deux types » |
| Déclinaison par SER | `greco_de_ser()`, `niveau_modele()`, `poids_transition()` | National → grande région → SER, bande de transition sans rupture |
| Lissage, livrables | `lisser_probabilites()`, `ecrire_livrables()` | `types.tif`, `variables.tif`, `confiance.tif`, fiche de validation |
| Validation | `fiche_validation()`, `controle_coherence()` | Matrices de confusion à la placette et à la grappe ; contrôle de cohérence quand il n'y a pas de placettes |

## Essayer

```sh
Rscript -e 'pkgload::load_all(); lancer_demo("sorties/demo_r")'
LC_ALL=C.UTF-8 Rscript -e 'testthat::test_local()'
```

La commande de tests du projet est dans `.claude/test-command`. Le prototype Python
(`src/`, `tests/*.py`) ne sert plus que de référence de comparaison.

## À savoir avant d'utiliser

- **La clé de `config/exemple.json` n'est pas une typologie** : ses types et ses seuils
  servent à faire tourner la chaîne.
- **Sans placettes, pas de validation indépendante** : la fiche ne donne alors qu'un
  contrôle de cohérence.
- **H0 du jeu ONF non calibrée** : la hauteur potentielle hérite de son biais (fiche ONF,
  p. 2).

## Nuage de points LiDAR HD : lasR et GDAL

Le couvert des strates du GSM (`couvert_strates_dalle()`, mission 008) lit les dalles du
LiDAR HD de l'IGN avec [lasR](https://github.com/r-lidar/lasR). lasR n'est pas sur le
CRAN : il est en `Suggests` et s'installe depuis r-universe. Il se compile et demande
GDAL (en-têtes de développement) :

```sh
sudo apt-get install -y libgdal-dev   # Debian, Ubuntu
Rscript -e 'install.packages("lasR", repos = "https://r-lidar.r-universe.dev")'
```

Sans lasR, le reste de la chaîne tourne, `couvert_strates_dalle()` s'arrête en le disant,
et les tests qui lisent l'extrait de nuage sont sautés. Une dalle de 1 km² (277 Mo,
49 millions de points, Vercors) se traite en 2 min environ sur 4 cœurs et demande près de
9 Go de mémoire (mesure du 2026-11-22) ; on la traite seule, puis on la supprime.

## Licence

GPL-3.0-or-later.

# typopeuplement

Typologie automatique des peuplements forestiers par sylvoécorégion (SER) : pour chaque
pixel de 25 m, un **type de peuplement** (composition, structure, capital), sa
**probabilité**, et les drapeaux qui disent quand s'en méfier.

Le projet est décrit dans [`docs/brief-typologie-peuplements.md`](docs/brief-typologie-peuplements.md).
Ce dépôt contient le **socle de la chaîne** (version 0.1.0), qui tourne pour l'instant
sur données synthétiques ; les vraies sources (LiDAR HD, Sentinel-2, BD Forêt v3,
placettes) entrent par les mêmes colonnes.

## Ce que fait la chaîne

| Étape du brief | Module | Ce qui est codé |
|---|---|---|
| Variables d'abord, types ensuite | `modeles.py` | Une forêt aléatoire par variable (G, parts de résineux, PB, BM, GB), erreurs en validation croisée |
| Hauteur potentielle | `hauteur_potentielle.py` | Apprise sur les peuplements adultes fermés, par famille d'essences ; enveloppe haute ; incertitude par pixel ; rapport hauteur mesurée / potentielle, laissé vide et signalé si trop incertain |
| Seuils durs → probabilités | `cle.py` | Clé floue : chaque seuil devient une sigmoïde de « souplesse » réglable ; souplesse nulle = clé dure ; drapeau « entre deux types » |
| Triangle des structures | `dendro.py` | Surface terrière et parts PB / BM / GB par placette, seuils propres à la SER |
| Lecture au quart ou demi-hectare | `lissage.py` | Moyenne des probabilités sur une fenêtre de pixels |
| Socle national, calibration locale | `ser.py` | Configuration national → grande région → SER ; héritage du modèle de la grande région quand une SER manque de placettes ; bande de transition sans rupture aux limites |
| Validation à l'échelle de lecture | `validation.py` | Matrices de confusion, précision, kappa, à la placette et à la grappe de 0,5 ha ; fiche de validation en Markdown |
| Comparer les classifieurs | `modeles.py` | Forêts aléatoires, SVM, analyse discriminante, en validation croisée stratifiée |

## Essayer

```sh
pip install -e '.[test]'
python3 -m typopeuplement demo --sortie sorties/demo
python3 -m pytest -q
```

La démo écrit `carte_types.csv`, `fiche_validation.md`, `erreurs_variables.csv` et
`rmse_hauteur_potentielle.json`. Sur vraies données :

```sh
python3 -m typopeuplement executer --config config/exemple.json --ser exemple-vosges \
    --placettes placettes.csv --pixels pixels.csv --sortie sorties/vosges
```

## À savoir avant d'utiliser

- **La clé de `config/exemple.json` n'est pas une typologie.** Ses types, seuils et
  souplesses sont des valeurs provisoires pour faire tourner la chaîne. Chaque SER pilote
  y mettra sa clé, sourcée.
- Le calcul des métriques LiDAR HD et Sentinel-2 n'est pas encore branché : la chaîne
  prend des tableaux déjà calculés.
- Rien n'est tranché : la stack est proposée dans [`docs/adr/0001-stack-python-libre.md`](docs/adr/0001-stack-python-libre.md).

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

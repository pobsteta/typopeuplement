# ADR 0002 — Rust ou Python pour la chaîne

- **Date :** 2026-11-22
- **Statut :** remplacée par ADR 0003
- **Proposée par :** Claude (orchestrateur), à la question de Pascal
- **Tranchée par :** Pascal (à trancher)
- **Complète :** ADR 0001 (Python, bibliothèques libres), proposée elle aussi

## Ma réponse d'abord (Pascal)

« vitesse sur toutes les SER de France » — Pascal, 2026-11-22

## La décision en une phrase (proposition)

Garder Python pour la chaîne et les modèles. Mesurer d'abord où se passe le temps sur
une dalle LiDAR HD et une SER pilote. Ne passer en Rust que le noyau qui le justifie,
probablement le calcul des métriques du nuage de points, appelé depuis Python (PyO3).

## Contexte

La chaîne a trois étages, qui n'ont pas le même besoin de vitesse :

| Étage | Volume | Ce qui existe déjà | Où Rust aiderait |
|---|---|---|---|
| 1. Métriques LiDAR HD par pixel de 25 m (hauteurs, couvert, sous-étage) | Le plus lourd : tout le nuage de points des forêts | PDAL (C++), lidR (R, cœur C++), Computree (chaîne ONF) ; en Rust, les crates `las` et `copc` | Fort, si l'on écrit son propre noyau ; nul si PDAL ou lidR suffisent |
| 2. Modèles : apprentissage sur quelques milliers de placettes, prédiction sur la grille | Apprentissage léger ; prédiction proportionnelle au nombre de pixels | scikit-learn (forêts aléatoires, SVM, analyse discriminante), cœur compilé | Faible : `linfa` et `smartcore` en Rust sont bien moins complets, sans gain sûr |
| 3. Clé, lissage, raccord de SER, validation | Opérations vectorisées sur la grille | numpy, scipy (déjà codé, testé) | Faible |

Les SER se traitent indépendamment (sauf la bande de transition) : le parallélisme se
gagne d'abord en lançant plusieurs SER ou plusieurs dalles en même temps, quel que soit
le langage.

Options envisagées :

1. **Tout en Python** (état actuel).
2. **Tout en Rust** : un binaire unique et rapide ; il faut récrire les modèles.
3. **Python et noyau Rust** : la chaîne en Python, le calcul du nuage de points en Rust
   par PyO3, après mesure.
4. **Python et PDAL ou lidR** pour le nuage de points, sans écrire de noyau.

## Le crible FRANCE

| Lettre | Question | Option 3 (proposée) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Est-ce la solution la plus simple qui tienne ? | Rust seulement là où la mesure le montre ; option 4 d'abord si PDAL suffit | Deux langages dans le dépôt, si le noyau Rust devient nécessaire | à trancher |
| **R**esponsable | Qui fait quoi ? | Les forestiers et les chercheurs partenaires (ONF, INRAE, CNPF) lisent Python ou R ; le noyau Rust reste petit | Peu de partenaires pourraient maintenir du Rust | à trancher |
| **A**nticiper | Et si l'imprévu arrive ? | Le noyau Rust peut se remplacer par PDAL, et l'inverse | Une chaîne de compilation de plus à faire vivre | à trancher |
| **N**ovateur | Toutes les idées ? | Tout Rust écouté : le plus rapide à l'exécution | Récrire forêts aléatoires, SVM et analyse discriminante, et perdre scikit-learn | à trancher |
| **C**oût | Coût complet ? | inconnu : il dépend de la mesure | inconnu | à trancher |
| **É**cologique | Que réutilise-t-on ? | scikit-learn, PDAL, la chaîne ONF si elle est partageable | — | à trancher |

## Valeurs sacrifiées

- **Option 3 :** une part de la vitesse brute de l'option 2, contre la lisibilité pour
  les partenaires (test du successeur) et la richesse de scikit-learn.
- **Option 2 :** le test du successeur et la réutilisation, contre la vitesse.

## Valeur provisoire à mesurer avant de geler

Le temps de calcul d'une dalle LiDAR HD puis d'une SER pilote, étage par étage, en
Python, avec PDAL et avec un noyau Rust minimal. Sans cette mesure, le gain de Rust n'a
pas de chiffre. Aucun chiffre n'est donné ici faute de source.

## Sources

- `docs/brief-typologie-peuplements.md` : livrables, outils libres, partenaires.
- Hypothèse non sourcée : maturité comparée de `linfa` / `smartcore` et de scikit-learn,
  à vérifier par le contradicteur.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

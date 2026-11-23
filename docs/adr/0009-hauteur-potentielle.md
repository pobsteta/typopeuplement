# ADR 0009 — Hauteur potentielle : méthode, référence, critère, repli

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après le cadrage A (`R/hauteur_potentielle.R`) et l'ADR 0007 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par les arbitrages C2 et C4
- **Tranchée par :** Pascal (arbitrages C2 et C4, 2026-11-23)
- **Précise :** brief, section « Hauteur potentielle : le milieu en donnée d'entrée » (démarche, points 1 et 5) ; spec, critère 5

## La décision en une phrase

La hauteur potentielle est un **livrable conditionnel**, avec un critère d'erreur propre à
chaque SER fixé avant les résultats ; la **cible à terme** est le croisement du LiDAR HD
avec les séries annuelles de hauteur de nemetoncanopee ; d'ici là, la méthode de A reste un
prototype, confrontée aux indices de fertilité de l'IFN ; si le critère n'est pas tenu, la
clé GSM se replie sur la hauteur mesurée, et le dit.

## Contexte

- A : la hauteur potentielle est apprise sur des « adultes fermés » repérés par le LiDAR
  (couvert ≥ 0,7, hauteur ≥ 15 m ; `peuplements_adultes()`, `R/hauteur_potentielle.R`),
  avec le relief seul et une enveloppe k ; la parade était le contrôle par les courbes de
  hauteur dominante de nemeton là où l'âge est connu.
- B : repérer les adultes par le seul LiDAR est circulaire ; la fertilité n'est expliquée
  qu'à 49 à 64 % même avec un sol mesuré (chiffres rapportés par B, non relus) ; B
  proposait de réutiliser d'abord la carte de fertilité de l'ONF et les modèles d'indice de
  fertilité de l'IFN.
- Le GSM met la hauteur potentielle au cœur de sa clé (ADR 0008) : on ne peut pas s'en
  passer en H10.

### Méthode (arbitrage C4)

1. **Cible à terme** : croisement du LiDAR HD avec les séries annuelles de hauteur de
   **nemetoncanopee** (croissance en hauteur). Profondeur et précision de ces séries : **à
   vérifier** (nemetoncanopee n'a pas été consulté pour cette ADR). nemetoncanopee est un projet Python de Pascal (`pobsteta/nemetoncanopee`), distinct du paquet R nemeton : cartes annuelles de hauteur, volume et biomasse, parties de FORMS-T et améliorées par le LiDAR HD (README, 2026-11-23). La carte de fertilité de l'ONF est écartée parce qu'elle ne couvre que des sites ONF : elle ne donnerait pas une qualité égale en forêt publique et privée (arbitrage C14) ; le « pas de contact ONF » s'ajoute pour en obtenir les données.
2. **D'ici là** : la méthode de A, en **prototype**, confrontée aux indices de fertilité
   issus de l'IFN (Bontemps et Bouriaud, cités par B).
3. **Adultes** : définis par un critère extérieur au LiDAR (âge, indice de fertilité) si
   un tel critère est disponible ; sinon seul le critère LiDAR reste, et son risque de
   circularité est dit dans la fiche de validation.
4. **Pas de carte de fertilité de l'ONF** (écartée par l'arbitrage ; l'option 5 de B ne
   tient plus).
5. **Critère par SER** et **repli** (arbitrage C2).

### Critère et repli

- Seuil d'erreur et métrique fixés **par SER, avant de voir les résultats** (B). Là où il
  n'est pas tenu, il n'y a pas de couche de hauteur potentielle livrée comme telle.
- **Repli** : la clé GSM utilise la hauteur mesurée ; le repli est signalé dans la couche
  de confiance et dans la fiche de validation (ADR 0006, 0008). Conséquence : jeune
  peuplement et peuplement chétif ne sont plus séparés là où le repli joue.
- Pour le type générique national, la hauteur potentielle n'est qu'un attribut
  (ADR 0008).
- Croissance en hauteur entre deux modèles de surface successifs (option 3 de B) :
  piste, sans engagement ; elle rejoint la cible 1.

Le contrôle par les courbes de nemeton (brief de A) reste écrit, mais Pascal a répondu
« Non » à « nemeton en contrôle croisé » le 2026-11-23 (journal, mission 013) : sa portée
est à préciser.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Prototype existant ; repli toujours disponible | Deux chemins dans la clé | Oui |
| **R**esponsable | Qui fait quoi ? | Pascal fixe les critères avant résultats ; dépendance extérieure (INRAE, AgroParisTech, nemetoncanopee) nommée comme risque | Démarche de partenariat éventuelle | À organiser |
| **A**nticiper | Si l'imprévu arrive ? | Modèle en échec : repli signalé ; erreur d'essence propagée tracée | — | Oui |
| **N**ovateur | Idées étranges ? | Séries de hauteur annuelles de nemetoncanopee | Vérification de leur profondeur | Oui |
| **C**oût | Coût à l'ensemble ? | Relevés d'âge ou de sol dans les pilotes | Terrain, à chiffrer | À chiffrer |
| **É**cologique | Réutilisation ? | Carte de productivité réutilisable, sans empiéter sur la typologie des stations | Frontière avec BioClimSol à vérifier | Oui |

## Valeurs sacrifiées

- La promesse de séparer partout jeune et chétif : elle ne vaut que là où le modèle tient.
- La rapidité du prototype de A, dont les adultes sont repérés par le LiDAR.
- Le recours aux données de fertilité de l'ONF.

## Sources

Reprises de l'ADR 0007 de B. **À vérifier par un humain** : HAL et le site de la revue
avaient bloqué l'accès à B le 2026-11-23 ; ni les titres ni le chiffre de 49 à 64 % n'ont
pu être relus.

- Seynave et al., CJFR 35, 2005 : https://hal.inrae.fr/hal-02681419
- Bergès et al., Ann. For. Sci., 2006 : https://www.afs-journal.org/articles/forest/ref/2006/01/F5098/F5098.html
- Bontemps et Bouriaud, 2014 : https://hal.archives-ouvertes.fr/hal-01268953
- ONF, webinaire Theia, 26 mars 2024 (carte de fertilité, écartée ici) : https://www.theia-land.fr/wp-content/uploads/2024/03/26032024_Webinaire_ART_Theia_ModelisationLIDAR.pdf
- Dans A : `R/hauteur_potentielle.R`, `docs/referentiels/typologie-h10.md` (lignes 44 et 62), journal du 2026-11-23.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0007 — Hauteur potentielle : méthode, référence, critère, repli

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** sujet proposé par le contradicteur, rédigée par Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

La hauteur potentielle est un livrable conditionnel : modélisée par essence ou famille à
partir des variables de milieu, sur des peuplements de référence définis par l'âge ou
l'indice de fertilité, elle n'entre dans la clé que si son erreur reste sous le seuil
fixé par SER ; sinon la clé utilise la hauteur mesurée et le signale.

## Contexte

Repérer les « adultes fermés » par le seul LiDAR est circulaire. Même avec un sol mesuré,
la fertilité n'est expliquée qu'à 49 à 64 %. Options envisagées :
1. Adultes repérés par LiDAR seul (brief de cadrage) : rejeté, circulaire.
2. **Référence par âge ou indice de fertilité de placettes** : retenue ; à vérifier :
   quelles placettes portent un âge.
3. Croissance en hauteur entre deux modèles de surface successifs : piste, sans
   engagement.
4. Pas de hauteur potentielle : c'est le repli.
5. **Réutiliser l'existant d'abord** (ajout après critique) : carte de fertilité des sols
   de l'ONF tirée du LiDAR (webinaire Theia 2024, diapositive 18) et modèles d'indice de
   fertilité tirés de l'IFN (Bontemps et Bouriaud) ; notre propre modèle n'intervient
   que si ces deux options ne tiennent pas.

L'option 3 est faisable dès maintenant sur les ~40 sites ONF qui ont un vol LiDAR
antérieur au LiDAR HD ; ailleurs, elle attend un second passage du LiDAR HD.

Le seuil d'erreur et sa métrique sont à fixer au pilote, avant de voir les résultats.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Repli toujours disponible | Deux chemins dans la clé | Oui |
| **R**esponsable | Qui fait quoi ? | Aucun accord n'existe avec INRAE ni AgroParisTech : dépendance extérieure, nommée comme risque | Démarche de partenariat | À organiser |
| **A**nticiper | Si l'imprévu arrive ? | Erreur d'essence propagée : tracée dans l'incertitude | — | Oui |
| **N**ovateur | Idées étranges ? | Option 3 gardée en piste | — | — |
| **C**oût | Coût à l'ensemble ? | Relevés d'âge ou de sol dans les pilotes | Terrain | À chiffrer |
| **É**cologique | Réutilisation ? | Carte de productivité réutilisable, sans empiéter sur la typologie des stations | Frontière avec BioClimSol à vérifier | Oui |

## Valeurs sacrifiées

- La promesse de séparer partout jeune et chétif : elle ne vaut que là où le modèle tient.

## Sources

À vérifier par un humain : HAL et le site de la revue ont bloqué l'accès le 2026-11-23 ;
ni les titres ni le chiffre de 49 à 64 % n'ont pu être relus.

- ONF, webinaire Theia, 26 mars 2024 : https://www.theia-land.fr/wp-content/uploads/2024/03/26032024_Webinaire_ART_Theia_ModelisationLIDAR.pdf

- Seynave et al., CJFR 35, 2005 : https://hal.inrae.fr/hal-02681419
- Bergès et al., Ann. For. Sci., 2006 : https://www.afs-journal.org/articles/forest/ref/2006/01/F5098/F5098.html
- Bontemps et Bouriaud, 2014 : https://hal.archives-ouvertes.fr/hal-01268953

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

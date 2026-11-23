# ADR 0003 — Sortie par classes de diamètre et groupes d'essences, seuils par référentiel

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23
- **Proposée par :** sujet proposé par le contradicteur, rédigée par Claude (orchestrateur), révisée après critique
- **Tranchée par :** Pascal

## La décision en une phrase

Les modèles prédisent la surface terrière par classe de diamètre de 5 cm **et par
groupe d'essences** (au moins feuillus / résineux), plus la part de taillis ; les seuils
et les clés sont des paramètres d'une table des référentiels (SRGS, guides, DRA/SRA)
tenue par le projet et appliquée en aval ; la méthode de prédiction est choisie au
pilote parmi trois.

## Contexte

Le SRGS Auvergne-Rhône-Alpes (2023) fixe la limite des gros bois à 47,5 cm toutes
essences, 42,5 cm admis en résineux avec une typologie : il faut donc connaître la
distribution par groupe d'essences. Les types SRGS « taillis » et « mélange
futaie-taillis » demandent la part de taillis. Priorité de Pascal au type local
(ADR 0006).

Options de seuillage :
1. Seuils par SER : rejeté (contredit par le SRGS).
2. Seuils nationaux uniques : rejeté.
3. **Distribution par classes × groupes + référentiel en paramètre** : retenue.

Méthodes de prédiction de la distribution, **comparées au pilote** :
- A. un modèle par classe (somme non garantie) ;
- B. imputation de listes d'arbres par plus proches voisins (cohérente par
  construction) ;
- C. loi paramétrique (Weibull).
Piste bibliographique à vérifier par l'`acquereur` : Maltamo et Gobakken, « Predicting
tree diameter distributions », *Forestry Applications of Airborne Laser Scanning*,
Springer, 2014.

**Table des référentiels** : les SRGS sont publiés en PDF ; le projet saisit et
maintient une table versionnée (seuils, groupes d'essences, clés), relue par le CNPF et
l'ONF. C'est un livrable.

**Critères ajoutés à la spec** : erreur par classe ; erreur sur les parts PB, BM, GB
après application des seuils de chaque référentiel ; tolérance d'additivité (A5) fixée au
pilote si la méthode retenue ne la garantit pas.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un jeu de modèles, n référentiels | Sortie multibande lourde | Oui |
| **R**esponsable | Qui fait quoi ? | Le projet saisit et maintient la table ; CNPF et ONF la relisent | Saisie et mise à jour à notre charge | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Un nouveau SRGS ne demande pas de recalibrer | Mise à jour de la table | Oui |
| **N**ovateur | Idées étranges ? | Imputation k-NN et loi paramétrique comparées | Temps de pilote | Oui |
| **C**oût | Coût à l'ensemble ? | Classes fines plus bruitées | Précision par classe | Oui, mesurée |
| **É**cologique | Réutilisation ? | La distribution sert à d'autres usages (volume, carbone) | — | Oui |

## Valeurs sacrifiées

- La légèreté de la sortie (classes × groupes d'essences).
- La précision par classe fine, plus faible que celle d'une part agrégée : mesurée et
  publiée.

## Sources

- SRGS Auvergne-Rhône-Alpes, p. 11-12 : https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

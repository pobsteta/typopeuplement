# ADR 0006 — Légendes : type local d'abord, type générique national ensuite

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23
- **Proposée par :** Claude (orchestrateur), révisée après la critique du contradicteur
- **Tranchée par :** Pascal

## La décision en une phrase

La légende qui fait foi est celle du référentiel du gestionnaire (au minimum les 8 types
SRGS de la région, plus le guide de sylviculture ou la DRA/SRA quand ils existent),
validée à la parcelle et au demi-hectare ; un type générique national, aligné si
possible sur les variables IFN de structure et de composition, est livré en second pour
comparer les SER ; tous deux sont calculés à partir des variables continues et des
classes de diamètre, et la hauteur potentielle est un attribut, pas une dimension de
légende.

## Contexte

Question de sens tranchée par Pascal le 2026-11-23 : les deux résultats comptent,
**priorité au local** (justesse du type SRGS ou du guide, à la parcelle, pour
l'aménagement ou le PSG).

Options envisagées :
1. Clé nationale générique + table de correspondance vers les types locaux : rejetée
   comme voie principale, un type générique pouvant se partager entre deux types locaux,
   et l'erreur du type local n'étant alors jamais mesurée.
2. Clés distinctes par SER : 91 légendes, pas de comparaison, ruptures aux limites.
3. **Types locaux calculés directement depuis les variables continues (ADR 0003), type
   générique en second** : retenue.
4. Clé générique alignée sur les variables IFN : retenue pour le type générique, sous
   réserve que l'`acquereur` confirme ces variables.

Conséquences :
- la fiche de validation de chaque SER donne la précision sur le type local (priorité)
  et sur le type générique ;
- le type local est aussi validé à la parcelle, à partir d'un polygone fourni par
  l'utilisateur, avec un estimateur nommé ;
- la hauteur potentielle (conditionnelle, ADR 0007) est livrée comme attribut « écart à
  la hauteur potentielle », pour que les légendes restent comparables entre SER.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un seul jeu de modèles, plusieurs clés en aval | Deux légendes à valider par SER | Oui (Pascal) |
| **R**esponsable | Qui fait quoi ? | Le projet saisit et maintient la table des référentiels ; CNPF et ONF la relisent | Leur temps de relecture | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Un SRGS change : seule la clé change, pas les modèles | — | Oui |
| **N**ovateur | Idées étranges ? | Alignement sur les variables IFN | Vérification par l'`acquereur` | Oui |
| **C**oût | Coût à l'ensemble ? | Pas de terrain en plus : la clé s'applique aux arbres mesurés des grappes | Calcul et rédaction des fiches | Oui |
| **É**cologique | Réutilisation ? | Type local utilisable tel quel dans les documents de gestion ; type générique réutilisable au national | — | Oui |

## Valeurs sacrifiées

- La simplicité d'une seule légende : deux légendes par SER à valider, et une table des
  référentiels à tenir.

## Sources

- SRGS Auvergne-Rhône-Alpes, p. 11-12 : https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf
- IGN, conférence du 19 janvier 2021 (variables forestières, CODE_TFV) : https://www.ign.fr/publications-de-l-ign/institut/Conferences-ligne/210119_donnees_forestieres/conference_en_ligne_donnees_forestieres_19012021.pdf
- Monnet et Munoz, RFPT n° 211-212, 2015 (erreur à la parcelle, estimateurs) : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

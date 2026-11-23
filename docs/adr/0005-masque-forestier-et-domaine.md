# ADR 0005 — Emprises de calcul et de forêt, domaine de validité

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23
- **Proposée par :** Claude (orchestrateur), d'après le contradicteur, révisée après critique
- **Tranchée par :** Pascal

## La décision en une phrase

La chaîne calcule sur une emprise élargie (Masque Forêt IGN plus landes, accrus et
terrains nus, et tout polygone de gestion fourni par un utilisateur, vides compris),
pour que les 8 types SRGS puissent sortir ; l'emprise « forêt » au sens IGN ne sert
qu'aux statistiques ; le domaine de validité est l'aire d'applicabilité de Meyer et
Pebesma (2021).

## Contexte

Les 8 types SRGS incluent landes, terrain nu, accrus, peupleraie ; selon la définition
IGN (adoptée de la FAO), les landes ne sont pas de la forêt. La définition parle
d'arbres « pouvant atteindre une hauteur supérieure à 5 mètres à maturité in situ » :
un masque tiré du MNH exclurait coupes rases et jeunes peuplements.

Options envisagées :
1. Masque Forêt IGN seul : rejeté (landes, vides absents).
2. Définition IFN appliquée sur le MNH : rejetée (lecture erronée de la définition).
3. Masque issu du MNH seul : rejeté (confond haies, parcs ; exclut les coupes).
4. **Deux emprises** : retenue.
   - **Emprise de calcul** : Masque Forêt IGN ∪ landes, accrus, terrains nus (source à
     proposer par l'`acquereur` : BD Topo, OCS GE, coupes détectées par Sentinel-2) ∪
     tout polygone de gestion fourni par l'utilisateur, calculé en entier.
   - **Emprise forêt** : au sens IGN, pour statistiques et comparaisons avec l'IFN et la
     BD Forêt v3.

**Domaine de validité** : aire d'applicabilité (indice de dissimilarité dans l'espace
des prédicteurs pondéré par leur importance, seuil tiré de la validation croisée,
quantile 0,95 des auteurs), paquet R CAST ou équivalent.

**Codes** : « hors emprise » est une classe « non-forêt », pas une absence de donnée.
La liste unique des codes « sans donnée » (hors LiDAR, ZICAD, hors domaine) est définie
dans l'ADR 0010 et reprise partout par lien.

**Peupleraies** : relèvent des SER d'alluvions récentes et de leur clé à part.

**À vérifier par l'`acquereur`** : diffusion du Masque Forêt v1 comme produit à part,
licence, millésime, couverture de la Corse.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Réutiliser le masque IGN, l'élargir | Une source de plus | Oui |
| **R**esponsable | Qui fait quoi ? | L'IGN maintient le masque ; le projet l'élargit ; le gestionnaire fournit ses polygones | — | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Masque modifié : millésime tracé dans chaque sortie | Rejeu | Oui |
| **N**ovateur | Idées étranges ? | Aire d'applicabilité plutôt qu'une enveloppe maison | — | Oui |
| **C**oût | Coût à l'ensemble ? | Calcul sur des surfaces non forestières en plus | Calcul | Oui |
| **É**cologique | Réutilisation ? | Emprise forêt identique à la BD Forêt v3 | — | Oui |

## Valeurs sacrifiées

- La simplicité d'une seule emprise.
- L'indépendance vis-à-vis d'une source de plus pour les landes et les vides.

## Sources

- IGN, mémento 2022 (définition « à maturité in situ ») : https://www.ign.fr/publications-de-l-ign/institut/kiosque/publications/docs_thematiques/memento_2022.pdf
- IGN, conférence du 19 janvier 2021 : https://www.ign.fr/publications-de-l-ign/institut/Conferences-ligne/210119_donnees_forestieres/conference_en_ligne_donnees_forestieres_19012021.pdf
- BD Forêt v3 bêta (construite sur le Masque Forêt v1) : https://www.data.gouv.fr/datasets/jeu-de-donnees-test-bd-foret-v3-juin-2026-beta
- MNH LiDAR HD, ZICAD en nodata : https://www.data.gouv.fr/datasets/mnh-lidar-hd
- Meyer H., Pebesma E., Methods in Ecology and Evolution 12(9), 2021, p. 1620-1633, DOI 10.1111/2041-210X.13650 : https://arxiv.org/abs/2005.07939

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0007 — Seuils par référentiel typologique ; surface terrière par classe de diamètre et groupe d'essences

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après l'ADR 0003 du cadrage B (`docs/cadrage`, commit 7b714f1) et la décision de Pascal du 2026-11-22 sur H10, corrigée par l'arbitrage C1
- **Tranchée par :** Pascal (arbitrage C1, 2026-11-23)
- **Précise :** CLAUDE.md (« Seuils propres à chaque SER ») ; spec, critère 2 ; brief, section « Déclinaison par sylvoécorégion »

## La décision en une phrase

Les modèles prédisent la surface terrière par classe de diamètre de 5 cm **et par groupe
d'essences** (au moins feuillus et résineux), plus la part de taillis ; les seuils des
catégories de bois sont un **paramètre du référentiel typologique** (pas de la SER) et
s'appliquent en aval ; pour H10, la limite entre bois moyens et gros bois est de 42,5 cm
toutes essences (GSM).

## Contexte

- A : seuils « propres à chaque SER » (CLAUDE.md, spec critère 2), 42,5 cm pour H10 « fidèle
  au GSM », toutes essences (décision de Pascal, 2026-11-22), et des parts PB / BM / GB à
  seuil fixé dans la configuration.
- B : seuils « par référentiel typologique et groupe d'essences, jamais par SER », car le
  SRGS Auvergne-Rhône-Alpes 2023 fixe la limite des gros bois à 47,5 cm toutes essences,
  42,5 cm admis en résineux quand une typologie l'utilise (SRGS, p. 11-12, rapporté par B).
- Dans A, `docs/referentiels/typologie-h10.md` (ligne 76) lit le même SRGS comme « possible
  de garder la valeur du GSM quand une typologie comme le GSM est utilisée », sans
  restriction aux résineux.
- Deux légendes sur une même SER (SRGS et GSM, ADR 0008) portent chacune sa limite : un
  seuil par SER ne sait pas l'écrire.

**Arbitrage C1** : combinaison. Le mécanisme est celui de B (surface terrière par classe
de 5 cm × groupe d'essences, seuil = paramètre du référentiel). La valeur de A pour H10
est gardée : **GSM, 42,5 cm, toutes essences**. « 42,5 cm seulement en résineux » ne vaut
que pour le SRGS AURA, s'il est livré en plus.

Options de seuillage :
1. Seuils par SER (A) : abandonnée, contredite par le SRGS.
2. Seuils nationaux uniques : rejetée.
3. **Distribution par classes × groupes d'essences + référentiel en paramètre** : retenue.

Méthodes de prédiction de la distribution, **comparées au pilote** (B) :
- A. un modèle par classe (somme non garantie) ;
- B. imputation de listes d'arbres par plus proches voisins (cohérente par construction) ;
- C. loi paramétrique (Weibull).
Piste à vérifier : Maltamo et Gobakken, « Predicting tree diameter distributions »,
*Forestry Applications of Airborne Laser Scanning*, Springer, 2014.

**Table des référentiels** : les SRGS sont publiés en PDF ; le projet saisit et maintient
une table **versionnée** (seuils, groupes d'essences, clés) ; c'est un livrable, relu par
le CNPF seul (contact par Pascal ; l'ONF n'est plus sollicité, ADR 0015). Emplacement
dans le dépôt : à fixer par la mission (`config/` pour les paramètres, `docs/referentiels/`
pour les sources).

**Part de taillis** : elle rend exprimable le type T du GSM et les types SRGS « taillis » et
« mélange futaie-taillis ». Le type X du GSM reste non exprimable (peuplement sans rôle de
production).

**Critères ajoutés à la spec** (amendements de la réconciliation) : erreur par classe ;
erreur sur les parts PB, BM, GB après application des seuils de chaque référentiel ;
tolérance d'additivité fixée au pilote si la méthode retenue ne la garantit pas.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un jeu de modèles, n référentiels | Sortie multibande lourde | Oui |
| **R**esponsable | Qui fait quoi ? | Le projet saisit et maintient la table ; le CNPF la relit | Saisie, mise à jour, temps du CNPF | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Un nouveau SRGS ne demande pas de recalibrer | Mise à jour de la table | Oui |
| **N**ovateur | Idées étranges ? | k-NN et loi paramétrique comparés | Temps de pilote | Oui |
| **C**oût | Coût à l'ensemble ? | Classes fines plus bruitées | Précision par classe | Oui, mesurée |
| **É**cologique | Réutilisation ? | La distribution sert à d'autres usages (volume, carbone, selon B) | — | Oui |

## Valeurs sacrifiées

- La légèreté de la sortie (classes × groupes d'essences).
- La précision par classe fine, plus faible que celle d'une part agrégée : mesurée et publiée.
- La simplicité d'un seuil par SER.

## Sources

Reprises de l'ADR 0003 de B, non reconsultées le 2026-11-23.

- SRGS Auvergne-Rhône-Alpes, p. 11-12 : https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf
- Dans A : `docs/referentiels/typologie-h10.md` (GSM p. 54 ; SRGS ligne 76), `config/exemple.json`, journal du 2026-11-22.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0008 — Légendes : SRGS d'abord, GSM ensuite, type générique national ; forêt pilote

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (réconciliation des cadrages)
- **Proposée par :** Claude (orchestrateur), d'après le cadrage A (cap GSM pour H10) et l'ADR 0006 du cadrage B (`docs/cadrage`, commit 7b714f1), corrigée par les arbitrages C2 et C3 et par l'arbitrage « forêt pilote »
- **Tranchée par :** Pascal (arbitrages C2, C3 et forêt pilote, 2026-11-23)
- **Précise :** cap du 2026-11-22 sur le GSM pour H10 (`docs/referentiels/typologie-h10.md`) ; brief, question ouverte « clé nationale ou clés par SER » ; choix de la forêt pilote par délégation (journal, 2026-11-22)

## La décision en une phrase

Priorité aux forêts privées : les **8 types SRGS** sont la légende prioritaire, validée en
premier ; le **GSM Alpes du Nord** vient en second pour H10 ; un **type générique
national** est livré en plus ; la hauteur potentielle est un **critère de la clé GSM** et
un simple attribut du type générique ; l'AOI pilote est la forêt domaniale de Léoncel
plus les forêts privées voisines dans H10.

## Contexte

- A : le GSM est la légende de H10 (cap du 2026-11-22) ; sa clé dépend de la hauteur
  potentielle (Hₒ potentielle < 15 m → type CH ; strates = quarts de Hₒ potentielle ;
  `docs/referentiels/typologie-h10.md`, lignes 44 et 62). A avait écarté les 8 types du SRGS
  comme légende de la carte de H10 (« trop grossiers », option (c), ligne 166).
- B : la légende qui fait foi est celle du gestionnaire, au minimum les 8 types SRGS ;
  type générique national en second ; hauteur potentielle « un attribut, pas une dimension
  de légende ».
- Les deux se concilient par la priorité donnée par Pascal à la forêt privée.

### Légendes (arbitrage C3)

1. **8 types SRGS** (futaie régulière, futaie irrégulière, mélange futaie-taillis,
   taillis, peupleraie, accrus, landes, terrain nu : SRGS AURA 2023, p. 11-12, cités par
   B), calculés depuis les variables continues et les classes de diamètre
   (ADR 0007) ; légende prioritaire, **validée en premier** (ADR 0006). Elle suppose la
   part de taillis (ADR 0007) et des types « landes, accrus, terrain nu » (ADR 0011).
2. **GSM Alpes du Nord**, en second, pour H10 (limite à 42,5 cm, ADR 0007).
3. **Type générique national**, aligné si possible sur les variables de structure et de
   composition de l'IFN (variables à confirmer par l'`acquereur`), livré pour comparer les
   SER. Son rang par rapport au GSM n'est pas précisé par l'arbitrage.

### Hauteur potentielle (arbitrage C2)

- **Clé locale GSM** : critère de la clé (A).
- **Type générique national** : simple attribut, « écart à la hauteur potentielle » (B).
- **Repli** : si le modèle de hauteur potentielle échoue à son critère (ADR 0009), la clé
  GSM se replie sur la hauteur mesurée ; le repli est signalé dans la couche de
  confiance et dans la fiche de validation (ADR 0006).

### Forêt pilote (arbitrage « forêt pilote »)

**AOI pilote** : la forêt domaniale de Léoncel (contrôle par la carte GSM de
l'aménagement, `docs/referentiels/typologie-h10.md`, source S4) **plus les forêts privées
voisines dans H10** (légende SRGS, usage PSG). L'arbitrage C3 signalait que Léoncel
seule, domaniale et choisie par délégation le 2026-11-22, ne collait plus à la priorité
privée ; cet ajout y répond. La mission 006 de A en tient compte (plan de lecture du
Vercors).

### Relecture

La clé locale est relue par le CNPF seul, sur des cas types ; le contact est pris par
Pascal (ce qui touche l'extérieur lui est réservé). Pas de relecture par l'ONF (ADR 0015).

Options envisagées (ADR 0006 de B) :
1. Clé nationale générique + table de correspondance vers les types locaux : rejetée comme
   voie principale (l'erreur du type local n'y serait jamais mesurée).
2. Clés distinctes par SER : 91 légendes, pas de comparaison, ruptures aux limites.
3. **Types locaux calculés depuis les variables continues, type générique en plus** : retenue.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un seul jeu de modèles, plusieurs clés en aval | Trois légendes à valider par SER pilote | Oui (Pascal) |
| **R**esponsable | Qui fait quoi ? | Le projet tient la table des référentiels ; le CNPF relit | Temps du CNPF | Oui |
| **A**nticiper | Si l'imprévu arrive ? | Un SRGS change : seule la clé change ; modèle de hauteur potentielle en échec : repli signalé | — | Oui |
| **N**ovateur | Idées étranges ? | Alignement du type générique sur les variables IFN | Vérification par l'`acquereur` | Oui |
| **C**oût | Coût à l'ensemble ? | Pas de terrain en plus : la clé s'applique aux mesures des placettes | Calcul, rédaction des fiches | Oui |
| **É**cologique | Réutilisation ? | Types SRGS utilisables dans les PSG ; générique réutilisable au national | — | Oui |

## Valeurs sacrifiées

- La simplicité d'une seule légende.
- La règle de B « la hauteur potentielle n'est jamais une dimension de légende » : elle ne
  vaut que pour le type générique.
- La carte GSM seule comme objectif premier de H10 ; l'AOI pilote reste domaniale pour
  partie, ce qui garde le contrôle par l'aménagement ONF (public).

## Sources

Reprises de l'ADR 0006 de B, non reconsultées le 2026-11-23.

- SRGS Auvergne-Rhône-Alpes, p. 11-12 : https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf
- IGN, conférence du 19 janvier 2021 (variables forestières, CODE_TFV) : https://www.ign.fr/publications-de-l-ign/institut/Conferences-ligne/210119_donnees_forestieres/conference_en_ligne_donnees_forestieres_19012021.pdf
- Monnet et Munoz, RFPT n° 211-212, 2015 (erreur à la parcelle, estimateurs) : https://rfpt.sfpt.fr/index.php/RFPT/article/download/548/280/2079
- Dans A : `docs/referentiels/typologie-h10.md` (GSM, SRGS, Léoncel), `pilotage/missions/006-plan.md`.

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# ADR 0002 — Référence, unité et protocole de validation

- **Date :** 2026-11-23
- **Statut :** acceptée par Pascal le 2026-11-23 (révisée après critique)
- **Proposée par :** sujet proposé par le contradicteur, rédigée par Claude (orchestrateur)
- **Tranchée par :** Pascal

## La décision en une phrase

L'unité d'évaluation est le pixel, comparé au type calculé par la clé sur les arbres
mesurés du disque de 15 m centré sur son nœud, dans des grappes de 50 × 100 m alignées
sur la grille et inventoriées en plein ; la carte passe si un test de non-infériorité
apparié, à marge fixée d'avance, la montre au moins aussi bonne qu'une base de
comparaison, d'abord sur le type local, puis sur le type générique.

## Contexte

Le 76 % du rapport 2020 porte sur la seule structure ; le brief refuse toute vérité « à
dire d'expert » ; Pascal donne la priorité au type local à la parcelle (ADR 0006).

**Unité d'évaluation** (tranchée par Pascal) : options (a) pixel, (b) bloc de 0,5 ha.
Retenue : **(a)**, seul choix qui donne un contenu à l'erreur par pixel et qui valide
toutes les échelles (pixel, demi-hectare, parcelle) avec le même terrain
(Stehman et Wickham, 2011).

**Grappe** : rectangle de 50 × 100 m aligné sur la grille, plus une bande de 15 m
(≈ 0,9 ha), inventaire en plein avec position des arbres ; le disque de chacun des
8 pixels est recalculé ; estimateurs pour sondage en grappes ; le demi-hectare et la
parcelle sont validés à partir des mêmes arbres.

**Plan de sondage** : aléatoire stratifié par type prédit (Olofsson et al., 2014), donc
mesuré après la carte ; effectifs par type chiffrés d'après les repères d'Olofsson et al.

**Test de passage** : non-infériorité apparié sur les mêmes grappes (Foody, 2009), marge
Δ fixée avant les résultats ; sous-test sur les grappes feuillues ; d'abord sur le type
local (8 types SRGS au minimum), puis sur le type générique. **Base de comparaison** par
SER, écrite avant les résultats (par exemple règle BD Forêt v3 + MNH, ou clé 2020 rejouée
sur LiDAR HD).

**Second niveau** : proportions de types par SER de la carte comparées aux estimations
IFN, avec un estimateur nommé (les données brutes ne permettent pas de refaire les
résultats officiels faute des poids de post-stratification).

**Date** : écart maximal vol / relevé fixé ; grappe exclue si coupe ou dépérissement
détecté entre les deux (fordead ou équivalent).

**Couche `confiance`** : précision utilisateur du type prédit dans la SER, avec IC, et
écart entre les deux premières probabilités.

**Probabilité** : diagramme de fiabilité et score de Brier sur les grappes ; si elle
n'est pas calibrée, la couche s'appelle « score ».

**Indépendance** : distance minimale entre une grappe et la placette de calibration la
plus proche ; choix du modèle par validation croisée spatiale (Ploton et al., 2020).

**Variables continues** : biais et RMSE de chaque variable dans la fiche de validation.

**Clé** : relue par le CNPF et l'ONF sur des cas types.

## Le crible FRANCE

| Lettre | Question | Réponse (une ligne) | Ce que ça coûte | Prêts à payer ? |
|---|---|---|---|---|
| **F**rugale | Plus simple qui tienne ? | Un seul dispositif de terrain pour toutes les échelles | Inventaire en plein, position des arbres | Oui (Pascal) |
| **R**esponsable | Qui fait quoi ? | Validation mesurée, si possible, par une autre équipe que la calibration | Organisation terrain | À organiser |
| **A**nticiper | Si l'imprévu arrive ? | Erreur systématique de clé : relue par CNPF et ONF sur cas types | Leur temps | Oui |
| **N**ovateur | Idées étranges ? | Unité « bloc » examinée ; second niveau IFN | — | — |
| **C**oût | Coût à l'ensemble ? | ≈ 0,9 ha inventorié en plein par grappe, le poste le plus cher | Terrain, à chiffrer | Oui (Pascal) |
| **É**cologique | Réutilisation ? | Grappes réutilisables pour toutes les échelles et pour la calibration future | — | Oui |

## Valeurs sacrifiées

- La comparabilité directe avec le chiffre de 2020.
- Le coût du terrain : un inventaire en plein coûte plus cher qu'un jeu de placettes.
- L'expertise de terrain comme juge : elle revient par l'avis des gestionnaires et la
  relecture de la clé.

## Sources

- Olofsson et al., Remote Sensing of Environment 148, 2014, p. 42-57, DOI 10.1016/j.rse.2014.02.015
- Stehman S.V., Wickham J.D., Remote Sensing of Environment 115(12), 2011, p. 3044-3055
- Foody G.M., Remote Sensing of Environment 113(8), 2009, p. 1658-1663, DOI 10.1016/j.rse.2009.03.014
- Ploton P. et al., Nature Communications 11, 4540, 2020, DOI 10.1038/s41467-020-18321-y
- fordead : https://zenodo.org/records/12802457
- Données brutes IFN : https://www.data.gouv.fr/datasets/donnees-brutes-de-l-inventaire-forestier

## Question de contrôle

Cette décision tient-elle nos six valeurs, et que sommes-nous prêts à payer pour cela ?

# Mission 018 — Carte SRGS et GSM sur l'AOI pilote élargie

> Fiche écrite par Claude (orchestrateur) le 2026-11-23, **validée par délégation n° 3**
> (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Brancher la clé SRGS dans la chaîne et produire, sur l'AOI pilote (forêt domaniale de Léoncel et forêts privées voisines dans H10), la carte des 8 types SRGS en légende prioritaire et la carte GSM en second, avec leur couche de confiance, pour livrer la première carte de typologie demandée par Pascal.

**Redite par l'agent :** _à compléter par l'agent avant d'agir._

## Les trois questions

| Question | Réponse |
|---|---|
| Redire en une phrase ? | oui |
| Sait-il comment faire ? | en partie : choix de l'emprise privée voisine (dalles LiDAR HD à ajouter, temps de calcul) à écrire dans un plan |
| A-t-il les moyens ? | oui : chaîne de 013, dalles LiDAR HD (WFS IGN), rasters ONF en contrôle |

**Temps de la main :** **prendre** — plan d'abord (emprise, dalles, coût de calcul), validé par délégation. **Degré :** le chef tranche (délégation n° 3).

## Ma réponse d'abord

_Pascal s'en passe (« je m'en passe », 2026-11-23) ; rubrique laissée à sa main._

## L'Homme

- **Agent :** `dev` · **Modèle :** opus
- **Ce qui ne lui est pas demandé :** la validation statistique (pas de placettes indépendantes) ; le rapport (015).

## Harnais

- **Peut (périmètre) :** `R/chaine.R`, `R/typer_peuplements.R`, `R/cle.R`, `inst/extdata/config/` (AOI pilote), `man/`, `NAMESPACE`.
- **Câblé :** pas de commit sur `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** modifier les tests de 017 ; modifier la clé de 016 ; traiter forêts publiques et privées différemment (arbitrage C14).
- **Sources autorisées :** ADR de la réconciliation ; `docs/referentiels/` ; journal (013).

## Journal

Une ligne par rendu et par aller-retour, proposée à l'orchestrateur (ajout seul).

## Valeur provisoire (chiffre, réglage)

Paramètres de segmentation de 013 (fenêtre 3 m, hauteur min 2 m) : provisoires, repris tels quels.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** 013 (PR n° 2) fusionnée, 016, 017.
- **Ordre :** 017 et 018 groupées.
- **CI rouge attendue :** aucune à la fusion groupée.

## Tests

tests de 017 verts ; un test d'intégration sur un extrait de l'AOI (deux dalles) produit les deux cartes et la confiance.

## Terrain

trois pixels en forêt privée, choisis par l'orchestrateur, à vérifier par Pascal quand il le voudra.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis l'orchestrateur par délégation n° 3.
- **Critère d'arrêt :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Qui tranche :** l'orchestrateur (délégation n° 3) ; Pascal pour ce qui lui est réservé.

## Comment saura-t-on que ça marche ?

Les rasters `type_srgs`, `type_gsm` et `confiance` couvrent toute l'AOI, publique et privée, sans trou autre que les codes « sans donnée ».

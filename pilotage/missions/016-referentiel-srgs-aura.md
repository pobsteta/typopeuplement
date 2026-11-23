# Mission 016 — Référentiel SRGS Auvergne-Rhône-Alpes : 8 types et seuils

> Fiche écrite par Claude (orchestrateur) le 2026-11-23, **validée par délégation n° 3**
> (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Transcrire, avec page et source, les 8 types obligatoires du SRGS Auvergne-Rhône-Alpes et leurs critères (seuils de catégories de bois, précomptage, futaie / taillis / mélange) en une clé lisible par la chaîne, parce que la légende SRGS est prioritaire (réconciliation, arbitrage C3).

**Redite par l'agent :** « Transcrire, avec page et source, les 8 types obligatoires du SRGS AURA 2023 et leurs critères (catégories de bois, précomptage, futaie / taillis / mélange) en un fichier de clé que `lire_configuration()` charge » (acquereur, plan du 2026-11-23).

## Les trois questions

| Question | Réponse |
|---|---|
| Redire en une phrase ? | oui |
| Sait-il comment faire ? | oui : SRGS AURA 2023, p. 11-12 (https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf) ; format des clés de `inst/extdata/config/` ; liste de contrôle du skill `methode` |
| A-t-il les moyens ? | oui |

**Temps de la main :** **prendre** — codes et nomenclatures : l'agent rend d'abord un plan ; l'orchestrateur le valide par délégation. **Degré :** le chef tranche (délégation n° 3).

## Ma réponse d'abord

_Pascal s'en passe (« je m'en passe », 2026-11-23) ; rubrique laissée à sa main._

## L'Homme

- **Agent :** `acquereur` · **Modèle :** opus — justesse des données
- **Ce qui ne lui est pas demandé :** le code de la clé ; les autres régions.

## Harnais

- **Peut (périmètre) :** `docs/referentiels/srgs-aura.md`, `inst/extdata/config/` (fichier de clé SRGS nouveau).
- **Câblé :** pas de commit sur `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** inventer un seuil ; trancher entre deux lectures du SRGS (le signaler) ; contacter le CNPF.
- **Sources autorisées :** SRGS AURA ; `docs/referentiels/typologie-h10.md` (format) ; ADR de légendes et de seuils de la réconciliation.

## Journal

Une ligne par rendu et par aller-retour, proposée à l'orchestrateur (ajout seul).

## Valeur provisoire (chiffre, réglage)

Toute règle que le SRGS laisse à l'appréciation (part du taillis, seuil futaie / mélange) : valeur provisoire nommée, à confirmer par le CNPF (contact réservé à Pascal).

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** aucune.
- **CI rouge attendue :** aucune.

## Tests

chaque critère porte sa page ; les 8 types sont présents ; la clé se charge par `lire_configuration()`.

## Terrain

trois critères tirés au hasard, confrontés au PDF.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis l'orchestrateur par délégation n° 3.
- **Critère d'arrêt :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Qui tranche :** l'orchestrateur (délégation n° 3) ; Pascal pour ce qui lui est réservé.

## Comment saura-t-on que ça marche ?

La chaîne peut charger une clé SRGS des 8 types sans autre document.

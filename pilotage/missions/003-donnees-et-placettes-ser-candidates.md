# Mission 003 — Inventaire des données et des placettes des SER candidates

> Fiche écrite par Claude (orchestrateur) le 2026-11-23 avec `/imperatrice:mission`,
> **à valider par Pascal** (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Inventorier, pour les quatre SER pilotes candidates du brief de cadrage, les données spatiales publiques (SER et GRECO, masque forestier, forêts publiques, LiDAR HD et ZICAD, cartes existantes, tuiles Sentinel-2) et les placettes connues, pour éclairer le choix des SER pilotes que Pascal doit faire.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les trois questions (règle de staffing)

| Question | Réponse | Conséquence |
|---|---|---|
| Peut-il redire la mission en une phrase, avec son but ? | oui | — |
| Sait-il comment faire ? (sources, conventions nommées ci-dessous) | oui | sources nommées ; liste de contrôle jointe |
| A-t-il les moyens ? (outils, données d'essai, tests) | oui en partie | les placettes ONF et PSG ne sont pas publiques : l'agent en liste seulement ce qui est publié et ce qu'il faudra demander |

**Temps de la main :** **donner** — inventaire documentaire, sans effet durable ; le relecteur puis Pascal valident.

**Degré de la main :** le chef tranche.

## Ma réponse d'abord

_Rempli par Pascal seul, avant de lire le travail de l'agent._

## L'Homme

- **Agent :** `acquereur`
- **Modèle :** sonnet.
- **Ce qui ne lui est pas demandé :** pas de choix des SER pilotes (Pascal) ; pas de téléchargement massif de données ; pas de demande à un organisme.

## Harnais

- **Peut (périmètre) :** `docs/inventaire/` (une fiche par SER candidate, une fiche par source).
- **Câblé (ne peut pas) :** pas de commit sur `main` (hook `garde_main`) ; pas de « terminé » sans tests verts (hook `tests_obligatoires`) ; journal en ajout seul (hooks `journal_ajout_seul`, `journal_intact`).
- **Ne doit pas (écrit) :** conclure à la place de Pascal ; contacter l'ONF, le CNPF, l'IGN ou le CRAIG.
- **Sources autorisées :** `docs/brief-typologie-peuplements.md` (« SER pilotes suggérées ») ; `docs/spec.md` § 5, besoins 1, 5 à 10 ; data.gouv.fr ; géoservices IGN ; GeoData INRAE ; `docs/adr/0004`, `0005`, `0008`, `0009`.

## Journal

- **Ce que l'agent inscrit :** une ligne par rendu et par aller-retour, proposée à l'orchestrateur, dans `pilotage/journal.md` (ajout seul) : ce qu'il a vu, ce qu'il a fait, ce qui permettrait de le défaire.

## Valeur provisoire (chiffre, réglage)

aucune.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** aucune.
- **Ordre de fusion :** indifférent.
- **PR en brouillon jusqu'à :** —
- **CI rouge attendue :** aucune (seul `docs/` change).

## Tests

- **Comment saura-t-on que c'est juste :** pour chaque SER candidate : couverture et dates de vol LiDAR HD, part de ZICAD, sources du masque et des forêts publiques avec licence et millésime, cartes existantes disponibles, placettes publiées et à demander ; chaque affirmation sourcée ; liste de contrôle cochée.

## Terrain

- **Échantillon que Pascal vérifiera :** la fiche de la SER Alpes du Nord, que Pascal compare à ce qu'il sait du terrain.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis Pascal.
- **Critère d'arrêt de la relecture :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Point de suivi :** à la PR.
- **Qui tranche :** Pascal. Les demandes aux organismes sont faites par Pascal, après lecture.

## Comment saura-t-on que ça marche ?

Pascal peut choisir ses SER pilotes en lisant les quatre fiches, et sait quelles demandes faire à l'ONF et au CNPF.

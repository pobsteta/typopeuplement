# Mission 010 — transcrire la clé du GSM dans la configuration de H10

## Mission

**En une phrase (quoi, et pourquoi) :** transcrire les 20 types du GSM Alpes du Nord
(logigramme, p. 54-55, et tableau, p. 56-57) dans `vercors-h10.json` avec le format à
« ou » de 007, la limite des gros bois à 42,5 cm (Pascal) et chaque seuil sourcé, pour
que la première carte de H10 parle la langue des gestionnaires.

## Les trois questions

- oui ;
- oui : `docs/referentiels/typologie-h10.md`, GSM (texte lisible par pdftotext) ;
- moyens : après 007 (format), 008 et 009 (noms des variables).

**Temps de la main :** donner. **Degré :** le chef tranche.

## L'Homme

`acquereur` · sonnet.

## Harnais

- **Peut :** `inst/extdata/config/vercors-h10.json`, `docs/referentiels/typologie-h10.md`.
- **Ne doit pas :** inventer un seuil ; trancher une ambiguïté du logigramme (elle va à Pascal).

Mineurs reportés de la relecture de 005 :
- page de Léoncel (p. 4 imprimée, pas p. 12) ;
- citation du SRGS sans « expressément » ;
- réserve « lu sur image » retirée, puisque le texte du PDF suffit.

Souplesses du jeu Vercors (Pascal, 2026-11-22) : EQM de la fiche ONF, p. 1, à écrire dans
`jeux.vercors_onf.souplesse` : G 7,32 m²/ha, part de résineux 0,199, part de gros bois 0,163.
L'ONF compte les très gros bois dans la part de gros bois (Pascal).

## Dépend de / rouge attendu jusqu'à

Dépend de 007, 008 et 009 (noms des variables). Ordre : en dernier.

## Tests

- La configuration se charge.
- Les 20 codes sont présents.
- Chaque seuil a sa page.

## Terrain

Pascal relit le logigramme et reconnaît les types sur une forêt du Vercors.

## Qui tranche

`relecteur`, puis Pascal.

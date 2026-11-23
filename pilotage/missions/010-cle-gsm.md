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

## Reprise courte, après 012 (décisions par délégation, 2026-11-22)

1. Le seuil de 15 m (CH contre les autres types) porte sur la hauteur potentielle sans
   enveloppe, comme les strates. La variable est exposée par 012 sous le nom `hpot`.
2. Ajouter à la doc la lecture littérale de l'arrondi (déficitaire ≤ 0,2, prépondérant ≥ 0,5)
   comme alternative. Le défaut 0,25 / 0,45 est gardé, provisoire.
3. Ajouter à la notice : « taillis et peuplements sans rôle de production non détectés »
   (types X et T non exprimables).
4. Un test automatique de la clé de H10, confié au `testeur` : 16 types et 4 non
   exprimables, soit 20 codes, une `source` par type, et l'exclusivité en clé dure.

## Reprise courte, aller-retour 1/3 (2026-11-23)

1. **Acquéreur.** Corriger le paragraphe « Câblage à vérifier » de `typologie-h10.md`
   (l. 120 environ).
   - En mode « variables fournies » (`executer_chaine_fournie`), la clé reçoit `hpot`,
     `h_pot`, `c*_hpot` (argument `strates`), `couvert` et `N`, et `N` est lue par
     `couches_onf()`.
   - En mode placettes (`executer_chaine`, `R/chaine.R` l. 78), seule `rapport_h` est
     passée : la clé de H10 n'y tourne pas.
2. **Testeur.** Dans `test-cle-h10.R` :
   - une assertion verrouille `hpot` comme variable du seuil de 15 m dans les 16 types ;
   - le comptage des chevauchements se fait sur l'appartenance brute (avant
     normalisation), ou sur les probabilités strictement positives, pour qu'un
     chevauchement soit signalé comme chevauchement.

## Branche N de L et R (2026-11-23, Pascal)

Le seuil de 800 tiges/ha porte sur `N` du jeu ONF (tiges précomptables). Transcrire la
branche N de L et R selon le logigramme (p. 54), avec les « ou » du format de 007.
L'ambiguïté 6 (branches qui se recouvrent) reste à poser, pas à trancher. Le test
`test-cle-h10.R` doit rester vert : il lit les seuils dans la clé.

## Ambiguïté 6 tranchée par Pascal (2026-11-23) : cascade L, puis 3, puis R

On lit la colonne du logigramme dans l'ordre : le premier type vrai l'emporte. La clé
n'ayant pas d'ordre de priorité, la cascade s'écrit en conditions exclusives :

- **L** : (c3 < 0,45 et c4 < 0,45) ou N < 800 ;
- **3** : c3 ≥ 0,45 et N ≥ 800 ;
- **R** : c3 < 0,45 et c4 ≥ 0,45 et N ≥ 800.

Partir du patch mis de côté (`scratchpad/branche_N_LR.patch`) ; le test d'exclusivité
redevient vert.

# Mission 014 — CI, releases calendaires et badges, comme dans Marculus et sylvostation

> Fiche écrite par Claude (orchestrateur) le 2026-11-23, **validée par délégation n° 3**
> (porte n° 2). Une mission = une phrase = une branche = une PR.

## Mission

**En une phrase (quoi, et pourquoi) :** Mettre en place la CI (tests R et Python, couverture), les tags et releases calendaires `vAAAA.MM.N` après tests verts sur `main`, la règle « pas de release pour docs, pilotage, *.md, badges, tests » et les badges du README, en reprenant les scripts de sylvostation (paquet R) et la convention de Marculus, pour que chaque fusion soit vérifiée et publiée sans geste manuel (demande de Pascal, 2026-11-23).

**Redite par l'agent :** je mets en place, en reprenant les scripts de sylvostation, la CI (tests R puis Python, couverture), la release calendaire `vAAAA.MM.N` avec l'archive `R CMD build` après une CI verte sur `main`, la règle « pas de release pour docs, pilotage, *.md, badges, tests » et les badges du README, pour que chaque fusion soit vérifiée et publiée sans geste manuel.

## Les trois questions

| Question | Réponse |
|---|---|
| Redire en une phrase ? | oui |
| Sait-il comment faire ? | oui : `pobsteta/sylvostation` (origin/main) a déjà la version R de la convention : `.github/workflows/ci.yml`, `release.yml`, `.github/scripts/*.sh` et leurs tests |
| A-t-il les moyens ? | oui : GitHub Actions, `gh`, dépôt `pobsteta/typopeuplement` |

**Temps de la main :** **donner**. **Degré :** le chef tranche (délégation n° 3).

## Ma réponse d'abord

_Pascal s'en passe (« je m'en passe », 2026-11-23) ; rubrique laissée à sa main._

## L'Homme

- **Agent :** `dev` · **Modèle :** sonnet
- **Ce qui ne lui est pas demandé :** aucune fonction métier ; pas de site pkgdown (mission 015).

## Harnais

- **Peut (périmètre) :** `.github/` (workflows, scripts et leurs tests, badges), `README.md` (badges et section « Déployer et publier »), `DESCRIPTION` (champ `Version` seulement), `.Rbuildignore`.
- **Câblé :** pas de commit sur `main` ; pas de « terminé » sans tests verts ; journal en ajout seul.
- **Ne doit pas :** inventer une règle de version ; écrire un test qui ne vérifie rien ; relancer une CI de `main` déjà verte.
- **Sources autorisées :** `/home/pascal/dev/sylvostation` et `/home/pascal/dev/marculus` en lecture seule (`git show origin/main:…`) ; ADR de versions de la réconciliation ; `.claude/test-command`.

## Journal

Une ligne par rendu et par aller-retour, proposée à l'orchestrateur (ajout seul).

## Valeur provisoire (chiffre, réglage)

- **Valeur provisoire :** `Version` du `DESCRIPTION` avant la première release.
- **Mesurée par :** la première release de la CI.
- **Gel :** jamais à la main.

## Dépend de / rouge attendu jusqu'à

- **Dépend de :** PR n° 2 et amendement de réconciliation fusionnés dans `main`.
- **Ordre de fusion :** après eux.
- **CI rouge attendue :** aucune.

## Tests

- scripts de version et de décision de release testés (cas de sylvostation repris) ;
- `.claude/test-command` vert ; première CI verte sur la PR.

## Terrain

la page Actions et la première release après fusion ; badges allumés dans le README.

## Qui veille, qui tranche

- **Relecteur :** `relecteur`, puis l'orchestrateur par délégation n° 3.
- **Critère d'arrêt :** 3 allers-retours ; au-delà, la décision remonte à Pascal.
- **Qui tranche :** l'orchestrateur (délégation n° 3) ; Pascal pour ce qui lui est réservé.

## Comment saura-t-on que ça marche ?

Après fusion, une release `v2026.11.N` apparaît avec l'archive du paquet ; une PR qui ne touche que `docs/` n'en crée pas.

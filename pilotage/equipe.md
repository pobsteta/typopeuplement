# Équipe de TypoPeuplement

> Produit par l'orchestrateur avec `/imperatrice:mission`, **validé par Pascal** avant
> tout démarrage. Règle de staffing : un agent par mission qui passe les trois
> questions, jamais un agent « par principe ».

- **Statut :** validée
- **Validée par :** Pascal, le 2026-11-23 (porte n° 2)

## Plafond humain

- **PR ouvertes en même temps, au plus :** 3
- **Rythme de relecture de Pascal :** _…_

## Délégation

> Ce que Pascal demande à l'orchestrateur de trancher à sa place (skill `methode`,
> « La délégation »). Vide : aucune délégation, Pascal tranche tout.

- **Portée :** _aucune_
- **Jusqu'à :** _…_
- **Réservé à Pascal :** _…_ (toujours, même si rien n'est écrit : sa réponse d'abord ;
  rendre la main ; ce qui touche l'extérieur et ne se défait pas)
- **Inscrite au journal le :** _…_

## Le vivier (catalogue, pas une équipe)

| Agent | A / plan | Modèle | Écrit du code ? |
|---|---|---|---|
| `contradicteur` | Abstraction · Polos | opus | non |
| `acquereur` | Acquisition · Ponos | sonnet | non (référentiels et données) |
| `archiviste` | Archivage · Pontos | sonnet | non (docs) |
| `analyste` | Analyse · Ponos | sonnet | non |
| `afficheur` | Affichage · Ponos | sonnet | oui (interface) |
| `dev` | réalisation · Ponos | sonnet | oui |
| `testeur` | réalisation · Ponos | sonnet | oui (tests) |
| `relecteur` | contrôle · C3 | opus | non (lecture seule) |

## Missions

| Mission | Agent | Modèle | Temps de la main | Les 3 questions | Cycle |
|---|---|---|---|---|---|
| [001](missions/001-squelette-paquet-ci-releases.md) Squelette du paquet, CI, releases | `dev` | sonnet | donner | oui · oui · oui | 1 |
| [002](missions/002-referentiels-typologiques-aura.md) Référentiels typologiques AURA | `acquereur` | opus | prendre (plan d'abord) | oui · oui · oui | 1 |
| [003](missions/003-donnees-et-placettes-ser-candidates.md) Données et placettes des SER candidates | `acquereur` | sonnet | donner | oui · oui · en partie (placettes non publiques : liste des demandes) | 1 |
| [004](missions/004-tests-grille-et-disque.md) Tests de la grille et du disque | `testeur` | sonnet | donner | oui · oui · oui (après 001) | 2 |
| [005](missions/005-grille-et-metriques-au-disque.md) Grille et métriques au disque de 15 m | `dev` | opus | prendre (plan d'abord) | oui · en partie · oui | 2 |
| [006](missions/006-tests-cle-type-local.md) Tests de la clé du type local | `testeur` | sonnet | donner | oui · oui · **non** (attend 002) | 3 |
| [007](missions/007-cle-type-local.md) Clé du type local | `dev` | sonnet | donner | oui · oui · **non** (attend 002, 006) | 3 |

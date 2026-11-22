# Équipe de typopeuplement

> Produit par l'orchestrateur avec `/imperatrice:mission`, **validé par Pascal** avant
> tout démarrage.

- **Statut :** proposée le 2026-11-22
- **Validée par :** _…_

## Plafond humain

- **PR ouvertes en même temps, au plus :** 3
- **Rythme de relecture de Pascal :** _…_

## Délégation

- **Portée :** les points B2 à B6 et A1 à A6 de la critique du contradicteur du
  2026-11-22 (« Pour tous les autres points, je te laisse juge sachant qu'à terme ce
  projet servira nemeton »)
- **Jusqu'à :** leur report dans le brief et les ADR
- **Réservé à Pascal :** sa réponse d'abord ; rendre la main ; ce qui touche
  l'extérieur et ne se défait pas (contact IGN, convention d'accès IFN)
- **Inscrite au journal le :** 2026-11-22 (close : arbitrages reportés)

### Délégation n° 2 (en cours)

- **Mots de Pascal :** « Valide toi même les plans et arbitrage » (2026-11-22)
- **Portée :** les plans des missions en « prendre la main » ou en « plan d'abord » (008 et
  suivantes du cycle) et les arbitrages de sens soulevés par les relecteurs et les agents
- **Jusqu'à :** la fin de la mission 010. Durée non dite : lue au plus court.
- **Réservé à Pascal :** sa réponse d'abord ; rendre la main (fusion sans relecture
  humaine) ; ce qui touche l'extérieur et ne se défait pas (contact avec l'ONF, l'IGN ou
  un tiers, publication) ; la fusion des PR vers `main`, qu'il n'a pas déléguée

## Missions

| Mission | Agent | Modèle | Temps de la main | Les 3 questions | Cycle |
|---|---|---|---|---|---|
| [001 Environnement R](missions/001-environnement-r.md) | `dev` | sonnet | donner | oui · oui · oui | 1 |
| [002 Référentiel des SER](missions/002-referentiel-ser.md) | `acquereur` | sonnet | donner | oui · oui · oui | 1 |
| [004 Tests testthat](missions/004-tests-r.md) | `testeur` | sonnet | donner | oui · oui · après 001 | 1 |
| [003 Portage en R](missions/003-portage-r.md) | `dev` | opus | **prendre** (plan d'abord) | oui · oui · après 001 et 004 | 1 (plan), 2 (code) |

| [005 Typologie H10](missions/005-typologie-h10.md) | `acquereur` | sonnet | donner | oui · oui · oui | 2 |
| [006 Lecture du Vercors](missions/006-lecture-vercors.md) | `dev` | opus | donner, plan d'abord | oui · non → plan · oui | 2 |
| [007 Clé à disjonctions](missions/007-cle-disjonctions.md) | `dev` | sonnet | donner | oui · oui · oui | 3 |
| [009 Hauteur potentielle par le relief](missions/009-hauteur-potentielle-mnt.md) | `dev` | opus | donner | oui · oui · à vérifier | 3 |
| [008 Couvert des strates LiDAR HD](missions/008-couvert-strates-lidar.md) | `dev` | opus | **prendre** (plan) | oui · non · après 009 | 3-4 |
| [010 Clé du GSM](missions/010-cle-gsm.md) | `acquereur` | sonnet | donner | oui · oui · après 007-009 | 4 |
| [012 Brancher les strates](missions/012-brancher-strates.md) | `dev` | opus | donner | oui · oui · oui | 4 |
| [011 Incertitude locale de h_pot](missions/011-incertitude-locale-hpot.md) | `dev` | opus | donner, plan court | oui · oui · oui | 5 |

**En attente, faute de réponse à la 1re question** : lire les données d'une AOI, typologie
locale d'une SER pilote, mesure des temps (ADR 0003). Toutes trois attendent le choix des
SER pilotes et d'une AOI pilote.

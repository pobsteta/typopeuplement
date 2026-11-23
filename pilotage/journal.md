# Journal de TypoPeuplement

> **Règle du sommier : on n'efface pas, on ajoute.**
> Chaque inscription est datée et signée (agent ou personne). Une correction est une
> nouvelle ligne qui renvoie à l'ancienne. Un hook refuse toute modification qui
> supprimerait ou réécrirait une inscription existante.
>
> Format : `AAAA-MM-JJ · auteur · mission · ce qui a été fait / décidé / bloqué`
>
> **Le carnet des écarts** (fiche n° 3), en une ligne marquée `écart` :
> `AAAA-MM-JJ · auteur · mission · écart · attendu : … · vu : … · vérifié : comment (ou « non ») · décision : …`
> La décision est l'une des trois : **garder** (vérifié : on adopte), **creuser** (prochain
> essai, daté), **abandonner** (vrai hasard : on le note).
> Règle : on ne sanctionne pas un écart signalé ; on regarde d'abord, on corrige ensuite,
> s'il le faut.
>
> **Les changements de cap** (fiche n° 13), en une ligne marquée `cap`, signée par qui l'a
> décidé : `AAAA-MM-JJ · auteur · mission · cap · ancien → nouveau · pourquoi : … · fait : …`
>
> **La délégation**, en une ligne marquée `délégation`, signée de Pascal :
> `AAAA-MM-JJ · Pascal · — · délégation · portée : … · jusqu'à : … · réservé : …`
> Chaque décision prise par délégation :
> `AAAA-MM-JJ · Claude (orchestrateur, par délégation) · mission · décidé : … · pourquoi : … · ce que Pascal peut défaire : …`

2026-11-23 · Claude (orchestrateur) · — · méthode installée : CLAUDE.md, docs/brief.md (gabarit), pilotage/ (equipe, kanban, journal, missions/), docs/adr/ · nom, phrase, destinataires et référentiels retenus par Pascal · reste à remplir : brief (via /brief, en s'appuyant sur docs/brief-typologie-peuplements.md), spec, ADR, .claude/test-command, équipe et délégation
2026-11-23 · Pascal · — · brief relu et retenu (docs/brief.md) · réponse d'abord : « je m'en passe » · coût complet : inconnu · pas de grille 20 ou 25 m à trancher par ADR · décidé : placette de référence de 15 m de rayon (30 m de diamètre)
2026-11-23 · contradicteur · — · brief critiqué : 3 bloquants (critère 76 % non comparable et sans référence ; placettes IFN au km sous secret statistique, protocole concentrique 6/9/15 m ; seuils par SER contredits par le SRGS AURA à 47,5 cm et 8 types obligatoires), 5 importants (support 707 m² vs pas, existant ONF/FORMS/BD Forêt v3, circularité de la hauteur potentielle, couverture LiDAR et masque, diffusion privée), 7 mineurs · 10 ADR proposées · à trancher par Pascal
2026-11-23 · Pascal · — · arbitrages de la critique, tous retenus : B1 (critère de passage réécrit : référence = clé sur arbres mesurés de grappes au demi-ha, précisions avec IC par SER, au moins aussi bien qu'une base par SER, avis des gestionnaires) ; B2 (IFN en validation d'agrégats seulement, pas de demande à l'IGN qui ne donne pas d'autorisation ; placettes de calibration au mètre près) ; B3 (seuils par référentiel typologique et groupe d'essences, surface terrière par classe de 5 cm, correspondance 8 types SRGS obligatoire) ; I1 (pas de 25 m, support 15 m de rayon, Lambert-93) ; I2 (section existant, problème reformulé, ADR reprise chaîne ONF) ; I3 (hauteur potentielle conditionnelle) ; I4 (masque + LiDAR, classes sans donnée, couche date de vol, continuité aux blocs LiDAR) ; I5 (deux niveaux de diffusion) ; M1 à M7
2026-11-23 · Claude (orchestrateur) · — · arbitrages reportés dans docs/brief.md et CLAUDE.md (règles métier)
2026-11-23 · Claude (orchestrateur) · — · docs/spec.md rédigée (proposée) ; 11 ADR proposées dans docs/adr/ (0001 à 0011), à critiquer par le contradicteur puis à trancher par Pascal
2026-11-23 · contradicteur · — · ADR 0001-0011 et spec critiquées : 4 bloquants (unité d'évaluation pixel / demi-ha et « erreur par pixel » non définies ; masque contre 8 types SRGS — landes, terrain nu, accrus ; « au moins aussi bien » sans test de non-infériorité ; A5 et A14 renvoient à des ADR inexistantes, ADR continuité manquante), importants dont : source du recalage erronée (Monnet et Mermin 2014), lien Etalab mort, lidR plus financé depuis 2024 (lasR), placettes 2020 antérieures au LiDAR HD, validation IFN par agrégats absente, probabilité non calibrée, type SRGS jamais validé · ADR 0012 « continuité » proposée · ordre proposé : 0006, 0003, 0005, 0002+0001, 0012, 0004, 0009, 0011, 0007, 0010, 0008 · à trancher par Pascal
2026-11-23 · Claude (orchestrateur) · — · corrections factuelles sans décision : source du recalage (Monnet et Mermin 2014) dans ADR 0004, liens Sentinel-2 (0001) et Etalab (0008), mention « sujet proposé par le contradicteur, rédigée par l'orchestrateur » (0001-0004, 0007)
2026-11-23 · Pascal · — · décidé : le résultat qui compte est double, priorité au local — d'abord la justesse du type du référentiel du gestionnaire (SRGS ou guide local) à l'échelle de sa parcelle ; ensuite le type générique national au demi-hectare pour comparer les SER
2026-11-23 · Pascal · ADR 0006 · acceptée : légende qui fait foi = référentiel du gestionnaire (SRGS, guide, DRA/SRA) à la parcelle et au demi-ha ; type générique national en second ; hauteur potentielle en attribut
2026-11-23 · Pascal · ADR 0003 · acceptée : surface terrière par classe de 5 cm × groupe d'essences + part de taillis ; trois méthodes comparées au pilote (par classe, k-NN, Weibull) ; table des référentiels tenue par le projet
2026-11-23 · Pascal · ADR 0005 · acceptée : emprise de calcul élargie (masque IGN + landes, accrus, terrains nus + polygones de gestion) ; emprise forêt IGN pour les statistiques ; aire d'applicabilité (Meyer et Pebesma 2021)
2026-11-23 · Pascal · ADR 0002 · décidé : unité d'évaluation = le pixel ; grappes de 50 × 100 m alignées sur la grille, inventaire en plein avec position des arbres, bande de 15 m
2026-11-23 · Pascal · ADR 0001, 0002 · acceptées après révision (non-infériorité appariée, second niveau IFN, couche confiance définie, probabilité calibrée, validation croisée spatiale ; Monnet et Munoz cités exactement, support Sentinel-2 élargi)
2026-11-23 · Pascal · ADR 0012 · acceptée : bande de transition pondérée aux limites de SER, signalement aux limites de blocs LiDAR, limites SRGS non lissées
2026-11-23 · Pascal · ADR 0004 · acceptée : protocole ONF complété, position des arbres obligatoire, placettes anciennes contrôlées contre le MNH LiDAR HD ; jeux lidaRtRee (quatre_montagnes, chablais3) examinés à la demande de Pascal : données de test de la chaîne, pas de validation du type
2026-11-23 · Pascal · ADR 0009 · acceptée : chaîne nouvelle sur socle lidaRtRee ; placettes ONF à instruire au cadrage, séparément du code
2026-11-23 · Pascal · ADR 0011 · acceptée : paquet R + PDAL en ligne de commande, renv + conteneur ; .claude/test-command écrit
2026-11-23 · Pascal · ADR 0007 · acceptée : hauteur potentielle conditionnelle ; réutiliser d'abord la carte de fertilité ONF et les modèles d'indice de fertilité IFN ; sources non relues signalées
2026-11-23 · Pascal · ADR 0013 · décidé : versions calendaires vAAAA.MM.N, tags, releases et notation comme dans Marculus ; badges au README
2026-11-23 · Claude (orchestrateur) · — · ADR 0013 rédigée d'après pobsteta/marculus origin/main ; README.md créé avec badges (CI, Release, Version, Couverture, R, LiDAR HD, Lambert-93, Licence à trancher) ; carte « CI et releases » au bac à sable du kanban
2026-11-23 · Pascal · ADR 0010 · acceptée : COG + RAT, codes sans donnée 250-253 et 255, STAC + INSPIRE, millésime vAAAA.MM.N, dépôt pérenne avec DOI
2026-11-23 · Pascal · ADR 0008 · acceptée : code GPL-3.0, données Licence Ouverte Etalab 2.0, produit complet remis sur demande par CNPF / ONF au rédacteur mandaté, dégradation instruite par un juriste au cadrage
2026-11-23 · Claude (orchestrateur) · — · LICENSE (GPL-3.0) ajouté, badge Licence du README mis à jour ; docs/spec.md révisée selon les ADR 0001 à 0013 (26 critères d'acceptation) ; questions ouvertes du brief mises à jour · reste : validation du brief et de la spec par Pascal (porte n° 1) ; rien n'est encore commité
2026-11-23 · Claude (orchestrateur) · — · écart · attendu : .claude/test-command vert en fin de tour · vu : échec « Could not find a root 'DESCRIPTION' file », le paquet R n'existe pas encore (aucun code avant la porte n° 1) ; un paquet vide échoue aussi (« No test files found ») · vérifié : essai d'un paquet vide dans le bloc-notes · décision : creuser — ne pas écrire de test factice ; le squelette du paquet et ses premiers vrais tests vont dans la première mission (avec la CI, ADR 0011 et 0013)
2026-11-23 · hook tests_obligatoires · — · arrêt accepté au second essai sans tests verts (tests rouges, code 1, `Rscript -e 'testthat::test_local()'`) : mission non vérifiée, à reprendre.
2026-11-23 · Pascal · — · porte n° 1 franchie : brief (docs/brief.md) et spec (docs/spec.md) validés · prochaine étape : /imperatrice:mission (porte n° 2)
2026-11-23 · hook tests_obligatoires · — · arrêt accepté au second essai sans tests verts (tests rouges, code 1, `Rscript -e 'testthat::test_local()'`) : mission non vérifiée, à reprendre.
2026-11-23 · Claude (orchestrateur) · — · /mission : 7 fiches proposées (001 squelette + CI + releases, dev ; 002 référentiels AURA, acquereur, prendre ; 003 inventaire des SER candidates, acquereur ; 004/005 tests puis grille et disque, testeur puis dev opus, prendre ; 006/007 tests puis clé du type local, attendent 002) · cycle 1 proposé : 001, 002, 003 (plafond de 3 PR) · en attente de la porte n° 2
2026-11-23 · hook tests_obligatoires · — · arrêt accepté au second essai sans tests verts (tests rouges, code 1, `Rscript -e 'testthat::test_local()'`) : mission non vérifiée, à reprendre.
2026-11-23 · Pascal · — · porte n° 2 franchie : équipe et missions 001 à 007 validées ; cycle 1 = 001, 002, 003 ; 004 à 007 planifiées
2026-11-23 · hook tests_obligatoires · — · arrêt accepté au second essai sans tests verts (tests rouges, code 1, `Rscript -e 'testthat::test_local()'`) : mission non vérifiée, à reprendre.

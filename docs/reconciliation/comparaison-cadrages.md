# Comparaison des deux cadrages de typopeuplement — A (à garder) contre B (à exploiter)

Préparée le 2026-11-23 pour Pascal, sans rien trancher. Lecture seule du dépôt (`git show`).

- **A** = `origin/ccr-77332e39-02nzhw` (contient `origin/main` + le cycle 2, 44 commits d'avance, aucun de retard).
  Les citations « A » donnent le fichier et la ligne dans cette branche.
- **B** = `docs/cadrage` (commit 7b714f1). Les citations « B » donnent le fichier et la section (ADR, critère).
- Catégories : **1** déjà dans A, identique · **2** dans A mais différent ou contradictoire (à Pascal) ·
  **3** absent de A, apport neuf · **4** absent de A, caduc ou inutile du fait de A.

**Attention de forme pour la PR d'amendement** : A a déjà des ADR 0001 à 0004 (stack). Toute ADR reprise
de B doit être renumérotée (0005 et suivantes) et ses renvois internes (« ADR 0003 », « A14 »…) réécrits.

**Décompte : 15 en catégorie 1, 14 en catégorie 2, 19 en catégorie 3, 5 en catégorie 4 (53 points),
plus 17 points de la critique du contradicteur qui s'appliquent à A (section 6).**

---

## 1. Tableau de synthèse

| # | Sujet | Cat. | A dit | B dit | Proposition |
|---|---|---|---|---|---|
| 1.1 | Référence de validation | 1 | Clé appliquée aux mesures, pas le type à dire d'expert (CLAUDE.md l.45-46) | Idem (brief, « Critères de passage » ; ADR 0002) | Rien à reprendre |
| 1.2 | Placettes IFN | 1 | Coordonnées au km, contrôle à l'échelle SER, jamais calibration, pas de contact IGN (spec l.36, l.62 ; journal l.33) | Validation d'agrégats seulement, pas de demande à l'IGN (ADR 0004) | Rien (voir 3.13 pour la méthode) |
| 1.3 | Langage R, paquet, testthat | 1 | ADR 0004 l.11-13 ; test-command | ADR 0011 | Rien |
| 1.4 | Licence du code | 1 | GPL-3 (DESCRIPTION ; README l.77 « GPL-3.0-or-later ») | GPL-3.0 (ADR 0008) | Rien sur le choix (voir 3.8) |
| 1.5 | Typologie descriptive, hors périmètre | 1 | CLAUDE.md l.35-36, l.51 ; spec l.58-61 | brief « Ce qu'il ne fait pas » | Rien |
| 1.6 | SER 86 + 5, GRECO A-K + L | 1 | CLAUDE.md l.52-54, vérifié (mission 002, `docs/referentiels/ser.md`) | Idem, « à confirmer » | Rien : A l'a confirmé |
| 1.7 | Lambert-93, hexagone + Corse | 1 | brief l.52 ; R/milieu.R l.70 | ADR 0001 | Corriger « hexagonale » seul dans CLAUDE.md l.3-4 et DESCRIPTION (mineur, propre à A) |
| 1.8 | Comparer RF, SVM, LDA | 1 | brief l.99 ; `comparer_classifieurs()` (R/modeles.R) | brief (M6) | Rien |
| 1.9 | Clé à part pour les SER d'alluvions | 1 | brief l.142 ; kanban | ADR 0005 (peupleraies) | Rien |
| 1.10 | BD Forêt v3 en entrée, jamais vérité | 1 | brief l.91 ; spec l.40 | brief, CLAUDE.md | Rien |
| 1.11 | Bande de transition pondérée aux limites de SER | 1 | CLAUDE.md l.56-57 ; spec critère 4 (l.72) ; `poids_transition()` R/ser.R l.72 (demi-largeur 500 m provisoire) | ADR 0012 (pondération linéaire, largeur fixée au pilote, GRECO héritée sans limite interne) | Rien (voir 3.12 pour les blocs LiDAR) |
| 1.12 | Repli sur la hauteur mesurée, signalé | 1 | brief l.120 ; spec critère 5 ; drapeau `hp_incertaine` | ADR 0007 (repli) | Rien (voir 3.14) |
| 1.13 | Cartes jugées utilisables par les gestionnaires | 1 | brief l.201 | brief « Pilotes » ; spec A14 (protocole d'avis) | Option : reprendre « protocole d'avis écrit, avec son seuil » dans spec A critère 7 |
| 1.14 | Rejeu après coupe, dépérissement, nouveau vol | 1 | brief l.184 | spec O5 | Voir 3.16 pour fordead |
| 1.15 | Priorité au type du référentiel local | 1 | Types venus de la typologie locale (CLAUDE.md l.37-39) ; cap GSM pour H10 (journal l.82) | ADR 0006 : la légende qui fait foi est celle du gestionnaire | Rien sur le principe (voir 2.2, 2.3, 3.2) |
| 2.1 | **Seuils de diamètre : où ils s'attachent** | 2 | « Seuils propres à chaque SER » ; H10 = 42,5 cm, fidèle au GSM (CLAUDE.md l.40-42 ; spec critère 2 l.68-69 ; journal l.83) ; config par SER / grande région | « Par référentiel typologique et groupe d'essences, jamais par SER » ; SRGS AURA 47,5 cm toutes essences, 42,5 admis **en résineux** avec une typologie (ADR 0003 ; CLAUDE.md B) | **À Pascal.** Voir détail : conflit avec la décision 42,5 « toutes essences » pour H10 |
| 2.2 | **8 types SRGS obligatoires** | 2 | SRGS jugé « trop grossier » pour la carte de H10 (typologie-h10.md l.68, l.166) ; table de correspondance avec « la typologie locale » (spec l.54) | Livrable obligatoire de chaque pilote, légende minimale (brief B3 ; ADR 0006 ; spec A6) | **À Pascal** : SRGS en seconde légende de H10, ou non |
| 2.3 | **Hauteur potentielle : attribut ou dimension de la légende** | 2 | La clé GSM de H10 en dépend (CH si Hₒ pot. < 15 m ; strates = quarts de Hₒ pot.) (vercors-h10.json ; typologie-h10.md l.44, l.62) | « Un attribut, pas une dimension de légende » (ADR 0006) | **À Pascal** : contraire au cap A ; la règle de B ne tient pas avec le GSM |
| 2.4 | **Hauteur potentielle : méthode** | 2 | Apprise sur les « adultes fermés » repérés par LiDAR (couvert ≥ 0,7, h ≥ 15 m), relief seul, enveloppe k (brief l.114 ; R/hauteur_potentielle.R l.11-30 ; journal l.107-110) | Adultes LiDAR rejetés (circulaire) ; référence par âge ou indice de fertilité ; réutiliser d'abord la carte de fertilité ONF et les modèles IFN (ADR 0007) | **À Pascal** ; la mission 011 de A (incertitude locale) est le bon endroit |
| 2.5 | **Grille et support** | 2 | « De l'ordre de 25 m » (brief l.54) ; en pratique la grille ONF de 26,6 m (README l.21 ; R/donnees_lidar.R l.5) ; défaut 25 m (`ecrire_livrables`, typer_peuplements.R l.293) | Pas 25 m, origine multiple de 25 m, métriques sur un disque de 15 m de rayon centré sur le nœud ; 26,6 m « comparé au pilote » (ADR 0001 ; spec A1-A2) | **À Pascal** ; noter que la source citée par B (Monnet et Munoz 2015) penche pour le pavage carré, donc pour la grille ONF de A |
| 2.6 | **Unité d'évaluation et grappes** | 2 | Placette et grappe = maille carrée de 70,7 m (0,5 ha) regroupant des placettes (R/validation.R l.55-62 ; CLAUDE.md l.49-50) | Unité = le pixel ; grappes 50 × 100 m alignées sur la grille + bande de 15 m, inventaire en plein avec position des arbres, 8 pixels recalculés ; plan stratifié par type prédit (ADR 0002) | **À Pascal** ; coût terrain élevé (≈ 0,9 ha en plein par grappe) |
| 2.7 | **Critère de passage** | 2 | Seuil « par usage et par SER, fixé avec les utilisateurs ; repère de 76 % » (spec critère 7 l.78-79 ; brief l.201 ; journal l.28) ; précision et kappa (spec critère 6) | Non-infériorité appariée face à une base de comparaison écrite d'avance, marge Δ fixée avant, sous-test feuillus ; précisions utilisateur / producteur avec IC (Olofsson 2014) ; « le 76 % n'est pas le seuil du projet » (ADR 0002 ; spec A11, A13) | **À Pascal** |
| 2.8 | **Échelle : AOI ou produit national** | 2 | Calcul par AOI (forêt, au plus massif), pas la France d'un coup (brief l.11, l.53 ; spec l.60 ; décision de Pascal B1) | Carte par SER, millésimes nationaux, dépôt avec DOI, stockage national estimé (brief B ; ADR 0010) | **À Pascal** ; le périmètre de A prime sauf décision contraire |
| 2.9 | **Reprise de l'existant** | 2 | Les rasters ONF du Vercors sont **l'entrée** de la chaîne (mode « variables fournies », README l.20-22) ; pas de contact ONF (journal l.84, l.117) | Chaîne nouvelle sur socle lidaRtRee ; cartes ONF **en contrôle** seulement (option « en entrée » écartée, support différent) ; accès aux placettes ONF instruit au cadrage (ADR 0009) | **À Pascal** ; touche l'extérieur (ONF) |
| 2.10 | **Outil du nuage de points** | 2 | lasR (Suggests, r-universe), en usage pour strates et houppiers (ADR 0003 A ; README l.58-73 ; DESCRIPTION) | lidR + lidaRtRee + PDAL en ligne de commande ; lasR « en réserve » ; risque : Laval ne finance plus ni lidR ni lasR depuis 2024 (ADR 0011) | **À Pascal** ; le risque vaut pour lasR aussi |
| 2.11 | **Validation croisée** | 2 | Plis mélangés au hasard (dendro, R/modeles.R l.82-92) et stratifiés (classifieurs, l.160-200) ; plis par blocs pour la seule hauteur potentielle | Choix du modèle par validation croisée **spatiale** (Ploton 2020) ; distance minimale grappe–placette (ADR 0002 ; spec A10, A12) | **À Pascal** ; impacte des chiffres déjà rapportés (0,84 / 0,81) |
| 2.12 | **« Probabilité » du type** | 2 | Appartenance floue (produits de sigmoïdes normalisés, R/cle.R l.5-30, l.69-71), appelée « probabilité » (spec l.47) | Diagramme de fiabilité + score de Brier ; si non calibrée, la couche s'appelle « score » (ADR 0002) | **À Pascal** : renommer ou calibrer |
| 2.13 | **Contenu de la couche de confiance** | 2 | Drapeaux : entre deux types, h_pot incertaine, niveau du modèle, hors clé, strates basses estimées (CLAUDE.md l.47-48 ; typer_peuplements.R l.260) | Précision utilisateur du type prédit dans la SER avec IC + écart entre les deux premières probabilités + sauts aux blocs LiDAR (ADR 0002, 0012) | **À Pascal** : ajouter la précision utilisateur aux drapeaux de A ? |
| 2.14 | **Diffusion en forêt privée** | 2 | Parade : « résolution dégradée en diffusion publique, comme dans le Vercors drômois » (brief l.221) | Deux niveaux **ou aucun**, à instruire par un juriste ; produit complet remis sur demande par le CNPF ou l'ONF au rédacteur mandaté (ADR 0008) | **À Pascal** ; touche l'extérieur (CNPF, ONF, juriste) |
| 3.1 | Surface terrière par classe de 5 cm × groupe d'essences, part de taillis, table des référentiels | 3 | A prédit des parts PB/BM/GB à seuil fixé (`variables_cibles`, exemple.json) ; « part du taillis absente », d'où le type T du GSM non exprimable (typologie-h10.md l.92, l.129) | Distribution par classes, seuils appliqués en aval ; 3 méthodes comparées (par classe, k-NN, Weibull) ; table versionnée des référentiels, livrable (ADR 0003) | Reprendre en ADR et dans spec A (variables, livrables) ; lié à 2.1 |
| 3.2 | Type générique national en second | 3 | Question ouverte « clé nationale ou clés par SER » (brief l.228 ; spec l.96) | Tranchée : type local d'abord, type générique national ensuite, aligné sur les variables IFN (ADR 0006) | Si retenu : fermer la question dans brief A l.228 et spec A l.96 |
| 3.3 | Protocole de placette, contrôles à l'import, contrôle contre le MNH, recalage | 3 | Placettes « des utilisateurs », sans protocole écrit ; vœux du brief l.179 | Protocole ONF de 15 m complété (rayon horizontal, position des arbres obligatoire, origine, état) ; rejet X/Y inversés et WGS84 ; placettes anciennes contrôlées contre le MNH LiDAR HD ; recalage Monnet et Mermin 2014 (ADR 0004 ; spec A7-A9) | Ajouter à spec A (critères) et en ADR ; utile avant toute placette réelle |
| 3.4 | Emprise de calcul élargie, emprise forêt pour les statistiques | 3 | Aucune emprise définie ; X, P, A non exprimables, pixels de couvert < 0,1 sans type (typologie-h10.md l.133) | Masque Forêt IGN ∪ landes, accrus, terrains nus ∪ polygones de gestion ; emprise IGN pour les statistiques (ADR 0005) | En ADR ; s'articule avec l'AOI de A |
| 3.5 | Domaine de validité = aire d'applicabilité | 3 | « Domaine de validité » cité (spec l.53) mais non défini | Aire d'applicabilité de Meyer et Pebesma 2021 (CAST), code 253 (ADR 0005 ; spec A19) | Spec A, livrables et critères |
| 3.6 | Codes « sans donnée » 250-253 et 255 | 3 | Idée présente (spec l.50-51) mais « pas encore portée » (typer_peuplements.R l.281-282) | Liste unique, RAT, couche de codes pour les couches continues (ADR 0010) | Spec A + `ecrire_livrables()` |
| 3.7 | COG, `.qml`, STAC, INSPIRE, dépôt DOI, millésime immuable | 3 | GeoTIFF simples (typer_peuplements.R l.319) ; ADR 0004 l.43-44 « GeoTIFF ou COG » | ADR 0010 ; spec A21, A23-A24 | COG + `.qml` + RAT faciles ; STAC/INSPIRE/DOI à juger selon 2.8 |
| 3.8 | Licence des données, fichier LICENSE | 3 | Pas de fichier LICENSE dans A ; « GPL-3 » (DESCRIPTION) contre « GPL-3.0-or-later » (README l.77) ; aucune licence pour les cartes | LICENSE GPL-3.0 ; données sous Licence Ouverte Etalab 2.0 (ADR 0008) | Copier LICENSE de B ; aligner DESCRIPTION/README ; Etalab 2.0 pour les livrables |
| 3.9 | Versions calendaires vAAAA.MM.N, CI, release conditionnelle, badges | 3 | `Version: 0.1.0`, ni `.github/` ni CI | Convention de Marculus, décision de Pascal (ADR 0013 ; README B ; spec A22) | Reprendre ADR 0013 et le README de B (badges), puis une mission CI |
| 3.10 | Reproductibilité : renv, conteneur, graines et fils, `targets` | 3 | Graines fixées ; pas de renv ni d'image ; test-command encore avec pytest | ADR 0011 ; spec A20 | Mission avec 3.9 |
| 3.11 | Jeux de test lidaRtRee | 3 | Fixtures propres (synthétique, extrait Vercors, `nuage.laz`) | `tree_inventory_chablais3` + `chm_chablais3` (arbres positionnés, essence, hauteur) ; `quatre_montagnes` (96 placettes de 15 m dans le Vercors, G, N) (ADR 0004) | Chablais 3 peut tester la segmentation des houppiers (013) contre des arbres mesurés ; lidaRtRee en Suggests seulement |
| 3.12 | Limites de blocs LiDAR, couche `vol`, limites SRGS non lissées | 3 | Risque « date et saison du vol en variable » (brief l.220), non codé | Vol le plus récent en recouvrement, saut signalé dans `confiance`, jamais lissé ; couche date et saison du vol ; légende SRGS non lissée (ADR 0012 ; spec A17-A18) | Spec A critères + livrables |
| 3.13 | Méthode du contrôle IFN | 3 | Critère 6 « contrôle par les placettes IFN de la SER », partiel, test sauté (journal l.92) | Protocole concentrique 6/9/15 m ramené à 15 m avec sa variance ; proportions de types de la carte contre estimations IFN, estimateur nommé, pas de poids de post-stratification dans les données brutes (brief B2 ; ADR 0002) | Préciser spec A critère 6 |
| 3.14 | Hauteur potentielle : livrable conditionnel par SER | 3 | Drapeau par pixel (seuil relatif 0,2) | Critère propre par SER, seuil d'erreur fixé avant les résultats ; sinon pas de couche `hpot` (ADR 0007 ; spec A16) | Spec A critère 5 ; attention à 2.3 (le GSM ne peut pas s'en passer) |
| 3.15 | Synthèse et validation à la parcelle | 3 | AOI en polygones, pas de synthèse par parcelle | Surfaces par type et variables moyennes par polygone, estimateur et règle des bordures nommés ; validation à la parcelle (spec P3, A25 ; ADR 0006) | Spec A parcours + critère |
| 3.16 | Écart vol / relevé, exclusion des zones coupées | 3 | Constat 2 à 4 ans d'écart (brief l.30, l.86) ; pas de règle | Écart maximal fixé ; grappe exclue si coupe détectée (fordead) (ADR 0002, 0004) | Spec A |
| 3.17 | Relecture de la clé par le CNPF et l'ONF sur cas types | 3 | Absente (la relecture de la clé GSM est faite par Pascal et sur 3 pixels de terrain) | Spec A15 | Touche l'extérieur : à Pascal |
| 3.18 | Sentinel-2 : rééchantillonnage unique, support effectif | 3 | Non branché (kanban, bac à sable) | Une seule fois vers Lambert-93, support > 15 m (géolocalisation 6-7 m CE95) (ADR 0001) | À garder pour la mission Sentinel-2 |
| 3.19 | Cadrage : existant complété, coût complet, juriste, vol avec et sans feuilles | 3 | Existant : SDIF, MNH, FORMS, ONF Ain, nemeton (brief l.69-73) ; coût « inconnu » | Open-Canopy, cartes ONF 700 m², Vercors drômois ; estimer le coût au cadrage ; juriste ; un vol feuillé et un non feuillé par SER pilote (brief B) | Ajouts de brief, mineurs |
| 4.1 | Typologie de départ : triangle des structures de Souchon, types 1, 2, 3 | 4 | Remplacée par les 20 types du GSM pour H10 (cap du 2026-11-22, journal l.82) | CLAUDE.md B | Ne pas reprendre |
| 4.2 | Choix des SER pilotes (question ouverte, mission 003 de B) | 4 | H10, AOI Vercors drômois, forêt de Léoncel (journal l.44, l.60, l.91) | Inventaire des 4 SER candidates pour choisir | Caduc pour la 1re SER ; l'inventaire peut resservir pour la SER feuillue et la SER privée (brief A l.150-151) |
| 4.3 | Missions 001 (squelette du paquet) et 002 (référentiels AURA) de B | 4 | Paquet existant ; SRGS 8 types et GSM déjà saisis avec pages (typologie-h10.md) | Fiches B 001, 002 | Ne garder que CI/renv (3.9-3.10) et le protocole IFN (3.13) |
| 4.4 | Clé du type local sur une liste d'arbres (mission 007 de B) | 4 | `types_observes()` (R/cle.R l.254) applique la clé aux mesures ; la clé GSM demande des couverts de strates, qu'une liste d'arbres (essence, diamètre, origine) ne donne pas | Fiche B 007 | Caduc sous cette forme ; voir remarque 5.3 |
| 4.5 | Débat Python / mixte / Computree (ADR 0011 B) | 4 | Tranché : R, compagnon de nemeton (ADR 0001-0004 A) | ADR 0011, options 2 à 4 | Ne pas reprendre |

---

## 2. Catégorie 1 — déjà dans A, identique (15)

Rien à reprendre ; les citations du tableau suffisent. Deux nuances :

- **1.6** B écrit « GRECO K et L, à confirmer » : A l'a confirmé (mission 002, journal l.41-42, l.92-93).
- **1.15** Le principe « priorité au référentiel du gestionnaire » est commun, mais ses deux conséquences dans B
  (8 types SRGS obligatoires, hauteur potentielle hors légende) ne le sont pas : voir 2.2 et 2.3.

## 3. Catégorie 2 — différent ou contradictoire (14), du plus au moins important

**2.1 Seuils de diamètre — conflit avec une décision de Pascal (journal A l.83, 2026-11-22).**
- A : seuils **par SER** (CLAUDE.md l.40-42 ; spec critère 2, l.68-69 : « un arbre de 45 cm compte en gros bois en
  Savoie et en bois moyen dans les Vosges »). H10 : 42,5 cm « fidèle au GSM », appliqué **à toutes les essences**
  (`seuils_diametre.bm_gb_cm = 42.5`, vercors-h10.json).
- B : « par référentiel typologique et groupe d'essences, **jamais par SER** » ; SRGS AURA 2023 : 47,5 cm toutes
  essences, 42,5 cm admis **en résineux** quand une typologie l'utilise (CLAUDE.md B ; ADR 0003).
- Où ça coince : (a) la règle de B, appliquée au GSM, garderait 42,5 cm pour les résineux mais mettrait les feuillus
  de Léoncel (hêtre) à 47,5 cm, contre la décision de Pascal ; (b) si les 8 types SRGS sont aussi livrés pour H10
  (2.2), la même SER porte deux limites (42,5 pour le GSM, 47,5 pour le SRGS), ce que la configuration de A, un
  seuil par SER, ne sait pas écrire ; (c) le critère 2 de A serait à réécrire. Le texte du SRGS est déjà recopié
  dans A (typologie-h10.md l.70) : sa lecture y est « possible de garder la valeur du GSM quand une typologie
  comme le GSM est utilisée » (l.76), sans restriction aux résineux, ce qui diffère de la lecture de B.
- À Pascal : où s'attache le seuil (SER ou référentiel) ; 42,5 cm pour toutes les essences ou pour les seuls
  résineux en H10.

**2.3 Hauteur potentielle : attribut (B) ou dimension de la légende (A).** B ADR 0006 la sort de la légende
« pour que les légendes restent comparables entre SER ». Or le GSM, retenu par Pascal (cap A, journal l.82), la
met au cœur de sa clé : CH si Hₒ potentielle < 15 m, et les quatre strates sont des quarts de Hₒ potentielle
(typologie-h10.md l.44, l.62). Le repli de B (« la clé utilise la hauteur mesurée ») n'a pas d'équivalent écrit
dans le GSM. La règle de B ne peut valoir, au plus, que pour le type générique national (3.2).

**2.2 8 types SRGS obligatoires.** A a examiné et écarté le SRGS comme légende de la carte de H10 (« trop
grossiers », typologie-h10.md l.68, option (c) l.166). B en fait la légende minimale et un livrable obligatoire de
chaque pilote (spec B A6, P5). Les deux ne s'excluent pas (le SRGS en seconde légende, déduite des mêmes variables),
mais cela suppose la part de taillis (3.1) et des types « landes, accrus, terrain nu » que A ne sait pas produire (3.4).

**2.4 Méthode de la hauteur potentielle.** A apprend sur les « adultes fermés » repérés par LiDAR (couvert ≥ 0,7,
hauteur ≥ 15 m ; R/hauteur_potentielle.R l.11-30), relief seul, enveloppe k = quantile 0,9 hors sac (journal
l.110). B rejette cette option comme circulaire (ADR 0007, option 1) et veut d'abord réutiliser la carte de
fertilité ONF (webinaire Theia 2024) et les modèles d'indice de fertilité tirés de l'IFN (Bontemps et Bouriaud).
La parade de A était le contrôle par les courbes de nemeton là où l'âge est connu (brief l.118 ; spec critère 5) ;
noter que Pascal a répondu « Non » à « nemeton en contrôle croisé » le 2026-11-23 (journal l.149, dans le contexte
de 013 : portée à préciser). Le pixel 2 de Léoncel donne un premier retour favorable (journal l.147).

**2.7 Critère de passage.** A : seuil par usage et par SER fixé avec les utilisateurs, « repère de 76 % » pour les
résineux de montagne (spec l.78-79 ; décision par délégation, journal l.28), précision et kappa (spec l.75-76). B :
non-infériorité appariée face à une base de comparaison écrite avant les résultats (règle BD Forêt v3 + MNH, ou clé
2020 rejouée sur LiDAR HD), marge Δ fixée d'avance, sous-test feuillus, précisions avec IC par type et par SER, et
« le 76 % porte sur la seule structure : ce n'est pas le seuil du projet ». B ne parle pas du kappa ; Olofsson et al.
(2014), cité par B, le déconseille (à vérifier dans le texte).

**2.6 Unité d'évaluation et grappes.** A : grappe = maille carrée de 70,7 m qui regroupe des placettes existantes,
type observé majoritaire (R/validation.R l.55-80). B : le pixel, par des grappes rectangulaires de 50 × 100 m
alignées sur la grille, inventoriées en plein avec la position des arbres, plan stratifié par type prédit. 70,7 m
n'est un multiple ni de 25 ni de 26,6 m. Le dispositif de B coûte cher en terrain (≈ 0,9 ha en plein par grappe).

**2.8 Échelle.** A calcule par AOI (Pascal, arbitrage B1 du 2026-11-22) ; B produit des millésimes nationaux par
SER, avec dépôt DOI et estimation de stockage national. Tout ce qui, dans B, suppose le produit national (ADR 0010
dépôt, ADR 0012 « carte nationale sans couture ») est à relire à l'échelle AOI.

**2.5 Grille.** A tourne sur la grille ONF de 26,6 m (≈ 707 m², la surface de la placette) en mode « variables
fournies », avec un défaut à 25 m ailleurs. B impose 25 m + disque de 15 m et ne garde 26,6 m que comme option
comparée au pilote. La source citée par B (Monnet et Munoz 2015 : pixels carrés « légèrement meilleurs du point de
vue du biais », « il semble donc judicieux d'utiliser des pixels ») va plutôt dans le sens de A.

**2.9 Reprise de l'existant.** A prend les rasters ONF comme entrée (G, N, p100GGB, H0…) ; B les réserve au contrôle
et bâtit sur lidaRtRee. B veut aussi instruire l'accès aux placettes ONF au cadrage, alors que Pascal a dit « pas de
contact ONF » pour 006 et 008 (journal l.84, l.117).

**2.10 Outil du nuage de points.** A : lasR, en usage (strates, houppiers ; catalogue avec tampon, journal l.158).
B : lidR + lidaRtRee + PDAL, lasR en réserve. L'argument de B (fin du financement de Laval en 2024) touche lasR autant
que lidR ; lasR est en plus hors CRAN et se compile.

**2.11 Validation croisée.** Plis mélangés dans A (R/modeles.R l.82-92, l.160-200) contre validation croisée spatiale
dans B (Ploton 2020). Les chiffres de A (placette 0,84, grappe 0,81, journal l.71) sont probablement optimistes.

**2.12 « Probabilité ».** Les valeurs de A sont des appartenances floues normalisées (R/cle.R), jamais confrontées
à des fréquences observées. B : diagramme de fiabilité + Brier, sinon la couche s'appelle « score ».

**2.13 Couche de confiance.** Les drapeaux de A et la définition de B ne se recouvrent que sur « écart entre les
deux premières probabilités » ≈ « entre deux types ». B ajoute la précision utilisateur avec IC, que A n'a pas.

**2.14 Diffusion en forêt privée.** A pose la dégradation comme parade acquise (brief l.221) ; B la laisse ouverte
(deux niveaux ou aucun) jusqu'à l'avis d'un juriste, et organise la remise du produit complet par le CNPF ou l'ONF.

## 4. Catégorie 3 — apports neufs (19), du plus au moins important, avec le fichier de A visé

1. **3.1 G par classe de 5 cm × groupe d'essences + part de taillis + table des référentiels** → nouvelle ADR,
   `docs/spec.md` (variables, livrables), `docs/referentiels/`. Règle 2.1 et rend T du GSM exprimable.
2. **3.3 Protocole de placette, contrôles à l'import, contrôle contre le MNH, recalage** → nouvelle ADR,
   `docs/spec.md` (critères), à faire avant toute placette réelle.
3. **3.5 Aire d'applicabilité (CAST)** → `docs/spec.md` (livrables « domaine de validité », critère), `DESCRIPTION`
   (CAST en Suggests).
4. **3.6 Codes « sans donnée » 250-255** → `docs/spec.md` (livrables), `R/typer_peuplements.R` (`ecrire_livrables`).
5. **3.4 Emprise de calcul élargie / emprise forêt** → nouvelle ADR ; s'articule avec l'AOI.
6. **3.13 Méthode du contrôle IFN** → `docs/spec.md` critère 6.
7. **3.2 Type générique national en second** → `docs/brief-typologie-peuplements.md` l.228, `docs/spec.md` l.96.
8. **3.8 LICENSE + Etalab 2.0 pour les données** → fichier `LICENSE` (copie de B), `DESCRIPTION`, `README.md` l.77.
9. **3.9 Versions calendaires, CI, releases, badges** → ADR (0013 de B renumérotée), `README.md`, mission CI.
10. **3.10 renv, conteneur, `targets`** → même mission que 3.9.
11. **3.7 COG, `.qml`, RAT, STAC, INSPIRE, DOI** → `docs/spec.md` critère 8 ; COG + `.qml` d'abord.
12. **3.12 Blocs LiDAR, couche `vol`, limites SRGS non lissées** → `docs/spec.md` critère 4 et livrables.
13. **3.11 Jeux de test lidaRtRee** → `tests/testthat/` (houppiers contre arbres mesurés de Chablais 3).
14. **3.14 Hauteur potentielle : critère par SER** → `docs/spec.md` critère 5 (sous réserve de 2.3).
15. **3.15 Synthèse et validation à la parcelle** → `docs/spec.md` parcours et critères.
16. **3.16 Écart vol / relevé, exclusion des zones coupées** → `docs/spec.md`.
17. **3.17 Relecture de la clé par le CNPF et l'ONF** → `docs/spec.md` ; touche l'extérieur.
18. **3.18 Sentinel-2** → future fiche de mission Sentinel-2.
19. **3.19 Existant, coût, juriste, vols feuillés / non feuillés** → `docs/brief-typologie-peuplements.md`.

## 5. Catégorie 4 — caduc du fait de A (5)

Voir tableau (4.1 à 4.5). Trois remarques :

1. La fiche 003 de B (inventaire des SER candidates) peut resservir pour les SER pilotes encore ouvertes dans A
   (plaine feuillue, forêt privée : brief A l.150-151).
2. La fiche 002 de B demandait aussi le protocole IFN en vigueur : ce morceau n'est pas caduc (3.13).
3. **Conséquence de croiser A et B** : B définit la référence de validation comme « le type calculé par la clé sur
   les arbres mesurés ». Avec le GSM, la clé demande les couverts des quatre strates (estimés à l'œil dans le GSM,
   typologie-h10.md l.64) et la Hₒ potentielle : une liste d'arbres avec essence et diamètre ne suffit pas. Il
   faudrait des hauteurs et des projections de houppiers relevées sur le terrain, ou une règle pour les reconstruire.
   Ni A ni B ne le disent.

## 6. Critique du contradicteur de B : points qui touchent A

Sources : journal B (deux lignes « contradicteur » du 2026-11-23) et ADR B. Classés du plus au moins important.

| # | Point du contradicteur (B) | Ce qu'il touche dans A |
|---|---|---|
| C1 | Le 76 % porte sur la seule structure | brief A l.19 (« 76 % de bonne classification au demi-hectare », sans dire « structure » ; le tableau l.32 le dit) ; spec critère 7 |
| C2 | Hauteur potentielle circulaire si les adultes sont repérés par LiDAR | `ajuster_hauteur_potentielle()` / `peuplements_adultes()` (couvert ≥ 0,7, h ≥ 15 m) ; parade nemeton dont la portée est à préciser (journal l.149) |
| C3 | « Au moins aussi bien » sans test de non-infériorité | spec A critère 7, encore plus vague (« fixé avec les utilisateurs ») |
| C4 | Probabilité non calibrée | sorties `proba` de A (R/cle.R), présentées comme probabilité (spec l.47) |
| C5 | « Erreur par pixel » non définie | objectif 4 du brief A (l.47) : rien dans A ne la définit |
| C6 | Masque contre types SRGS non forestiers (landes, terrain nu, accrus) | X, P, A du GSM non exprimables ; pixels de couvert < 0,1 sans type (typologie-h10.md l.133) |
| C7 | Validation IFN par agrégats absente ; protocole concentrique 6/9/15 m, petits bois sur 113 m² | critère 6 de A partiel, test sauté |
| C8 | Validation croisée non spatiale (Ploton 2020, ADR 0002) | plis mélangés de R/modeles.R |
| C9 | lidR (et lasR) plus financés depuis 2024 | dépendance de A à lasR (hors CRAN, compilation, GDAL) |
| C10 | Type SRGS jamais validé | « table de correspondance avec la typologie locale » (spec A l.54) : livrable sans validation prévue |
| C11 | Seuils par SER contredits par le SRGS AURA (47,5 cm, 8 types) | CLAUDE.md l.40-42, spec critère 2, config (voir 2.1) |
| C12 | Placettes 2020 antérieures au LiDAR HD (2 à 7 ans) | toute reprise des placettes de Souchon ; règle d'écart absente de A |
| C13 | Pixel de bord : le support déborde sur la parcelle voisine (Monnet et Munoz 2015, p. 101) | lissage 3 × 3 de A (0,56 ha) aux limites de parcelles et d'AOI |
| C14 | Support de 707 m² contre le pas | A est cohérent sur la grille ONF (26,6 m ≈ 707 m²) mais garde un défaut de 25 m (`ecrire_livrables`) et un lissage décrit en pixels de 25 m (R/lissage.R l.26) |
| C15 | Couverture LiDAR, trous ZICAD, dates de vol | non porté dans les livrables de A (typer_peuplements.R l.281-282) |
| C16 | Feuillus mal servis | 78 % des pixels feuillus « incertains » avant correction, 14 % après (journal l.107, l.112) ; pas de sous-test feuillus |
| C17 | Coût complet inconnu | « inconnu » dans les cribles des ADR de A |

Un point du contradicteur va **dans le sens de A** : Monnet et Munoz (2015) trouvent les pixels carrés légèrement
meilleurs que les cercles (C14, 2.5).

## 7. Ce que la petite PR d'amendement pourrait contenir

Sans préjuger des choix de Pascal, les apports sans conflit sont : 3.8 (LICENSE, Etalab), 3.6 (codes), 3.5 (aire
d'applicabilité), 3.3 (protocole et contrôles), 3.13 (méthode IFN), 3.9-3.10 (ADR versions et reproductibilité, à
mettre en œuvre par mission), 3.11 (jeux lidaRtRee). Les points 2.1, 2.3 et 2.7 demandent une décision de Pascal
avant toute écriture.

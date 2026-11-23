# SRGS Auvergne-Rhône-Alpes (2023) : les 8 types de peuplements des documents de gestion

- **Propriétaire :** Pascal Obstétar
- **Consulté le :** 2026-11-23 (agent `acquereur`, mission 016)
- **Décision éclairée :** la légende SRGS est prioritaire dans la réconciliation (arbitrage C3) : quels types la chaîne sait reconnaître, avec quelles valeurs, et lesquels elle ne peut pas exprimer.
- **Fichier de configuration :** `inst/extdata/config/srgs-aura.json` (SER H10, 3 types exprimés, 5 non exprimables).
- **Blocs `national` et `jeux` du fichier : copies de `vercors-h10.json`** (un fichier = une configuration). **À resynchroniser si `vercors-h10.json` change.**
- **Statut : PROVISOIRE, NON GELÉ.** Le SRGS ne publie aucun seuil de reconnaissance des 8 types. Tout ce qui sert à reconnaître FRE et FIR vient du GSM de H10 par substitution (décision de l'orchestrateur, délégation n° 3). Rien n'est confirmé par le CNPF (contact réservé à Pascal).

## Source (une seule par référence)

| # | Source | Version / date | Ce qu'on y prend |
|---|---|---|---|
| S1 | SRGS Auvergne-Rhône-Alpes, `https://draaf.auvergne-rhone-alpes.agriculture.gouv.fr/IMG/pdf/aura_srgs_vf.pdf` (125 p. ; page imprimée = page du PDF) | arrêté du ministère de l'Agriculture paru au JO du 14 décembre 2023 (p. 4) | Les 8 types (p. 11-12), leurs critères de description (p. 12), les classes de grosseur (p. 12), les codes (p. 53 et p. 76) |
| S2 | `docs/referentiels/typologie-h10.md` et `inst/extdata/config/vercors-h10.json` | missions 005 et 010 | Les 20 types GSM de H10 et leurs conditions (substitution de FRE et FIR). Non recopiés ici : lus. |

URL consultée : celle de S1. Le PDF a été lu en images, page par page (p. 3-14, 59-65, 76-79, 87-88, 90-91, 95-96, 104-105, 112-113, 117-118, 120-125) et dans son texte extrait par pdftotext (`/tmp/claude-1000/-home-pascal-dev-typopeuplement/2a5a7f36-d17a-4683-9025-b40cdf51616a/scratchpad/m016/srgs-aura.txt`) : lu en entier pour les p. 14-29 et 53-58, et par recherche de mots (m², tiges, couvert, défini, surface terrière) pour le reste. Les pages 30-52, 66-75, 80-86, 89, 92-94, 97-103, 106-111, 114-116 et 119 n'ont pas été relues en entier : aucun seuil de reconnaissance n'y a été trouvé par ces recherches.

## Les 8 types obligatoires (p. 11-12)

Texte p. 11 : « Dans les documents de gestion, **tous les peuplements doivent obligatoirement être rattachés à l'un de ces 8 types** ». Liste (p. 11-12), codes du SRGS (tableau « Traitements envisageables par grand type de peuplement », p. 53, repris p. 76 ; p. 53 : « Les codes des peuplements (FRE, PEU, ...) sont ceux utilisés pour la saisie en ligne des documents de gestion ») :

| # | Libellé (recopié) | Code SRGS | Page des critères |
|---|---|---|---|
| 1 | La futaie régulière | FRE | p. 12, 59-60 |
| 2 | La futaie irrégulière | FIR | p. 12, 61-62 |
| 3 | Le mélange futaie-taillis | MFT | p. 12, 62-63 |
| 4 | Le taillis simple ou fureté | TAS (et TAF, voir écarts) | p. 63-64 |
| 5 | La peupleraie | PEU | p. 61 |
| 6 | Les accrus | ACC | p. 112 |
| 7 | Les landes, friches et maquis | pas de code SRGS ; **LAN : code du projet, pas du SRGS** | p. 7-8, 12, 118 |
| 8 | Le terrain nu à (re)boiser | TNU | p. 117 |

Décompte : **8** (p. 11 : 4 libellés ; p. 12 : 4 libellés). Le tableau p. 53 et p. 76 ajoute un code `DIV` « Divers non-productifs et éléments accessoires à la forêt » : ce n'est pas un des 8 types ; il n'est pas transcrit.

### Critères de base (p. 12)

- **Composition** : proportion des essences majoritaires présentes.
- **Capital sur pied** : en surface terrière ou en volume, en différenciant taillis et futaie.
- **Structure** : en futaie régulière ou taillis, diamètre moyen, âge, densité et hauteur dominante ; en futaie irrégulière, proportion en PB, BM et GB ; en mélange futaie-taillis, la futaie et le taillis sont à décrire indépendamment.
- « Chacun peut faire l'objet d'une déclinaison plus détaillée (par classe d'âges, stade de développement, essence ou groupe d'essences…) » (p. 12).

### Catégories de grosseur (tableau p. 12, identique p. 59)

| Catégorie | Classes de diamètre (cm) | Abrégé | Stade de futaie régulière |
|---|---|---|---|
| Perche | 10 et 15 | P | bas perchis |
| Petits bois | 20 et 25 | PB | haut perchis |
| Bois moyens | 30 à 45 | BM | jeune futaie |
| Gros bois | 50 et + | GB | futaie adulte |
| dont Très gros bois | 70 et + | TGB | vieille futaie |

Note sous le tableau (p. 12), recopiée : « Par souci d'harmonisation, notamment pour les peuplements mixtes, la limite BM/GB est choisie à 47.5 cm pour toutes les essences (normalement 42.5 cm pour résineux : possible de la conserver quand des typologies sont utilisées) et celles des GB/TGB à 67.5 cm (au lieu de 62.5 cm pour résineux). »

Le SRGS donne des **classes** (centres), pas des bornes en cm. Les bornes ci-dessous sont lues par les centres de classe : **inférence**, non écrite telle quelle dans le SRGS.

| Limite | Valeur retenue (nominale du SRGS, toutes essences) | Alternative (résineux seulement) |
|---|---|---|
| précomptage / PB | 17,5 cm (classe 20) | idem |
| PB / BM | 27,5 cm (classe 30) | idem |
| BM / GB | **47,5 cm** | 42,5 cm, non exprimable tant que la chaîne n'a qu'un seuil par clé |
| GB / TGB | **67,5 cm** | 62,5 cm, idem |

Cohérence des bornes : PB 17,5 à 27,5 (classes 20 et 25) ; BM 27,5 à 47,5 (classes 30, 35, 40, 45) ; GB 47,5 à 67,5 (classes 50 à 65) ; TGB à partir de 67,5 (classe 70 et +). Avec 47,5 cm, les quatre bornes sont lues par les centres de classe de façon uniforme : PB/BM à 27,5 reste valable.

**Constat sur le seuil (arbitrage C1 de Pascal, `docs/reconciliation/arbitrages-de-pascal.md`, branche de la PR #2).** C1 dit : « valeur A pour H10 : GSM, 42,5 cm toutes essences ; « 42,5 cm seulement en résineux » ne vaut que pour le SRGS AURA s'il est livré en plus ». Pour le SRGS, 42,5 cm est donc réservé aux résineux. La chaîne n'a qu'un seuil par clé : la clé SRGS prend les valeurs nominales (47,5 et 67,5 cm), et la règle « 42,5 en résineux » reste une alternative documentée, non exprimable aujourd'hui (elle demande des seuils par groupe d'essences). Les conditions de FRE et FIR, héritées des types GSM, ne lisent pas `part_gb` : ce seuil ne change pas leur appartenance.

## Types exprimés dans la chaîne (3)

Variables de la clé : `couvert`, `hpot`, `G`, `N`, `c1_hpot` à `c4_hpot` (mode « variables fournies » seulement), comme `vercors-h10.json`. Les classes de couvert (déficitaire < 0,25 ; moyenne 0,25 à 0,45 ; prépondérante >= 0,45) et la valeur 15 m sont celles de H10 (provisoires, à trancher : `typologie-h10.md`).

| Code | Critère SRGS de reconnaissance | Conditions de la clé (provisoire) |
|---|---|---|
| **FRE** | aucun (p. 12, 59-60 : description par âge, diamètre moyen, densité, hauteur dominante) | substitution : types GSM 1, 1GB, 2, 2GB, 12, 12GB, 23, 3, avec `couvert` >= 0,1 et `hpot` >= 15 |
| **FIR** | aucun (p. 12, 61-62 : proportion PB / BM / GB) | substitution : types GSM 13, 13GB, J, JGB, avec `couvert` >= 0,1, `hpot` >= 15, `G` >= 10 |
| **TNU** | aucun chiffre propre au type ; p. 7 : état boisé = couvert >= 10 % ; GSM p. 54 : couvert total >= 1/10 | `couvert` < 0,1 ; **condition nécessaire, non suffisante** : le couvert seul ne distingue pas un terrain à (re)boiser d'une prairie, d'une lande ou d'un espace non boisé |

**Règle de correspondance** (décision de l'orchestrateur, délégation n° 3 ; statut provisoire, à confirmer par le CNPF) : **une strate ou deux strates adjacentes = FRE** ; **strates non adjacentes (13) ou structure jardinée (J, JGB) = FIR**. Justification : une futaie dont le couvert tient en une strate, ou en deux strates voisines, est lue comme une structure simple (régulière) ; deux étages séparés par une strate vide (1 et 3) ou trois strates moyennes (jardinée) sont lus comme une structure irrégulière. Les suffixes GB suivent leur type de base (extension validée).

**La correspondance se fait par types GSM, non par strates : la règle en mots résume, les types GSM font foi.** Exemple : strate 1 moyenne, strate 2 vide (déficitaire) et strate 3 prépondérante, avec G >= 10, donne le type GSM 3 (c1 < 0,45, c2 < 0,45, c3 >= 0,45), donc **FRE**, alors que la règle en mots (strates 1 et 3 non adjacentes) dirait FIR. La clé suit les types GSM.

Correspondance GSM vers SRGS (types GSM de `typologie-h10.md`, 20 au total) :

| Type GSM | Famille GSM (tableau p. 56-57) | Strates | Type SRGS | Justification |
|---|---|---|---|---|
| J, JGB | futaies jardinées | 1, 2 et 3 moyennes | FIR | structure jardinée ; le SRGS range la « futaie jardinée » dans FIR (p. 53) |
| 13, 13GB | futaies à 2 étages | 1 et 3 (non adjacentes) | FIR | strates non adjacentes ; 13GB suit 13 |
| 23 | jeunes futaies | 2 et 3 (adjacentes) | FRE | deux strates adjacentes, comme 12 |
| 1, 2, 3, 12 | futaies adultes (1, 12), jeunes futaies (2, 3) | une strate, ou 1 et 2 | FRE | une strate ou deux strates adjacentes |
| 1GB, 2GB, 12GB | futaies riches en GB | idem | FRE | suivent leur type de base : la part de GB ne change pas la structure |
| R, L, C, CH | jeunes futaies, futaies claires, peuplements chétifs | aucun | non attribués (décision de l'orchestrateur : hors clé SRGS) ; L et C relèvent de la ligne ACC du SRGS (« Peuplements clairs, accrus, prés-bois », p. 53), non exprimée |
| T, X, P, A | taillis, espaces non boisés | aucun | non exprimables dans la chaîne (voir `typologie-h10.md`) |

Décompte : 4 (FIR : 13, 13GB, J, JGB) + 8 (FRE : 1, 1GB, 2, 2GB, 12, 12GB, 23, 3) + 4 (aucun, R L C CH) + 4 (aucun, T X P A) = **20**.

**Alternative documentée, non appliquée** : FRE si une catégorie de grosseur porte une part >= 0,5 de G ; FIR si PB, BM et GB ont chacune une part >= 0,1 de G. Aucune de ces deux valeurs n'est dans le SRGS ; elles sont à confirmer par le CNPF.

## Types non exprimables dans la chaîne (5)

| Code | Pourquoi | Variable manquante | Page |
|---|---|---|---|
| MFT | origine des tiges (rejet ou franc-pied) et part du taillis absentes ; pas de seuil (repères de gestion : futaie de 6 à 13 m²/ha, 100 à 120 tiges/ha de réserves) | origine_tiges, part_taillis | p. 12, 62, 95-96 |
| TAS | origine des tiges (rejets), âge, révolution absents ; simple ou fureté non distinguables | origine_tiges, age | p. 63-64, 104 |
| PEU | essence (peuplier de culture) et plantation absentes ; pas de seuil de reconnaissance (150 à 280 tiges/ha : caractéristique du traitement) | essence | p. 61, 87 |
| ACC | historique d'usage (abandon agricole) non observable ; définition qualitative ; **pas de proxy sans accord de Pascal** | usage_sol_historique | p. 112 |
| LAN | pas de masque d'occupation du sol dans la chaîne ; définition à 800 tiges/ha, 70 % de la surface, 0,5 m (p. 8, 118) | occupation_du_sol | p. 7-8, 12, 118 |

Décompte : 3 exprimés + 5 non exprimables = **8**.

## Écarts relevés (non tranchés)

1. **Liste de la p. 11-12 contre tableau p. 53 et p. 76.** Les 8 types de la p. 11-12 fusionnent « taillis simple ou fureté » et ajoutent « landes, friches et maquis ». Le tableau p. 53 et p. 76 a 8 lignes de codes (FRE, PEU, FIR, MFT, TAS, TAF, ACC, TNU) : il sépare TAS (taillis simple) et TAF (taillis fureté), n'a pas de ligne pour les landes, et nomme la ligne ACC « Peuplements clairs, accrus, prés-bois ». Retenu : la liste p. 11-12 (les 8 « obligatoires »), un seul type TAS pour taillis simple ou fureté (décision de l'orchestrateur).
2. **BM/GB : 47,5 cm (SRGS) contre 42,5 cm (GSM, clé H10).** Déjà documenté dans `typologie-h10.md`. Clé SRGS : 47,5 cm (et GB/TGB 67,5), alternative 42,5 / 62,5 en résineux seulement (arbitrage C1). La clé H10 reste à 42,5 : deux clés, deux seuils, un seul par clé.
3. **Landes et boisements : 800 tiges/ha (p. 8, 118).** Ce seuil définit un semis comptable en forêt, pas une lande : une lande est ce qui reste sous ce seuil (p. 7 : hors forêt). Il ne permet pas, seul, de reconnaître une lande.
4. **12 et 23 : écart levé.** Ces deux types (deux strates adjacentes moyennes) étaient d'abord rangés l'un en FRE, l'autre en FIR, alors que le GSM les classe en « futaies adultes » et « jeunes futaies ». L'orchestrateur a rendu la règle cohérente : une strate ou deux strates adjacentes = FRE, donc 12 et 23 en FRE. Reste provisoire.

## Ambiguïtés du texte, valeurs provisoires et alternatives

| # | Ambiguïté | Valeur provisoire | Alternatives |
|---|---|---|---|
| 1 | Limite BM/GB et GB/TGB | 47,5 / 67,5 cm (SRGS p. 12, toutes essences ; arbitrage C1) | 42,5 / 62,5 cm en résineux seulement (non exprimable : un seul seuil par clé) |
| 2 | Bornes en cm des classes de grosseur | centres de classe (17,5 ; 27,5) : inférence | autres lectures des classes |
| 3 | Seuil de régularité (futaie régulière / irrégulière) | substitution par types GSM | règle par parts (>= 0,5 ; >= 0,1) |
| 4 | « Faible capital » de la futaie du mélange futaie-taillis | non exprimable | repères de gestion 6 à 13 m²/ha (p. 95-96) |
| 5 | Peupleraie | non exprimable | N de 150 à 280 tiges/ha comme proxy faible (non retenu) |
| 6 | Accrus | non exprimable | proxy « clair, hétérogène » (non retenu sans accord de Pascal) |
| 7 | Landes | non exprimable | masque d'occupation du sol à ajouter |
| 8 | Terrain nu : seuil de couvert | 0,1 (SRGS p. 7, GSM p. 54) | 0,1 et h_dom < 0,5 m |
| 9 | Taillis simple et fureté | un seul type (TAS) | deux types (TAS, TAF, p. 53) |

## Trois points au sol

1. Une futaie à deux étages nets (grands résineux sur hêtres) : FIR par la substitution (13 ou 13GB), mais le SRGS ne dit pas à partir de quand une futaie est « irrégulière ». À voir sur le terrain avec le gestionnaire.
2. Un boisement de feuillus à brins nombreux de 20 à 25 cm, sans gros bois : taillis, mélange futaie-taillis ou futaie de petits bois ? Le LiDAR ne voit pas l'origine des tiges (rejets) ; la clé range ce peuplement en FRE ou FIR selon ses strates.
3. Une parcelle à 600 tiges/ha, 3 m de haut, couvert 0,5 : le couvert dit « boisé » (>= 0,1) mais la hauteur potentielle (< 15 m) la met hors FRE et FIR ; accru, lande ou forêt (seuil de 800 tiges/ha, p. 8) ? Sans type SRGS.

## Question de contrôle

Quelle décision cette donnée va-t-elle éclairer ? **Quels types SRGS la réconciliation peut prendre en compte avec la chaîne (3 sur 8), avec quelles valeurs provisoires, et lesquels exigent une donnée de plus.**

## Liste de contrôle (méthode)

1. Chaque valeur a sa source et sa page : passé (champ `source` de chaque type, tableaux ci-dessus). Réserve : pages 30-52, 66-75, 80-86, 89, 92-94, 97-103, 106-111, 114-116, 119 relues par mots-clés seulement.
2. Décomptes : 8 types SRGS ; 3 + 5 = 8 ; 20 types GSM (4 + 8 + 4 + 4) ; 5 classes de grosseur : passé.
3. Termes recopiés : libellés, note p. 12, définitions p. 112 et p. 118 : passé.
4. Statut dit tel qu'il est : provisoire, non gelé ; substitution FRE / FIR à confirmer.
5. Chargement par `lire_configuration()` : **vérifié par le relecteur** (FRE 9 alternatives, FIR 2, TNU). Tests : à relancer après l'aller-retour 1/3 (l'acquéreur n'a pas d'outil pour lancer R).

## À l'attention des missions 017 et 018

`types_observes()` rend le premier type de la clé (FRE) pour un pixel hors clé. Avec cette clé, les pixels hors clé sont nombreux : `hpot` < 15 m, types GSM R, L, C et CH (non rattachés), et tout pixel dont les couverts de strates ne tombent dans aucune alternative. **Risque d'étiquetage faux** (un pixel hors clé étiqueté FRE) : à traiter par les missions 017 et 018.

## Journal (proposé)

`2026-11-23 · acquereur · 016 · clé SRGS AURA 2023 (srgs-aura.json, SER H10) : 8 types p. 11-12, aucun seuil de reconnaissance publié ; 3 exprimés (FRE, FIR par substitution des types GSM : une strate ou deux adjacentes = FRE, non adjacentes ou jardiné = FIR ; TNU couvert < 0,1, condition nécessaire non suffisante), R L C CH hors clé SRGS, 5 non exprimables (MFT, TAS, PEU, ACC, LAN) ; BM/GB 47,5 cm et GB/TGB 67,5 cm (nominales SRGS p. 12 ; 42,5 / 62,5 réservés aux résineux par l'arbitrage C1, non exprimable avec un seuil par clé) ; correspondance par types GSM (la règle en mots résume) ; hors clé nombreux, risque d'étiquetage de types_observes() pour 017/018 ; codes SRGS p. 53 (LAN = code du projet) ; non gelée`

## Constat sur le seuil BM/GB (aller-retour 1/3, 2026-11-23)

L'arbitrage C1 de Pascal (`docs/reconciliation/arbitrages-de-pascal.md`, branche de la PR #2) réserve 42,5 cm aux résineux pour le SRGS AURA : « valeur A pour H10 : GSM, 42,5 cm toutes essences ; « 42,5 cm seulement en résineux » ne vaut que pour le SRGS AURA s'il est livré en plus ». La chaîne n'a qu'un seuil BM/GB par clé. La clé SRGS porte donc les valeurs nominales du SRGS p. 12 (**47,5 cm** BM/GB, **67,5 cm** GB/TGB, toutes essences) ; la règle « 42,5 / 62,5 en résineux » reste une alternative documentée, non exprimable tant qu'il n'y a qu'un seuil par clé (elle demandera des seuils par groupe d'essences). La clé H10 (GSM) garde 42,5 cm.

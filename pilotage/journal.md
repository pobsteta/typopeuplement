# Journal de typopeuplement

> **Règle du sommier : on n'efface pas, on ajoute.**
> Chaque inscription est datée et signée (agent ou personne). Une correction est une
> nouvelle ligne qui renvoie à l'ancienne.
>
> Format : `AAAA-MM-JJ · auteur · mission · ce qui a été fait / décidé / bloqué`
>
> Carnet des écarts : `AAAA-MM-JJ · auteur · mission · écart · attendu : … · vu : … · vérifié : … · décision : …`
> Changements de cap : `AAAA-MM-JJ · auteur · mission · cap · ancien → nouveau · pourquoi : … · fait : …`

2026-11-21 · Pascal · — · brief déposé : `docs/brief-typologie-peuplements.md`
2026-11-22 · Claude (orchestrateur) · — · méthode installée (CLAUDE.md, pilotage/, docs/adr/, .claude/) ; restent à remplir : la réponse d'abord de Pascal, la critique du contradicteur, la spec, l'équipe
2026-11-22 · Claude (orchestrateur) · socle · Pascal demande « Lis et code le brief » : socle de la chaîne codé sur données synthétiques (clé floue, variables dendrométriques, hauteur potentielle, lissage, raccord de SER, validation à la grappe, comparaison RF / SVM / LDA), 17 tests verts. Rien n'est tranché : stack (ADR 0001), clé, seuils et souplesses sont des propositions, à valider par Pascal à la porte n° 1
2026-11-22 · Claude (orchestrateur) · socle · écart · attendu : modèle de hauteur potentielle appris sur les adultes fermés juste à moins de 3 m · vu : 3,4 m d'erreur, sous-estimation d'environ 10 % (un adulte n'a pas toujours atteint sa hauteur potentielle) · vérifié : test sur jeu synthétique · décision : creuser — enveloppe haute (quantile 0,9 des rapports observé / prédit), valeur provisoire à mesurer sur les SER pilotes
2026-11-22 · Pascal · brief · /brief lancé ; réponse d'abord : « je m'en passe »
2026-11-22 · Pascal · brief · question de stack : Rust plutôt que Python ? Sa réponse d'abord : « vitesse sur toutes les SER de France » ; ADR 0002 proposée, à critiquer par le contradicteur avant que Pascal tranche
2026-11-22 · contradicteur · brief · bénéficiaire et porteur non nommés ; recouvrement possible avec IGN (SDIF 2025-2030), FORMS, ONF Ain 2017 ; placettes IFN au km près ; hauteur potentielle peut-être circulaire ; ZICAD non diffusées ; seuil 76 % non transposable
2026-11-22 · contradicteur · ADR 0002 · étage nuage de points non encore codé ; options lasR/pylasr et MNH IGN absentes ; « vitesse » sans cible chiffrée (LiDAR HD ≈ 3 Po) ; linfa/smartcore sans banc indépendant face à scikit-learn ; ADR 0001 à trancher d'abord
2026-11-22 · Claude (orchestrateur) · brief · critique du contradicteur rendue à Pascal, avec une proposition par point ; en attente de ses arbitrages

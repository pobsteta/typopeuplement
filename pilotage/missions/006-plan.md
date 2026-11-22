# Mission 006 — plan validé par Pascal (2026-11-22, « oui au plan 006 »)

Le plan rendu par l'agent `dev` est résumé au journal du 2026-11-22. Il se lit avec les
décisions suivantes.

1. **Mode « variables fournies »** : les rasters de l'ONF (26,6 m, Lambert-93) donnent
   - `part_resineux = p100GR/100` ;
   - `part_gb = p100GGB/100` ;
   - `G` ;
   - `h_dom = H0_lidar` ;
   - `couvert = Tx_couv/100` ;
   - `famille = Compo1`.

   On saute l'ajustement dendrométrique. Les pixels où Compo1 vaut 0, ou G vaut 0 ou NA,
   portent le drapeau `non_precomptable`. Pas de contact avec l'ONF.
2. **Gros bois** : la limite de H10 est 42,5 cm (Pascal). La part de gros bois de l'ONF
   est calculée à 47,5 cm : c'est un intérim, déclaré dans la fiche et la confiance.
3. **`part_pb` absente** : drapeau `part_pb_absente`.
4. **Souplesses** de la clé floue tirées des erreurs du producteur (fiche du jeu, p. 3),
   sourcées. Pas de correction de biais.
5. **`confiance.tif`** : `niveau_modele = 0` « variables du producteur » ; ailleurs,
   « grande région requise » au lieu de « utilisée ».
6. **Hauteur potentielle** : vide et signalée partout dans 006. Le MNT viendra à la
   mission 009.
7. **Extrait de test** (moins de 300 ko) dans `tests/testthat/fixtures/vercors/`, ouvert à 006.
8. **AOI** : le massif entier pour la mesure des temps, l'extrait pour les tests. Pascal
   n'a pas encore choisi sa forêt.
9. **`Struc_fam`** n'est pas utilisée.

**Cap A (Pascal)** : la clé de H10 sera celle du GSM Alpes du Nord (missions 007 à 010).
Dans 006, la carte des types se calcule avec la configuration passée en argument (la clé
d'exemple dans les tests) ; aucune carte de H10 n'est publiée avant la clé du GSM.

**Fonctions et fichiers** (plan) :
- `typer_peuplements(..., variables = NULL, milieu = NULL)` ;
- `lire_parametres_lidar(dossier, aoi, couches = couches_onf())` ;
- `R/donnees_lidar.R` (nouveau), `R/typer_peuplements.R`, `R/chaine.R`
  (`executer_chaine_fournie`, temps par étage), `R/validation.R` (tableaux de contrôle
  contre Typo_etage, V de Cramér : cohérence, pas validation) ;
- les livrables sur la grille du jeu (gabarit) ;
- `temps_etages.csv` ;
- les mineurs reportés de 003.

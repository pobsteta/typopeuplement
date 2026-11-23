# Hauteur potentielle : le milieu en donnée d'entrée (hauteur_potentielle.py du prototype).
#
# 1. repérer les peuplements adultes fermés et relever leur hauteur dominante ;
# 2. modéliser cette hauteur en fonction des variables de milieu, par famille d'essences ;
# 3. appliquer le modèle à toute l'emprise ;
# 4. introduire dans la clé le rapport hauteur mesurée / hauteur potentielle.
# Le milieu sert à la hauteur potentielle, pas à une typologie de stations.

#' Ajuster le modèle de hauteur potentielle
#'
#' Apprend, par famille d'essences, la hauteur dominante des peuplements adultes fermés
#' en fonction des variables de milieu (forêt aléatoire ranger). La prédiction est
#' relevée par une enveloppe haute k : le quantile `quantile_enveloppe` du rapport hauteur
#' observée / hauteur prédite hors sac (out-of-bag de ranger) chez les adultes (au moins 1),
#' car un peuplement adulte n'a pas toujours atteint sa hauteur potentielle. Les adultes
#' appris sont ensuite prédits hors sac ([predire_hauteur_potentielle()]) : environ
#' `1 - quantile_enveloppe` d'entre eux dépassent leur hauteur potentielle.
#'
#' La RMSE de validation croisée par blocs (plis contigus) donne l'incertitude :
#' `h_pot_sd` = k × RMSE.
#'
#' @param df data.frame (pixels) : `h_dom` (m), `couvert` (0 à 1), les variables de milieu,
#'   et `famille` si l'on veut un modèle par famille d'essences.
#' @param variables_milieu Noms des variables de milieu (topographie, climat, sol).
#' @param couvert_min Couvert minimal d'un peuplement fermé. **Provisoire** : 0,7.
#' @param hauteur_min_m Hauteur dominante minimale d'un peuplement adulte, en m.
#'   **Provisoire** : 15.
#' @param incertitude_relative_max Au-delà de ce rapport écart-type / hauteur potentielle,
#'   la hauteur potentielle est jugée incertaine. **Provisoire** : 0,2.
#' @param quantile_enveloppe Quantile de l'enveloppe haute. **Provisoire** : 0,9.
#' @param graine Graine du hasard.
#' @param famille Nom de la colonne des familles d'essences ; absente, un seul modèle.
#' @param adultes_min Nombre minimal d'adultes fermés pour ajuster le modèle d'une famille.
#'   **Provisoire** : 20.
#' @param plis Nombre de plis (contigus) de la validation croisée. **Provisoire** : 5.
#' @param nombre_arbres Nombre d'arbres de chaque forêt. **Provisoire** : 200.
#' @param feuille_min Effectif minimal d'une feuille. **Provisoire** : 5.
#'
#' @return Objet `typo_hauteur_potentielle` : modèles, `rmse_cv` (RMSE de validation
#'   croisée par famille, m), `facteur` (enveloppe k) et `apprentissage` (lignes apprises
#'   et leur prédiction hors sac) par famille.
#' @seealso [predire_hauteur_potentielle()], [peuplements_adultes()]
#' @export
ajuster_hauteur_potentielle <- function(df, variables_milieu, couvert_min = 0.7,
                                        hauteur_min_m = 15, incertitude_relative_max = 0.2,
                                        quantile_enveloppe = 0.9, graine = 0,
                                        famille = "famille", adultes_min = 20, plis = 5,
                                        nombre_arbres = 200, feuille_min = 5) {
  verifier_colonnes(df, c("h_dom", "couvert", variables_milieu), "les pixels")
  modele <- structure(
    list(variables_milieu = variables_milieu, couvert_min = couvert_min,
         hauteur_min_m = hauteur_min_m, incertitude_relative_max = incertitude_relative_max,
         quantile_enveloppe = quantile_enveloppe, graine = graine, famille = famille,
         modeles = list(), rmse_cv = list(), facteur = list(), apprentissage = list()),
    class = "typo_hauteur_potentielle"
  )
  # Adultes fermés au milieu connu : une ligne sans milieu n'apprend rien.
  complet <- stats::complete.cases(as.data.frame(df)[, variables_milieu, drop = FALSE])
  adultes <- df[peuplements_adultes(modele, df) & complet, , drop = FALSE]
  fam <- if (famille %in% names(adultes)) as.character(adultes[[famille]]) else
    rep("toutes", nrow(adultes))
  for (nom in sort(unique(fam), method = "radix")) {
    g <- adultes[fam == nom, , drop = FALSE]
    if (nrow(g) < adultes_min) next
    X <- matrice_num(g, variables_milieu)
    y <- as.numeric(g$h_dom)
    pli <- plis_contigus(nrow(X), plis)
    pred_cv <- numeric(nrow(X))
    for (k in seq_len(plis)) {
      test <- pli == k
      m <- foret_regression(X[!test, , drop = FALSE], y[!test], nombre_arbres, feuille_min, graine)
      pred_cv[test] <- predire_foret(m, X[test, , drop = FALSE])
    }
    modele$rmse_cv[[nom]] <- sqrt(mean((pred_cv - y)^2))
    # Forêt finale, et ses prédictions hors sac (arbres où la ligne n'a pas servi) :
    # l'enveloppe se mesure sur des hauteurs que la forêt n'a pas apprises.
    m <- foret_regression(X, y, nombre_arbres, feuille_min, graine, keep.inbag = TRUE)
    hs <- hors_sac_par_ligne(m, X)
    modele$facteur[[nom]] <- max(1, unname(stats::quantile(y / hs$moy, quantile_enveloppe, type = 7)))
    m$inbag.counts <- NULL
    modele$modeles[[nom]] <- m
    modele$apprentissage[[nom]] <- list(cle = cle_lignes(g, c(variables_milieu, "h_dom", "couvert")),
                                        moy = hs$moy, sd = hs$sd)
  }
  if (length(modele$modeles) == 0) {
    arreter("trop peu de peuplements adultes ferm\u00e9s pour ajuster le mod\u00e8le de hauteur potentielle")
  }
  modele
}

#' Peuplements adultes fermés
#'
#' Masque des lignes retenues pour apprendre la hauteur potentielle :
#' `couvert >= couvert_min` et `h_dom >= hauteur_min_m` (seuils du modèle). Une ligne
#' où le couvert ou la hauteur manque n'est pas adulte (`FALSE`, jamais `NA`).
#'
#' @param modele Objet rendu par [ajuster_hauteur_potentielle()] (ou toute liste portant
#'   `couvert_min` et `hauteur_min_m`).
#' @param df data.frame : `couvert`, `h_dom`.
#' @return Vecteur logique.
#' @export
peuplements_adultes <- function(modele, df) {
  as.vector(df$couvert >= modele$couvert_min & df$h_dom >= modele$hauteur_min_m) %in% TRUE
}

#' Prédire la hauteur potentielle et le rapport des hauteurs
#'
#' Hauteur potentielle `h_pot` = k × moyenne des arbres de la forêt (k : enveloppe de la
#' famille), son incertitude `h_pot_sd` = k × RMSE de validation croisée par blocs de la
#' famille, et le rapport hauteur dominante mesurée / hauteur potentielle. Là où
#' l'incertitude relative `h_pot_sd / h_pot` dépasse `incertitude_relative_max`, le rapport
#' est vide (`NA`) et `hp_incertaine` est vrai : la clé s'en tient alors à la hauteur
#' mesurée. Là où une variable de milieu manque (pixel hors du MNT), `h_pot` et `h_pot_sd`
#' sont vides et `hp_incertaine` est vrai.
#'
#' **Hors sac.** Un adulte fermé qui a servi à l'apprentissage (même milieu, même `h_dom`,
#' même `couvert`, même famille qu'une ligne apprise) est prédit hors sac : par les seuls
#' arbres où il n'a pas servi. Les autres lignes ont la prédiction ordinaire (tous les
#' arbres). Sans cela, la forêt « reconnaîtrait » les adultes appris et l'enveloppe serait
#' trop basse pour eux.
#'
#' **Écart entre les deux prédictions.** La prédiction hors sac d'un adulte appris et la
#' prédiction ordinaire d'un pixel voisin de même milieu ne sont pas la même grandeur :
#' la forêt entière a vu l'adulte, ses arbres hors sac non. Sur le Vercors (relecture de
#' la mission 009), elles diffèrent d'environ 1 m. Une carte de `h_pot` peut donc montrer
#' un saut de cet ordre entre un adulte fermé appris et son voisin ; ce saut vient de la
#' méthode, pas du milieu (l'attribut `hors_sac` dit quelles lignes sont concernées).
#'
#' **Dispersion des arbres.** L'écart-type entre arbres (× k), rendu dans l'attribut
#' `sd_arbres`, n'est pas une erreur de prédiction : il dit combien la forêt varie d'un
#' arbre à l'autre en ce point. Il ne compte pas dans `h_pot_sd`, ni dans `hp_incertaine`.
#' Il ne porte pas sur les mêmes arbres partout : pour un adulte appris (prédit hors sac),
#' sur les seuls arbres hors sac (environ un tiers) ; pour les autres lignes, sur tous les
#' arbres. Les deux ne se comparent pas directement.
#'
#' **Drapeau « incertaine » : un seuil de hauteur potentielle.** `h_pot_sd` est constant
#' dans une famille (k × RMSE). Le test `h_pot_sd / h_pot > incertitude_relative_max`
#' revient donc à `h_pot < k × RMSE / incertitude_relative_max` : un seuil de hauteur
#' potentielle par famille, qui marque les stations les moins fertiles (décision de
#' 2026-11-22, option a ; la fiche de [executer_chaine_fournie()] donne ces seuils).
#'
#' La prédiction se fait par paquets de `taille_paquet` lignes, pour borner la mémoire
#' (une valeur par arbre et par ligne).
#'
#' @param modele Objet rendu par [ajuster_hauteur_potentielle()].
#' @param df data.frame : variables de milieu, `h_dom`, et la colonne de famille si elle existe.
#' @param taille_paquet Nombre de lignes prédites à la fois. **Provisoire** : 20 000.
#' @return data.frame : `h_pot` (m), `h_pot_sd` (m), `rapport_h`, `hp_incertaine` ; avec
#'   les attributs `sd_arbres` (m, dispersion des arbres, `NA` sans milieu) et `hors_sac`
#'   (logique : ligne prédite hors sac).
#' @export
predire_hauteur_potentielle <- function(modele, df, taille_paquet = 20000L) {
  verifier_colonnes(df, c("h_dom", modele$variables_milieu), "la table \u00e0 pr\u00e9dire")
  n <- nrow(df)
  hp <- rep(NA_real_, n)
  sd <- rep(NA_real_, n)
  sd_arbres <- rep(NA_real_, n)
  hors_sac <- rep(FALSE, n)
  fam <- if (modele$famille %in% names(df)) as.character(df[[modele$famille]]) else rep("toutes", n)
  defaut <- names(modele$modeles)[1]
  complet <- stats::complete.cases(as.data.frame(df)[, modele$variables_milieu, drop = FALSE])
  adulte <- if ("couvert" %in% names(df)) peuplements_adultes(modele, df) else rep(FALSE, n)
  for (nom in unique(fam)) {
    cle <- if (nom %in% names(modele$modeles)) nom else defaut
    m <- modele$modeles[[cle]]
    k <- modele$facteur[[cle]]
    idx <- which(fam == nom & complet)
    sd[idx] <- k * modele$rmse_cv[[cle]]
    # Adultes appris de cette famille : hors sac.
    app <- if (nom %in% names(modele$modeles)) modele$apprentissage[[nom]] else NULL
    if (!is.null(app)) {
      cand <- idx[adulte[idx]]
      pos <- match(cle_lignes(df[cand, , drop = FALSE],
                              c(modele$variables_milieu, "h_dom", "couvert")), app$cle)
      vus <- cand[!is.na(pos)]
      pos <- pos[!is.na(pos)]
      hp[vus] <- k * app$moy[pos]
      sd_arbres[vus] <- k * app$sd[pos]
      hors_sac[vus] <- TRUE
      idx <- setdiff(idx, vus)
    }
    for (debut in seq.int(1L, by = taille_paquet, length.out = ceiling(length(idx) / taille_paquet))) {
      ix <- idx[debut:min(length(idx), debut + taille_paquet - 1L)]
      X <- matrice_num(df[ix, , drop = FALSE], modele$variables_milieu)
      par_arbre <- k * stats::predict(m, data = as.data.frame(X), predict.all = TRUE,
                                      num.threads = 1)$predictions
      par_arbre <- matrix(par_arbre, nrow = length(ix))
      moy <- rowMeans(par_arbre)
      hp[ix] <- moy
      # Écart-type de population (comme numpy).
      sd_arbres[ix] <- sqrt(rowMeans((par_arbre - moy)^2))
    }
  }
  incertaine <- is.na(hp) | (sd / hp) > modele$incertitude_relative_max
  rapport <- ifelse(incertaine, NA_real_, as.numeric(df$h_dom) / hp)
  structure(data.frame(h_pot = hp, h_pot_sd = sd, rapport_h = rapport, hp_incertaine = incertaine),
            sd_arbres = sd_arbres, hors_sac = hors_sac)
}

# Moyenne et écart-type (de population) hors sac de chaque ligne apprise : sur les seuls
# arbres où elle n'a pas été tirée. La moyenne est celle de ranger (`m$predictions`). Une
# ligne tirée par tous les arbres (cas de probabilité négligeable) garde tous les arbres.
hors_sac_par_ligne <- function(m, X) {
  P <- stats::predict(m, data = as.data.frame(X), predict.all = TRUE, num.threads = 1)$predictions
  P <- matrix(P, nrow = nrow(X))
  dehors <- do.call(cbind, m$inbag.counts) == 0
  dehors[rowSums(dehors) == 0, ] <- TRUE
  nb <- rowSums(dehors)
  moy <- rowSums(P * dehors) / nb
  sd <- sqrt(rowSums(((P - moy)^2) * dehors) / nb)
  list(moy = moy, sd = sd)
}

# Clé texte d'une ligne (valeurs exactes) pour reconnaître une ligne apprise.
cle_lignes <- function(df, colonnes) {
  morceaux <- lapply(colonnes, function(c) sprintf("%.17g", as.numeric(as.data.frame(df)[[c]])))
  do.call(paste, c(morceaux, sep = "|"))
}

#' Écart aux courbes de station de nemeton
#'
#' Corrélation de rang (Spearman) entre la hauteur potentielle et l'indice de station de
#' nemeton (`nemeton::compute_site_index()`), là où l'âge et l'essence sont connus. Ce
#' n'est pas une égalité attendue : c'est un contrôle de cohérence, rapporté dans la fiche
#' de validation. nemeton est en Suggests : sans lui, la fonction s'arrête.
#'
#' @param h_pot Hauteur potentielle (m).
#' @param h_dom Hauteur dominante mesurée (m).
#' @param age Âge du peuplement (années) ; `NA` si inconnu.
#' @param essence Code d'essence au format de nemeton (IFN, 4 lettres) ; `NA` si inconnu.
#' @param age_reference Âge de référence de l'indice de station. **Provisoire** : 50 ans,
#'   valeur par défaut de nemeton.
#'
#' @return Liste : `n` (nombre de lignes où l'indice est estimable), `correlation_rang`
#'   (`NA` si moins de 3 lignes).
#' @export
ecart_courbes_station <- function(h_pot, h_dom, age, essence, age_reference = 50) {
  if (!requireNamespace("nemeton", quietly = TRUE)) {
    arreter("nemeton n'est pas install\u00e9 : l'indice de station ne peut pas \u00eatre calcul\u00e9")
  }
  connu <- !is.na(h_pot) & !is.na(h_dom) & !is.na(age) & !is.na(essence)
  indice <- rep(NA_real_, length(h_pot))
  if (any(connu)) {
    indice[connu] <- nemeton::compute_site_index(H_dom = h_dom[connu], age = age[connu],
                                                 species = essence[connu],
                                                 reference_age = age_reference)
  }
  ok <- connu & !is.na(indice)
  rho <- if (sum(ok) >= 3) stats::cor(h_pot[ok], indice[ok], method = "spearman") else NA_real_
  list(n = sum(ok), correlation_rang = rho)
}

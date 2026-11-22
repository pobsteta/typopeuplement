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
#' relevée par une enveloppe haute : le quantile `quantile_enveloppe` du rapport hauteur
#' observée / hauteur prédite hors échantillon chez les adultes (au moins 1), car un
#' peuplement adulte n'a pas toujours atteint sa hauteur potentielle.
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
#'   croisée par famille, m) et `facteur` (enveloppe) par famille.
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
         modeles = list(), rmse_cv = list(), facteur = list()),
    class = "typo_hauteur_potentielle"
  )
  adultes <- df[peuplements_adultes(modele, df), , drop = FALSE]
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
    modele$facteur[[nom]] <- max(1, unname(stats::quantile(y / pred_cv, quantile_enveloppe, type = 7)))
    modele$rmse_cv[[nom]] <- sqrt(mean((pred_cv - y)^2))
    modele$modeles[[nom]] <- foret_regression(X, y, nombre_arbres, feuille_min, graine)
  }
  if (length(modele$modeles) == 0) {
    arreter("trop peu de peuplements adultes ferm\u00e9s pour ajuster le mod\u00e8le de hauteur potentielle")
  }
  modele
}

#' Peuplements adultes fermés
#'
#' Masque des lignes retenues pour apprendre la hauteur potentielle :
#' `couvert >= couvert_min` et `h_dom >= hauteur_min_m` (seuils du modèle).
#'
#' @param modele Objet rendu par [ajuster_hauteur_potentielle()] (ou toute liste portant
#'   `couvert_min` et `hauteur_min_m`).
#' @param df data.frame : `couvert`, `h_dom`.
#' @return Vecteur logique.
#' @export
peuplements_adultes <- function(modele, df) {
  as.vector(df$couvert >= modele$couvert_min & df$h_dom >= modele$hauteur_min_m)
}

#' Prédire la hauteur potentielle et le rapport des hauteurs
#'
#' Hauteur potentielle (moyenne des arbres de la forêt, enveloppe comprise), son
#' incertitude (dispersion des arbres et erreur de validation croisée), et le rapport
#' hauteur dominante mesurée / hauteur potentielle. Là où l'incertitude relative dépasse
#' `incertitude_relative_max`, le rapport est vide (`NA`) et `hp_incertaine` est vrai :
#' la clé s'en tient alors à la hauteur mesurée.
#'
#' @param modele Objet rendu par [ajuster_hauteur_potentielle()].
#' @param df data.frame : variables de milieu, `h_dom`, et la colonne de famille si elle existe.
#' @return data.frame : `h_pot` (m), `h_pot_sd` (m), `rapport_h`, `hp_incertaine`.
#' @export
predire_hauteur_potentielle <- function(modele, df) {
  verifier_colonnes(df, c("h_dom", modele$variables_milieu), "la table \u00e0 pr\u00e9dire")
  n <- nrow(df)
  hp <- rep(NA_real_, n)
  sd <- rep(NA_real_, n)
  fam <- if (modele$famille %in% names(df)) as.character(df[[modele$famille]]) else rep("toutes", n)
  defaut <- names(modele$modeles)[1]
  for (nom in unique(fam)) {
    cle <- if (nom %in% names(modele$modeles)) nom else defaut
    m <- modele$modeles[[cle]]
    rmse <- modele$rmse_cv[[cle]]
    k <- modele$facteur[[cle]]
    idx <- which(fam == nom)
    X <- matrice_num(df[idx, , drop = FALSE], modele$variables_milieu)
    par_arbre <- k * stats::predict(m, data = as.data.frame(X), predict.all = TRUE,
                                    num.threads = 1)$predictions
    par_arbre <- matrix(par_arbre, nrow = length(idx))
    moy <- rowMeans(par_arbre)
    # Écart-type de population (comme numpy), puis erreur de validation croisée.
    sd_arbres <- sqrt(rowMeans((par_arbre - moy)^2))
    hp[idx] <- moy
    sd[idx] <- sqrt(sd_arbres^2 + (k * rmse)^2)
  }
  incertaine <- (sd / hp) > modele$incertitude_relative_max
  rapport <- ifelse(incertaine, NA_real_, as.numeric(df$h_dom) / hp)
  data.frame(h_pot = hp, h_pot_sd = sd, rapport_h = rapport, hp_incertaine = incertaine)
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

# Modèles : variables continues d'abord, types ensuite (modeles.py du prototype).
#
# La chaîne prédit d'abord les variables dendrométriques continues (surface terrière,
# parts de petits, moyens et gros bois, part de résineux), puis la clé en déduit les
# types. Forêts aléatoires de ranger, réglées au plus près de scikit-learn :
# `mtry` = nombre de prédicteurs, `min.bucket` = feuille minimale, graine fixée.

PARTS_CATEGORIES <- c("part_pb", "part_bm", "part_gb")

# Forêt de régression, seule source des paramètres des forêts de la chaîne (modèles
# dendrométriques, hauteur potentielle). `keep.inbag = TRUE` garde la trace des lignes
# tirées par chaque arbre (prédiction hors sac de la hauteur potentielle) ; cela ne
# change ni les arbres ni leurs prédictions.
foret_regression <- function(X, y, nombre_arbres, feuille_min, graine, keep.inbag = FALSE) {
  ranger::ranger(
    x = as.data.frame(X), y = y,
    num.trees = nombre_arbres, mtry = ncol(X),
    min.node.size = 2, min.bucket = feuille_min,
    seed = graine_ranger(graine), num.threads = 1, keep.inbag = keep.inbag
  )
}

predire_foret <- function(modele, donnees) {
  stats::predict(modele, data = as.data.frame(donnees), num.threads = 1)$predictions
}

# Parts bornées à [0, 1] ; PB + BM + GB ramenées à 1 (1/3 chacune si toutes nulles).
normaliser_parts <- function(df) {
  for (c in grep("^part_", names(df), value = TRUE)) df[[c]] <- pmin(pmax(df[[c]], 0), 1)
  if (all(PARTS_CATEGORIES %in% names(df))) {
    s <- rowSums(df[, PARTS_CATEGORIES, drop = FALSE])
    for (c in PARTS_CATEGORIES) df[[c]] <- ifelse(s == 0, 1 / 3, df[[c]] / s)
  }
  df
}

#' Ajuster les modèles dendrométriques
#'
#' Une forêt aléatoire de régression (ranger) par variable cible, apprise sur les
#' placettes.
#'
#' @param placettes data.frame des placettes : prédicteurs et variables cibles mesurées.
#' @param predicteurs Noms des colonnes de prédicteurs (métriques LiDAR, indices Sentinel-2...).
#' @param cibles Noms des variables cibles (`G`, `part_resineux`, `part_pb`...).
#' @param graine Graine du hasard.
#' @param nombre_arbres Nombre d'arbres par forêt. **Provisoire** : 150, repris du prototype.
#' @param feuille_min Effectif minimal d'une feuille. **Provisoire** : 3, repris du prototype.
#'
#' @return Objet `typo_modeles_dendro`.
#' @seealso [predire_dendro()], [predire_dendro_validation()], [erreurs_dendro()]
#' @export
ajuster_modeles_dendro <- function(placettes, predicteurs, cibles, graine = 0,
                                   nombre_arbres = 150, feuille_min = 3) {
  verifier_colonnes(placettes, c(predicteurs, cibles), "les placettes")
  X <- matrice_num(placettes, predicteurs)
  modeles <- lapply(cibles, function(c) {
    foret_regression(X, as.numeric(placettes[[c]]), nombre_arbres, feuille_min, graine)
  })
  names(modeles) <- cibles
  structure(
    list(predicteurs = predicteurs, cibles = cibles, graine = graine,
         nombre_arbres = nombre_arbres, feuille_min = feuille_min, modeles = modeles),
    class = "typo_modeles_dendro"
  )
}

#' Prédire les variables dendrométriques
#'
#' @param modeles Objet rendu par [ajuster_modeles_dendro()].
#' @param df data.frame portant les colonnes de prédicteurs (pixels ou placettes).
#' @return data.frame, une colonne par variable cible ; parts bornées à [0, 1] et parts
#'   PB + BM + GB ramenées à 1.
#' @export
predire_dendro <- function(modeles, df) {
  verifier_colonnes(df, modeles$predicteurs, "la table \u00e0 pr\u00e9dire")
  X <- matrice_num(df, modeles$predicteurs)
  out <- as.data.frame(lapply(modeles$modeles, predire_foret, donnees = X))
  names(out) <- modeles$cibles
  normaliser_parts(out)
}

#' Prédictions dendrométriques hors échantillon (validation croisée)
#'
#' Chaque placette est prédite par un modèle qui ne l'a pas vue : validation croisée à
#' `plis` plis mélangés, à graine fixée (celle des modèles).
#'
#' @inheritParams predire_dendro
#' @param placettes data.frame des placettes : prédicteurs et variables cibles.
#' @param plis Nombre de plis. **Provisoire** : 5, repris du prototype.
#' @return data.frame, une colonne par variable cible, une ligne par placette.
#' @export
predire_dendro_validation <- function(modeles, placettes, plis = 5) {
  verifier_colonnes(placettes, c(modeles$predicteurs, modeles$cibles), "les placettes")
  X <- matrice_num(placettes, modeles$predicteurs)
  n <- nrow(X)
  pli <- plis_melanges(n, plis, modeles$graine)
  out <- data.frame(row.names = seq_len(n))
  for (c in modeles$cibles) {
    y <- as.numeric(placettes[[c]])
    pred <- numeric(n)
    for (k in seq_len(plis)) {
      test <- pli == k
      if (!any(test)) next
      m <- foret_regression(X[!test, , drop = FALSE], y[!test], modeles$nombre_arbres,
                            modeles$feuille_min, modeles$graine)
      pred[test] <- predire_foret(m, X[test, , drop = FALSE])
    }
    out[[c]] <- pred
  }
  normaliser_parts(out)
}

#' Erreurs des modèles dendrométriques hors échantillon
#'
#' Biais et RMSE de chaque variable cible, en validation croisée.
#'
#' @inheritParams predire_dendro_validation
#' @return data.frame : `variable`, `biais`, `rmse` (unités de la variable).
#' @export
erreurs_dendro <- function(modeles, placettes, plis = 5) {
  pred <- predire_dendro_validation(modeles, placettes, plis)
  lignes <- lapply(modeles$cibles, function(c) {
    e <- pred[[c]] - as.numeric(placettes[[c]])
    data.frame(variable = c, biais = mean(e), rmse = sqrt(mean(e^2)), stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, lignes)
  rownames(out) <- out$variable
  out
}

kappa_cohen <- function(observe, predit) {
  codes <- sort(unique(c(observe, predit)), method = "radix")
  indicateurs_confusion(matrice_confusion(observe, predit, codes))$kappa
}

classifieur_predire <- function(nom, Xa, ya, Xt, graine, nombre_arbres) {
  ya <- droplevels(factor(ya))
  if (nom == "forets_aleatoires") {
    m <- ranger::ranger(x = as.data.frame(Xa), y = ya, num.trees = nombre_arbres,
                        mtry = max(1L, floor(sqrt(ncol(Xa)))), min.node.size = 1,
                        seed = graine_ranger(graine), num.threads = 1)
    return(as.character(stats::predict(m, data = as.data.frame(Xt), num.threads = 1)$predictions))
  }
  if (nom == "svm") {
    m <- e1071::svm(x = Xa, y = ya, kernel = "radial", cost = 1, scale = TRUE)
    return(as.character(stats::predict(m, Xt)))
  }
  # Analyse discriminante linéaire sur variables standardisées.
  centre <- colMeans(Xa)
  ech <- apply(Xa, 2, stats::sd)
  ech[!is.finite(ech) | ech == 0] <- 1
  za <- scale(Xa, centre, ech)
  zt <- scale(Xt, centre, ech)
  m <- MASS::lda(x = za, grouping = ya)
  as.character(stats::predict(m, zt)$class)
}

#' Comparer forêts aléatoires, SVM et analyse discriminante
#'
#' Validation croisée stratifiée des trois classifieurs que le brief demande de
#' comparer : forêts aléatoires (ranger), SVM radiale (e1071, `cost = 1`, variables
#' réduites) et analyse discriminante linéaire (MASS, variables standardisées). Un type
#' trop rare pour la validation croisée (un seul exemple) est écarté, et on le dit dans
#' l'attribut `types_ecartes`.
#'
#' @param X data.frame des prédicteurs.
#' @param y Types (un par ligne de `X`), par exemple ceux de [types_observes()].
#' @param plis Nombre de plis (ramené à l'effectif du type le plus rare). **Provisoire** : 5.
#' @param graine Graine du hasard.
#' @param nombre_arbres Nombre d'arbres de la forêt de classement. **Provisoire** : 300,
#'   repris du prototype.
#'
#' @return data.frame trié par kappa décroissant : `classifieur` (`forets_aleatoires`,
#'   `svm`, `analyse_discriminante`), `precision_globale`, `kappa` ; attribut
#'   `types_ecartes`.
#' @export
comparer_classifieurs <- function(X, y, plis = 5, graine = 0, nombre_arbres = 300) {
  y <- as.character(y)
  X <- as.matrix(as.data.frame(X))
  storage.mode(X) <- "double"
  effectifs <- table(y)
  rares <- names(effectifs)[effectifs < 2]
  if (length(rares) > 0) {
    garde <- !(y %in% rares)
    X <- X[garde, , drop = FALSE]
    y <- y[garde]
    effectifs <- effectifs[effectifs >= 2]
  }
  plis <- max(2L, min(as.integer(plis), as.integer(min(effectifs))))
  pli <- plis_stratifies(y, plis, graine)
  noms <- c("forets_aleatoires", "svm", "analyse_discriminante")
  lignes <- lapply(noms, function(nom) {
    pred <- character(length(y))
    for (k in seq_len(plis)) {
      test <- pli == k
      pred[test] <- classifieur_predire(nom, X[!test, , drop = FALSE], y[!test],
                                        X[test, , drop = FALSE], graine, nombre_arbres)
    }
    data.frame(classifieur = nom, precision_globale = mean(pred == y),
               kappa = kappa_cohen(y, pred), stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, lignes)
  out <- out[order(-out$kappa), , drop = FALSE]
  rownames(out) <- out$classifieur
  attr(out, "types_ecartes") <- rares
  out
}

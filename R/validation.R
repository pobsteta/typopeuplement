# Validation à l'échelle de lecture réelle (validation.py du prototype).
#
# Valider sur des grappes de placettes couvrant un quart à un demi-hectare, pas
# seulement à la placette, et publier par SER une fiche de validation.

#' Matrice de confusion
#'
#' @param observe Types observés.
#' @param predit Types prédits.
#' @param codes Codes des types, dans l'ordre des lignes et des colonnes ; par défaut,
#'   tous les codes rencontrés, triés.
#' @return Table : lignes « observé », colonnes « prédit ». Un type jamais observé ni
#'   prédit garde sa ligne et sa colonne.
#' @export
matrice_confusion <- function(observe, predit, codes = NULL) {
  observe <- as.character(observe)
  predit <- as.character(predit)
  if (is.null(codes)) codes <- sort(unique(c(observe, predit)), method = "radix")
  m <- table(factor(observe, levels = codes), factor(predit, levels = codes))
  names(dimnames(m)) <- c("observ\u00e9", "pr\u00e9dit")
  m
}

#' Indicateurs d'une matrice de confusion
#'
#' @param matrice Matrice de confusion (lignes observé, colonnes prédit).
#' @return Liste : `n`, `precision_globale`, `kappa` (kappa de Cohen ; `NA` s'il n'est pas
#'   défini, par exemple avec une seule classe), `rappel_par_type`, `precision_par_type`.
#'   Matrice vide : `n = 0` et indicateurs `NA`, rien d'inventé.
#' @export
indicateurs_confusion <- function(matrice) {
  m <- unclass(as.matrix(matrice))
  storage.mode(m) <- "double"
  codes <- rownames(m)
  n <- sum(m)
  if (n == 0) {
    vide <- stats::setNames(rep(NA_real_, length(codes)), codes)
    return(list(n = 0L, precision_globale = NA_real_, kappa = NA_real_,
                rappel_par_type = vide, precision_par_type = vide))
  }
  po <- sum(diag(m)) / n
  pe <- sum(colSums(m) * rowSums(m)) / n^2
  kappa <- if (pe < 1) (po - pe) / (1 - pe) else NA_real_
  rappel <- diag(m) / rowSums(m)
  precision <- diag(m) / colSums(m)
  rappel[is.nan(rappel)] <- NA_real_
  precision[is.nan(precision)] <- NA_real_
  list(n = as.integer(n), precision_globale = po, kappa = kappa,
       rappel_par_type = stats::setNames(as.numeric(rappel), codes),
       precision_par_type = stats::setNames(as.numeric(precision), codes))
}

#' Grappes de placettes par maille carrée
#'
#' Identifiant de grappe : maille carrée de `cote_m` (70,7 m de côté : 0,5 ha), partie
#' entière par le bas (une coordonnée de -1 m est dans la maille -1).
#'
#' @param x,y Coordonnées en m (Lambert-93 pour les vraies données).
#' @param cote_m Côté de la maille, en m. **Provisoire** : 70,7.
#' @return Vecteur de caractères `"<colonne>_<ligne>"`.
#' @export
grappes_par_maille <- function(x, y, cote_m = 70.7) {
  i <- floor(as.numeric(x) / cote_m)
  j <- floor(as.numeric(y) / cote_m)
  sprintf("%.0f_%.0f", i, j)
}

# Type le plus fréquent ; à égalité, le premier rencontré.
majoritaire <- function(v) {
  u <- unique(v)
  u[which.max(tabulate(match(v, u)))]
}

#' Agréger en grappes
#'
#' Par grappe : type observé majoritaire, et type prédit par les probabilités moyennes
#' (type de plus forte probabilité moyenne). Deux règles distinctes.
#'
#' @param observe Types observés (un par placette).
#' @param probas data.frame de probabilités prédites, une colonne par type.
#' @param grappe Identifiant de grappe de chaque placette.
#' @return data.frame : `grappe`, `observe`, `predit`, une ligne par grappe (triées).
#' @export
agreger_grappes <- function(observe, probas, grappe) {
  grappe <- as.character(grappe)
  observe <- as.character(observe)
  ids <- sort(unique(grappe), method = "radix")
  p <- as.matrix(probas)
  storage.mode(p) <- "double"
  moy <- do.call(rbind, lapply(ids, function(g) colMeans(p[grappe == g, , drop = FALSE])))
  pred <- colnames(p)[indice_max_ligne(moy)]
  obs <- vapply(ids, function(g) majoritaire(observe[grappe == g]), character(1))
  data.frame(grappe = ids, observe = unname(obs), predit = pred, stringsAsFactors = FALSE)
}

#' Fiche de validation d'une SER
#'
#' Matrices de confusion et indicateurs à la placette et à la grappe. Les probabilités
#' doivent venir de placettes non utilisées pour calibrer (validation croisée).
#'
#' @param observe Types observés (la clé dure appliquée aux mesures, [types_observes()]).
#' @param probas Probabilités prédites hors échantillon, une colonne par type.
#' @param grappe Identifiant de grappe de chaque placette ([grappes_par_maille()]).
#' @param ser Nom de la SER.
#' @return Liste : `ser`, `placette` et `grappe` (chacune `matrice`, `n`,
#'   `precision_globale`, `kappa`, `rappel_par_type`, `precision_par_type`).
#' @export
fiche_validation <- function(observe, probas, grappe, ser = "") {
  codes <- colnames(probas)
  pred <- codes[indice_max_ligne(probas)]
  m_plac <- matrice_confusion(observe, pred, codes)
  g <- agreger_grappes(observe, probas, grappe)
  m_grap <- matrice_confusion(g$observe, g$predit, codes)
  list(
    ser = ser,
    placette = c(list(matrice = m_plac), indicateurs_confusion(m_plac)),
    grappe = c(list(matrice = m_grap), indicateurs_confusion(m_grap))
  )
}

fmt_nombre <- function(x, chiffres = 2) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("non d\u00e9fini")
  formatC(x, format = "f", digits = chiffres, decimal.mark = ",")
}

fmt_pourcent <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("non d\u00e9finie")
  paste0(formatC(100 * x, format = "f", digits = 1, decimal.mark = ","), " %")
}

#' Fiche de validation en Markdown
#'
#' Texte de `fiche_validation.md` : à la placette et à la grappe, effectif, précision
#' globale, kappa et matrice de confusion ; puis, quand la chaîne les a ajoutés à la
#' fiche, le niveau du modèle, les erreurs des variables, la RMSE de la hauteur
#' potentielle et l'écart aux courbes de station de nemeton.
#'
#' @param fiche Liste rendue par [fiche_validation()] (ou par la chaîne,
#'   `resultat$fiche_validation`).
#' @return Vecteur de lignes de texte.
#' @export
fiche_en_markdown <- function(fiche) {
  lignes <- c(paste0("# Fiche de validation \u2014 SER ", fiche$ser), "")
  if (identical(fiche$mode, "variables fournies")) {
    lignes <- c(lignes,
                "Mode \u00ab variables fournies \u00bb : les variables viennent du producteur ;",
                "sans placettes, **pas de validation** (ni \u00e0 la placette ni \u00e0 la grappe).",
                "")
  }
  for (niveau in c("placette", "grappe")) {
    f <- fiche[[niveau]]
    if (is.null(f)) next
    m <- unclass(as.matrix(f$matrice))
    lignes <- c(
      lignes,
      paste0("## \u00c0 la ", niveau), "",
      paste0("- Effectif : ", f$n),
      paste0("- Pr\u00e9cision globale : ", fmt_pourcent(f$precision_globale)),
      paste0("- Kappa : ", fmt_nombre(f$kappa)), "",
      "Matrice de confusion (lignes : observ\u00e9, colonnes : pr\u00e9dit)", "",
      paste0("| observ\u00e9 \\ pr\u00e9dit | ", paste(colnames(m), collapse = " | "), " |"),
      paste0(strrep("|---", ncol(m) + 1), "|")
    )
    for (r in seq_len(nrow(m))) {
      lignes <- c(lignes, paste0("| ", rownames(m)[r], " | ",
                                 paste(as.integer(m[r, ]), collapse = " | "), " |"))
    }
    lignes <- c(lignes, "")
  }
  if (length(fiche$declarations) > 0) {
    lignes <- c(lignes, "## D\u00e9clarations", "", paste0("- ", fiche$declarations), "")
  }
  if (!is.null(fiche$controle)) {
    ct <- fiche$controle
    m <- unclass(as.matrix(ct$tableau))
    lignes <- c(lignes,
                paste0("## Contr\u00f4le de coh\u00e9rence avec ", ct$reference), "",
                "Contr\u00f4le de coh\u00e9rence, **pas une validation** : la couche du producteur ne d\u00e9crit pas les m\u00eames types.",
                "",
                paste0("- Pixels : ", ct$n),
                paste0("- V de Cram\u00e9r : ", fmt_nombre(ct$v_cramer)), "",
                paste0("| type \\ ", ct$reference, " | ", paste(colnames(m), collapse = " | "), " |"),
                paste0(strrep("|---", ncol(m) + 1), "|"))
    for (r in seq_len(nrow(m))) {
      lignes <- c(lignes, paste0("| ", rownames(m)[r], " | ",
                                 paste(as.integer(m[r, ]), collapse = " | "), " |"))
    }
    lignes <- c(lignes, "")
  }
  if (identical(fiche$niveau_modele, "producteur")) {
    lignes <- c(lignes, "## Niveau du mod\u00e8le", "",
                "- Niveau : producteur (variables du producteur, pas de mod\u00e8le ajust\u00e9)", "")
  } else if (!is.null(fiche$niveau_modele)) {
    lignes <- c(lignes, "## Niveau du mod\u00e8le", "",
                paste0("- Niveau : ", fiche$niveau_modele,
                       " (\u00ab grande_region \u00bb : grande r\u00e9gion *requise*, au moins un ",
                       "type de la cl\u00e9 a trop peu de placettes ; la bascule vers le mod\u00e8le ",
                       "de grande r\u00e9gion n'est pas encore \u00e9crite : le mod\u00e8le de la SER ",
                       "reste celui qui a servi)"),
                "")
  }
  if (!is.null(fiche$erreurs_variables)) {
    e <- fiche$erreurs_variables
    lignes <- c(lignes, "## Erreurs des variables (validation crois\u00e9e)", "",
                "| variable | biais | RMSE |", "|---|---|---|")
    for (r in seq_len(nrow(e))) {
      lignes <- c(lignes, paste0("| ", e$variable[r], " | ", fmt_nombre(e$biais[r], 3), " | ",
                                 fmt_nombre(e$rmse[r], 3), " |"))
    }
    lignes <- c(lignes, "")
  }
  if (!is.null(fiche$rmse_hauteur_potentielle)) {
    r <- fiche$rmse_hauteur_potentielle
    lignes <- c(lignes, "## Hauteur potentielle", "",
                paste0("- RMSE de validation crois\u00e9e, ", names(r), " : ",
                       vapply(r, fmt_nombre, character(1)), " m"))
    es <- fiche$ecart_station
    if (is.null(es) || is.null(es$correlation_rang)) {
      raison <- es$raison %||% "non calcul\u00e9e"
      lignes <- c(lignes, paste0("- Corr\u00e9lation de rang entre h_pot et l'indice de station ",
                                 "de nemeton : ", raison))
    } else {
      lignes <- c(lignes, paste0("- Corr\u00e9lation de rang entre h_pot et l'indice de station ",
                                 "de nemeton : ", fmt_nombre(es$correlation_rang), " (", es$n,
                                 " placettes d'\u00e2ge et d'essence connus ; contr\u00f4le de ",
                                 "coh\u00e9rence, pas une \u00e9galit\u00e9)"))
    }
    lignes <- c(lignes, "")
  }
  lignes
}

#' Contrôle de cohérence avec une couche de référence du producteur
#'
#' Tableau croisé des types de la carte et d'une couche catégorielle du producteur (par
#' exemple l'étagement `Typo_etage` du jeu ONF), et V de Cramér. C'est un **contrôle de
#' cohérence, pas une validation** : la référence de validation est la clé appliquée
#' aux mesures (Souchon, 2020), et la couche du producteur ne décrit pas les mêmes
#' types.
#'
#' @param types Types de la carte (un par pixel ; `NA` : pixel non typé, écarté).
#' @param reference Classe de la couche du producteur (un par pixel ; `NA` écarté).
#' @param nom Nom de la couche de référence, pour la fiche.
#' @param exclure Classes de `reference` à écarter (par exemple 0, « non précomptable »).
#' @return Liste : `reference` (le nom), `tableau` (lignes : types, colonnes : classes),
#'   `n`, `v_cramer` (`NA` si le tableau a moins de deux lignes ou deux colonnes).
#' @export
controle_coherence <- function(types, reference, nom = "reference", exclure = NULL) {
  garde <- !is.na(types) & !is.na(reference) & !(reference %in% exclure)
  tab <- table(as.character(types[garde]), as.character(reference[garde]))
  names(dimnames(tab)) <- c("type", nom)
  n <- sum(tab)
  v <- NA_real_
  if (n > 0 && nrow(tab) >= 2 && ncol(tab) >= 2) {
    m <- unclass(tab)
    storage.mode(m) <- "double"
    attendu <- outer(rowSums(m), colSums(m)) / n
    chi2 <- sum((m - attendu)^2 / attendu)
    v <- sqrt(chi2 / (n * (min(dim(m)) - 1)))
  }
  list(reference = nom, tableau = tab, n = as.integer(n), v_cramer = v)
}

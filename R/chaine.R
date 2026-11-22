# La chaîne de traitement, rejouable à chaque nouvelle donnée (chaine.py du prototype).
#
#   placettes + pixels --> variables dendrométriques (modèles)
#   pixels (milieu)    --> hauteur potentielle --> rapport hauteur mesurée / potentielle
#                                    |
#                                    v
#                      clé floue par SER --> lissage --> type, probabilité, drapeaux

modele_hp_depuis_conf <- function(pixels, conf) {
  hp <- conf$hauteur_potentielle %||% list()
  ajuster_hauteur_potentielle(
    pixels,
    variables_milieu = conf$variables_milieu,
    couvert_min = hp$couvert_min %||% 0.7,
    hauteur_min_m = hp$hauteur_min_m %||% 15,
    incertitude_relative_max = hp$incertitude_relative_max %||% 0.2,
    quantile_enveloppe = hp$quantile_enveloppe %||% 0.9,
    graine = conf$graine %||% 0
  )
}

# Écart aux courbes de station sur les placettes, si l'âge et l'essence y sont et si
# nemeton est installé ; sinon la raison, écrite dans la fiche.
ecart_station_placettes <- function(placettes, hp_plac) {
  if (!all(c("age", "essence") %in% names(placettes))) {
    return(list(raison = "non calcul\u00e9e (\u00e2ge ou essence absents des placettes)"))
  }
  if (!requireNamespace("nemeton", quietly = TRUE)) {
    return(list(raison = "non calcul\u00e9e (nemeton n'est pas install\u00e9)"))
  }
  ecart_courbes_station(hp_plac$h_pot, placettes$h_dom, placettes$age, placettes$essence)
}

#' Exécuter la chaîne sur des tableaux de placettes et de pixels
#'
#' 1. variables dendrométriques prédites sur les pixels (forêts aléatoires apprises sur
#'    les placettes) ;
#' 2. hauteur potentielle apprise sur les peuplements adultes fermés des pixels, et
#'    rapport hauteur mesurée / hauteur potentielle ;
#' 3. clé floue de la SER, lissage à l'échelle de lecture, décision et drapeaux ;
#' 4. validation sur les placettes, hors échantillon (validation croisée), à la placette
#'    et à la grappe, la référence étant la clé dure appliquée aux mesures.
#'
#' Entrées, une ligne par placette ou par pixel : les `predicteurs` et les
#' `variables_milieu` de la configuration, `h_dom` (m), `couvert`, `famille` ; pour les
#' pixels `i`, `j` (indices de grille) ; pour les placettes les variables mesurées (`G`,
#' parts) et `x`, `y` (m). Facultatif, sur les placettes : `age` et `essence`, pour
#' l'écart aux courbes de station de nemeton.
#'
#' @param placettes data.frame des placettes.
#' @param pixels data.frame des pixels de l'emprise.
#' @param conf Configuration effective d'une SER ([lire_configuration()]).
#'
#' @return Objet `typo_resultat` (liste) : `carte` (une ligne par pixel : `i`, `j`, `type`,
#'   `proba`, `type_second`, `proba_second`, `entre_deux`, `hors_cle`, les variables
#'   prédites, `h_dom`, `h_pot`, `h_pot_sd`, `rapport_h`, `hp_incertaine`, `p_<code>`),
#'   `fiche_validation`, `erreurs_variables`, `rmse_hauteur_potentielle`,
#'   `types_observes`, `niveau_modele`, `ser` et `cle`.
#' @export
executer_chaine <- function(placettes, pixels, conf) {
  cle <- conf$cle
  graine <- conf$graine %||% 0
  verifier_colonnes(pixels, c(conf$predicteurs, conf$variables_milieu, "h_dom", "couvert", "i", "j"),
                    "les pixels")
  verifier_colonnes(placettes, c(conf$predicteurs, conf$variables_milieu, conf$variables_cibles,
                                 "h_dom", "x", "y"), "les placettes")

  # 1. Variables dendrométriques.
  dendro <- ajuster_modeles_dendro(placettes, conf$predicteurs, conf$variables_cibles, graine)
  var_pix <- predire_dendro(dendro, pixels)

  # 2. Hauteur potentielle, apprise sur les peuplements adultes fermés des pixels.
  mhp <- modele_hp_depuis_conf(pixels, conf)
  hp_pix <- predire_hauteur_potentielle(mhp, pixels)
  hp_plac <- predire_hauteur_potentielle(mhp, placettes)

  # 3. Clé floue, lissage, décision.
  entree <- cbind(var_pix, rapport_h = hp_pix$rapport_h)
  probas <- appartenances_types(cle, entree)
  hors_cle <- attr(probas, "hors_cle")
  attr(probas, "hors_cle") <- NULL
  probas <- lisser_probabilites(probas, pixels$i, pixels$j, conf$lissage_fenetre %||% 3)
  carte <- decider_type(probas, as.numeric(cle$marge_entre_deux %||% 0.15))
  carte$hors_cle <- hors_cle
  p_cols <- probas
  names(p_cols) <- paste0("p_", names(probas))
  carte <- cbind(data.frame(i = pixels$i, j = pixels$j), carte, var_pix,
                 data.frame(h_dom = as.numeric(pixels$h_dom)), hp_pix, p_cols)
  rownames(carte) <- NULL

  # 4. Validation indépendante sur les placettes (prédictions hors échantillon).
  mesures <- cbind(placettes[, conf$variables_cibles, drop = FALSE], rapport_h = hp_plac$rapport_h)
  obs <- types_observes(cle, mesures)
  var_cv <- predire_dendro_validation(dendro, placettes)
  p_cv <- appartenances_types(cle, cbind(var_cv, rapport_h = hp_plac$rapport_h))
  attr(p_cv, "hors_cle") <- NULL
  grappe <- grappes_par_maille(placettes$x, placettes$y, conf$grappe_cote_m %||% 70.7)
  fiche <- fiche_validation(obs, p_cv, grappe, ser = conf$ser %||% "")

  codes <- codes_cle(cle)
  effectifs <- table(factor(obs, levels = codes))
  niveau <- niveau_modele(effectifs, codes, conf$placettes_min_par_type %||% 30)
  erreurs <- erreurs_dendro(dendro, placettes)

  fiche$niveau_modele <- niveau
  fiche$erreurs_variables <- erreurs
  fiche$rmse_hauteur_potentielle <- mhp$rmse_cv
  fiche$ecart_station <- ecart_station_placettes(placettes, hp_plac)

  structure(
    list(
      carte = carte,
      fiche_validation = fiche,
      erreurs_variables = erreurs,
      rmse_hauteur_potentielle = mhp$rmse_cv,
      types_observes = obs,
      niveau_modele = niveau,
      ser = conf$ser %||% "",
      cle = cle
    ),
    class = "typo_resultat"
  )
}

#' @export
print.typo_resultat <- function(x, ...) {
  cat(resume_resultat(x), sep = "\n")
  invisible(x)
}

resume_resultat <- function(res) {
  f <- res$fiche_validation
  c <- res$carte
  c(
    sprintf("SER %s : %d pixels class\u00e9s (niveau du mod\u00e8le : %s)", f$ser, nrow(c), res$niveau_modele),
    sprintf("  pr\u00e9cision \u00e0 la placette : %s (kappa %s)", fmt_pourcent(f$placette$precision_globale),
            fmt_nombre(f$placette$kappa)),
    sprintf("  pr\u00e9cision \u00e0 la grappe   : %s (kappa %s)", fmt_pourcent(f$grappe$precision_globale),
            fmt_nombre(f$grappe$kappa)),
    sprintf("  pixels entre deux types : %s", fmt_pourcent(mean(c$entre_deux))),
    sprintf("  hauteur potentielle incertaine : %s", fmt_pourcent(mean(c$hp_incertaine)))
  )
}

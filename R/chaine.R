# La chaîne de traitement, rejouable à chaque nouvelle donnée (chaine.py du prototype).
#
#   placettes + pixels --> variables dendrométriques (modèles)
#   pixels (milieu)    --> hauteur potentielle --> rapport hauteur mesurée / potentielle
#                                    |
#                                    v
#                      clé floue par SER --> lissage --> type, probabilité, drapeaux

modele_hp_depuis_conf <- function(pixels, conf, variables_milieu = conf$variables_milieu) {
  hp <- conf$hauteur_potentielle %||% list()
  ajuster_hauteur_potentielle(
    pixels,
    variables_milieu = variables_milieu,
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
  if (identical(res$niveau_modele, "producteur")) {
    types_ok <- !is.na(c$type)
    return(c(
      sprintf("SER %s : %d pixels, dont %d typ\u00e9s (variables du producteur, pas de validation)",
              f$ser, nrow(c), sum(types_ok)),
      sprintf("  pixels entre deux types : %s", fmt_pourcent(mean(c$entre_deux[types_ok]))),
      sprintf("  pixels non pr\u00e9comptables : %s", fmt_pourcent(mean(c$non_precomptable))),
      sprintf("  hauteur potentielle incertaine : %s", fmt_pourcent(mean(c$hp_incertaine))),
      sprintf("  V de Cram\u00e9r avec %s (coh\u00e9rence) : %s", f$controle$reference %||% "-",
              fmt_nombre(f$controle$v_cramer))
    ))
  }
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

# Chronomètre d'un étage : évalue `expr`, ajoute une ligne à `env$temps`.
chronometrer <- function(env, etage, pixels, expr) {
  debut <- proc.time()[["elapsed"]]
  valeur <- force(expr)
  env$temps <- rbind(env$temps, data.frame(etage = etage,
                                           secondes = proc.time()[["elapsed"]] - debut,
                                           pixels = as.integer(pixels),
                                           stringsAsFactors = FALSE))
  valeur
}

# Lignes de la fiche sur la hauteur potentielle apprise sur un milieu fourni : ce qu'elle
# voit (source du milieu), ce qui lui manque (variables de la configuration absentes),
# l'erreur de validation croisée par famille, la part de pixels « incertaine », et la
# hauteur dominante non calibrée du producteur.
declarations_milieu <- function(milieu, vm, conf, couches, mhp, incertaine) {
  out <- character(0)
  src <- attr(milieu, "source")
  out <- c(out, sprintf("Hauteur potentielle apprise sur : %s.",
                        src %||% paste(vm, collapse = ", ")))
  absentes <- setdiff(conf$variables_milieu, vm)
  if (length(absentes) > 0) {
    out <- c(out, sprintf(paste0("Variables de milieu de la configuration absentes du milieu ",
                                 "fourni : %s ; non invent\u00e9es."),
                          paste(absentes, collapse = ", ")))
  }
  if (!is.null(mhp)) {
    r <- unlist(mhp$rmse_cv)
    out <- c(out, sprintf("RMSE de validation crois\u00e9e de la hauteur potentielle (m) : %s.",
                          paste(sprintf("famille %s : %s", names(r),
                                        format(round(r, 2), decimal.mark = ",")), collapse = " ; ")))
    k <- unlist(mhp$facteur)
    out <- c(out, sprintf(paste0(
      "Enveloppe de la hauteur potentielle (quantile %s du rapport h_dom / pr\u00e9diction ",
      "hors sac des adultes ferm\u00e9s) : %s. Incertitude h_pot_sd = enveloppe \u00d7 RMSE ; ",
      "la dispersion des arbres de la for\u00eat (sd_arbres) est rendue \u00e0 part, ",
      "ce n'est pas une erreur de pr\u00e9diction."),
      format(mhp$quantile_enveloppe, decimal.mark = ","),
      paste(sprintf("famille %s : %s", names(k), format(round(k, 3), decimal.mark = ",")),
            collapse = " ; ")))
  }
  if (length(incertaine) > 0) {
    out <- c(out, sprintf("Hauteur potentielle incertaine sur %s %% des pixels pr\u00e9comptables.",
                          format(round(100 * mean(incertaine), 1), decimal.mark = ",")))
  }
  src_h <- if (!is.null(couches) && all(c("variable", "source") %in% names(couches))) {
    couches$source[couches$variable == "h_dom"]
  } else character(0)
  if (length(src_h) == 1 && grepl("non calibr", src_h)) {
    out <- c(out, paste0(
      "h_dom est la hauteur dominante brute du producteur, non calibr\u00e9e : la hauteur ",
      "potentielle est apprise dans la m\u00eame \u00e9chelle. Le rapport h_dom / h_pot ",
      "en est peu affect\u00e9 (biais commun) ; la hauteur potentielle en m\u00e8tres ne ",
      "se compare ni aux courbes de station ni aux quarts de hauteur du GSM sans calibration."))
  }
  out
}

# Variables appelées par les conditions d'une clé.
variables_cle <- function(cle) {
  unique(unlist(lapply(cle$types, function(t) {
    variables_type(t)
  })))
}

#' Exécuter la chaîne sur des variables fournies par un producteur
#'
#' Mode « variables fournies » (mission 006) : les variables de la clé viennent déjà
#' calculées (par exemple les paramètres forestiers LiDAR de l'ONF lus par
#' [lire_parametres_lidar()]). On saute l'ajustement dendrométrique : pas de placettes,
#' donc **pas de validation** ; la fiche porte un contrôle de cohérence avec l'étagement
#' du producteur (`typo_etage`), qui n'est pas une validation.
#'
#' Étages, chacun chronométré (`temps`) : `lecture` (repris de l'attribut
#' `temps_lecture` des variables), `hauteur_potentielle`, `cle`, `lissage`, `decision`,
#' `controle` ; `ecriture_rasters` et `ecriture_tables` sont ajoutés par
#' [ecrire_livrables()].
#'
#' - Les pixels `non_precomptable` ne sont pas typés (type vide).
#' - Les souplesses du jeu (bloc `jeux.<jeu>.souplesse` de la configuration, le jeu étant
#'   nommé par la colonne `jeu` de l'attribut `couches`, voir [couches_onf()]) remplacent
#'   celles de la clé pour leurs variables : réglage du jeu, dit dans la fiche pour les
#'   variables que la clé utilise.
#' - Variable absente : quand les types de tête ne se départagent que par une variable
#'   manquante, `type` est le groupe de ces types (`"R-PB-J | R-PB-C"`, voir
#'   [decider_type()]) et `entre_deux` est levé ; `correspondance_types.csv` liste les
#'   groupes.
#' - Si le seuil de gros bois du producteur diffère de `seuils_diametre$bm_gb_cm` de la
#'   configuration, le drapeau `gb_interim` est levé sur tous les pixels typés et la
#'   fiche le déclare.
#' - Avec `milieu`, la fiche dit ce que voit la hauteur potentielle (attribut `source`),
#'   les variables de milieu de la configuration absentes (jamais inventées), la RMSE de
#'   validation croisée par famille, l'enveloppe par famille (mesurée hors sac), la part
#'   de pixels « incertaine » et, si le producteur la déclare non calibrée, ce
#'   qu'implique une hauteur dominante brute. La carte porte `h_pot_sd` (enveloppe ×
#'   RMSE) et, à part, `sd_arbres` (dispersion des arbres de la forêt, pas une erreur).
#' - Jeu sans bloc `jeux` dans la configuration : la fiche le déclare (souplesses de la
#'   clé).
#' - Sans `milieu`, la hauteur potentielle est vide et signalée partout
#'   (`hp_incertaine`) ; la clé s'en tient alors aux autres variables.
#' - Une clé vide (SER sans typologie sourcée) arrête la chaîne : aucune carte de types
#'   sans clé.
#'
#' @param variables data.frame de pixels : `i`, `j` (indices de grille), `h_dom` (m),
#'   `couvert` (0 à 1), les variables de la clé autres que `rapport_h` (une colonne vide
#'   neutralise ses conditions), et facultativement `x`, `y`, `famille`, `typo_etage`,
#'   `non_precomptable`, `part_pb_absente`.
#' @param conf Configuration effective d'une SER ([lire_configuration()]).
#' @param milieu data.frame des variables de milieu, une ligne par ligne de `variables` ;
#'   ses colonnes utilisées sont celles de son attribut `variables_milieu` (posé par
#'   [milieu_pixels()]), sinon les `variables_milieu` de la configuration ; `NULL` :
#'   hauteur potentielle vide.
#' @return Objet `typo_resultat` : `carte`, `fiche_validation` (sans placette ni grappe,
#'   avec `controle` et `declarations`), `niveau_modele` (`"producteur"`), `ser`, `cle`
#'   (souplesses du jeu comprises), `temps` (`etage`, `secondes`, `pixels`), `gabarit`.
#' @seealso [typer_peuplements()], [controle_coherence()]
#' @export
executer_chaine_fournie <- function(variables, conf, milieu = NULL) {
  chrono <- new.env()
  chrono$temps <- data.frame(etage = character(0), secondes = numeric(0), pixels = integer(0),
                             stringsAsFactors = FALSE)
  n <- nrow(variables)
  t_lecture <- attr(variables, "temps_lecture")
  if (!is.null(t_lecture)) {
    chrono$temps <- data.frame(etage = "lecture", secondes = t_lecture, pixels = n,
                               stringsAsFactors = FALSE)
  }
  cle <- conf$cle
  ser <- conf$ser %||% ""
  if (length(cle$types) == 0) {
    arreter(sprintf(paste0("cl\u00e9 de types vide pour la SER %s : aucune carte de types ",
                           "sans typologie locale sourc\u00e9e"), ser))
  }
  verifier_colonnes(variables, c("i", "j", "h_dom", "couvert"), "les variables fournies")
  couches <- attr(variables, "couches")
  declarations <- character(0)

  # Souplesses du jeu (erreurs du producteur), à la place de celles de la clé : elles
  # viennent du bloc `jeux` de la configuration, jamais du code.
  jeux <- if (!is.null(couches) && "jeu" %in% names(couches)) unique(stats::na.omit(couches$jeu)) else character(0)
  utilisees <- variables_cle(cle)
  for (jeu in jeux) {
    if (is.null(conf$jeux[[jeu]])) {
      declarations <- c(declarations, sprintf(
        "Jeu %s : souplesses de la cl\u00e9, faute de bloc jeux.", jeu))
      next
    }
    sou <- conf$jeux[[jeu]]$souplesse
    for (v in names(sou)) {
      cle$souplesse[[v]] <- as.numeric(sou[[v]])
      # Une souplesse d'une variable que la clé n'utilise pas n'est pas déclarée.
      if (v %in% utilisees) {
        source <- conf$jeux[[jeu]]$source %||% paste0("jeu ", jeu)
        declarations <- c(declarations, sprintf("Souplesse de %s : %s (%s).", v,
                                                format(as.numeric(sou[[v]]), decimal.mark = ","), source))
      }
    }
  }

  non_prec <- if ("non_precomptable" %in% names(variables)) {
    as.logical(variables$non_precomptable) %in% TRUE
  } else rep(FALSE, n)
  pb_absente <- if ("part_pb_absente" %in% names(variables)) {
    as.logical(variables$part_pb_absente) %in% TRUE
  } else if ("part_pb" %in% names(variables)) is.na(variables$part_pb) else rep(TRUE, n)
  if (any(pb_absente)) {
    declarations <- c(declarations, paste0(
      "part_pb absente du jeu : ses conditions sont neutralis\u00e9es (drapeau part_pb_absente)."))
  }

  # Gros bois : seuil du producteur contre seuil de la SER.
  seuil_conf <- conf$seuils_diametre$bm_gb_cm
  seuil_prod <- if (!is.null(couches) && "seuil_cm" %in% names(couches)) {
    couches$seuil_cm[couches$variable == "part_gb"]
  } else numeric(0)
  gb_interim <- length(seuil_prod) == 1 && !is.na(seuil_prod) && !is.null(seuil_conf) &&
    abs(seuil_prod - as.numeric(seuil_conf)) > 1e-9
  if (gb_interim) {
    declarations <- c(declarations, sprintf(paste0(
      "Gros bois : INT\u00c9RIM. La part de gros bois du producteur est calcul\u00e9e \u00e0 %s cm, ",
      "la limite de la SER est %s cm (drapeau gb_interim)."),
      format(seuil_prod, decimal.mark = ","), format(as.numeric(seuil_conf), decimal.mark = ",")))
  }

  # 1. Hauteur potentielle. Les variables de milieu sont celles que porte `milieu`
  # (attribut `variables_milieu`, par exemple le relief de milieu_pixels()), sinon celles
  # de la configuration.
  vm <- if (is.null(milieu)) conf$variables_milieu else attr(milieu, "variables_milieu") %||% conf$variables_milieu
  mhp <- NULL
  hp <- chronometrer(chrono, "hauteur_potentielle", n, {
    if (is.null(milieu)) {
      data.frame(h_pot = rep(NA_real_, n), h_pot_sd = NA_real_, rapport_h = NA_real_,
                 hp_incertaine = TRUE)
    } else {
      if (nrow(milieu) != n) arreter("milieu doit avoir une ligne par ligne de variables")
      verifier_colonnes(milieu, vm, "le milieu")
      df <- cbind(as.data.frame(variables)[, setdiff(names(variables), vm), drop = FALSE],
                  as.data.frame(milieu)[, vm, drop = FALSE])
      # Trop peu d'adultes fermés dans l'emprise : pas de modèle, hauteur potentielle
      # vide et signalée partout (dit dans la fiche), plutôt qu'une hauteur sans appui.
      mhp <- tryCatch(modele_hp_depuis_conf(df[!non_prec, , drop = FALSE], conf, vm),
                      typo_erreur = function(e) {
                        if (!grepl("trop peu de peuplements adultes", conditionMessage(e))) stop(e)
                        NULL
                      })
      if (is.null(mhp)) {
        data.frame(h_pot = rep(NA_real_, n), h_pot_sd = NA_real_, rapport_h = NA_real_,
                   hp_incertaine = TRUE)
      } else predire_hauteur_potentielle(mhp, df)
    }
  })
  # Dispersion des arbres de la forêt (pas une erreur de prédiction), rendue à part.
  hp$sd_arbres <- attr(hp, "sd_arbres") %||% rep(NA_real_, n)
  if (is.null(milieu)) {
    declarations <- c(declarations, paste0(
      "Hauteur potentielle vide et signal\u00e9e partout (milieu non fourni) : ",
      "rapport_h neutralis\u00e9 dans la cl\u00e9."))
  } else if (is.null(mhp)) {
    declarations <- c(declarations, paste0(
      "Hauteur potentielle vide et signal\u00e9e partout (trop peu de peuplements adultes ",
      "ferm\u00e9s dans l'emprise pour l'apprendre) : rapport_h neutralis\u00e9 dans la cl\u00e9."))
  } else {
    declarations <- c(declarations, declarations_milieu(milieu, vm, conf, couches, mhp,
                                                        hp$hp_incertaine[!non_prec]))
  }

  # 2. Clé floue sur les pixels précomptables.
  ok <- which(!non_prec)
  vars <- setdiff(variables_cle(cle), "rapport_h")
  verifier_colonnes(variables, vars, "les variables fournies (variables de la cl\u00e9)")
  probas <- chronometrer(chrono, "cle", length(ok), {
    entree <- as.data.frame(variables)[ok, vars, drop = FALSE]
    entree$rapport_h <- hp$rapport_h[ok]
    appartenances_types(cle, entree)
  })
  hors_cle <- attr(probas, "hors_cle")
  touche_na <- attr(probas, "touche_na")
  attr(probas, "hors_cle") <- NULL
  attr(probas, "touche_na") <- NULL

  # 3. Lissage à l'échelle de lecture.
  probas <- chronometrer(chrono, "lissage", length(ok), {
    lisser_probabilites(probas, variables$i[ok], variables$j[ok], conf$lissage_fenetre %||% 3)
  })

  # 4. Décision et assemblage de la carte (une ligne par pixel, vide hors précomptable).
  carte <- chronometrer(chrono, "decision", length(ok), {
    # Variable absente : les types qui ne se départagent que par elle forment un groupe.
    dec <- decider_type(probas, as.numeric(cle$marge_entre_deux %||% 0.15), touche_na = touche_na)
    codes <- names(probas)
    tout <- data.frame(type = rep(NA_character_, n), proba = NA_real_,
                       type_second = NA_character_, proba_second = NA_real_,
                       entre_deux = NA, hors_cle = NA, stringsAsFactors = FALSE)
    tout[ok, c("type", "proba", "type_second", "proba_second", "entre_deux")] <- dec
    tout$hors_cle[ok] <- hors_cle
    p_cols <- as.data.frame(matrix(NA_real_, n, length(codes)))
    names(p_cols) <- paste0("p_", codes)
    p_cols[ok, ] <- as.matrix(probas)
    xy <- if (all(c("x", "y") %in% names(variables))) {
      data.frame(x = variables$x, y = variables$y)
    } else NULL
    gardees <- intersect(c("G", "part_resineux", "part_pb", "part_bm", "part_gb", "h_dom",
                           "couvert", "famille", "typo_etage"), names(variables))
    morceaux <- list(data.frame(i = variables$i, j = variables$j), xy, tout,
                     as.data.frame(variables)[, gardees, drop = FALSE],
                     hp[, c("h_pot", "h_pot_sd", "rapport_h", "hp_incertaine", "sd_arbres")],
                     data.frame(non_precomptable = non_prec, part_pb_absente = pb_absente,
                                gb_interim = gb_interim & !non_prec),
                     p_cols)
    out <- do.call(cbind, morceaux[!vapply(morceaux, is.null, logical(1))])
    rownames(out) <- NULL
    out
  })

  # 5. Contrôle de cohérence avec l'étagement du producteur (pas une validation).
  controle <- chronometrer(chrono, "controle", length(ok), {
    if ("typo_etage" %in% names(variables)) {
      controle_coherence(carte$type[ok], variables$typo_etage[ok], "Typo_etage",
                         exclure = 0)
    } else NULL
  })

  fiche <- list(
    ser = ser,
    mode = "variables fournies",
    placette = NULL,
    grappe = NULL,
    niveau_modele = "producteur",
    controle = controle,
    declarations = declarations
  )
  structure(
    list(
      carte = carte,
      fiche_validation = fiche,
      erreurs_variables = NULL,
      rmse_hauteur_potentielle = if (is.null(mhp)) NULL else unlist(mhp$rmse_cv),
      types_observes = NULL,
      niveau_modele = "producteur",
      ser = ser,
      cle = cle,
      temps = chrono$temps,
      gabarit = attr(variables, "gabarit")
    ),
    class = "typo_resultat"
  )
}

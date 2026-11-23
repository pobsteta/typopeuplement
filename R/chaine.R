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
    # h_pot_sd est constant dans une famille : le drapeau « incertaine » revient à un seuil
    # de hauteur potentielle par famille (décision du 2026-11-22, option a).
    seuil <- k[names(r)] * r / mhp$incertitude_relative_max
    out <- c(out, sprintf(paste0(
      "Le drapeau \u00ab hauteur potentielle incertaine \u00bb (h_pot_sd / h_pot > %s) revient ",
      "\u00e0 un seuil de hauteur potentielle par famille, h_pot < enveloppe \u00d7 RMSE / %s : ",
      "%s. Il marque les stations les moins fertiles, pas une incertitude locale."),
      format(mhp$incertitude_relative_max, decimal.mark = ","),
      format(mhp$incertitude_relative_max, decimal.mark = ","),
      paste(sprintf("famille %s : %s m", names(seuil), format(round(seuil, 1), decimal.mark = ",")),
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

#' Apprendre la hauteur potentielle sur des variables fournies
#'
#' Ajuste le modèle de hauteur potentielle exactement comme le fait
#' [executer_chaine_fournie()] (pixels précomptables, variables de milieu de l'attribut
#' `variables_milieu` de `milieu`, réglages `hauteur_potentielle` de la configuration),
#' pour l'apprendre sur une grande emprise (le massif) et l'appliquer à une petite
#' (une forêt) : `typer_peuplements(aoi, ..., modele_hp = m)`. Une petite emprise a trop
#' peu de peuplements adultes fermés pour apprendre seule.
#'
#' @param variables data.frame de pixels ([lire_parametres_lidar()]) : `h_dom`,
#'   `couvert`, `famille`, et `non_precomptable` s'il existe.
#' @param milieu data.frame des variables de milieu, une ligne par ligne de `variables`
#'   ([milieu_pixels()]).
#' @param conf Configuration effective d'une SER ([lire_configuration()]) ; sa `graine`
#'   (0 par défaut) est celle de la chaîne.
#' @return Objet `typo_hauteur_potentielle` ([ajuster_hauteur_potentielle()]).
#' @export
apprendre_hauteur_potentielle <- function(variables, milieu, conf) {
  vm <- attr(milieu, "variables_milieu") %||% conf$variables_milieu
  if (nrow(milieu) != nrow(variables)) arreter("milieu doit avoir une ligne par ligne de variables")
  verifier_colonnes(milieu, vm, "le milieu")
  non_prec <- if ("non_precomptable" %in% names(variables)) {
    as.logical(variables$non_precomptable) %in% TRUE
  } else rep(FALSE, nrow(variables))
  df <- cbind(as.data.frame(variables)[, setdiff(names(variables), vm), drop = FALSE],
              as.data.frame(milieu)[, vm, drop = FALSE])
  modele_hp_depuis_conf(df[!non_prec, , drop = FALSE], conf, vm)
}

# Variables appelées par les conditions d'une clé.
variables_cle <- function(cle) {
  unique(unlist(lapply(cle$types, function(t) {
    variables_type(t)
  })))
}

# Variables que porte la chaîne en mode « variables fournies », une colonne par variable,
# une ligne par pixel : celles du producteur, puis la hauteur potentielle (h_pot, hpot,
# rapport_h), puis les couverts des strates. Les dernières l'emportent à nom égal.
variables_portees <- function(variables, hp, couverts = NULL) {
  out <- as.list(as.data.frame(variables))
  for (v in c("h_pot", "hpot", "rapport_h")) out[[v]] <- hp[[v]]
  if (!is.null(couverts)) for (v in names(couverts)) out[[v]] <- couverts[[v]]
  out
}

# Couverts des strates, une ligne par ligne de `variables` (NA pour un pixel sans
# couvert) : colonnes c1_<ref> à c4_<ref>, et densite_houppiers quand les houppiers
# servent. Méthode (mission 013) :
# - « tranches » : les quatre strates par les tranches de hauteur (mission 008) ;
# - « houppiers » : les quatre strates par les houppiers (vu du dessus) ;
# - « hybride » (défaut) : strate 1 par les houppiers, strates 2 à 4 par les tranches
#   corrigées de l'occlusion, sans les retours qui tombent dans les houppiers de la
#   strate 1 (décision de Pascal du 2026-11-23) : il faut pour cela une segmentation (ou
#   des dalles, segmentées ici) et des tranches calculées depuis les dalles avec elle,
#   ou des comptes qui l'ont déjà fait (colonnes r1_*).
# `strates` : liste `tranches` / `houppiers`, ou une seule source : table (ou .rds) de
# comptes (tranches), de couverts par houppiers (colonne n_houppiers), segmentation
# (segmenter_houppiers()), dalles de nuage de points (calculées ici, avec la référence
# prise dans la chaîne : hpot = h_pot / k ; hpot_k = h_pot ; h0 = h_dom), ou couverts
# déjà calculés (c1..c4 sans comptes) pris tels quels, quelle que soit la méthode.
# Colonne `part_retours_sous_s1` : part des retours du pixel qui passent sous la strate 1
# et servent aux strates 2 à 4 (sous_s1_<ref> des comptes, couvert_depuis_comptes()) ;
# vide si les tranches ne viennent pas de comptes (méthode « houppiers », couverts déjà
# calculés).
# Attributs : `methode` (celle appliquée, ou « fournis »), `parametres` (segmentation),
# `retrait_s1` (hybride : TRUE si les retours des houppiers de la strate 1 sont retirés,
# FALSE sinon, NA si on ne peut pas le savoir).
preparer_strates <- function(strates, variables, hp, reference, plancher_m = 1,
                             methode = "hybride", ncores = NULL) {
  if (!is.character(reference) || length(reference) != 1 || !nzchar(reference)) {
    arreter("reference_strates doit \u00eatre un nom de r\u00e9f\u00e9rence (hpot, hpot_k, h0)")
  }
  if (!is.character(methode) || length(methode) != 1 || !methode %in% METHODES_STRATES) {
    arreter(sprintf("methode_strates inconnue : %s (%s)", paste(methode, collapse = ", "),
                    paste(METHODES_STRATES, collapse = ", ")))
  }
  verifier_colonnes(variables, c("x", "y"), "les variables fournies (strates appari\u00e9es par x, y)")
  gabarit <- attr(variables, "gabarit")
  cols <- paste0("c", 1:4, "_", reference)
  refs_chaine <- list(hpot = hp$hpot, hpot_k = hp$h_pot, h0 = as.numeric(variables$h_dom))
  references <- function() {
    if (!reference %in% names(refs_chaine)) {
      arreter(sprintf("r\u00e9f\u00e9rence des strates inconnue de la cha\u00eene : %s (hpot, hpot_k, h0)",
                      reference))
    }
    refs <- data.frame(x = variables$x, y = variables$y)
    refs[[reference]] <- refs_chaine[[reference]]
    refs
  }

  # Sources : tranches et houppiers.
  src_t <- NULL
  src_h <- NULL
  if (is.list(strates) && !is.data.frame(strates) && !inherits(strates, "typo_houppiers") &&
      any(c("tranches", "houppiers") %in% names(strates))) {
    src_t <- strates$tranches
    src_h <- strates$houppiers
  } else {
    nat <- nature_strates(strates)
    if (nat == "couverts") {
      # Couverts déjà calculés : pris tels quels, la méthode est celle de leur auteur.
      cv <- lire_couverts_fournis(strates, reference)
      out <- apparier_couverts(cv, variables, gabarit)
      attr(out, "methode") <- "fournis"
      return(out)
    }
    if (nat == "dalles") {
      if (methode != "houppiers") src_t <- strates
      if (methode != "tranches") src_h <- strates
    } else if (nat %in% c("segmentation", "houppiers")) {
      src_h <- strates
    } else {
      src_t <- strates
    }
  }
  manque <- c(tranches = methode != "houppiers" && is.null(src_t),
              houppiers = methode != "tranches" && is.null(src_h))
  if (any(manque)) {
    arreter(sprintf(paste0(
      "m\u00e9thode des strates \u00ab %s \u00bb : couvert par %s manquant ; donner strates = ",
      "list(tranches = ..., houppiers = ...), des dalles, ou choisir methode_strates"),
      methode, paste(names(manque)[manque], collapse = " et ")))
  }

  # Segmentation : des dalles sont segmentées ici, en un seul exec. Une segmentation
  # unique sert aussi, en hybride, à retirer des tranches les retours des houppiers de la
  # strate 1.
  seg <- NULL
  if (methode != "tranches") {
    if (nature_strates(src_h) == "dalles") {
      if (is.null(gabarit)) arreter("houppiers : les variables doivent porter leur gabarit")
      src_h <- segmenter_houppiers(src_h, file.path(tempdir(), paste0("houppiers_", Sys.getpid())),
                                   ncores = ncores)
    }
    if (segmentation_unique(src_h)) seg <- src_h
  }
  sous <- paste0("sous_s1_", reference)
  cv_t <- NULL
  retrait <- NA
  if (methode != "houppiers") {
    if (nature_strates(src_t) == "dalles") {
      masque <- if (methode == "hybride") seg else NULL
      cv <- couverts_depuis_dalles(src_t, gabarit, references(), plancher_m = plancher_m,
                                   houppiers = masque)
      retrait <- !is.null(masque)
      cv <- as.data.frame(cv)[, c("x", "y", cols, sous)]
    } else {
      cv <- lire_couverts_fournis(src_t, reference)
      retrait <- attr(cv, "retrait_s1")
    }
    cv_t <- apparier_couverts(cv, variables, gabarit)
  }
  cv_h <- NULL
  if (methode != "tranches") {
    refs <- if (nature_strates(src_h) == "segmentation") references() else NULL
    cv_h <- couverts_houppiers_chaine(src_h, variables, refs, reference, gabarit, ncores = ncores)
  }
  out <- switch(methode,
    tranches = cv_t,
    houppiers = cv_h,
    hybride = {
      o <- cv_t
      o[[cols[1]]] <- cv_h[[cols[1]]]
      o$densite_houppiers <- cv_h$densite_houppiers
      o
    })
  part <- if (!is.null(cv_t) && sous %in% names(cv_t)) cv_t[[sous]] else rep(NA_real_, nrow(variables))
  out <- out[, setdiff(names(out), sous), drop = FALSE]
  out$part_retours_sous_s1 <- part
  attr(out, "methode") <- methode
  attr(out, "parametres") <- attr(cv_h, "parametres")
  attr(out, "retrait_s1") <- if (methode == "hybride") retrait else NA
  out
}

# Ligne de la fiche sur la méthode du couvert des strates (mission 013).
ligne_methode_strates <- function(methode, parametres = NULL) {
  if (is.null(methode)) return(character(0))
  seg <- if (is.null(parametres)) "" else sprintf(paste0(
    " Segmentation (PROVISOIRE) : MNH \u00e0 %s m, maxima locaux sur %s m, hauteur minimale %s m, ",
    "croissance de r\u00e9gions (lasR region_growing)."),
    format(parametres$resolution_m, decimal.mark = ","), format(parametres$fenetre_m, decimal.mark = ","),
    format(parametres$hauteur_min_m, decimal.mark = ","))
  switch(methode,
    hybride = paste0(
      "M\u00e9thode des strates : HYBRIDE. Strate 1 par les houppiers (chaque arbre rang\u00e9 par la ",
      "hauteur de sa cime, surface de ses houppiers) ; strates 2 \u00e0 4 par les tranches de ",
      "hauteur corrig\u00e9es de l'occlusion, sans les retours qui tombent dans les houppiers de ",
      "la strate 1 (mesur\u00e9es dans ses trou\u00e9es), ESTIM\u00c9ES : la couche de confiance porte ",
      "la part des retours qui passent sous la strate 1 et servent \u00e0 les mesurer ",
      "(part_retours_sous_s1, de 0 \u00e0 1 ; pr\u00e8s de 0, peu de retours).", seg),
    houppiers = paste0(
      "M\u00e9thode des strates : HOUPPIERS. Les quatre strates par les houppiers, vus du dessus : ",
      "les strates 2 \u00e0 4 sont masqu\u00e9es par les houppiers du dessus, sous-estim\u00e9es et ",
      "ESTIM\u00c9ES (part_retours_sous_s1 vide : pas de comptes de retours).", seg),
    tranches = paste0(
      "M\u00e9thode des strates : TRANCHES. Les quatre strates par les tranches de hauteur des retours ",
      "(mission 008), ESTIM\u00c9ES (part_retours_sous_s1 dans la couche de confiance) ; la ",
      "strate 1 y est sous-estim\u00e9e : la partie basse d'un houppier compte dans les strates ",
      "du dessous."),
    fournis = paste0(
      "M\u00e9thode des strates : couverts fournis, pris tels quels (m\u00e9thode de leur auteur, ",
      "non v\u00e9rifi\u00e9e par la cha\u00eene)."))
}

# Lignes de la fiche sur le couvert des strates : référence, part des pixels couverts,
# contrôle de c1 contre le taux de couvert du producteur (pas la somme des strates).
declarations_strates <- function(couverts, variables, non_prec, reference) {
  c1 <- couverts[[paste0("c1_", reference)]]
  pc <- !non_prec
  cc <- paste0("c", 1:4, "_", reference)
  avec <- stats::complete.cases(couverts[, cc, drop = FALSE]) & pc
  out <- sprintf(paste0(
    "Couvert des strates (GSM, quarts de la hauteur de r\u00e9f\u00e9rence) : r\u00e9f\u00e9rence %s, ",
    "PROVISOIRE ; couverts pour %s %% des pixels pr\u00e9comptables (%d sur %d) ; sans couvert, ",
    "les conditions des strates sont neutralis\u00e9es."),
    reference, format(round(100 * sum(avec) / max(1, sum(pc)), 1), decimal.mark = ","),
    sum(avec), sum(pc))
  out <- c(out, ligne_methode_strates(attr(couverts, "methode"), attr(couverts, "parametres")))
  if (identical(attr(couverts, "methode"), "hybride")) {
    r <- attr(couverts, "retrait_s1")
    if (isFALSE(r)) {
      out <- c(out, paste0(
        "ATTENTION : les retours qui tombent dans les houppiers de la strate 1 ne sont PAS ",
        "retir\u00e9s des strates 2 \u00e0 4 (comptes ou dalles sans segmentation unique) : ",
        "strate 2 surestim\u00e9e par la partie basse des houppiers de la strate 1."))
    } else if (is.na(r %||% NA)) {
      out <- c(out, paste0(
        "Strates 2 \u00e0 4 fournies d\u00e9j\u00e0 calcul\u00e9es : le retrait des retours tomb\u00e9s ",
        "dans les houppiers de la strate 1 n'est pas v\u00e9rifiable."))
    }
  }
  if (any(avec)) {
    somme <- rowSums(couverts[avec, cc, drop = FALSE])
    out <- c(out, sprintf(paste0(
      "Somme c1 + c2 + c3 + c4 (%s) : m\u00e9diane %s, au-del\u00e0 de 1 sur %s des pixels couverts. ",
      "Chaque strate a son propre couvert (strates superpos\u00e9es, comme au GSM) : la somme ",
      "peut d\u00e9passer 1."),
      reference, fmt_nombre(stats::median(somme)), fmt_pourcent(mean(somme > 1 + 1e-9))))
  }
  if ("part_retours_sous_s1" %in% names(couverts)) {
    q <- couverts$part_retours_sous_s1[pc]
    if (any(!is.na(q))) {
      out <- c(out, sprintf(paste0(
        "Part des retours qui passent sous la strate 1 (part_retours_sous_s1) : m\u00e9diane %s, ",
        "premier d\u00e9cile %s ; sous 0,1 pour %s des pixels pr\u00e9comptables mesur\u00e9s."),
        fmt_nombre(stats::median(q, na.rm = TRUE)),
        fmt_nombre(stats::quantile(q, 0.1, na.rm = TRUE, names = FALSE)),
        fmt_pourcent(mean(q[!is.na(q)] < 0.1))))
    }
  }
  if ("densite_houppiers" %in% names(couverts)) {
    d <- couverts$densite_houppiers[pc]
    ligne <- sprintf(paste0(
      "Densit\u00e9 des houppiers (sommets par hectare) : m\u00e9diane %s tiges/ha ; rendue pour ",
      "la lecture, elle ne sert pas \u00e0 la cl\u00e9 (le seuil de densit\u00e9 porte sur N du ",
      "producteur, d\u00e9cision du 2026-11-23)"),
      fmt_nombre(stats::median(d, na.rm = TRUE), 0))
    if ("N" %in% names(variables)) {
      n <- as.numeric(variables$N)[pc]
      ok <- !is.na(d) & !is.na(n)
      r <- if (sum(ok) >= 3 && stats::sd(d[ok]) > 0 && stats::sd(n[ok]) > 0) stats::cor(d[ok], n[ok]) else NA_real_
      ligne <- paste0(ligne, sprintf(" ; N du producteur : m\u00e9diane %s tiges/ha, r de Pearson %s (n = %d)",
                                     fmt_nombre(stats::median(n, na.rm = TRUE), 0), fmt_nombre(r), sum(ok)))
    }
    out <- c(out, paste0(ligne, "."))
  }
  if ("couvert" %in% names(variables)) {
    k <- controle_couvert_c1(c1[pc], as.numeric(variables$couvert)[pc])
    out <- c(out, sprintf(paste0(
      "Contr\u00f4le : c1_%s (couvert de la strate haute vu du dessus) contre le taux de ",
      "couvert du producteur : r de Pearson %s, de Spearman %s (n = %d). Corr\u00e9lation ",
      "mesur\u00e9e, sans seuil ; pas une validation."),
      reference, fmt_nombre(k$pearson), fmt_nombre(k$spearman), k$n))
  }
  out
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
#' `temps_lecture` des variables), `hauteur_potentielle`, `strates` (si `strates` est
#' donné), `cle`, `lissage`, `decision`, `controle` ; `ecriture_rasters` et `ecriture_tables` sont ajoutés par
#' [ecrire_livrables()].
#'
#' - Les pixels `non_precomptable` ne sont pas typés (type vide).
#' - Les souplesses du jeu (bloc `jeux.<jeu>.souplesse` de la configuration, le jeu étant
#'   nommé par la colonne `jeu` de l'attribut `couches`, voir [couches_onf()]) remplacent
#'   celles de la clé pour leurs variables : réglage du jeu, dit dans la fiche pour les
#'   variables que la clé utilise.
#' - Variables de la clé (mission 012) : la clé reçoit toute variable qu'elle cite et que
#'   la chaîne porte : celles de `variables` (dont `N`, densité de l'ONF), `h_pot`
#'   (hauteur potentielle avec l'enveloppe), `hpot` (sans l'enveloppe : h_pot / k de la
#'   famille, référence des strates par défaut), `rapport_h`, et les couverts des
#'   strates `c1_<ref>` à `c4_<ref>`. Une variable citée que la chaîne ne porte pas est
#'   vide : ses conditions sont neutralisées et la fiche la nomme.
#' - Couvert des strates (`strates`, voir [typer_peuplements()]) : rattaché aux pixels
#'   par `x`, `y` ; un pixel sans couvert a ses conditions de strates neutralisées. La
#'   fiche dit la référence (provisoire), la méthode (`methode_strates`, hybride par
#'   défaut) et les paramètres de segmentation (provisoires), la part des pixels couverts,
#'   et la corrélation de `c1_<ref>` (strate haute vue du dessus) avec le taux de couvert
#'   du producteur (`couvert`), sans seuil : un contrôle, pas une validation. Avec les
#'   houppiers, la carte porte `densite_houppiers` (tiges/ha, non passée à la clé) et la
#'   fiche la compare à `N`. La fiche dit aussi la somme `c1 + c2 + c3 + c4` (médiane,
#'   part au-delà de 1 : chaque strate a son propre couvert, la somme peut dépasser 1)
#'   et, en hybride, si les retours des houppiers de la strate 1 ont été retirés des
#'   strates 2 à 4. Les strates basses sont estimées : la carte porte
#'   `part_retours_sous_s1` (de 0 à 1, remplace le drapeau booléen
#'   `strates_basses_estimees`, décision de Pascal du 2026-11-23), la part des retours
#'   du pixel qui passent sous la strate 1 (sous 3/4 H, sol compris) et servent aux
#'   strates 2 à 4, hors houppiers de la strate 1 en hybride ; près de 0, les strates
#'   basses reposent sur très peu de retours. Vide si les tranches ne viennent pas de
#'   comptes ; absente pour des couverts fournis tout faits.
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
#'   La fiche donne aussi, par famille, le seuil de hauteur potentielle auquel revient le
#'   drapeau `hp_incertaine` (`h_pot` < enveloppe × RMSE / `incertitude_relative_max`).
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
#' @param strates,reference_strates,modele_hp,methode_strates Voir [typer_peuplements()].
#' @param plancher_m Bas de la strate 4, quand le couvert est calculé depuis des dalles
#'   ([comptes_strates()]). **Provisoire** : 1 m.
#' @return Objet `typo_resultat` : `carte`, `fiche_validation` (sans placette ni grappe,
#'   avec `controle` et `declarations`), `niveau_modele` (`"producteur"`), `ser`, `cle`
#'   (souplesses du jeu comprises), `temps` (`etage`, `secondes`, `pixels`), `gabarit`.
#' @seealso [typer_peuplements()], [controle_coherence()]
#' @export
executer_chaine_fournie <- function(variables, conf, milieu = NULL, strates = NULL,
                                    reference_strates = "hpot", modele_hp = NULL,
                                    plancher_m = 1, methode_strates = "hybride") {
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
  if (!is.null(modele_hp)) {
    if (is.null(milieu)) arreter("modele_hp donn\u00e9 sans milieu : la hauteur potentielle ne peut pas \u00eatre pr\u00e9dite")
    vm <- modele_hp$variables_milieu
  }
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
      mhp <- if (!is.null(modele_hp)) modele_hp else {
        tryCatch(modele_hp_depuis_conf(df[!non_prec, , drop = FALSE], conf, vm),
                 typo_erreur = function(e) {
                   if (!grepl("trop peu de peuplements adultes", conditionMessage(e))) stop(e)
                   NULL
                 })
      }
      if (is.null(mhp)) {
        data.frame(h_pot = rep(NA_real_, n), h_pot_sd = NA_real_, rapport_h = NA_real_,
                   hp_incertaine = TRUE)
      } else predire_hauteur_potentielle(mhp, df)
    }
  })
  # Dispersion des arbres de la forêt (pas une erreur de prédiction), rendue à part.
  hp$sd_arbres <- attr(hp, "sd_arbres") %||% rep(NA_real_, n)
  # Hauteur potentielle sans l'enveloppe (h_pot / k de la famille), exposée à la clé sous
  # le nom `hpot` : c'est la référence des strates par défaut (décision du 2026-11-22).
  hp$hpot <- if (is.null(mhp)) rep(NA_real_, n) else {
    hpot_sans_enveloppe(hp$h_pot, if ((mhp$famille %||% "") %in% names(variables)) {
      variables[[mhp$famille]]
    } else NULL, mhp$facteur)
  }
  if (is.null(milieu)) {
    declarations <- c(declarations, paste0(
      "Hauteur potentielle vide et signal\u00e9e partout (milieu non fourni) : ",
      "rapport_h neutralis\u00e9 dans la cl\u00e9."))
  } else if (is.null(mhp)) {
    declarations <- c(declarations, paste0(
      "Hauteur potentielle vide et signal\u00e9e partout (trop peu de peuplements adultes ",
      "ferm\u00e9s dans l'emprise pour l'apprendre) : rapport_h neutralis\u00e9 dans la cl\u00e9."))
  } else {
    if (!is.null(modele_hp)) {
      declarations <- c(declarations, paste0(
        "Hauteur potentielle : mod\u00e8le fourni (modele_hp), appris hors de l'emprise ",
        "(par exemple sur le massif) puis appliqu\u00e9 \u00e0 ses pixels."))
    }
    declarations <- c(declarations, declarations_milieu(milieu, vm, conf, couches, mhp,
                                                        hp$hp_incertaine[!non_prec]))
  }

  # 1 bis. Couvert des strates (GSM), par pixel, pour la référence choisie.
  couverts <- NULL
  if (!is.null(strates)) {
    couverts <- chronometrer(chrono, "strates", n, {
      preparer_strates(strates, variables, hp, reference_strates, plancher_m,
                       methode = methode_strates)
    })
    declarations <- c(declarations, declarations_strates(couverts, variables, non_prec,
                                                         reference_strates))
  }

  # 2. Clé floue sur les pixels précomptables. La clé reçoit toute variable qu'elle cite
  # et que la chaîne porte : celles du producteur (dont N), la hauteur potentielle
  # (h_pot, hpot, rapport_h), les couverts des strates. Une variable citée que la chaîne
  # ne porte pas est vide : ses conditions sont neutralisées (groupe de types, drapeau
  # entre_deux), et la fiche la nomme.
  ok <- which(!non_prec)
  vars <- variables_cle(cle)
  # La densité des houppiers est rendue mais ne sert pas à la clé (décision du 2026-11-23) ;
  # la part des retours sous la strate 1 va à la couche de confiance.
  estimees <- NULL
  if (!is.null(couverts) && "part_retours_sous_s1" %in% names(couverts)) {
    estimees <- data.frame(part_retours_sous_s1 = couverts$part_retours_sous_s1)
    couverts <- couverts[, setdiff(names(couverts), "part_retours_sous_s1"), drop = FALSE]
  }
  portees <- variables_portees(variables, hp, couverts[setdiff(names(couverts), "densite_houppiers")])
  absentes <- sort(setdiff(vars, names(portees)))
  if (length(absentes) > 0) {
    declarations <- c(declarations, sprintf(paste0(
      "Variables de la cl\u00e9 absentes de la cha\u00eene : %s ; leurs conditions sont ",
      "neutralis\u00e9es (groupe de types, drapeau entre_deux)."), paste(absentes, collapse = ", ")))
  }
  probas <- chronometrer(chrono, "cle", length(ok), {
    entree <- as.data.frame(lapply(stats::setNames(vars, vars), function(v) {
      if (v %in% names(portees)) as.numeric(portees[[v]][ok]) else rep(NA_real_, length(ok))
    }))
    appartenances_types(cle, entree)
  })
  hors_cle <- attr(probas, "hors_cle")
  touche_na <- attr(probas, "touche_na")
  attr(probas, "hors_cle") <- NULL
  attr(probas, "touche_na") <- NULL

  # 3. Lissage à l'échelle de lecture. Un pixel hors clé (aucun type ne le décrit, par
  # exemple couvert < 0,1) a un poids nul : ses probabilités égales ne diluent pas celles
  # de ses voisins, et il ne leur en emprunte pas (aller-retour 1/3 de la mission 012).
  probas <- chronometrer(chrono, "lissage", length(ok), {
    lisser_probabilites(probas, variables$i[ok], variables$j[ok], conf$lissage_fenetre %||% 3,
                        poids = as.numeric(!hors_cle))
  })

  # 4. Décision et assemblage de la carte (une ligne par pixel, vide hors précomptable).
  carte <- chronometrer(chrono, "decision", length(ok), {
    # Variable absente : les types qui ne se départagent que par elle forment un groupe.
    dec <- decider_type(probas, as.numeric(cle$marge_entre_deux %||% 0.15), touche_na = touche_na)
    codes <- names(probas)
    tout <- data.frame(type = rep(NA_character_, n), proba = NA_real_,
                       type_second = NA_character_, proba_second = NA_real_,
                       entre_deux = NA, hors_cle = NA, stringsAsFactors = FALSE)
    # Hors clé : pas de type. Type, probabilités et entre_deux restent vides ; seul le
    # drapeau hors_cle est porté.
    dec[hors_cle, c("type", "type_second")] <- NA_character_
    dec[hors_cle, c("proba", "proba_second")] <- NA_real_
    dec$entre_deux[hors_cle] <- NA
    tout[ok, c("type", "proba", "type_second", "proba_second", "entre_deux")] <- dec
    tout$hors_cle[ok] <- hors_cle
    p_cols <- as.data.frame(matrix(NA_real_, n, length(codes)))
    names(p_cols) <- paste0("p_", codes)
    pm <- as.matrix(probas)
    pm[hors_cle, ] <- NA_real_
    p_cols[ok, ] <- pm
    xy <- if (all(c("x", "y") %in% names(variables))) {
      data.frame(x = variables$x, y = variables$y)
    } else NULL
    gardees <- intersect(c("G", "part_resineux", "part_pb", "part_bm", "part_gb", "N", "h_dom",
                           "couvert", "famille", "typo_etage"), names(variables))
    morceaux <- list(data.frame(i = variables$i, j = variables$j), xy, tout,
                     as.data.frame(variables)[, gardees, drop = FALSE],
                     hp[, c("h_pot", "hpot", "h_pot_sd", "rapport_h", "hp_incertaine", "sd_arbres")],
                     couverts,
                     estimees,
                     data.frame(non_precomptable = non_prec, part_pb_absente = pb_absente,
                                gb_interim = gb_interim & !non_prec),
                     p_cols)
    out <- do.call(cbind, morceaux[!vapply(morceaux, is.null, logical(1))])
    rownames(out) <- NULL
    out
  })

  declarations <- c(declarations, declarations_repartition(carte$type[ok], hors_cle))

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

# Déclarations de la fiche : part des pixels hors clé (sans type) et répartition des types
# sur les pixels précomptables typés.
declarations_repartition <- function(types, hors_cle) {
  n <- length(types)
  if (n == 0) return(character(0))
  out <- sprintf(paste0("Pixels hors cl\u00e9 (aucun type de la cl\u00e9 ne les d\u00e9crit, ",
                        "par exemple couvert trop faible) : %s des pixels pr\u00e9comptables ",
                        "(%d sur %d) ; ils n'ont pas de type (drapeau hors_cle) et ne comptent ",
                        "pas dans le lissage de leurs voisins."),
                 fmt_pourcent(mean(hors_cle)), sum(hors_cle), n)
  typ <- types[!is.na(types)]
  if (length(typ) > 0) {
    tab <- sort(table(typ), decreasing = TRUE)
    out <- c(out, paste0("R\u00e9partition des types (pixels typ\u00e9s, n = ", length(typ), ") : ",
                         paste(sprintf("%s %s", names(tab), vapply(as.numeric(tab) / length(typ), fmt_pourcent, character(1))),
                               collapse = " ; "), "."))
  }
  out
}

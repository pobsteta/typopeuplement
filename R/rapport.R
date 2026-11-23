# Rapport Quarto de l'AOI (mission 015) : cartes des types, couche de confiance, etat de
# preuve, limites. Le rapport ne calcule rien de nouveau : il lit les livrables ecrits par
# ecrire_livrables() (types.tif, confiance.tif, variables.tif, fiche_validation.md,
# correspondance_types.csv) et, s'ils existent, ceux d'une autre legende (types_srgs.tif et
# correspondance_types_srgs.csv, mission 018 : convention supposee, a confirmer par 018).
# Les tables sont calculees ici (testables) puis ecrites en CSV ; le modele .qmd les lit.

# Etiquettes lisibles des couches de drapeaux (confiance.tif, types.tif).
etiquettes_drapeaux <- function() {
  data.frame(
    couche = c("entre_deux", "hp_incertaine", "hors_cle", "non_precomptable",
               "part_pb_absente", "gb_interim", "strates_basses_estimees"),
    drapeau = c("Entre deux types (\u00e9cart d'appartenance faible)",
                "Hauteur potentielle incertaine",
                "Hors cl\u00e9 (aucun type de la cl\u00e9 ne convient)",
                "Non pr\u00e9comptable (tiges sous le seuil de pr\u00e9comptage)",
                "Part de petits bois absente",
                "Gros bois provisoire (interim)",
                "Strates basses estim\u00e9es, non mesur\u00e9es"),
    stringsAsFactors = FALSE
  )
}

#' Chemin du modèle de rapport Quarto
#'
#' Le fichier `rapport.qmd` du paquet. Le pipeline le suit comme fichier : quand il change,
#' le rapport est périmé et se refait (`targets::tar_outdated()`).
#'
#' @return Chemin du modèle (chaîne vide s'il est introuvable).
#' @export
modele_rapport <- function() {
  system.file("rapport", "rapport.qmd", package = "typopeuplement")
}

# Legendes disponibles dans un dossier de livrables : types.tif (cle de la configuration,
# GSM pour H10) et types_<legende>.tif (SRGS : types_srgs.tif, mission 018).
legendes_livrables <- function(dossier, etiquette_types = "Type GSM (H10)") {
  fichiers <- list.files(dossier, pattern = "^types(_[A-Za-z0-9]+)?\\.tif$")
  if (length(fichiers) == 0) return(data.frame(id = character(), raster = character(),
                                               table = character(), titre = character(),
                                               stringsAsFactors = FALSE))
  id <- ifelse(fichiers == "types.tif", "types", sub("^types_(.*)\\.tif$", "\\1", fichiers))
  suff <- ifelse(id == "types", "", paste0("_", id))
  titre <- ifelse(id == "types", etiquette_types,
                  ifelse(id == "srgs", "Type SRGS (8 types)", paste("Type", toupper(id))))
  d <- data.frame(id = id, raster = file.path(dossier, fichiers),
                  table = file.path(dossier, paste0("correspondance_types", suff, ".csv")),
                  titre = titre, stringsAsFactors = FALSE)
  d[order(d$id != "srgs", d$id != "types"), , drop = FALSE]  # SRGS, puis GSM, puis le reste
}

# Part de chaque type de la legende `id` (comptage direct des pixels).
parts_types <- function(raster, table) {
  r <- terra::rast(raster)[["type"]]
  v <- terra::values(r, mat = FALSE)
  v <- v[!is.na(v)]
  corr <- if (file.exists(table)) utils::read.csv(table, fileEncoding = "UTF-8",
                                                  stringsAsFactors = FALSE) else
    data.frame(valeur = sort(unique(v)), code = as.character(sort(unique(v))),
               libelle = "", stringsAsFactors = FALSE)
  n <- vapply(corr$valeur, function(k) sum(v == k), numeric(1))
  data.frame(code = corr$code, libelle = corr$libelle, pixels = n,
             part = if (length(v)) n / length(v) else NA_real_, stringsAsFactors = FALSE)
}

# Part des pixels portant chaque drapeau (couches 0/1 de confiance.tif et types.tif).
resume_drapeaux <- function(dossier) {
  et <- etiquettes_drapeaux()
  sortie <- list()
  for (f in c("types.tif", "confiance.tif")) {
    chemin <- file.path(dossier, f)
    if (!file.exists(chemin)) next
    r <- terra::rast(chemin)
    for (couche in intersect(et$couche, names(r))) {
      v <- terra::values(r[[couche]], mat = FALSE)
      v <- v[!is.na(v)]
      sortie[[couche]] <- data.frame(
        couche = couche, drapeau = et$drapeau[et$couche == couche], pixels = length(v),
        part = if (length(v)) mean(v > 0) else NA_real_, stringsAsFactors = FALSE)
    }
  }
  if (length(sortie) == 0) return(data.frame(couche = character(), drapeau = character(),
                                             pixels = numeric(), part = numeric()))
  do.call(rbind, unname(sortie))
}

# Types d'une legende que la configuration dit non exprimables (cle$non_exprimables).
types_non_exprimables <- function(configuration, ser) {
  if (is.null(configuration) || !file.exists(configuration)) return(character())
  conf <- jsonlite::fromJSON(configuration, simplifyVector = FALSE)
  ne <- conf$ser[[ser]]$cle$non_exprimables
  vapply(ne, function(t) paste0(t$code, " (", t$libelle, ")"), character(1))
}

#' Table « état de preuve » d'une carte
#'
#' Pour chaque chiffre du rapport : s'il est **mesuré** (compté directement sur les
#' livrables), **provisoire** (valeur ou réglage non gelé, sortie non calibrée) ou
#' **non vérifié** (rien ne le confronte à la réalité). Il n'y a aucune validation
#' indépendante : aucune placette publiée dans H10 (ADR 0006, 0010). Le nombre associé au
#' type s'appelle *appartenance* tant qu'il n'est pas calibré (arbitrage C12).
#'
#' @param dossier Dossier des livrables de l'AOI ([ecrire_livrables()]).
#' @param demo `TRUE` pour un jeu synthétique : tout chiffre est alors sans valeur sur
#'   données réelles.
#' @return Un `data.frame` : `chiffre`, `statut` (`mesure`, `provisoire`, `non verifie`
#'   avec accents dans le rapport), `commentaire`.
#' @export
etat_de_preuve <- function(dossier, demo = FALSE) {
  ligne <- function(chiffre, statut, commentaire)
    data.frame(chiffre = chiffre, statut = statut, commentaire = commentaire,
               stringsAsFactors = FALSE)
  mesure <- "mesur\u00e9"; prov <- "provisoire"; nv <- "non v\u00e9rifi\u00e9"
  fiche <- file.path(dossier, "fiche_validation.md")
  txt <- if (file.exists(fiche)) readLines(fiche, encoding = "UTF-8", warn = FALSE) else character()
  sans_placette <- any(grepl("pas de validation", txt)) || !any(grepl("Effectif", txt))
  lignes <- list()
  if (demo) {
    lignes <- c(lignes, list(ligne(
      "Tous les chiffres de ce rapport", nv,
      "Jeu synth\u00e9tique et cl\u00e9 d'exemple : d\u00e9monstration du pipeline, aucune for\u00eat r\u00e9elle.")))
  }
  lignes <- c(lignes, list(
    ligne("Validation ind\u00e9pendante de la carte", nv,
          paste("Aucune validation ind\u00e9pendante : aucune placette publi\u00e9e dans H10",
                "(ADR 0010). La carte est produite, non valid\u00e9e.")),
    ligne("Nombre de pixels, part de chaque type, part de chaque drapeau", mesure,
          "Comptage direct sur les rasters livr\u00e9s ; ce n'est pas une exactitude."),
    ligne("Type d'un pixel", nv,
          "Sortie de la cl\u00e9 appliqu\u00e9e aux variables mod\u00e9lis\u00e9es ; non confront\u00e9e \u00e0 des relev\u00e9s ind\u00e9pendants."),
    ligne("Appartenance au type", prov,
          "Non calibr\u00e9e : ce n'est pas une probabilit\u00e9 (arbitrage C12) ; \u00e0 lire en ordre, pas en valeur."),
    ligne("Seuils de la cl\u00e9 (diam\u00e8tre, couvert, hauteur)", prov,
          "Seuils par r\u00e9f\u00e9rentiel (ADR 0007), certains encore provisoires dans la configuration."),
    ligne("Hauteur potentielle", prov,
          "Mod\u00e8le appris sur les adultes ferm\u00e9s ; H0 du jeu ONF non calibr\u00e9e (fiche ONF, p. 2).")))
  if (sans_placette) {
    lignes <- c(lignes, list(ligne(
      "Pr\u00e9cision et kappa", nv,
      if (demo) "Calcul\u00e9s sur placettes synth\u00e9tiques : sans valeur sur donn\u00e9es r\u00e9elles."
      else "La fiche de validation n'a pas de placettes : pas de pr\u00e9cision, pas de kappa.")))
  } else {
    lignes <- c(lignes, list(ligne(
      "Pr\u00e9cision et kappa de la fiche de validation", if (demo) nv else prov,
      if (demo) "Calcul\u00e9s sur placettes synth\u00e9tiques : sans valeur sur donn\u00e9es r\u00e9elles."
      else "Validation crois\u00e9e sur les placettes de calibration : pas une validation ind\u00e9pendante.")))
  }
  do.call(rbind, lignes)
}

#' Section « Limites » d'une carte
#'
#' Limites tirées des drapeaux des livrables, de la fiche de validation et, s'il existe,
#' du fichier `journal_aoi.md` du dossier (une limite par ligne commençant par `- `), et
#' des types non exprimables déclarés par la configuration.
#'
#' @inheritParams etat_de_preuve
#' @param configuration Chemin du JSON de configuration (optionnel) : sert à lister les
#'   types de la légende que la chaîne ne sait pas exprimer.
#' @param ser Nom de la SER dans la configuration.
#' @return Vecteur de phrases.
#' @export
limites_rapport <- function(dossier, demo = FALSE, configuration = NULL, ser = "H10") {
  pct <- function(x) paste0(formatC(100 * x, format = "f", digits = 1, decimal.mark = ","), " %")
  lim <- c("La carte est une aide \u00e0 la d\u00e9cision, pas un diagnostic : elle ne remplace pas la visite de terrain (typologie descriptive).",
           "Pas de validation ind\u00e9pendante : aucune placette publi\u00e9e dans H10 ; la carte est produite et non valid\u00e9e.")
  if (demo) lim <- c("Jeu synth\u00e9tique et cl\u00e9 d'exemple : aucune de ces cartes ne d\u00e9crit une for\u00eat r\u00e9elle.", lim)
  dr <- resume_drapeaux(dossier)
  part <- function(couche) { x <- dr$part[dr$couche == couche]; if (length(x)) x else NA_real_ }
  v <- file.path(dossier, "variables.tif")
  noms_var <- if (file.exists(v)) names(terra::rast(v)) else character()
  if ("densite_houppiers" %in% noms_var) {
    lim <- c(lim, paste("Houppiers : la densit\u00e9 de tiges vient d'une segmentation du mod\u00e8le de canop\u00e9e",
                        "(param\u00e8tres provisoires) ; les tiges domin\u00e9es sous le couvert sont mal vues."))
  }
  s <- part("strates_basses_estimees")
  if (!is.na(s)) lim <- c(lim, paste0("Strates basses : ", pct(s), " des pixels ont des strates basses estim\u00e9es, non mesur\u00e9es."))
  h <- part("hors_cle")
  if (!is.na(h)) lim <- c(lim, paste0("Hors cl\u00e9 : ", pct(h), " des pixels ne correspondent \u00e0 aucun type de la cl\u00e9."))
  e <- part("entre_deux")
  if (!is.na(e)) lim <- c(lim, paste0("Entre deux types : ", pct(e), " des pixels, o\u00f9 le second type est presque aussi plausible que le premier."))
  hp <- part("hp_incertaine")
  if (!is.na(hp)) lim <- c(lim, paste0("Hauteur potentielle incertaine sur ", pct(hp), " des pixels : les types qui en d\u00e9pendent y sont moins s\u00fbrs."))
  for (lg in seq_len(nrow(leg <- legendes_livrables(dossier)))) {
    p <- parts_types(leg$raster[lg], leg$table[lg])
    absents <- p$code[p$pixels == 0]
    if (length(absents) > 0)
      lim <- c(lim, paste0(leg$titre[lg], " : types de la l\u00e9gende absents de la carte : ",
                           paste(absents, collapse = ", "), "."))
  }
  ne <- types_non_exprimables(configuration, ser)
  if (length(ne) > 0)
    lim <- c(lim, paste0("Types non exprimables par la cha\u00eene (donn\u00e9es absentes) : ",
                         paste(ne, collapse = " ; "), "."))
  fiche <- file.path(dossier, "fiche_validation.md")
  if (file.exists(fiche)) {
    txt <- readLines(fiche, encoding = "UTF-8", warn = FALSE)
    i <- grep("^## D\u00e9clarations", txt)
    if (length(i) > 0) {
      reste <- txt[(i[1] + 1):length(txt)]
      fin <- grep("^## ", reste)
      if (length(fin) > 0) reste <- reste[seq_len(fin[1] - 1)]
      lim <- c(lim, paste0("Fiche de validation : ", sub("^- ", "", reste[grepl("^- ", reste)])))
    }
  }
  jr <- file.path(dossier, "journal_aoi.md")
  if (file.exists(jr)) {
    txt <- readLines(jr, encoding = "UTF-8", warn = FALSE)
    lim <- c(lim, paste0("Journal : ", sub("^- ", "", txt[grepl("^- ", txt)])))
  }
  lim
}

#' Écrire les tables du rapport
#'
#' Calcule les tables que lit le modèle de rapport (état de preuve, limites, parts de
#' types, drapeaux) et les écrit en CSV dans `sortie`. Ne modifie jamais `dossier`.
#'
#' @inheritParams limites_rapport
#' @param sortie Dossier où écrire les tables (créé au besoin).
#' @return La liste des chemins écrits, invisible.
#' @export
tables_rapport <- function(dossier, sortie, demo = FALSE, configuration = NULL, ser = "H10") {
  dir.create(sortie, recursive = TRUE, showWarnings = FALSE)
  ecr <- function(x, nom) {
    f <- file.path(sortie, nom)
    utils::write.csv(x, f, row.names = FALSE, fileEncoding = "UTF-8")
    f
  }
  chemins <- c(
    ecr(etat_de_preuve(dossier, demo), "etat_de_preuve.csv"),
    ecr(data.frame(limite = limites_rapport(dossier, demo, configuration, ser),
                   stringsAsFactors = FALSE), "limites.csv"),
    ecr(resume_drapeaux(dossier), "drapeaux.csv"))
  leg <- legendes_livrables(dossier)
  for (k in seq_len(nrow(leg)))
    chemins <- c(chemins, ecr(parts_types(leg$raster[k], leg$table[k]),
                              paste0("parts_", leg$id[k], ".csv")))
  invisible(chemins)
}

#' Rendre le rapport Quarto d'une AOI
#'
#' Écrit les tables ([tables_rapport()]), copie le modèle ([modele_rapport()]) dans
#' `sortie` et le rend en HTML autonome avec Quarto. Ne lance aucun calcul de chaîne ni de
#' LiDAR : il lit les livrables déjà écrits. `dossier` n'est jamais modifié.
#'
#' @inheritParams tables_rapport
#' @param sortie Dossier du rapport (par défaut `dossier`).
#' @param titre_aoi Nom de l'AOI affiché en titre.
#' @param etiquette_types Titre de la légende de `types.tif`.
#' @param modele Modèle `.qmd` (par défaut [modele_rapport()]).
#' @return Chemin du `rapport.html`.
#' @export
rendre_rapport <- function(dossier, sortie = dossier, demo = FALSE,
                           titre_aoi = "AOI", etiquette_types = "Type GSM (H10)",
                           configuration = NULL, ser = "H10", modele = modele_rapport()) {
  if (!requireNamespace("quarto", quietly = TRUE) || is.null(quarto::quarto_path()))
    stop("Quarto est requis pour rendre le rapport (paquet quarto et CLI quarto).", call. = FALSE)
  if (!nzchar(modele) || !file.exists(modele)) stop("Mod\u00e8le de rapport introuvable.", call. = FALSE)
  if (!file.exists(file.path(dossier, "types.tif")))
    stop("Livrables absents : pas de types.tif dans ", dossier, ".", call. = FALSE)
  dir.create(sortie, recursive = TRUE, showWarnings = FALSE)
  dossier <- normalizePath(dossier); sortie <- normalizePath(sortie)
  tables_rapport(dossier, sortie, demo, configuration, ser)
  qmd <- file.path(sortie, "rapport.qmd")
  file.copy(modele, qmd, overwrite = TRUE)
  legendes <- legendes_livrables(dossier, etiquette_types)
  quarto::quarto_render(qmd, output_format = "html", quiet = TRUE, execute_params = list(
    dossier = dossier, tables = sortie, demo = isTRUE(demo), titre_aoi = titre_aoi,
    etiquette_types = etiquette_types))
  html <- file.path(sortie, "rapport.html")
  if (!file.exists(html)) stop("Le rendu n'a pas produit rapport.html.", call. = FALSE)
  html
}

#' Cibles `targets` du rapport
#'
#' Trois cibles : `modele` (le `.qmd`, suivi comme fichier : s'il change, le rapport est
#' périmé), `livrables` (mode démonstration : chaîne sur le jeu synthétique, sans réseau ;
#' mode réel : suivi des fichiers d'un dossier déjà calculé, **aucun calcul LiDAR**) et
#' `rapport` (le HTML). À placer dans le `_targets.R`.
#'
#' @param aoi `NULL` (démonstration) ou chemin des livrables d'une AOI déjà calculée.
#' @param sortie Dossier de travail du pipeline (rapport et, en démonstration, livrables).
#' @param modele Chemin du modèle `.qmd`.
#' @param titre_aoi,etiquette_types,configuration,ser Voir [rendre_rapport()].
#' @return Une liste de cibles.
#' @export
cibles_rapport <- function(aoi = NULL, sortie = "sorties/rapport", modele = modele_rapport(),
                           titre_aoi = if (is.null(aoi)) "D\u00e9monstration (jeu synth\u00e9tique)" else "AOI",
                           etiquette_types = if (is.null(aoi)) "Type (cl\u00e9 d'exemple, pas une typologie)" else "Type GSM (H10)",
                           configuration = NULL, ser = "H10") {
  demo <- is.null(aoi)
  livr <- if (demo) file.path(sortie, "livrables") else aoi
  if (!requireNamespace("targets", quietly = TRUE)) stop("Le paquet targets est requis.", call. = FALSE)
  cible_livrables <- if (demo) {
    targets::tar_target_raw("livrables", bquote({
      # Jeu synthetique et cle d'exemple de la chaine, sans reseau.
      typopeuplement::lancer_demo(.(livr), graine = 0)
      list.files(.(livr), full.names = TRUE)
    }), format = "file")
  } else {
    targets::tar_target_raw("livrables", bquote(
      list.files(.(aoi), pattern = "\\.(tif|csv|md)$", full.names = TRUE)), format = "file")
  }
  list(
    targets::tar_target_raw("modele", bquote(.(modele)), format = "file"),
    cible_livrables,
    targets::tar_target_raw("rapport", bquote({
      livrables; modele
      typopeuplement::rendre_rapport(
        .(livr), sortie = .(sortie), demo = .(demo), titre_aoi = .(titre_aoi),
        etiquette_types = .(etiquette_types), configuration = .(configuration),
        ser = .(ser), modele = modele)
    }), format = "file")
  )
}

# Point d'entrée, livrables et démonstration (cli.py du prototype).

#' Typer les peuplements d'une emprise
#'
#' Point d'entrée de la chaîne : produit la carte du type de peuplement d'une emprise
#' (AOI), sa couche de confiance et la fiche de validation de la SER.
#'
#' Deux modes tournent aujourd'hui :
#' - **pixels préparés** : `aoi` est un data.frame de pixels (les colonnes décrites dans
#'   [executer_chaine()]), avec `placettes` et `ser` donnés ; les variables sont prédites
#'   par des modèles calibrés sur les placettes, et validées sur elles ;
#' - **variables fournies** (mission 006) : `variables` est un data.frame de pixels dont
#'   les variables viennent d'un producteur, par exemple les paramètres forestiers LiDAR
#'   de l'ONF lus par [lire_parametres_lidar()]. Pas d'ajustement dendrométrique, pas de
#'   placettes, donc pas de validation (voir [executer_chaine_fournie()]). `aoi` peut
#'   alors être `NULL` (toutes les lignes de `variables`) ou un objet `sf` (seuls les
#'   pixels dont le centre `x`, `y` tombe dedans sont gardés).
#'
#' Pixels préparés sans colonnes `x`, `y` : les centres des pixels sont pris à
#' `x = i × taille_pixel`, `y = j × taille_pixel` (convention du jeu synthétique, voir
#' [ecrire_livrables()]). Pour de vraies données, donner `x`, `y` en Lambert-93.
#'
#' Ce qui reste en attente (arrêt net, message dit) :
#' - `aoi` en `sf` ou chemin de GeoPackage : la SER est localisée par
#'   `nemeton::localiser_ser()` (nemeton en Suggests), puis arrêt : la lecture des
#'   données ouvertes (LiDAR HD, Sentinel-2, BD Forêt v3, climat, sol) n'est pas écrite ;
#' - `placettes = NULL` : arrêt, les modèles de grande région ne sont pas disponibles ;
#' - `ser = NULL` avec un data.frame : arrêt, la SER ne se devine pas.
#'
#' La typologie est descriptive : la carte aide à décider, elle ne remplace pas le
#' diagnostic de terrain. Vérifier en priorité les pixels « entre deux types ».
#'
#' @param aoi Emprise : data.frame de pixels préparés, objet `sf` ou chemin de GeoPackage
#'   (Lambert-93).
#' @param placettes data.frame des placettes de calibration (voir [executer_chaine()]).
#' @param ser Nom de la SER dans la configuration.
#' @param configuration Chemin du fichier JSON de configuration ([lire_configuration()]).
#' @param sortie Dossier où écrire les livrables ([ecrire_livrables()]) ; `NULL` : rien
#'   n'est écrit.
#' @param graine Graine du hasard ; remplace celle de la configuration.
#' @param variables data.frame de pixels aux variables fournies
#'   ([lire_parametres_lidar()]) ; `NULL` : mode « pixels préparés ».
#' @param milieu En mode « variables fournies », data.frame des variables de milieu
#'   (une ligne par ligne de `variables`) pour la hauteur potentielle, par exemple le
#'   relief tiré du MNT de l'IGN ([milieu_pixels()]) ; ses attributs `variables_milieu`
#'   et `source` disent ce que voit la hauteur potentielle (sinon les
#'   `variables_milieu` de la configuration) ; `NULL` : hauteur potentielle vide et
#'   signalée partout.
#' @param strates En mode « variables fournies », couvert des strates du GSM pour la
#'   clé (colonnes `c1_<ref>` à `c4_<ref>`, `<ref>` étant `reference_strates`), calculé
#'   selon `methode_strates` :
#'   - `NULL` : pas de couvert ; une clé qui cite les strates les neutralise (groupe de
#'     types, drapeau `entre_deux`) et la fiche le dit ;
#'   - `list(tranches = ..., houppiers = ...)` : les deux sources du mode hybride ;
#'     `tranches` prend les formes ci-dessous (comptes, `.rds`, dalles) ; `houppiers` est
#'     une table de [couvert_houppiers()] (ou son `.rds`), une segmentation de
#'     [segmenter_houppiers()] (le couvert est alors calculé avec la référence de la
#'     chaîne), ou des dalles ;
#'   - une table de [couvert_houppiers()] ou une segmentation seule : source houppiers ;
#'   - un data.frame de [couvert_depuis_comptes()] (ou de [comptes_strates()] avec `x`,
#'     `y`), ou les chemins de fichiers `.rds` qui en contiennent (par exemple les
#'     comptes de [couvert_strates_dalle()], une dalle par fichier : ils sont
#'     additionnés) ; les lignes sont rattachées aux pixels par leurs coordonnées `x`,
#'     `y` (Lambert-93) ; ces couverts doivent avoir été calculés avec la même hauteur de
#'     référence que la chaîne (même milieu, même modèle de hauteur potentielle) ;
#'   - les chemins de dalles de nuage de points (`.las`, `.laz`, `.copc.laz`) : le couvert
#'     est calculé ici, avec la référence tirée de la chaîne (lasR requis ; choisir les
#'     dalles avec [dalles_sur_aoi()]) : tranches une dalle à la fois, houppiers en un
#'     seul `exec` avec tampon ([segmenter_houppiers()], paramètres par défaut) ; en
#'     hybride, la segmentation sert à retirer des tranches les retours des houppiers de
#'     la strate 1 ;
#'   - un data.frame de couverts déjà calculés (`c1_<ref>` à `c4_<ref>`, sans comptes
#'     ni `n_houppiers`) : pris tels quels, quelle que soit `methode_strates` (la fiche
#'     le dit).
#' @param methode_strates Méthode du couvert des strates (mission 013, plan validé par
#'   Pascal le 2026-11-23) : `"hybride"` (**par défaut**) : strate 1 par les houppiers,
#'   strates 2 à 4 par les tranches de hauteur corrigées de l'occlusion, sans les
#'   retours qui tombent dans les houppiers de la strate 1 (décision du 2026-11-23 ; il
#'   faut une segmentation unique et des tranches calculées depuis les dalles, ou des
#'   comptes de [couvert_strates_dalle()] avec `houppiers`), déclarées estimées
#'   (`part_retours_sous_s1`) ; `"houppiers"` : les quatre strates par les houppiers vus du dessus ;
#'   `"tranches"` : les quatre par les tranches (mission 008). Les colonnes
#'   `c1_<ref>` à `c4_<ref>` gardent leurs noms. Une source manquante pour la méthode
#'   arrête la chaîne.
#' @param reference_strates Hauteur de référence des strates : `"hpot"` (hauteur
#'   potentielle sans enveloppe, h_pot / k ; **par défaut, provisoire**, décision du
#'   2026-11-22), `"hpot_k"` (h_pot) ou `"h0"` (h_dom). Voir [references_strates()].
#' @param modele_hp En mode « variables fournies », modèle de hauteur potentielle déjà
#'   appris ([apprendre_hauteur_potentielle()]), par exemple sur tout le massif, appliqué
#'   aux pixels de l'emprise ; `NULL` : appris sur les pixels de l'emprise. Demande
#'   `milieu`.
#'
#' @section Variables passées à la clé:
#' Variables passées à la clé, en mode « variables fournies » : toute variable que la clé
#' cite et que la chaîne porte — celles du producteur (`G`, parts, `couvert`, `N`…), la
#' hauteur potentielle `h_pot` (avec l'enveloppe), `hpot` (sans l'enveloppe, h_pot / k),
#' `rapport_h`, et les couverts des strates. Une variable citée que la chaîne ne porte
#' pas est neutralisée (voir [executer_chaine_fournie()]).
#'
#' @return Objet `typo_resultat` (voir [executer_chaine()]), invisible si `sortie` est donné.
#' @examples
#' \donttest{
#' jeu <- generer_jeu_synthetique(30, 30, 200, graine = 1)
#' chemin <- system.file("extdata", "config", "exemple.json", package = "typopeuplement")
#' res <- typer_peuplements(jeu$pixels, jeu$placettes, "exemple-alpes-du-nord", chemin)
#' res
#' }
#' @export
typer_peuplements <- function(aoi, placettes = NULL, ser = NULL, configuration, sortie = NULL,
                              graine = 0, variables = NULL, milieu = NULL, strates = NULL,
                              reference_strates = "hpot", modele_hp = NULL,
                              methode_strates = "hybride") {
  if (!is.null(variables)) {
    if (is.null(ser)) arreter("SER non donn\u00e9e : en mode \u00ab variables fournies \u00bb, donner `ser`")
    conf <- lire_configuration(configuration, ser)
    conf$graine <- graine
    if (!is.null(aoi)) {
      garde <- pixels_dans_aoi(variables, aoi)
      variables <- garder_lignes(variables, garde)
      if (!is.null(milieu)) {
        a <- attributes(milieu)[c("variables_milieu", "source")]
        milieu <- milieu[garde, , drop = FALSE]
        for (k in names(a)) if (!is.null(a[[k]])) attr(milieu, k) <- a[[k]]
      }
    }
    res <- executer_chaine_fournie(variables, conf, milieu, strates = strates,
                                   reference_strates = reference_strates, modele_hp = modele_hp,
                                   methode_strates = methode_strates)
    if (!is.null(sortie)) {
      ecrire_livrables(res, sortie)
      return(invisible(res))
    }
    return(res)
  }
  if (is.character(aoi) || inherits(aoi, "sf")) {
    if (is.character(aoi)) aoi <- sf::st_read(aoi, quiet = TRUE)
    if (is.null(ser)) ser <- localiser_ser_aoi(aoi)
    arreter(sprintf(paste0("SER %s : lecture des donn\u00e9es ouvertes non \u00e9crite ",
                        "(LiDAR HD, Sentinel-2, BD For\u00eat, climat, sol) ; ",
                        "fournir un data.frame de pixels pr\u00e9par\u00e9s"), ser))
  }
  if (!is.data.frame(aoi)) {
    arreter("aoi doit \u00eatre un data.frame de pixels, un objet sf ou un chemin de GeoPackage")
  }
  if (is.null(ser)) {
    arreter("SER non donn\u00e9e : avec un data.frame de pixels, la SER ne se devine pas")
  }
  if (is.null(placettes)) {
    arreter(paste0("placettes absentes : mod\u00e8les de grande r\u00e9gion indisponibles ",
                "(calibration nationale ou par GRECO non \u00e9crite)"))
  }
  conf <- lire_configuration(configuration, ser)
  conf$graine <- graine
  res <- executer_chaine(placettes, aoi, conf)
  if (!is.null(sortie)) {
    ecrire_livrables(res, sortie)
    return(invisible(res))
  }
  res
}

# SER majoritaire d'une AOI, par nemeton::localiser_ser() (plus grande intersection).
localiser_ser_aoi <- function(aoi) {
  if (!requireNamespace("nemeton", quietly = TRUE)) {
    arreter("nemeton n'est pas install\u00e9 : la SER de l'AOI ne peut pas \u00eatre localis\u00e9e ; donner `ser`")
  }
  loc <- nemeton::localiser_ser(aoi)
  codes <- stats::na.omit(as.character(loc$ser))
  if (length(codes) == 0) arreter("AOI hors de toute SER")
  names(sort(table(codes), decreasing = TRUE))[1]
}

# Pixels de `variables` dont le centre (x, y, dans le système du gabarit, Lambert-93 par
# défaut) tombe dans l'AOI (objet sf ou sfc).
pixels_dans_aoi <- function(variables, aoi) {
  if (!inherits(aoi, c("sf", "sfc"))) arreter("en mode \u00ab variables fournies \u00bb, aoi doit \u00eatre NULL ou un objet sf")
  verifier_colonnes(variables, c("x", "y"), "les variables fournies")
  crs <- attr(variables, "gabarit")$crs %||% "EPSG:2154"
  pts <- sf::st_as_sf(data.frame(x = variables$x, y = variables$y), coords = c("x", "y"),
                      crs = sf::st_crs(crs))
  zone <- sf::st_union(sf::st_transform(sf::st_geometry(aoi), sf::st_crs(pts)))
  lengths(sf::st_intersects(pts, zone)) > 0
}

# Sous-ensemble de lignes qui garde les attributs de lecture (gabarit, couches, temps).
garder_lignes <- function(variables, garde) {
  a <- attributes(variables)[c("gabarit", "couches", "temps_lecture")]
  out <- variables[garde, , drop = FALSE]
  rownames(out) <- NULL
  for (k in names(a)) if (!is.null(a[[k]])) attr(out, k) <- a[[k]]
  out
}

# Coordonnées des centres de pixels : colonnes x, y de la carte si elles existent ; sinon
# x = i * taille_pixel, y = j * taille_pixel (convention du jeu synthétique).
centres_pixels <- function(carte, taille_pixel) {
  if (all(c("x", "y") %in% names(carte))) return(cbind(as.numeric(carte$x), as.numeric(carte$y)))
  cbind(as.numeric(carte$i) * taille_pixel, as.numeric(carte$j) * taille_pixel)
}

# Raster multicouche à partir de colonnes numériques de la carte. Avec un gabarit (grille
# du jeu d'entrée), le raster reprend exactement son emprise, sa résolution et son système.
raster_couches <- function(xy, valeurs, taille_pixel, crs, gabarit = NULL) {
  if (!is.null(gabarit)) {
    r <- terra::rast(xmin = gabarit$xmin, xmax = gabarit$xmax, ymin = gabarit$ymin,
                     ymax = gabarit$ymax, resolution = gabarit$resolution, crs = gabarit$crs,
                     nlyrs = ncol(valeurs))
  } else {
    demi <- taille_pixel / 2
    r <- terra::rast(
      xmin = min(xy[, 1]) - demi, xmax = max(xy[, 1]) + demi,
      ymin = min(xy[, 2]) - demi, ymax = max(xy[, 2]) + demi,
      resolution = taille_pixel, crs = crs, nlyrs = ncol(valeurs)
    )
  }
  cellules <- terra::cellFromXY(r, xy)
  m <- matrix(NA_real_, terra::ncell(r), ncol(valeurs))
  m[cellules, ] <- as.matrix(valeurs)
  terra::values(r) <- m
  names(r) <- colnames(valeurs)
  r
}

#' Table de correspondance des types
#'
#' Valeur entière de chaque type dans `types.tif`, son code et son libellé dans la clé de
#' la SER. Avec `types` (la colonne `type` d'une carte), les **groupes de types** qu'elle
#' contient (codes réunis par `" | "`, voir [decider_type()]) sont ajoutés après les types
#' de la clé, avec une valeur propre, le libellé étant la réunion des libellés.
#'
#' @param cle La clé d'une SER (`lire_configuration(...)$cle`).
#' @param types Codes de types d'une carte, ou `NULL` (types de la clé seulement).
#' @return data.frame : `valeur`, `code`, `libelle`.
#' @export
correspondance_types <- function(cle, types = NULL) {
  codes <- codes_cle(cle)
  libelles <- libelles_cle(cle)
  corr <- data.frame(valeur = seq_along(codes), code = codes, libelle = libelles,
                     stringsAsFactors = FALSE)
  groupes <- sort(unique(stats::na.omit(as.character(types))))
  groupes <- groupes[!(groupes %in% codes)]
  if (length(groupes) > 0) {
    # Dans l'ordre de la clé, pour un ordre stable d'une carte à l'autre.
    ordre <- order(vapply(strsplit(groupes, " | ", fixed = TRUE),
                          function(g) min(match(g, codes), na.rm = TRUE), numeric(1)), groupes)
    groupes <- groupes[ordre]
    lib <- vapply(strsplit(groupes, " | ", fixed = TRUE),
                  function(g) paste(libelles[match(g, codes)], collapse = " | "), character(1))
    corr <- rbind(corr, data.frame(valeur = length(codes) + seq_along(groupes), code = groupes,
                                   libelle = lib, stringsAsFactors = FALSE))
  }
  corr
}

#' Écrire les livrables d'une emprise
#'
#' Écrit dans `dossier` :
#' - `types.tif` : `type` (valeur entière, voir la table de correspondance : un groupe de
#'   types, quand une variable manque, a sa propre valeur), `proba`, `type_second`,
#'   `entre_deux` (0 ou 1) ;
#' - `variables.tif` : `G`, `part_resineux`, `part_pb`, `part_bm`, `part_gb`, `N` (si
#'   lue), `h_dom`, `h_pot`, `hpot` (h_pot sans l'enveloppe, mode « variables fournies »),
#'   `h_pot_sd`, `rapport_h`, les couverts des strates `c1_<ref>` à `c4_<ref>` s'ils
#'   ont été fournis, et `densite_houppiers` (tiges/ha) si les houppiers ont servi ;
#' - `confiance.tif` : `hp_incertaine`, `hors_cle` (0 ou 1), `niveau_modele` (0 :
#'   variables du producteur, 1 : SER, 2 : grande région *requise* — la bascule vers le
#'   modèle de grande région n'est pas encore écrite, c'est le modèle de la SER qui a
#'   servi) ; en mode « variables fournies », aussi `non_precomptable`, `part_pb_absente`
#'   et `gb_interim` (0 ou 1), et `part_retours_sous_s1` (de 0 à 1 : part des retours
#'   du pixel qui passent sous la strate 1 et servent aux strates 2 à 4, estimées ; vide
#'   sans comptes de retours) quand le couvert des strates a été calculé par la chaîne ;
#' - `fiche_validation.md` ; `carte_types.csv` (la carte, une ligne par pixel) ;
#' - `correspondance_types.csv` (`valeur`, `code`, `libelle`), groupes de types compris ;
#' - `correspondance_niveau_modele.csv` (`valeur`, `niveau`, `sens`) : les codes de
#'   `niveau_modele` de `confiance.tif` ;
#' - `temps_etages.csv` (`etage`, `secondes`, `pixels`), si la chaîne a chronométré ses
#'   étages ([executer_chaine_fournie()]) ; les étages `ecriture_rasters` (les trois
#'   GeoTIFF) et `ecriture_tables` (fiche et CSV) y sont ajoutés.
#'
#' Grille : si le résultat porte un `gabarit` (grille du jeu d'entrée, par exemple
#' [lire_parametres_lidar()]), les rasters reprennent exactement cette grille et se
#' superposent au jeu. Sinon la grille part des centres `x`, `y` de la carte ; **sans
#' `x`, `y`, les centres sont pris à `i × taille_pixel`, `j × taille_pixel`** (convention
#' du jeu synthétique), ce qui ne place pas les pixels sur le terrain.
#'
#' Les rasters sont des GeoTIFF : ils s'ouvrent dans QGIS et dans R (terra) sans
#' conversion. Les zones sans donnée (ZICAD, hors LiDAR) ne sont pas encore portées par
#' `confiance.tif` : la lecture des données ouvertes n'est pas écrite.
#'
#' @param resultat Objet `typo_resultat` ([typer_peuplements()], [executer_chaine()]).
#' @param dossier Dossier de sortie (créé au besoin).
#' @param taille_pixel Côté des pixels, en m. **Provisoire** : 25.
#' @param crs Système de coordonnées. Lambert-93 (`"EPSG:2154"`) par défaut.
#' @return Le chemin du dossier, invisible.
#' @export
ecrire_livrables <- function(resultat, dossier, taille_pixel = 25, crs = "EPSG:2154") {
  debut <- proc.time()[["elapsed"]]
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  gabarit <- resultat$gabarit
  carte <- resultat$carte
  corr <- correspondance_types(resultat$cle, c(carte$type, carte$type_second))
  xy <- centres_pixels(carte, taille_pixel)

  types <- data.frame(
    type = match(carte$type, corr$code),
    proba = carte$proba,
    type_second = match(carte$type_second, corr$code),
    entre_deux = as.numeric(carte$entre_deux)
  )
  noms_var <- c("G", "part_resineux", "part_pb", "part_bm", "part_gb", "N", "h_dom", "h_pot",
                "hpot", "h_pot_sd", "rapport_h", grep("^c[1-4]_", names(carte), value = TRUE),
                "densite_houppiers")
  variables <- carte[, intersect(noms_var, names(carte)), drop = FALSE]
  confiance <- data.frame(
    hp_incertaine = as.numeric(carte$hp_incertaine),
    hors_cle = as.numeric(carte$hors_cle),
    niveau_modele = rep(code_niveau_modele(resultat$niveau_modele), nrow(carte))
  )
  for (drapeau in c("non_precomptable", "part_pb_absente", "gb_interim", "part_retours_sous_s1")) {
    if (drapeau %in% names(carte)) confiance[[drapeau]] <- as.numeric(carte[[drapeau]])
  }
  couches <- list(types.tif = types, variables.tif = variables, confiance.tif = confiance)
  for (f in names(couches)) {
    r <- raster_couches(xy, couches[[f]], taille_pixel, crs, gabarit)
    terra::writeRaster(r, file.path(dossier, f), overwrite = TRUE)
  }
  fin_rasters <- proc.time()[["elapsed"]]
  ecrire_lignes_utf8(fiche_en_markdown(resultat$fiche_validation),
                     file.path(dossier, "fiche_validation.md"))
  ecrire_csv_utf8(carte, file.path(dossier, "carte_types.csv"))
  ecrire_csv_utf8(corr, file.path(dossier, "correspondance_types.csv"))
  ecrire_csv_utf8(table_niveau_modele(), file.path(dossier, "correspondance_niveau_modele.csv"))
  if (!is.null(resultat$temps)) {
    temps <- rbind(resultat$temps,
                   data.frame(etage = c("ecriture_rasters", "ecriture_tables"),
                              secondes = c(fin_rasters - debut,
                                           proc.time()[["elapsed"]] - fin_rasters),
                              pixels = nrow(carte), stringsAsFactors = FALSE))
    ecrire_csv_utf8(temps, file.path(dossier, "temps_etages.csv"))
  }
  invisible(dossier)
}

# Table des codes de niveau_modele (confiance.tif), livrée à côté de lui.
table_niveau_modele <- function() {
  data.frame(
    valeur = c(0, 1, 2),
    niveau = c("producteur", "ser", "grande_region"),
    sens = c("variables du producteur, pas de mod\u00e8le ajust\u00e9",
             "mod\u00e8le ajust\u00e9 sur la SER",
             paste0("grande r\u00e9gion requise (trop peu de placettes par type) ; la bascule n'est ",
                    "pas \u00e9crite, c'est le mod\u00e8le de la SER qui a servi")),
    stringsAsFactors = FALSE
  )
}

# Code du niveau de modèle dans confiance.tif : 0 producteur, 1 SER, 2 grande région requise.
code_niveau_modele <- function(niveau) {
  if (identical(niveau, "producteur")) return(0)
  if (identical(niveau, "ser")) return(1)
  2
}

#' Lancer la démonstration
#'
#' Fait tourner la chaîne sur un jeu synthétique ([generer_jeu_synthetique()]), écrit les
#' livrables dans `sortie` et affiche un résumé (précision et kappa à la placette et à la
#' grappe, part des pixels entre deux types, part de hauteur potentielle incertaine).
#' Le jeu n'imite aucune forêt réelle et la clé est celle de l'exemple.
#'
#' @param sortie Dossier des livrables.
#' @param configuration Chemin du JSON de configuration ; par défaut l'exemple du package.
#' @param ser Nom de la SER dans la configuration.
#' @param graine Graine du hasard (jeu synthétique et modèles).
#' @return Objet `typo_resultat`, invisible.
#' @examples
#' \donttest{
#' lancer_demo(file.path(tempdir(), "demo"))
#' }
#' @export
lancer_demo <- function(sortie = file.path(tempdir(), "typopeuplement_demo"),
                        configuration = system.file("extdata", "config", "exemple.json",
                                                    package = "typopeuplement"),
                        ser = "exemple-alpes-du-nord", graine = 0) {
  conf <- lire_configuration(configuration, ser)
  conf$graine <- graine
  jeu <- generer_jeu_synthetique(graine = graine)
  res <- executer_chaine(jeu$placettes, jeu$pixels, conf)
  ecrire_livrables(res, sortie)
  message(paste(c(resume_resultat(res), paste0("  livrables : ", sortie)), collapse = "\n"))
  invisible(res)
}

# Variables dendrométriques tirées des arbres d'une placette (dendro.py du prototype).

#' Surface terrière d'un arbre
#'
#' @param diametre_cm Diamètre à 1,30 m, en cm.
#' @return Surface terrière en m².
#' @examples
#' surface_terriere_arbre(100)  # pi / 4
#' @export
surface_terriere_arbre <- function(diametre_cm) {
  d <- as.numeric(diametre_cm) / 100
  pi * d^2 / 4
}

#' Variables dendrométriques d'une placette
#'
#' Agrège les arbres par placette : surface terrière et parts de petits, moyens et gros
#' bois et de résineux. Les seuils de catégories sont propres à chaque SER et viennent de
#' sa configuration (`lire_configuration(...)$seuils_diametre`) : la limite des gros bois
#' est à 42,5 cm en Savoie et dans les Pyrénées, à 47,5 cm dans les Vosges (Souchon, 2020).
#'
#' Conventions : un arbre compte si `diametre_cm >= precomptage_cm` ; il est petit bois
#' si `diametre_cm < pb_bm_cm`, bois moyen si `diametre_cm < bm_gb_cm`, gros bois sinon.
#' Une placette sans arbre compté a `G = 0` et des parts non définies (`NA`).
#'
#' @param arbres data.frame : `placette`, `diametre_cm` (cm à 1,30 m), `resineux` (logique).
#' @param surface_placette_ha Surface de la placette, en ha.
#' @param seuils Liste : `precomptage_cm`, `pb_bm_cm`, `bm_gb_cm`.
#'
#' @return data.frame, une ligne par placette (dans l'ordre d'apparition) : `placette`,
#'   `G` (m²/ha), `part_pb`, `part_bm`, `part_gb`, `part_resineux` (parts de la surface
#'   terrière, entre 0 et 1).
#' @export
variables_placette <- function(arbres, surface_placette_ha, seuils) {
  verifier_colonnes(arbres, c("placette", "diametre_cm", "resineux"), "la table des arbres")
  ids <- unique(as.character(arbres$placette))
  a <- arbres[arbres$diametre_cm >= seuils$precomptage_cm, , drop = FALSE]
  g <- surface_terriere_arbre(a$diametre_cm) / surface_placette_ha
  d <- a$diametre_cm
  cat_d <- ifelse(d < seuils$pb_bm_cm, "pb", ifelse(d < seuils$bm_gb_cm, "bm", "gb"))
  plac <- factor(as.character(a$placette), levels = ids)
  somme <- function(masque) {
    v <- tapply(g[masque], plac[masque], sum)
    v[is.na(v)] <- 0
    as.numeric(v[ids])
  }
  tout <- rep(TRUE, length(g))
  G <- somme(tout)
  out <- data.frame(placette = ids, G = G, stringsAsFactors = FALSE)
  for (c in c("pb", "bm", "gb")) out[[paste0("part_", c)]] <- somme(cat_d == c) / G
  out$part_resineux <- somme(as.logical(a$resineux)) / G
  for (c in grep("^part_", names(out))) out[[c]][is.nan(out[[c]])] <- NA_real_
  rownames(out) <- ids
  out
}

# Mission 010, reprise courte point 4 : test automatique de la cle de H10.
# Source : inst/extdata/config/vercors-h10.json lu par lire_configuration(..., "H10").
# Les noms de variables (couvert, h_pot / hpot, c1_hpot...) sont lus dans la cle elle-meme.

conf_h10 <- function() {
  chemin <- normalizePath(testthat::test_path("..", "..", "inst", "extdata", "config",
                                              "vercors-h10.json"))
  lire_configuration(chemin, "H10")
}

CODES_TYPES_H10 <- c("CH", "L", "3", "R", "1", "1GB", "2", "2GB", "12", "12GB", "13", "13GB",
                     "23", "C", "J", "JGB")
CODES_NON_EXPRIMABLES_H10 <- c("X", "P", "A", "T")

test_that("H10 : 16 types, 4 non exprimables, 20 codes sans doublon", {
  cle <- conf_h10()$cle
  codes <- vapply(cle$types, function(t) as.character(t$code), character(1))
  non_expr <- vapply(cle$non_exprimables, function(t) as.character(t$code), character(1))
  expect_identical(codes, CODES_TYPES_H10)
  expect_identical(non_expr, CODES_NON_EXPRIMABLES_H10)
  tous <- c(codes, non_expr)
  expect_length(tous, 20)
  expect_false(anyDuplicated(tous) > 0)
})

test_that("H10 : chaque type a une source non vide qui cite une page", {
  cle <- conf_h10()$cle
  for (t in cle$types) {
    src <- t$source
    expect_true(is.character(src) && length(src) == 1 && nzchar(trimws(src)),
                info = paste("source vide pour le type", t$code))
    expect_true(grepl("\\bp\\. ?[0-9]+", src), info = paste("aucune page citee pour le type", t$code))
  }
})

test_that("H10 : limite BM/GB a 42,5 cm et souplesses du jeu vercors_onf", {
  conf <- conf_h10()
  expect_identical(as.numeric(conf$seuils_diametre$bm_gb_cm), 42.5)
  sou <- conf$jeux$vercors_onf$souplesse
  expect_identical(as.numeric(sou$G), 7.32)
  expect_identical(as.numeric(sou$part_resineux), 0.199)
  expect_identical(as.numeric(sou$part_gb), 0.163)
})

# Toutes les conditions d'un type (conditions et alternatives), sous forme de liste plate.
conditions_plates <- function(t) {
  c(t$conditions, unlist(t$alternatives, recursive = FALSE))
}

test_that("H10 : le seuil de 15 m porte sur hpot (sans enveloppe) dans les 16 types", {
  cle <- conf_h10()$cle
  for (t in cle$types) {
    sur_15 <- Filter(function(cd) isTRUE(cd$min == 15) || isTRUE(cd$max == 15),
                     conditions_plates(t))
    vars <- vapply(sur_15, function(cd) as.character(cd$variable), character(1))
    expect_gte(length(vars), 1, label = paste("conditions a 15 m du type", t$code))
    expect_true(all(vars == "hpot"),
                info = paste("seuil de 15 m hors hpot pour le type", t$code,
                             ":", paste(vars, collapse = ", ")))
  }
})

test_that("H10 : en cle dure, chaque combinaison boisee recoit exactement un type", {
  cle <- conf_h10()$cle
  codes <- vapply(cle$types, function(t) as.character(t$code), character(1))

  # Noms de variables lus dans la cle : couvert = variable du seuil min 0,1 de CH ;
  # hauteur potentielle = variable du seuil max 15 de CH.
  ch <- conditions_plates(cle$types[[which(codes == "CH")]])
  var_couvert <- unique(vapply(Filter(function(cd) isTRUE(cd$min == 0.1), ch),
                               function(cd) as.character(cd$variable), character(1)))
  var_hauteur <- unique(vapply(Filter(function(cd) isTRUE(cd$max == 15), ch),
                               function(cd) as.character(cd$variable), character(1)))
  expect_length(var_couvert, 1)
  expect_length(var_hauteur, 1)
  expect_identical(var_hauteur, "hpot")

  # Seuils par variable, puis valeurs qui encadrent chaque seuil (seuil - pas, seuil, seuil + pas ;
  # de pas : 0,01 pour les variables a seuil <= 1, 0,1 sinon), plus 0.
  seuils <- list()
  for (t in cle$types) {
    for (cd in conditions_plates(t)) {
      v <- as.character(cd$variable)
      seuils[[v]] <- sort(unique(c(seuils[[v]], cd$min, cd$max)))
    }
  }
  valeurs <- lapply(seuils, function(s) {
    pas <- if (max(s) <= 1) 0.01 else 0.1
    sort(unique(c(0, s - pas, s, s + pas)))
  })
  # Les seuils attendus doivent etre dans la cle (sinon la grille ne les encadre pas).
  expect_true(all(c(0.25, 0.45) %in% unlist(seuils[grepl("^c[1-4]_", names(seuils))])))
  expect_true(10 %in% seuils[["G"]])
  expect_true(0.6 %in% seuils[["part_gb"]])
  expect_true(15 %in% seuils[[var_hauteur]])
  expect_true(0.1 %in% seuils[[var_couvert]])

  grille <- expand.grid(valeurs, KEEP.OUT.ATTRS = FALSE)
  dure <- cle
  dure$souplesse <- list()
  probas <- appartenances_types(dure, grille)
  boise <- grille[[var_couvert]] >= 0.1
  expect_gt(sum(boise), 1000)

  p <- as.matrix(probas)
  attr(p, "hors_cle") <- NULL
  hors_cle <- attr(probas, "hors_cle")
  # Souplesse nulle : un chevauchement doit etre signale comme tel. appartenances_types()
  # normalise (deux types a 1 donnent 0,5 chacun, et rowSums(p == 1) les ferait passer pour
  # « sans type ») : on compte donc les probabilites strictement positives, hors lignes
  # hors cle (qui recoivent 1/16 partout).
  expect_true(all(abs(rowSums(p) - 1) < 1e-9))
  nb_types <- rowSums(p > 0)
  n_zero <- sum(boise & hors_cle)
  n_multi <- sum(boise & !hors_cle & nb_types > 1)
  expect_identical(n_zero, 0L, info = sprintf("%d combinaisons boisees sans type", n_zero))
  expect_identical(n_multi, 0L, info = sprintf("%d combinaisons boisees a plusieurs types", n_multi))

  # La decision rend alors un code de la cle, jamais un groupe « a | b ».
  dec <- decider_type(probas)
  expect_true(all(dec$type[boise] %in% codes))
})

# Mission 017 : tests d'acceptation de la cle SRGS AURA (mission 016).
# Source : inst/extdata/config/srgs-aura.json lue par lire_configuration(..., "H10") ;
# fiche docs/referentiels/srgs-aura.md. Modele : test-cle-h10.R.
# Les noms de variables sont lus dans la cle elle-meme. Ces tests sont ecrits sans lire
# aucun code de la mission 018.

chemin_config <- function(nom) {
  normalizePath(testthat::test_path("..", "..", "inst", "extdata", "config", nom))
}
conf_srgs <- function() lire_configuration(chemin_config("srgs-aura.json"), "H10")
conf_h10_gsm <- function() lire_configuration(chemin_config("vercors-h10.json"), "H10")

CODES_EXPRIMES_SRGS <- c("FRE", "FIR", "TNU")
CODES_NON_EXPRIMABLES_SRGS <- c("MFT", "TAS", "PEU", "ACC", "LAN")
GSM_FRE <- c("1", "1GB", "2", "2GB", "12", "12GB", "23", "3")
GSM_FIR <- c("13", "13GB", "J", "JGB")
GSM_HORS_CLE_SRGS <- c("R", "L", "C", "CH")

codes_de <- function(types) vapply(types, function(t) as.character(t$code), character(1))

conditions_plates <- function(t) {
  c(t$conditions, unlist(t$alternatives, recursive = FALSE))
}

# Seuils par variable, lus dans la cle.
seuils_de <- function(cle) {
  seuils <- list()
  for (t in cle$types) {
    for (cd in conditions_plates(t)) {
      v <- as.character(cd$variable)
      seuils[[v]] <- sort(unique(c(seuils[[v]], cd$min, cd$max)))
    }
  }
  seuils
}

# Grille qui encadre chaque seuil (seuil - pas, seuil, seuil + pas ; pas 0,01 si tous les
# seuils de la variable sont <= 1, 0,1 sinon), plus 0.
grille_de <- function(cle, seuils = seuils_de(cle)) {
  valeurs <- lapply(seuils, function(s) {
    pas <- if (max(s) <= 1) 0.01 else 0.1
    sort(unique(c(0, s - pas, s, s + pas)))
  })
  expand.grid(valeurs, KEEP.OUT.ATTRS = FALSE)
}

# Cle dure (souplesse nulle) appliquee a une grille : probabilites et drapeau hors_cle.
appartenances_dures <- function(cle, grille) {
  dure <- cle
  dure$souplesse <- list()
  probas <- appartenances_types(dure, grille)
  hors_cle <- attr(probas, "hors_cle")
  p <- as.matrix(probas)
  attr(p, "hors_cle") <- NULL
  attr(p, "touche_na") <- NULL
  list(p = p, hors_cle = hors_cle, probas = probas)
}

# Nombre de lignes de la grille qui satisfont plus d'un type (probabilites strictement
# positives : appartenances_types() normalise, deux types a 1 donnent 0,5 chacun).
nb_recouvrements <- function(cle, grille = grille_de(cle)) {
  a <- appartenances_dures(cle, grille)
  sum(!a$hors_cle & rowSums(a$p > 0) > 1)
}

test_that("SRGS : la cle se charge et porte les seuils de diametre 17,5 / 27,5 / 47,5 / 67,5 cm", {
  conf <- conf_srgs()
  expect_identical(conf$ser, "H10")
  sd <- conf$seuils_diametre
  expect_identical(as.numeric(sd$precomptage_cm), 17.5)
  expect_identical(as.numeric(sd$pb_bm_cm), 27.5)
  expect_identical(as.numeric(sd$bm_gb_cm), 47.5)
  expect_identical(as.numeric(sd$gb_tgb_cm), 67.5)
  expect_gt(length(conf$cle$types), 0)
})

test_that("SRGS : 8 types, 3 exprimes + 5 non exprimables, sans doublon", {
  cle <- conf_srgs()$cle
  codes <- codes_de(cle$types)
  non_expr <- codes_de(cle$non_exprimables)
  expect_identical(codes, CODES_EXPRIMES_SRGS)
  expect_identical(non_expr, CODES_NON_EXPRIMABLES_SRGS)
  tous <- c(codes, non_expr)
  expect_length(tous, 8)
  expect_false(anyDuplicated(tous) > 0)
})

test_that("SRGS : chaque type (exprime ou non) a une source non vide qui cite une page", {
  cle <- conf_srgs()$cle
  for (t in c(cle$types, cle$non_exprimables)) {
    src <- t$source
    expect_true(is.character(src) && length(src) == 1 && nzchar(trimws(src)),
                info = paste("source vide pour le type", t$code))
    expect_true(grepl("\\bp\\. ?[0-9]+", src),
                info = paste("aucune page citee pour le type", t$code))
  }
})

test_that("SRGS : le seuil de 15 m porte sur hpot et celui de 0,1 sur le couvert, lus dans la cle", {
  cle <- conf_srgs()$cle
  fre <- cle$types[[which(codes_de(cle$types) == "FRE")]]
  sur_15 <- Filter(function(cd) isTRUE(cd$min == 15) || isTRUE(cd$max == 15), conditions_plates(fre))
  expect_gte(length(sur_15), 1)
  expect_true(all(vapply(sur_15, function(cd) cd$variable == "hpot", logical(1))))
  tnu <- cle$types[[which(codes_de(cle$types) == "TNU")]]
  expect_identical(as.numeric(tnu$conditions[[1]]$max), 0.1)
})

test_that("SRGS : en cle dure, aucun pixel de la grille n'est dans deux types", {
  cle <- conf_srgs()$cle
  seuils <- seuils_de(cle)
  # Les seuils attendus sont dans la cle (sinon la grille ne les encadre pas).
  expect_true(all(c(0.25, 0.45) %in% unlist(seuils[grepl("^c[1-4]_", names(seuils))])))
  expect_true(10 %in% seuils[["G"]])
  expect_true(800 %in% seuils[["N"]])
  expect_true(15 %in% seuils[["hpot"]])
  expect_true(0.1 %in% seuils[["couvert"]])

  grille <- grille_de(cle, seuils)
  expect_gt(nrow(grille), 10000)
  a <- appartenances_dures(cle, grille)
  expect_true(all(abs(rowSums(a$p) - 1) < 1e-9))
  n_multi <- sum(!a$hors_cle & rowSums(a$p > 0) > 1)
  expect_identical(n_multi, 0L, info = sprintf("%d combinaisons a plusieurs types", n_multi))

  # Le terrain nu est exactement le couvert < 0,1 : jamais FRE ni FIR, et inversement.
  codes <- colnames(a$p)
  nu <- grille$couvert < 0.1
  expect_gt(sum(nu), 100)
  expect_false(any(a$hors_cle[nu]))
  expect_true(all(a$p[nu, "TNU"] == 1))
  expect_true(all(a$p[!nu & !a$hors_cle, "TNU"] == 0))
})

test_that("SRGS : chaque type exprime est atteint, et un cas juste sous un seuil ne l'atteint pas", {
  cle <- conf_srgs()$cle
  base_fre <- data.frame(couvert = 0.5, hpot = 20, G = 20, N = 500,
                         c1_hpot = 0.5, c2_hpot = 0, c3_hpot = 0)
  base_fir <- data.frame(couvert = 0.6, hpot = 20, G = 20, N = 500,
                         c1_hpot = 0.3, c2_hpot = 0.1, c3_hpot = 0.3)
  base_tnu <- data.frame(couvert = 0.05, hpot = 0, G = 0, N = 0,
                         c1_hpot = 0, c2_hpot = 0, c3_hpot = 0)
  # Les variables du cas sont celles de la cle.
  vars_cle <- names(seuils_de(cle))
  expect_true(all(names(base_fre) %in% vars_cle))
  type_dur <- function(df) {
    a <- appartenances_dures(cle, df)
    if (a$hors_cle) return(NA_character_)
    colnames(a$p)[which.max(a$p)]
  }
  expect_identical(type_dur(base_fre), "FRE")
  expect_identical(type_dur(base_fir), "FIR")
  expect_identical(type_dur(base_tnu), "TNU")

  # Juste sous le seuil de hpot : ni FRE ni FIR.
  expect_true(is.na(type_dur(transform(base_fre, hpot = 14.9))))
  expect_true(is.na(type_dur(transform(base_fir, hpot = 14.9))))
  expect_identical(type_dur(transform(base_fre, hpot = 15)), "FRE")
  # Juste sous le seuil de G (10) : FIR n'est plus atteint.
  expect_true(is.na(type_dur(transform(base_fir, G = 9.9))))
  expect_identical(type_dur(transform(base_fir, G = 10)), "FIR")
  # Juste sous le seuil de couvert (0,1) : TNU, et plus FRE ; a 0,1 : FRE, plus TNU.
  expect_identical(type_dur(transform(base_fre, couvert = 0.09)), "TNU")
  expect_identical(type_dur(transform(base_fre, couvert = 0.1)), "FRE")
  expect_identical(type_dur(transform(base_tnu, couvert = 0.1)), NA_character_)

  # Sur la grille, les 3 types exprimes sont atteints.
  a <- appartenances_dures(cle, grille_de(cle))
  atteints <- colnames(a$p)[colSums(a$p == 1 & !a$hors_cle) > 0]
  expect_setequal(atteints, CODES_EXPRIMES_SRGS)
})

# Pixels de la grille de la cle H10 (GSM) classes dans chaque type GSM, puis lus par la cle SRGS.
cache_gsm <- new.env()
gsm_vers_srgs <- function() {
  if (!is.null(cache_gsm$v)) return(cache_gsm$v)
  gsm <- conf_h10_gsm()$cle
  srgs <- conf_srgs()$cle
  grille <- grille_de(gsm)
  vars_srgs <- names(seuils_de(srgs))
  manquantes <- setdiff(vars_srgs, names(grille))
  a_gsm <- appartenances_dures(gsm, grille)
  ok <- !a_gsm$hors_cle & rowSums(a_gsm$p > 0) == 1
  type_gsm <- colnames(a_gsm$p)[max.col(a_gsm$p, ties.method = "first")]
  a_srgs <- appartenances_dures(srgs, grille[, vars_srgs, drop = FALSE])
  type_srgs <- ifelse(a_srgs$hors_cle, NA_character_,
                      colnames(a_srgs$p)[max.col(a_srgs$p, ties.method = "first")])
  cache_gsm$v <- list(manquantes = manquantes, ok = ok, type_gsm = type_gsm, type_srgs = type_srgs,
                      srgs_hors_cle = a_srgs$hors_cle, grille = grille)
  cache_gsm$v
}

test_that("SRGS : correspondance par types GSM (FRE : 8 types, FIR : 4 types)", {
  g <- gsm_vers_srgs()
  expect_length(g$manquantes, 0)
  attendu <- c(stats::setNames(rep("FRE", length(GSM_FRE)), GSM_FRE),
               stats::setNames(rep("FIR", length(GSM_FIR)), GSM_FIR))
  for (code in names(attendu)) {
    lignes <- g$ok & g$type_gsm == code
    expect_gt(sum(lignes), 0, label = paste("pixels du type GSM", code))
    expect_true(all(g$type_srgs[lignes] == attendu[[code]]),
                info = sprintf("type GSM %s : %d pixels, attendu %s, obtenus %s", code,
                               sum(lignes), attendu[[code]],
                               paste(unique(g$type_srgs[lignes]), collapse = ", ")))
  }
})

test_that("SRGS : les types GSM R, L, C, CH n'ont aucun type SRGS (declares hors cle)", {
  g <- gsm_vers_srgs()
  for (code in GSM_HORS_CLE_SRGS) {
    lignes <- g$ok & g$type_gsm == code
    expect_gt(sum(lignes), 0, label = paste("pixels du type GSM", code))
    expect_true(all(g$srgs_hors_cle[lignes]),
                info = sprintf("type GSM %s : des pixels recoivent un type SRGS (%s)", code,
                               paste(unique(g$type_srgs[lignes]), collapse = ", ")))
  }
})

# Pixels hors cle SRGS : types GSM R, L, C, CH, et tout pixel boise de hpot < 15.
pixels_hors_cle_srgs <- function() {
  g <- gsm_vers_srgs()
  gr <- g$grille[, names(seuils_de(conf_srgs()$cle)), drop = FALSE]
  gr[g$srgs_hors_cle, , drop = FALSE]
}

test_that("SRGS : un pixel hors cle est declare hors cle (appartenances_types)", {
  cle <- conf_srgs()$cle
  hc <- pixels_hors_cle_srgs()
  expect_gt(nrow(hc), 100)
  a <- appartenances_dures(cle, hc)
  expect_true(all(a$hors_cle))
  # Cas nommes : hpot < 15 avec couvert boise, et G < 10 sans regeneration dense.
  nomme <- data.frame(couvert = c(0.5, 0.5), hpot = c(14.9, 20), G = c(20, 9.9), N = c(500, 500),
                      c1_hpot = 0.5, c2_hpot = 0, c3_hpot = 0)
  expect_true(all(appartenances_dures(cle, nomme)$hors_cle))
})

# ROUGE ATTENDU jusqu'a la mission 018 : la fiche 016 signale que types_observes() rend
# le premier type de la cle (FRE) pour un pixel hors cle. Ce test l'exige autrement.
test_that("SRGS : un pixel hors cle ne recoit jamais FRE (ni aucun type de la cle)", {
  cle <- conf_srgs()$cle
  codes <- codes_de(cle$types)
  hc <- pixels_hors_cle_srgs()
  obs <- types_observes(cle, hc)
  expect_length(obs, nrow(hc))
  expect_false(any(obs %in% "FRE"),
               info = sprintf("%d pixels hors cle etiquetes FRE sur %d", sum(obs %in% "FRE"), nrow(hc)))
  expect_false(any(obs %in% codes),
               info = sprintf("%d pixels hors cle etiquetes d'un type de la cle sur %d",
                              sum(obs %in% codes), nrow(hc)))
  # Cas nommes du terrain : hpot < 15 m (couvert 0,5, 600 tiges/ha, 3 m de haut).
  nomme <- data.frame(couvert = 0.5, hpot = 3, G = 20, N = 600,
                      c1_hpot = 0.5, c2_hpot = 0, c3_hpot = 0)
  expect_false(isTRUE(types_observes(cle, nomme) == "FRE"))
})

test_that("SRGS : un pixel qui a un type n'est pas touche (types_observes = type de la cle)", {
  cle <- conf_srgs()$cle
  cas <- data.frame(couvert = c(0.5, 0.6, 0.05), hpot = c(20, 20, 0), G = c(20, 20, 0),
                    N = c(500, 500, 0), c1_hpot = c(0.5, 0.3, 0), c2_hpot = c(0, 0.1, 0),
                    c3_hpot = c(0, 0.3, 0))
  expect_identical(as.character(types_observes(cle, cas)), c("FRE", "FIR", "TNU"))
})

test_that("SRGS : echec prouve sur une cle cassee (deux types qui se recouvrent)", {
  cle <- conf_srgs()$cle
  codes <- codes_de(cle$types)
  # La vraie cle ne recouvre rien (reference).
  expect_identical(nb_recouvrements(cle), 0L)

  # Casse 1 : TNU monte a couvert < 0,2 : il recouvre FRE et FIR entre 0,1 et 0,2.
  cassee1 <- cle
  cassee1$types[[which(codes == "TNU")]]$conditions[[1]]$max <- 0.2
  expect_gt(nb_recouvrements(cassee1), 0)

  # Casse 2 : FIR perd sa condition de couvert >= 0,1 : il recouvre TNU.
  cassee2 <- cle
  fir <- which(codes == "FIR")
  cassee2$types[[fir]]$conditions <- Filter(function(cd) cd$variable != "couvert",
                                            cassee2$types[[fir]]$conditions)
  expect_gt(nb_recouvrements(cassee2), 0)

  # Casse 3 : FIR devient une copie de FRE.
  cassee3 <- cle
  cassee3$types[[fir]]$conditions <- cle$types[[which(codes == "FRE")]]$conditions
  cassee3$types[[fir]]$alternatives <- cle$types[[which(codes == "FRE")]]$alternatives
  expect_gt(nb_recouvrements(cassee3), 0)
})

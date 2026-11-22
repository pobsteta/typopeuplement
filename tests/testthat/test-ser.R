# Critere 3 (heritage), critere 4 (pas de rupture) et referentiel des SER.
# Equivalents R de test_configuration_heritee, test_heritage_quand_un_type_manque_de_placettes et
# test_transition_sans_rupture du prototype.
# Fonctions : lire_configuration, greco_de_ser, niveau_modele, poids_transition, raccorder_probabilites.
# Suppose : niveau_modele(effectifs, codes, minimum) avec effectifs vecteur nomme ; raccorder_probabilites
# (p_ser, p_voisine, poids) rend un data.frame, comme raccorder() du prototype.

test_that("configuration heritee : national, puis grande region, puis SER", {
  f <- ecrire_json('{
    "national": {"a": 1, "seuils": {"gb": 42.5, "pb": 27.5}},
    "grandes_regions": {"vosges": {"seuils": {"gb": 47.5}}},
    "ser": {"s1": {"grande_region": "vosges", "a": 2}}
  }')
  eff <- lire_configuration(f, "s1")
  expect_equal(eff$seuils$gb, 47.5)
  expect_equal(eff$seuils$pb, 27.5)  # non redit par la grande region : herite du national
  expect_equal(eff$a, 2)             # la SER l'emporte sur le national
  expect_equal(eff$ser, "s1")
})

test_that("SER inconnue de la configuration : erreur", {
  f <- ecrire_json('{"national": {"a": 1}, "ser": {"s1": {}}}')
  expect_erreur(lire_configuration(f, "inconnue"), "inconnue")
})

test_that("configuration d'exemple : valeurs provisoires du socle national", {
  # Valeurs de config/exemple.json, marquees provisoires (plan 003, section 6).
  conf <- lire_configuration(chemin_config_exemple(), SER_EXEMPLE)
  expect_equal(conf$placettes_min_par_type, 30)
  expect_equal(conf$transition_demi_largeur_m, 500)
  expect_equal(conf$grappe_cote_m, 70.7)
  expect_equal(conf$ser, SER_EXEMPLE)
})

test_that("critere 3 : une SER qui manque de placettes pour un type prend le modele de sa grande region", {
  expect_identical(niveau_modele(c(A = 40, B = 35), c("A", "B"), 30), "ser")
  expect_identical(niveau_modele(c(A = 40, B = 5), c("A", "B"), 30), "grande_region")
})

test_that("critere 3 : limites de l'heritage (seuil inclus, type absent)", {
  # Exactement le minimum suffit ; un de moins bascule ; un type sans aucune placette bascule.
  expect_identical(niveau_modele(c(A = 30, B = 30), c("A", "B"), 30), "ser")
  expect_identical(niveau_modele(c(A = 30, B = 29), c("A", "B"), 30), "grande_region")
  expect_identical(niveau_modele(c(A = 50), c("A", "B"), 30), "grande_region")
})

test_that("critere 3 : la carte de confiance dit le niveau de modele utilise (jeu exporte)", {
  # Sur le jeu exporte, R-PB-J n'a que 16 placettes observees et R-PB-C aucune, pour un minimum de 30
  # (references_prototype.csv) : le niveau attendu est « grande_region ».
  # Ce test ne prouve que le calcul du niveau ; la bascule effective vers un modele de grande region
  # reste en stub dans 003 (plan, reponse 7), un vert ne dit rien sur elle.
  ref <- references_prototype()
  expect_equal(unname(ref["n_observe_R-PB-J"]), 16)
  res <- resultat_chaine()
  expect_identical(res$niveau_modele, "grande_region")
  obs <- table(factor(res$types_observes, levels = c("F", "M", "R-PB-J", "R-PB-C", "R-GB", "R-IRR")))
  expect_equal(as.integer(obs[["R-PB-J"]]), 16L)
  expect_equal(as.integer(obs[["R-PB-C"]]), 0L)
})

test_that("critere 4 : sur la limite de SER, les deux modeles pesent chacun pour moitie", {
  w <- poids_transition(c(-1000, 0, 250, 1000), 500)
  expect_equal(w, c(0.5, 0.5, 0.75, 1.0))
  a <- data.frame(A = c(1, 1))
  b <- data.frame(B = c(1, 1))
  m <- raccorder_probabilites(a, b, c(0.5, 1.0))
  expect_equal(m$A, c(0.5, 1.0), tolerance = 1e-12)
  expect_equal(m$B, c(0.5, 0.0), tolerance = 1e-12)
  expect_equal(m$A + m$B, c(1, 1), tolerance = 1e-12)
})

test_that("critere 4 : les deux cotes de la limite voient la meme chose", {
  # Un pixel sur la limite, vu de la SER 1 (modele 1 a 0,5, modele 2 a 0,5) ou de la SER 2 (l'inverse),
  # recoit les memes probabilites : pas de marche.
  p1 <- data.frame(A = 0.8, B = 0.2)
  p2 <- data.frame(A = 0.1, B = 0.9)
  cote1 <- raccorder_probabilites(p1, p2, 0.5)
  cote2 <- raccorder_probabilites(p2, p1, 0.5)
  expect_equal(unlist(cote1[1, c("A", "B")]), unlist(cote2[1, c("A", "B")]), tolerance = 1e-12)
  expect_equal(cote1$A, 0.45, tolerance = 1e-12)
})

test_that("critere 4 : le poids est continu et monotone, et nul de bande donne un poids de 1", {
  d <- seq(-800, 800, by = 50)
  w <- poids_transition(d, 500)
  expect_true(all(diff(w) >= -1e-12))
  expect_true(all(w >= 0.5 & w <= 1))
  # Pas de saut : la pente est de 1/(2 x 500) = 0,001 par metre, deux distances voisines de 1 m different de 0,001 au plus.
  expect_lte(max(abs(diff(poids_transition(seq(-600, 600, by = 1), 500)))), 1e-3 + 1e-12)
  expect_equal(poids_transition(c(-10, 0, 10), 0), c(1, 1, 1))
})

test_that("raccorder : un type absent d'un cote vaut 0 et la somme reste 1", {
  a <- data.frame(A = c(0.7, 0.2), B = c(0.3, 0.8))
  b <- data.frame(B = c(0.5, 0.5), C = c(0.5, 0.5))
  m <- raccorder_probabilites(a, b, c(0.6, 0.9))
  expect_setequal(names(m), c("A", "B", "C"))
  expect_equal(rowSums(m[, c("A", "B", "C")]), c(1, 1), tolerance = 1e-12)
  expect_equal(m$A[1], 0.6 * 0.7, tolerance = 1e-12)
})

# --- Referentiel des SER : inst/extdata/ser/ser_codes.csv (mission 002) -----------------------------
# Decomptes de docs/referentiels/ser.md (section « Decomptes »), recomptes sur le fichier le 2026-11-22.
# Ces tests lisent le fichier et ne dependent pas de R/ : ils sont verts des maintenant.

lire_ser_codes <- function() {
  utils::read.csv(chemin_ser_codes(), comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
}

test_that("ser_codes.csv : 86 SER principales, 5 d'alluvions, 91 codes distincts", {
  d <- lire_ser_codes()
  expect_equal(nrow(d), 91L)
  expect_equal(sum(d$type_ser == "principale"), 86L)
  expect_equal(sum(d$type_ser == "alluvions_recentes"), 5L)
  expect_setequal(unique(d$type_ser), c("principale", "alluvions_recentes"))
  expect_equal(length(unique(d$code_ser)), 91L)
})

test_that("ser_codes.csv : GRECO A a K plus L, avec la repartition des SER principales", {
  d <- lire_ser_codes()
  expect_equal(length(unique(d$code_greco)), 12L)
  expect_setequal(unique(d$code_greco), c(LETTERS[1:11], "L"))
  princ <- d[d$type_ser == "principale", ]
  expect_equal(length(unique(princ$code_greco)), 11L)  # A a K : la Corse est la GRECO K
  par_greco <- table(princ$code_greco)
  attendu <- c(A = 6, B = 21, C = 8, D = 2, E = 2, F = 12, G = 14, H = 6, I = 5, J = 7, K = 3)
  expect_equal(as.integer(par_greco[names(attendu)]), as.integer(attendu))
  expect_equal(sum(attendu), 86)
  # Les 5 SER d'alluvions sont L1 a L5, toutes en GRECO L.
  allu <- d[d$type_ser == "alluvions_recentes", ]
  expect_setequal(allu$code_ser, paste0("L", 1:5))
  expect_true(all(allu$code_greco == "L"))
})

test_that("ser_codes.csv : la GRECO est la premiere lettre du code SER", {
  d <- lire_ser_codes()
  expect_identical(substr(d$code_ser, 1, 1), d$code_greco)
})

test_that("greco_de_ser : premiere lettre du code, pour les 91 codes du referentiel", {
  d <- lire_ser_codes()
  expect_identical(unname(greco_de_ser("H10")), "H")
  expect_identical(unname(greco_de_ser(c("A11", "K13", "L5"))), c("A", "K", "L"))
  expect_identical(unname(greco_de_ser(d$code_ser)), d$code_greco)
})

test_that("greco_de_ser : un code hors referentiel est refuse (a confirmer par Pascal)", {
  # Hypothese du testeur : un code absent de ser_codes.csv (« Z99 », « h10 », vide) ne doit pas
  # produire de GRECO inventee. Le plan de 003 ne dit pas si c'est une erreur ou un NA : question posee.
  expect_erreur(greco_de_ser("Z99"))
})

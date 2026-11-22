# Outils internes (non exportés).

# Valeur par défaut d'un champ de liste absent.
`%||%` <- function(a, b) if (is.null(a)) b else a

# Évalue `expr` avec une graine fixée, sans toucher au générateur aléatoire de
# l'utilisateur (l'état de .Random.seed est restauré en sortie).
avec_graine <- function(graine, expr) {
  env <- globalenv()
  existait <- exists(".Random.seed", envir = env, inherits = FALSE)
  ancien <- if (existait) get(".Random.seed", envir = env, inherits = FALSE) else NULL
  on.exit({
    if (existait) {
      assign(".Random.seed", ancien, envir = env)
    } else if (exists(".Random.seed", envir = env, inherits = FALSE)) {
      rm(".Random.seed", envir = env)
    }
  }, add = TRUE)
  set.seed(graine)
  force(expr)
}

# Graine passée à ranger. Pour ranger, `seed = 0` veut dire « graine tirée au hasard » :
# on décale donc de 1 pour que la graine 0 du prototype reste reproductible.
graine_ranger <- function(graine) as.integer(graine) + 1L

# Arrête net si des colonnes manquent, en les nommant.
verifier_colonnes <- function(df, colonnes, quoi = "le tableau") {
  manque <- setdiff(colonnes, names(df))
  if (length(manque) > 0) {
    arreter(sprintf("colonnes absentes de %s : %s", quoi, paste(manque, collapse = ", ")))
  }
  invisible(TRUE)
}

# Matrice numérique des colonnes `colonnes` d'un data.frame.
matrice_num <- function(df, colonnes) {
  m <- as.matrix(as.data.frame(df)[, colonnes, drop = FALSE])
  storage.mode(m) <- "double"
  m
}

# Découpage en plis, comme KFold de scikit-learn sans mélange : plis contigus, les
# premiers d'une unité plus grands quand n n'est pas divisible par k.
plis_contigus <- function(n, plis) {
  tailles <- rep(n %/% plis, plis)
  reste <- n %% plis
  if (reste > 0) tailles[seq_len(reste)] <- tailles[seq_len(reste)] + 1L
  rep(seq_len(plis), times = tailles)
}

# Découpage en plis mélangés (KFold avec mélange), à graine fixée.
plis_melanges <- function(n, plis, graine) {
  avec_graine(graine, sample(rep_len(seq_len(plis), n)))
}

# Découpage en plis stratifiés par classe (StratifiedKFold avec mélange), à graine fixée.
plis_stratifies <- function(y, plis, graine) {
  y <- as.character(y)
  pli <- integer(length(y))
  avec_graine(graine, {
    for (cl in sort(unique(y), method = "radix")) {
      idx <- which(y == cl)
      pli[idx] <- sample(rep_len(seq_len(plis), length(idx)))
    }
  })
  pli
}

# Indice de la première valeur maximale de chaque ligne.
indice_max_ligne <- function(m) {
  m <- as.matrix(m)
  max.col(replace(m, is.na(m), -Inf), ties.method = "first")
}

# Arrêt avec un message en UTF-8 préservé : un objet condition n'est pas retraduit dans
# l'encodage de la session (une session en locale C ou POSIX abîmerait les accents).
arreter <- function(message) {
  stop(structure(class = c("typo_erreur", "error", "condition"),
                 list(message = enc2utf8(message), call = NULL)))
}

# Écrit des lignes de texte en UTF-8, octet pour octet, quelle que soit la locale.
ecrire_lignes_utf8 <- function(lignes, chemin) {
  con <- file(chemin, open = "wb")
  on.exit(close(con), add = TRUE)
  writeLines(enc2utf8(as.character(lignes)), con, useBytes = TRUE)
  invisible(chemin)
}

# Écrit un data.frame en CSV (séparateur virgule, point décimal, en-tête, chaînes entre
# guillemets, NA écrit « NA »), en UTF-8 quelle que soit la locale de la session.
ecrire_csv_utf8 <- function(df, chemin) {
  champ <- function(v) {
    if (is.factor(v)) v <- as.character(v)
    if (is.character(v)) {
      out <- paste0("\"", gsub("\"", "\"\"", enc2utf8(v), fixed = TRUE), "\"")
      out[is.na(v)] <- "NA"
      return(out)
    }
    out <- as.character(v)
    out[is.na(v)] <- "NA"
    out
  }
  entete <- paste(paste0("\"", enc2utf8(names(df)), "\""), collapse = ",")
  if (nrow(df) == 0) return(ecrire_lignes_utf8(entete, chemin))
  colonnes <- lapply(df, champ)
  corps <- do.call(paste, c(colonnes, sep = ","))
  ecrire_lignes_utf8(c(entete, corps), chemin)
}

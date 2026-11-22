# Lissage à l'échelle de lecture (lissage.py du prototype).

# Somme sur une fenêtre carrée de `fenetre` pixels, bords remplis de zéros, alignée
# comme uniform_filter de scipy (fenêtre de i - fenetre %/% 2 à i - fenetre %/% 2 + fenetre - 1).
somme_fenetre <- function(grille, fenetre) {
  ni <- nrow(grille)
  nj <- ncol(grille)
  d0 <- -(fenetre %/% 2)
  decalages <- d0:(d0 + fenetre - 1)
  out <- matrix(0, ni, nj)
  for (di in decalages) {
    for (dj in decalages) {
      li <- seq_len(ni) + di
      lj <- seq_len(nj) + dj
      oki <- li >= 1 & li <= ni
      okj <- lj >= 1 & lj <= nj
      out[oki, okj] <- out[oki, okj] + grille[li[oki], lj[okj]]
    }
  }
  out
}

#' Lisser les probabilités à l'échelle de lecture
#'
#' Moyenne les probabilités de chaque type sur une fenêtre carrée de pixels (3 × 3 pixels
#' de 25 m font 0,56 ha : lecture au quart ou au demi-hectare). Les pixels absents (hors
#' forêt) ne comptent pas dans la moyenne ; les lignes sont ramenées à une somme de 1.
#'
#' @param probas data.frame de probabilités, une colonne par type, une ligne par pixel.
#' @param i,j Indices entiers de ligne et de colonne de chaque pixel dans la grille.
#' @param fenetre Côté de la fenêtre, en pixels. **Provisoire** : 3, repris du prototype.
#'
#' @return data.frame de mêmes colonnes et de mêmes lignes que `probas`.
#' @export
lisser_probabilites <- function(probas, i, j, fenetre = 3) {
  if (fenetre <= 1) return(probas)
  i <- as.integer(i)
  j <- as.integer(j)
  i0 <- i - min(i) + 1L
  j0 <- j - min(j) + 1L
  forme <- c(max(i0), max(j0))
  pos <- cbind(i0, j0)
  presence <- matrix(0, forme[1], forme[2])
  presence[pos] <- 1
  n <- somme_fenetre(presence, fenetre)[pos]
  out <- matrix(0, nrow(probas), ncol(probas))
  for (k in seq_len(ncol(probas))) {
    grille <- matrix(0, forme[1], forme[2])
    grille[pos] <- as.numeric(probas[[k]])
    out[, k] <- somme_fenetre(grille, fenetre)[pos] / n
  }
  out <- out / rowSums(out)
  res <- as.data.frame(out)
  names(res) <- names(probas)
  res
}

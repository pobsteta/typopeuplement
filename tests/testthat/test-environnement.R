test_that("les dependances de l'ADR 0004 se chargent", {
  for (pkg in c("sf", "terra", "ranger", "e1071", "MASS")) {
    expect_true(
      requireNamespace(pkg, quietly = TRUE),
      info = paste("paquet absent :", pkg)
    )
  }
})

test_that("les versions respectent les minimums de DESCRIPTION", {
  expect_true(packageVersion("sf") >= "1.0-0")
  expect_true(packageVersion("terra") >= "1.7-0")
  expect_true(getRversion() >= "4.1.0")
})

test_that("sf et terra fonctionnent en Lambert-93 (EPSG:2154)", {
  # Point en x, y (m), systeme explicite : Lambert-93.
  pt <- sf::st_sfc(sf::st_point(c(700000, 6600000)), crs = 2154)
  expect_equal(sf::st_crs(pt)$epsg, 2154L)
  r <- terra::rast(nrows = 2, ncols = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2,
                   crs = "EPSG:2154")
  expect_equal(terra::ncell(r), 4L)
})

test_that("ranger, e1071 et MASS tournent sur un jeu minimal", {
  set.seed(1)
  d <- iris
  rf <- ranger::ranger(Species ~ ., data = d, num.trees = 20, seed = 1)
  expect_s3_class(rf, "ranger")
  nb <- e1071::naiveBayes(Species ~ ., data = d)
  expect_length(predict(nb, d), nrow(d))
  lda <- MASS::lda(Species ~ ., data = d)
  expect_length(predict(lda, d)$class, nrow(d))
})

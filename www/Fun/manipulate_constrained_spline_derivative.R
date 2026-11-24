## Explore derivative-constrained regression splines while varying degree,
## segments, derivative order, sample size, and constraint bounds.
## The constraints follow Du, Parmeter and Racine (2013), Statistica Sinica.

library(manipulate)
library(crs)
library(quadprog)

## Refit and redraw the constrained spline after a control changes.

manipulate.plot <- function(n, spline.degree, spline.segments, dgp.frequency, lower, upper, deriv.order, which.plot, weighted, smoothing, distance) {

  if (lower > upper) {
    lower <- upper - 0.01
  }

  if (identical(lower, upper)) {
    lower <- upper - 0.01
  }

  if (smoothing != "joint" && spline.degree < deriv.order && (lower > 0 || upper < 0))
    stop("This spline degree gives a zero derivative. Increase the degree or include zero in the bounds.")

  ramp <- grDevices::hcl.colors(256L, "viridis")
  free.col <- ramp[35L]
  fit.col <- ramp[130L]
  weighted.col <- ramp[178L]

  set.seed(42)

  x <- sort(runif(n))
  dgp <- function(x) sin(dgp.frequency * pi * x)
  dgp.partial.1 <- function(x) dgp.frequency * pi * cos(dgp.frequency * pi * x)
  dgp.partial.2 <- function(x) -dgp.frequency^2 * pi^2 * sin(dgp.frequency * pi * x)
  y <- dgp(x) + rnorm(n, sd = .5 * sd(dgp(x)))

  data.train <- data.frame(y, x)

  rm(x, y)

  ## Cross-validate segment count alone or jointly with spline degree.
  model.unres <- crs(y ~ x, data = data.train, basis = "tensor",
    cv = if (smoothing == "manual") "none" else "exhaustive",
    complexity = if (smoothing == "segments") "knots" else "degree-knots",
    degree = spline.degree, segments = spline.segments,
    degree.min = deriv.order, deriv = deriv.order)
  spline.degree <- model.unres$degree
  spline.segments <- model.unres$segments

  if (which.plot == "Conditional mean and Partial derivative") {
    par(mfrow = c(2, 1))
  } else {
    par(mfrow = c(1, 1))
  }

  ## A.fit maps changes in response weights to changes in fitted levels
  ## via its transpose. The bounds apply at the observed x.
  A.fit <- crshat(model.unres, y = data.train$y, output = "constraint")
  A <- crshat(model.unres, y = data.train$y, output = "constraint",
    deriv = deriv.order, deriv.index = 1)
  p.hat <- rep(1, n)
  object.unres <- drop(crossprod(A, p.hat))
  if (any(object.unres < lower | object.unres > upper)) {
    ## Center the QP at unit weights; regularize the fitted-level objective.
    D <- diag(n)
    if (distance == "fits") D <- tcrossprod(A.fit) + sqrt(.Machine$double.eps) * D
    delta <- solve.QP(Dmat = D, dvec = numeric(n), Amat = cbind(A, -A),
      bvec = c(lower - object.unres, object.unres - upper))$solution
    p.hat <- p.hat + delta
  }

  ## Refit with the constrained response weights.
  data.trans <- data.frame(y = p.hat * data.train$y, data.train[, 2:ncol(data.train), drop = FALSE])

  model.res <- crs(y ~ x, cv = "none",
                   deriv = deriv.order,
                   degree = model.unres$degree,
                   segments = model.unres$segments,
                   basis = model.unres$basis,
                   data = data.trans)

  ## Compare the true, unrestricted, and constrained objects.
  if (which.plot == "Conditional mean" || which.plot == "Conditional mean and Partial derivative") {

    ylim <- with(data.train, c(min(y, dgp(x), fitted(model.unres), fitted(model.res)),
                              max(y, dgp(x), fitted(model.unres), fitted(model.res))))

    with(data.train, plot(x, y,
                         cex = 0.25,
                         col = "lightgrey",
                         ylab = "Y",
                         xlab = "X",
                         ylim = ylim,
                         main = "Constrained B-spline Regression",
                         sub = paste("Spline degree = ", spline.degree, ", spline segments = ", spline.segments, ", n = ", n, ", upper = ", formatC(upper, format = "f", digits = 1), ", lower = ", formatC(lower, format = "f", digits = 1), sep = "")))

    with(data.train, lines(x, dgp(x), lty = 1, col = 1))

    with(data.train, lines(x, fitted(model.unres), lty = 2, col = free.col, lwd = 2))
    with(data.train, lines(x, fitted(model.res), col = fit.col, lty = 4, lwd = 2))
    ## Weighted responses are observations on the mean panel.
    if (weighted) with(data.train, points(x, y * p.hat, col = weighted.col, cex = 0.35))

    legend("topleft",
           c(paste("DGP: sin(", dgp.frequency, "*pi*x)", sep = ""), "Unconstrained Estimate",
             "Constrained Estimate", if (weighted) "Weighted Y"),
           col = c("black", free.col, fit.col, if (weighted) weighted.col),
           lwd = c(1, 2, 2, if (weighted) NA),
           lty = c(1, 2, 4, if (weighted) NA),
           pch = c(NA_integer_, NA_integer_, NA_integer_, if (weighted) 1L),
           cex = 0.75, bty = "n")
  }

  if (which.plot == "Partial derivative" || which.plot == "Conditional mean and Partial derivative") {

    if (deriv.order == 1) {
      deriv.vec <- with(data.train, dgp.partial.1(x))
    } else {
      deriv.vec <- with(data.train, dgp.partial.2(x))
    }

    ylim <- c(min(deriv.vec, model.unres$deriv.mat[, 1], model.res$deriv.mat[, 1]),
      max(deriv.vec, model.unres$deriv.mat[, 1], model.res$deriv.mat[, 1]))

    with(data.train, plot(x, deriv.vec,
                         ylab = "Derivative",
                         xlab = "X",
                         ylim = ylim,
                         main = "Constrained B-spline Derivative",
                         sub = paste("Spline degree = ", spline.degree, ", spline segments = ", spline.segments, ", n = ", n, ", upper = ", formatC(upper, format = "f", digits = 2), ", lower = ", formatC(lower, format = "f", digits = 2), sep = ""), type = "l", lty = 1, col = 1))

    with(data.train, lines(x, model.unres$deriv.mat[, 1], lty = 2, col = free.col, lwd = 2))
    with(data.train, lines(x, model.res$deriv.mat[, 1], lty = 4, col = fit.col, lwd = 2))

    legend("topleft",
           c(paste("True Derivative (order ", deriv.order, ")", sep = ""), "Unconstrained Derivative", "Constrained Derivative"),
           col = c("black", free.col, fit.col),
           lwd = c(1, 2, 2),
           lty = c(1, 2, 4),
           cex = 0.75,
           bty = "n")

  }

}

manipulate(manipulate.plot(n, spline.degree, spline.segments, dgp.frequency, lower, upper, deriv.order, which.plot, weighted, smoothing, distance),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           deriv.order = picker(1, 2, label = "Order of derivative"),
           which.plot = picker("Conditional mean", "Partial derivative", "Conditional mean and Partial derivative", label = "Function to plot"),
           dgp.frequency = slider(1, 4, 2, label = "DGP frequency (a*pi*x)", step = 1, ticks = TRUE),
           spline.degree = slider(0, 10, 5, label = "B-spline degree", step = 1, ticks = TRUE),
           spline.segments = slider(1, 10, 2, label = "B-spline segments", step = 1, ticks = TRUE),
           lower = slider(-150, 150, -10, step = 1, label = "Lower bound"),
           upper = slider(-150, 150, 10, step = 1, label = "Upper bound"),
           distance = picker("Weight deviation" = "weights",
                             "Fit deviation (regularized)" = "fits",
                             label = "Objective"),
           smoothing = picker("Manual" = "manual",
                              "Cross-validate segments" = "segments",
                              "Cross-validate segments and degree" = "joint",
                              label = "Smoothing parameter selection"),
           weighted = checkbox(FALSE, "Show weighted Y"))

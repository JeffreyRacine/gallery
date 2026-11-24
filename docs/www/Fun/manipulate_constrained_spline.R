## Bound the level, slope, or curvature of a regression spline at the observed x.
## The constraints follow Du, Parmeter and Racine (2013), Statistica Sinica.
library(manipulate)
library(crs)
library(quadprog)

manipulate.plot <- function(n, spline.degree, spline.segments, dgp.frequency,
                            deriv.order, lower, upper, weighted, smoothing, distance) {
  if (lower > upper)
    stop("Set the lower bound at or below the upper bound.")
  if (smoothing != "joint" && spline.degree < deriv.order)
    stop("Choose a spline degree at least as large as the derivative order.")

  set.seed(42)
  x <- sort(runif(n))
  omega <- dgp.frequency * pi
  signal <- sin(omega * x)
  scale <- sd(signal)
  truth <- signal / scale
  y <- truth + rnorm(n, sd = .5)
  data.train <- data.frame(x = x, y = y)

  ## Choose the spline structure once and keep it fixed when imposing bounds.
  model <- crs(y ~ x, data = data.train, basis = "tensor",
    cv = if (smoothing == "manual") "none" else "exhaustive",
    complexity = if (smoothing == "segments") "knots" else "degree-knots",
    degree = spline.degree, segments = spline.segments, degree.min = deriv.order)

  ## A.fit maps response weights to fitted levels via its transpose.
  ## A uses the same spline to evaluate the quantity selected for the bounds.
  A.fit <- crshat(model, y = y, output = "constraint")
  A <- if (deriv.order == 0L) A.fit else
    crshat(model, y = y, deriv = deriv.order, deriv.index = 1, output = "constraint")
  p <- rep(1, n)
  unrestricted <- drop(crossprod(A, p))
  if (any(unrestricted < lower | unrestricted > upper)) {
    D <- diag(n)
    if (distance == "fits")
      D <- tcrossprod(A.fit) + sqrt(.Machine$double.eps) * D

    ## Solve for changes from unit weights. Equal bounds prescribe an exact
    ## value; only independent equations are needed in the quadratic program.
    if (lower == upper) {
      basis <- qr(A, LAPACK = TRUE)
      diagonals <- abs(diag(qr.R(basis)))
      rank <- sum(diagonals > max(diagonals) * n * .Machine$double.eps)
      keep <- basis$pivot[seq_len(rank)]
      delta <- solve.QP(D, numeric(n), A[, keep, drop = FALSE],
                        lower - unrestricted[keep], meq = length(keep))$solution
    } else {
      delta <- solve.QP(D, numeric(n), cbind(A, -A),
                        c(lower - unrestricted, unrestricted - upper))$solution
    }
    p <- p + delta
  }
  restricted <- drop(crossprod(A, p))
  if (any(!is.finite(restricted)) || max(lower - restricted, restricted - upper) > 1e-6)
    stop("The selected bounds were not attained on the observation grid.")

  fit <- drop(crossprod(A.fit, p))
  fit.free <- as.numeric(fitted(model))
  quantity <- c("Level", "Slope", "Curvature")[deriv.order + 1L]
  old.par <- par(no.readonly = TRUE)
  on.exit(par(old.par), add = TRUE)
  par(mfrow = c(1, if (deriv.order > 0L) 2L else 1L),
      mar = c(3.5, 3.8, 2.1, .8), oma = c(1.8, 0, 0, 0), mgp = c(2.1, .7, 0))
  guides <- c(lower, upper)
  plot(x, y, pch = 16, cex = .35, col = "grey75", xlab = "X", ylab = "Y",
       main = "B-spline regression",
       ylim = range(y, truth, fit.free, fit, if (weighted) y * p, if (deriv.order == 0L) guides))
  if (deriv.order == 0L) abline(h = guides, lty = 3, col = "grey50")
  if (weighted) points(x, y * p, pch = 1, col = "darkorange2", cex = .45)
  lines(x, truth)
  lines(x, fit.free, col = "steelblue4", lty = 2, lwd = 2)
  lines(x, fit, col = "firebrick3", lty = 4, lwd = 2)
  legend("topleft", c("Population", "Unrestricted", "Constrained", if (weighted) "Weighted Y"),
         col = c("black", "steelblue4", "firebrick3", if (weighted) "darkorange2"),
         lty = c(1, 2, 4, if (weighted) NA), lwd = c(1, 2, 2, if (weighted) NA),
         pch = c(NA_integer_, NA_integer_, NA_integer_, if (weighted) 1L), cex = .7, bty = "n")

  if (deriv.order > 0L) {
    deriv.truth <- if (deriv.order == 1L) omega * cos(omega * x) / scale else -omega^2 * truth
    plot(x, deriv.truth, type = "l", xlab = "X", ylab = quantity, main = paste(quantity, "bounds"),
         ylim = range(deriv.truth, unrestricted, restricted, guides))
    abline(h = guides, lty = 3, col = "grey50")
    lines(x, unrestricted, col = "steelblue4", lty = 2, lwd = 2)
    lines(x, restricted, col = "firebrick3", lty = 4, lwd = 2)
  }
  mtext(sprintf("%s bounds [%g, %g] at observed x  |  Degree %d, segments %d, n = %d",
                quantity, lower, upper, model$degree, model$segments, n),
        side = 1, outer = TRUE, line = .3, cex = .8)
  invisible(list(x = x, fit = fit, restricted = restricted, weights = p))
}

manipulate(
  manipulate.plot(n, spline.degree, spline.segments, dgp.frequency, deriv.order,
                  lower, upper, weighted, smoothing, distance),
  n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
  dgp.frequency = slider(1, 4, 2, step = 1, label = "DGP frequency (a*pi*x)"),
  spline.degree = slider(0, 10, 5, step = 1, label = "B-spline degree"),
  spline.segments = slider(1, 10, 4, step = 1, label = "B-spline segments"),
  deriv.order = picker("Level (0)" = 0L, "Slope (1)" = 1L, "Curvature (2)" = 2L,
                       label = "Quantity to constrain"),
  lower = slider(-10, 10, -1.5, step = .1, label = "Lower bound"),
  upper = slider(-10, 10, 1.5, step = .1, label = "Upper bound"),
  distance = picker("Weight deviation" = "weights", "Fit deviation (regularized)" = "fits",
                    label = "Objective"),
  smoothing = picker("Manual" = "manual", "Cross-validate segments" = "segments",
                     "Cross-validate segments and degree" = "joint",
                     label = "Smoothing parameter selection"),
  weighted = checkbox(FALSE, "Show weighted Y"))

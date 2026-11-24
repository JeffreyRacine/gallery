## Source in RStudio. The simulation follows the ECON 768 Moment example.
## Wan, Datta, Lee and Kong (2017), "Monotonic single-index models to assess
## drug interactions", Statistics in Medicine 36, 655–670. doi:10.1002/sim.7158
## Their response function supplies the DGP. Here the link is estimated with
## npindex() and constrained by reweighting the responses on the fitted index.
## Start with a Gaussian local-constant fit and a manual bandwidth. Select
## "Cross-validate bandwidth" for the bandwidth selection used in the slides.
library(manipulate)
library(np)
library(quadprog)

isotonic_index_demo <- function(n, noise, n.grid, distance, view, weighted,
                                kernel = "gaussian", degree = 0L, bandwidth = .3,
                                smoothing = "manual") {
  set.seed(42)
  X <- data.frame(x1 = runif(n), x2 = runif(n))
  t.true <- X$x1 + X$x2
  mu <- 100 * t.true / (1 + t.true)
  y <- mu + rnorm(n, sd = noise * sd(mu))

  ## All three modes estimate beta. In manual mode the last entry of bws
  ## fixes h; the two zero entries ask np to initialize the index coefficients.
  dat <- data.frame(y, X)
  spec <- if (smoothing == "joint") {
    list(nomad = "auto", degree.min = 0L, degree.max = 5L)
  } else {
    list(regtype = "lp", degree = as.integer(degree), bernstein.basis = TRUE)
  }
  if (smoothing == "manual") {
    spec$bws <- c(0, 0, bandwidth)
    spec$only.optimize.beta <- TRUE
  }
  bw <- tryCatch(
    do.call(npindexbw, c(list(formula = y ~ x1 + x2, data = dat, ckertype = kernel), spec)),
    error = function(err) {
      if (smoothing == "manual" && grepl("raw-invalid held bandwidth", conditionMessage(err), fixed = TRUE))
        stop("The index fit could not use this manual bandwidth. Try a wider bandwidth or select cross-validation.\n",
             conditionMessage(err), call. = FALSE)
      stop(err)
    })
  model <- npindex(bws = bw, data = dat, se = FALSE)
  degree <- as.integer(bw$degree)
  index <- as.numeric(model$index)
  grid <- sort(c(index, seq(min(index), max(index), length.out = n.grid)))
  ## npindexhat() takes original predictor columns. Since beta[1] = 1,
  ## the evaluation row (t, 0) has index t. Training still uses both columns.
  X.grid <- data.frame(x1 = grid, x2 = 0)
  A <- npindexhat(model$bws, txdat = X, exdat = X.grid, y = y, output = "constraint")
  A1 <- npindexhat(model$bws, txdat = X, exdat = X.grid, y = y, s = 1L, output = "constraint")
  p <- rep(1, n)
  free <- drop(crossprod(A, p))
  slope.free <- drop(crossprod(A1, p))
  if (any(!is.finite(c(free, slope.free))))
    stop("The link or its slope is undefined at a grid point. Try a wider bandwidth.")
  constraints <- A1
  check.increments <- kernel != "gaussian" || degree > 0L
  if (check.increments) {
    ## A local-polynomial slope need not equal the slope of the plotted link.
    ## A uniform local-constant link can even jump while its within-step slope
    ## is zero. Require neighbouring fitted levels to be nondecreasing too.
    distinct <- which(!duplicated(grid))
    increments <- A[, distinct[-1L], drop = FALSE] - A[, head(distinct, -1L), drop = FALSE]
    constraints <- cbind(A1, increments)
  }
  at.unit.weights <- drop(crossprod(constraints, p))
  if (any(at.unit.weights < 0)) {
    ## Center the grid constraints at the unrestricted response weights.
    ## A' delta gives the change in the link at each grid entry.
    D <- diag(n)
    if (distance == "fits") D <- tcrossprod(A) + sqrt(.Machine$double.eps) * D
    ## Slopes and adjacent increments can have very different scales. Divide
    ## both sides of each nonzero inequality by the same positive norm.
    norms <- sqrt(colSums(constraints^2))
    keep <- which(norms > 0)
    delta <- solve.QP(Dmat = D, dvec = numeric(n),
                      Amat = sweep(constraints[, keep, drop = FALSE], 2L, norms[keep], "/"),
                      bvec = -at.unit.weights[keep] / norms[keep])$solution
    p <- p + delta
  }
  fit <- drop(crossprod(A, p))
  slope <- drop(crossprod(A1, p))
  if (any(!is.finite(c(fit, slope))) || min(slope) < -1e-6 ||
      (check.increments && min(diff(fit)) < -1e-6))
    stop("The fit failed the isotonic check on the constraint grid. Try a wider bandwidth.")

  old.par <- par(no.readonly = TRUE)
  on.exit(par(old.par), add = TRUE)
  par(mfrow = c(1, if (view == "both") 2 else 1), mar = c(3.8, 4.1, 2.3, .9),
      oma = c(1.6, 0, 0, 0), mgp = c(2.2, .7, 0))
  if (view != "slope") {
    y.weighted <- if (weighted) y * p
    plot(index, y, pch = 16, cex = .45, col = "grey65",
         ylim = range(y, fit, free, y.weighted), main = "Single-index link",
         xlab = "Fitted index", ylab = "Response")
    if (weighted) points(index, y.weighted, col = "darkorange2", cex = .55)
    lines(grid, free, col = "steelblue4", lwd = 2)
    lines(grid, fit, col = "firebrick3", lty = 2, lwd = 2)
    legend("topleft", c("Unrestricted", "Constrained", if (weighted) "Weighted Y"),
           col = c("steelblue4", "firebrick3", if (weighted) "darkorange2"),
           lty = c(1, 2, if (weighted) NA), pch = c(NA_integer_, NA_integer_, if (weighted) 1L),
           lwd = 2, bty = "n", cex = .75)
  }
  if (view != "link") {
    plot(grid, slope.free, type = "l", col = "steelblue4", lwd = 2,
         ylim = range(0, slope, slope.free),
         main = if (kernel == "uniform" && degree == 0L) "Slope within steps" else "Estimated link slope",
         xlab = "Fitted index", ylab = "Slope")
    abline(h = 0, lty = 3, col = "grey45")
    lines(grid, slope, col = "firebrick3", lty = 2, lwd = 2)
    legend("topright", c("Unrestricted", "Constrained"), col = c("steelblue4", "firebrick3"),
           lty = 1:2, lwd = 2, bty = "n", cex = .75)
  }
  subtitle <- sprintf("%s kernel, degree %d, h = %.3g, beta = (1, %.3f)",
                      kernel, degree, bw$bw[1L], coef(model)[2L])
  mtext(subtitle, side = 1, outer = TRUE, line = .2, cex = .8)
  invisible(list(grid = grid, index = index, beta = coef(model), bandwidth = bw$bw, degree = degree,
                 unrestricted = free, constrained = fit, slope.unrestricted = slope.free,
                 slope.constrained = slope, weights = p))
}

manipulate(
  isotonic_index_demo(n, noise, n.grid, distance, view, weighted, kernel, degree, bandwidth, smoothing),
  n = slider(100, 1000, initial = 500, step = 100, label = "Observations"),
  noise = slider(.25, 1.5, initial = 1, step = .25, label = "Noise SD relative to signal SD"),
  kernel = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
  degree = slider(0, 5, initial = 0, step = 1, label = "Local polynomial degree"),
  bandwidth = slider(.05, 1, initial = .3, step = .05, label = "Manual bandwidth (index units)"),
  n.grid = slider(0, 1000, initial = 1000, step = 100, label = "Grid points in addition to observed indices"),
  distance = picker("Fit deviation (regularized)" = "fits", "Weight deviation" = "weights",
                    label = "Objective"),
  smoothing = picker("Manual" = "manual", "Cross-validate bandwidth" = "bandwidth",
                     "Cross-validate bandwidth and degree" = "joint",
                     label = "Smoothing parameter selection"),
  view = picker("Link and derivative" = "both", "Link" = "link", "Derivative" = "slope",
                label = "Display"),
  weighted = checkbox(FALSE, "Show weighted Y"))

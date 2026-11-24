## Explore bounded local-polynomial regression while varying the
## bandwidth, sample size, constraint bounds, and distance criterion.
## The estimator follows Du, Parmeter and Racine (2013), Statistica Sinica.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
library(quadprog)

build_fixed_degree_bw <- function(formula, data, degree, sf, ckertype) {
  npregbw(formula,
    data = data,
    regtype = "lp",
    degree = as.integer(degree),
    degree.select = "manual",
    bernstein.basis = TRUE,
    ckertype = ckertype,
    ## A manual scale factor is converted to h using the spread of x and n^(-1/5).
    bandwidth.compute = is.null(sf),
    bwscaling = !is.null(sf),
    bws = sf)
}

build_nomad_lp_bw <- function(formula, data, degree.start, degree.min, degree.max, ckertype) {
  if (!requireNamespace("crs", quietly = TRUE)) {
    stop("Automatic LP degree search uses npregbw(..., nomad = \"auto\"), ",
      "which currently requires the 'crs' package.")
  }

  npregbw(formula,
    data = data,
    regtype = "lp",
    ckertype = ckertype,
    ## nomad = "auto" uses exhaustive search for p = 1 and NOMAD otherwise.
    nomad = "auto",
    degree.min = as.integer(degree.min),
    degree.max = as.integer(degree.max),
    degree.start = as.integer(degree.start))
}

## Expose the estimator and constraint controls in an interactive panel.
manipulate.plot <- function(n, dgp.frequency, p, gradient, sf, ckertype, lower, upper, weighted, smoothing, distance = "weights", population = TRUE) {

  if (smoothing != "joint" && gradient > p)
    stop("Choose a polynomial degree at least as large as the derivative order.")

  if (lower > upper)
    stop("Set the lower bound at or below the upper bound.")

  ramp <- grDevices::hcl.colors(256L, "viridis")
  free.col <- ramp[35L]
  fit.col <- ramp[130L]
  weighted.col <- ramp[178L]

  set.seed(42)

  x <- sort(runif(n))
  omega <- dgp.frequency * pi
  signal <- sin(omega * x)
  signal.sd <- sd(signal)
  truth <- signal / signal.sd
  y <- truth + rnorm(n, sd = .5)
  lp.data <- data.frame(y = y, x = x)

  if (smoothing == "joint") {
    lp.bw <- build_nomad_lp_bw(formula = y ~ x,
      data = lp.data,
      degree.start = max(p, gradient),
      degree.min = gradient,
      degree.max = 5L,
      ckertype = ckertype)
  } else {
    lp.bw <- build_fixed_degree_bw(formula = y ~ x,
      data = lp.data,
      degree = p,
      sf = if (smoothing == "manual") sf else NULL,
      ckertype = ckertype)
  }

  bw <- lp.bw$bandwidth$x[1L]
  p <- as.integer(lp.bw$degree[1L])

  ## Each column gives the response-weighted coefficients at one observed x.
  ## Transposing A.fit maps weights to fitted levels; A supplies the constraints.
  p.u <- rep(1, n)
  A.fit <- npreghat(bws = lp.bw, txdat = lp.data["x"], y = y,
    output = "constraint")
  A <- if (gradient == 0) A.fit else
    npreghat(bws = lp.bw, txdat = lp.data["x"], y = y,
      output = "constraint", s = as.integer(gradient))

  fitted.unres <- drop(crossprod(A.fit, p.u))
  object.unres <- drop(crossprod(A, p.u))
  p.hat <- p.u
  if (any(object.unres < lower | object.unres > upper)) {
    ## With delta = p - p.u, the two distances are sums of squared changes
    ## in the response weights or in the fitted levels at the observed x.
    D <- diag(n)
    if (distance == "fits") {
      ## As in the Moment slides, add a small squared-weight penalty:
      ## the fit Gram matrix can be singular and solve.QP requires PD.
      D <- tcrossprod(A.fit) + sqrt(.Machine$double.eps) * D
    }
    ## Solve for changes from unit weights. Equal bounds prescribe an exact
    ## value; only independent equations are needed in the quadratic program.
    if (lower == upper) {
      ## If A = U diag(d) V', the independent restrictions on p are
      ## U' p = V' rep(lower, n) / d. Center them at the unit weights.
      basis <- svd(A)
      keep <- basis$d > max(basis$d) * n * .Machine$double.eps
      if (!any(keep)) stop("The selected polynomial cannot attain this bound.")
      Q <- basis$u[, keep, drop = FALSE]
      target <- lower * colSums(basis$v[, keep, drop = FALSE]) / basis$d[keep]
      delta <- solve.QP(D, numeric(n), Q, target - colSums(Q), meq = ncol(Q))$solution
    } else {
      delta <- solve.QP(D, numeric(n), cbind(A, -A),
                        c(lower - object.unres, object.unres - upper))$solution
    }
    p.hat <- p.u + delta
  }
  achieved <- drop(crossprod(A, p.hat))
  if (any(!is.finite(achieved)) || max(lower - achieved, achieved - upper) > 1e-6)
    stop("The selected bounds were not attained on the observation grid.")


  fitted.res <- drop(crossprod(A.fit, p.hat))

  old.par <- par(no.readonly = TRUE)
  on.exit(par(old.par), add = TRUE)
  par(mfrow = c(1, if (gradient > 0) 2 else 1), mar = c(3.7, 4, 2.3, .8),
      oma = c(1.7, 0, 0, 0), mgp = c(2.2, .7, 0))
  guides <- c(lower, upper)
  plot(x, y, pch = 16, cex = .35, col = "grey65",
       xlab = "X", ylab = "Y", main = "Local polynomial regression",
       ylim = range(y, truth, fitted.res, fitted.unres, if (weighted) y * p.hat,
                    if (gradient == 0) guides))
  if (gradient == 0) abline(h = guides, lty = 3, col = "grey50")
  if (weighted) points(x, y * p.hat, col = weighted.col, cex = .45)
  if (population) lines(x, truth)
  lines(x, fitted.unres, lty = 2, col = free.col, lwd = 2)
  lines(x, fitted.res, lty = 4, col = fit.col, lwd = 2)
  entries <- c(population, TRUE, TRUE, weighted)
  legend("topleft", c("True mean", "Unrestricted", "Constrained", "Weighted Y")[entries],
         col = c("black", free.col, fit.col, weighted.col)[entries],
         lty = c(1, 2, 4, NA)[entries], lwd = c(1, 2, 2, NA)[entries],
         pch = c(NA_integer_, NA_integer_, NA_integer_, 1L)[entries], cex = .7, bty = "o", bg = grDevices::adjustcolor("white", alpha.f = .9), box.col = NA)

  if (gradient > 0) {
    quantity <- if (gradient == 1) "Slope" else "Curvature"
    deriv.truth <- if (gradient == 1) omega * cos(omega * x) / signal.sd else -omega^2 * truth
    deriv.res <- achieved
    plot(x, deriv.truth, type = if (population) "l" else "n", xlab = "X", ylab = quantity,
         main = paste(quantity, "bounds"), ylim = range(deriv.truth, object.unres, deriv.res, guides))
    abline(h = guides, lty = 3, col = "grey50")
    lines(x, object.unres, col = free.col, lty = 2, lwd = 2)
    lines(x, deriv.res, col = fit.col, lty = 4, lwd = 2)
    entries <- c(population, TRUE, TRUE)
    legend("topright", c(paste("True", tolower(quantity)), "Unrestricted", "Constrained")[entries],
           col = c("black", free.col, fit.col)[entries], lty = c(1, 2, 4)[entries],
           lwd = c(1, 2, 2)[entries], cex = .7, bty = "o", bg = grDevices::adjustcolor("white", alpha.f = .9), box.col = NA)
  }
  mtext(sprintf("h = %.3g, degree = %d, n = %d, bounds [%g, %g]", bw, p, n, lower, upper),
        side = 1, outer = TRUE, line = .3, cex = .8)

}

manipulate(manipulate.plot(n, dgp.frequency, p, gradient, sf, ckertype, lower, upper, weighted, smoothing, distance, population),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           dgp.frequency = slider(1, 4, 2, label = "DGP frequency (a*pi*x)", step = 1, ticks = TRUE),
           p = slider(0, 5, 1, label = "Local Polynomial Order", step = 1, ticks = TRUE),
           gradient = picker(0, 1, 2, label = "s (order of derivative)"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           sf = slider(0.1, 2.5, 0.5, step = 0.1, label = "Manual bandwidth scale factor (x)"),
           lower = slider(-10, 10, -1.5, step = 0.5, label = "Lower bound"),
           upper = slider(-10, 10, 1.5, step = 0.5, label = "Upper bound"),
           distance = picker("Weight deviation" = "weights",
                             "Fit deviation (regularized)" = "fits",
                             label = "Objective"),
           smoothing = picker("Manual" = "manual",
                              "Cross-validate bandwidth" = "bandwidth",
                              "Cross-validate bandwidth and degree" = "joint",
                              label = "Smoothing parameter selection"),
           population = checkbox(TRUE, "Show population curve"),
           weighted = checkbox(FALSE, "Show weighted Y"))

## Explore bounded local-polynomial regression while varying the
## bandwidth, sample size, constraint bounds, and distance criterion.
## The estimator follows Du, Parmeter and Racine (2013), Statistica Sinica.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
library(quadprog)

build_fixed_degree_bw <- function(formula, data, degree, bw, ckertype) {
  npregbw(formula,
    data = data,
    regtype = "lp",
    degree = as.integer(degree),
    degree.select = "manual",
    bernstein.basis = TRUE,
    ckertype = ckertype,
    bandwidth.compute = is.null(bw),
    bws = bw)
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
manipulate.plot <- function(n, dgp.frequency, p, gradient, bw, ckertype, lower, upper, weighted, smoothing, distance = "weights") {

  if (smoothing != "joint" && gradient > p)
    stop("Choose a polynomial degree at least as large as the derivative order.")

  if (lower > upper) {
    lower <- upper - 0.01
  }

  if (identical(lower, upper)) {
    lower <- upper - 0.01
  }

  set.seed(42)

  x <- sort(runif(n))
  dgp <- function(x) {
    signal <- sin(dgp.frequency * pi * x)
    signal / sd(signal)
  }
  y <- dgp(x) + rnorm(n, sd = .5)
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
      bw = if (smoothing == "manual") bw else NULL,
      ckertype = ckertype)
  }

  bw <- lp.bw$bw[1L]
  p <- as.integer(lp.bw$degree[1L])

  plot(x, y,
    cex = 0.2,
    col = "black",
    ylab = "Y",
    xlab = "X",
    main = "Constrained Local Polynomial Regression",
    sub = paste("Bandwidth = ", format(bw, digits = 3, format = "f"),
      ", polynomial order = ", p,
      ", n = ", n,
      ", upper = ", formatC(upper, format = "f", digits = 1),
      ", lower = ", formatC(lower, format = "f", digits = 1),
      sep = ""))

  lines(x, dgp(x), lty = 1, col = 1)

  if (gradient == 0) {
    abline(h = lower, lty = 2, col = 1)
    abline(h = upper, lty = 2, col = 1)
  }

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
    ## Retain both bounds: satisfying one can make the other bind.
    delta <- solve.QP(Dmat = D, dvec = numeric(n),
      Amat = cbind(A, -A),
      bvec = c(lower - object.unres, object.unres - upper))$solution
    p.hat <- p.u + delta
  }

  fitted.res <- drop(crossprod(A.fit, p.hat))

  ## Plot the unrestricted and restricted models and restricted y

  lines(x, fitted.unres, lty = 2, col = 2, lwd = 2)
  lines(x, fitted.res, col = 4, lty = 4, lwd = 3)

  if (weighted) points(x, y * p.hat, col = "orange", cex = 0.35)

  legend("topleft",
    c(paste("DGP: sin(", dgp.frequency, "*pi*x)", sep = ""), "Unconstrained Estimate", "Constrained Estimate", "Weighted Y", "Actual Y"),
    col = c(1, 2, 4, "orange", "black"),
    lwd = c(1, 2, 3, NA, NA),
    lty = c(1, 2, 4, NA, NA),
    pch = c(NA, NA, NA, 1, 1),
    cex = 0.75,
    bty = "n")

}

manipulate(manipulate.plot(n, dgp.frequency, p, gradient, bw, ckertype, lower, upper, weighted, smoothing, distance),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           dgp.frequency = slider(1, 4, 2, label = "DGP frequency (a*pi*x)", step = 1, ticks = TRUE),
           p = slider(0, 5, 1, label = "Local Polynomial Order", step = 1, ticks = TRUE),
           gradient = picker(0, 1, 2, label = "s (order of derivative)"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           bw = slider(0.01, 0.1, 0.04, step = 0.01, label = "Bandwidth"),
           lower = slider(-10, 10, -1.5, step = 0.5, label = "Lower bound"),
           upper = slider(-10, 10, 1.5, step = 0.5, label = "Upper bound"),
           distance = picker("Weight deviation" = "weights",
                             "Fit deviation (regularized)" = "fits",
                             label = "Objective"),
           smoothing = picker("Manual" = "manual",
                              "Cross-validate bandwidth" = "bandwidth",
                              "Cross-validate bandwidth and degree" = "joint",
                              label = "Smoothing parameter selection"),
           weighted = checkbox(FALSE, "Show weighted Y"))

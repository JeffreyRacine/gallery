## Explore constrained local-polynomial production functions while varying
## the bandwidth, sample size, and imposed shape restrictions.
## The estimator follows Du, Parmeter and Racine (2013), Statistica Sinica.

## Note - for undersmoothed functions it is possible that the
## analytical derivative of the estimator \hat g(x) (i.e. were one to
## compute d \hat g(x)/dx) can differ from that delivered by the local
## polynomial estimator (\hat delta(x)). In this case, imposing
## constraints on derivatives may still result in \hat g(x|p)
## appearing to violate the imposed constraint. Any such divergence
## will vanish as the bandwidth increases.

library(manipulate)
library(np)
options(np.tree = "auto", np.messages = FALSE)
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
manipulate.plot <- function(n, p, bw, ckertype, constraints, weighted, unweighted, smoothing, distance) {

  set.seed(42)
  npseed(42)

  x <- sort(runif(n))
  dgp <- function(x) sqrt(x)
  y <- dgp(x) - abs(rnorm(n, sd = .1))
  y <- ifelse(y >= 0, y, 0)
  lp.data <- data.frame(y = y, x = x)

  if (smoothing == "joint") {
    lp.bw <- build_nomad_lp_bw(y ~ x, data = lp.data, degree.start = p,
      degree.min = 2L, degree.max = 7L, ckertype = ckertype)
  } else {
    lp.bw <- build_fixed_degree_bw(y ~ x, data = lp.data, degree = p,
      bw = if (smoothing == "manual") bw else NULL, ckertype = ckertype)
  }
  bw <- lp.bw$bw[1L]
  p <- as.integer(lp.bw$degree[1L])

  plot(x, dgp(x),
       ylab = "Y",
       xlab = "X",
       main = "Constrained Local Polynomial Regression",
       sub = paste("Bandwidth = ", format(bw, digits = 3, format = "f"),
         ", polynomial order = ", p,
         ", n = ", n,
         sep = ""),
       type = "l",
       lty = 1,
       col = 1)

  if (unweighted) points(x, y, col = 1, cex = 0.2)

  ## Each column maps response weights to the level at one observed x.
  A <- npreghat(bws = lp.bw, txdat = lp.data["x"], y = y, output = "constraint")
  p.u <- rep(1, n)
  p.hat <- p.u
  fitted.unres <- drop(crossprod(A, p.u))

  if (constraints != "none") {
    ## Assemble only the selected restrictions. All are written as lower bounds.
    active <- strsplit(constraints, ", ", fixed = TRUE)[[1L]]
    Amat <- list()
    target <- list()
    if ("y<=g(x)" %in% active) {
      Amat$frontier <- A
      target$frontier <- y
    }
    if ("g'(x)>=0" %in% active) {
      Amat$slope <- npreghat(bws = lp.bw, txdat = lp.data["x"], y = y,
        output = "constraint", s = 1L)
      target$slope <- numeric(n)
    }
    if ("g''(x)<=0" %in% active) {
      Amat$curvature <- -npreghat(bws = lp.bw, txdat = lp.data["x"], y = y,
        output = "constraint", s = 2L)
      target$curvature <- numeric(n)
    }
    Amat <- do.call(cbind, Amat)
    bounds <- unlist(target, use.names = FALSE)
    gap <- bounds - drop(crossprod(Amat, p.u))
    if (any(gap > 0)) {
      ## With delta = p - 1, A' delta is the change in fitted levels.
      D <- diag(n)
      if (distance == "fits") D <- tcrossprod(A) + sqrt(.Machine$double.eps) * D
      qp.message <- paste("Could not satisfy the selected production constraints.",
                          "Try a larger bandwidth, another kernel, or fewer constraints.")
      delta <- tryCatch(
        solve.QP(Dmat = D, dvec = numeric(n), Amat = Amat, bvec = gap)$solution,
        error = function(err) stop(qp.message, " (", conditionMessage(err), ")", call. = FALSE))
      p.hat <- p.u + delta
      ## Nearly dependent constraints can give a finite but infeasible solution.
      achieved <- drop(crossprod(Amat, p.hat))
      if (any(!is.finite(achieved)) || any(achieved < bounds - 1e-6 * pmax(1, abs(bounds))))
        stop(qp.message, call. = FALSE)
    }
  }
  fitted.res <- drop(crossprod(A, p.hat))

  ## Plot the unrestricted and restricted models and restricted y

  lines(x, fitted.unres, lty = 2, col = 2, lwd = 2)
  lines(x, fitted.res, col = 4, lty = 4, lwd = 3)

  if (weighted) points(x, y * p.hat, col = "orange", cex = 0.35)

  legend("topleft",
         c("DGP", "Unconstrained Estimate", "Constrained Estimate", "Weighted Y", "Actual Y"),
         col = c(1, 2, 4, "orange", "black"),
         lwd = c(1, 2, 3, NA, NA),
         lty = c(1, 2, 4, NA, NA),
         pch = c(NA, NA, NA, 1, 1),
         cex = 0.75,
         bty = "n")

}

manipulate(manipulate.plot(n, p, bw, ckertype, constraints, weighted, unweighted, smoothing, distance),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           p = slider(2, 5, 2, label = "Local Polynomial Order", step = 1, ticks = TRUE),
           bw = slider(0.01, 0.1, 0.04, step = 0.01, label = "Bandwidth"),
           constraints = picker("none", "g'(x)>=0, g''(x)<=0, y<=g(x)", "g''(x)<=0, y<=g(x)", "g'(x)>=0, y<=g(x)", "y<=g(x)", "g'(x)>=0, g''(x)<=0", "g''(x)<=0", "g'(x)>=0"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           distance = picker("Weight deviation" = "weights",
                             "Fit deviation (regularized)" = "fits",
                             label = "Objective"),
           smoothing = picker("Manual" = "manual",
                              "Cross-validate bandwidth" = "bandwidth",
                              "Cross-validate bandwidth and degree" = "joint",
                              label = "Smoothing parameter selection"),
           unweighted = checkbox(TRUE, "Show unweighted Y"),
           weighted = checkbox(FALSE, "Show weighted Y"))

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
manipulate.plot <- function(n, p, sf, ckertype, constraints, weighted, unweighted, smoothing, distance, view = "frontier") {

  ramp <- grDevices::hcl.colors(256L, "viridis")
  free.col <- ramp[35L]
  fit.col <- ramp[130L]
  weighted.col <- ramp[178L]

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
      sf = if (smoothing == "manual") sf else NULL, ckertype = ckertype)
  }
  bw <- lp.bw$bandwidth$x[1L]
  p <- as.integer(lp.bw$degree[1L])

  ## Each column maps response weights to the level at one observed x.
  A <- npreghat(bws = lp.bw, txdat = lp.data["x"], y = y, output = "constraint")
  p.u <- rep(1, n)
  p.hat <- p.u
  fitted.unres <- drop(crossprod(A, p.u))

  active <- strsplit(constraints, ", ", fixed = TRUE)[[1L]]
  if ("g'(x)>=0" %in% active || view == "slope")
    slope.op <- npreghat(bws = lp.bw, txdat = lp.data["x"], y = y, output = "constraint", s = 1L)
  if ("g''(x)<=0" %in% active || view == "curvature")
    curvature.op <- npreghat(bws = lp.bw, txdat = lp.data["x"], y = y, output = "constraint", s = 2L)
  if (constraints != "none") {
    ## Assemble only the selected restrictions. All are written as lower bounds.
    Amat <- list()
    target <- list()
    if ("y<=g(x)" %in% active) {
      Amat$frontier <- A
      target$frontier <- y
    }
    if ("g'(x)>=0" %in% active) {
      Amat$slope <- slope.op
      target$slope <- numeric(n)
    }
    if ("g''(x)<=0" %in% active) {
      Amat$curvature <- -curvature.op
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

  ## The generating frontier is sqrt(x). The one-sided noise moves the
  ## conditional mean below it; the reference in each view is the frontier.
  if (view == "frontier") {
    truth <- dgp(x)
    unrestricted <- fitted.unres
    restricted <- fitted.res
    quantity <- "Frontier"
  } else {
    op <- if (view == "slope") slope.op else curvature.op
    unrestricted <- drop(crossprod(op, p.u))
    restricted <- drop(crossprod(op, p.hat))
    truth <- if (view == "slope") 1 / (2 * sqrt(x)) else -1 / (4 * x^(3/2))
    quantity <- if (view == "slope") "Frontier slope" else "Frontier curvature"
  }
  ## The frontier derivatives diverge near zero. Include both full estimates
  ## and the reference for x >= .05 in the vertical scale.
  ref.range <- if (view == "frontier") truth else truth[x >= .05]
  limits <- range(ref.range, unrestricted, restricted, if (view != "frontier") 0,
                  if (view == "frontier" && unweighted) y,
                  if (view == "frontier" && weighted) y * p.hat)
  plot(x, truth, type = "n", xlab = "X", ylab = quantity, ylim = limits,
       main = paste("Production", tolower(quantity)),
       sub = sprintf("h = %.3g, degree = %d, n = %d", bw, p, n))
  if (view != "frontier") abline(h = 0, lty = 3, col = "grey55")
  show.y <- view == "frontier" && unweighted
  show.weighted <- view == "frontier" && weighted
  if (show.y) points(x, y, col = "grey60", cex = .35)
  if (show.weighted) points(x, y * p.hat, col = weighted.col, cex = .45)
  lines(x, truth)
  lines(x, unrestricted, col = free.col, lty = 2, lwd = 2)
  lines(x, restricted, col = fit.col, lty = 4, lwd = 2)
  if (any(truth < limits[1] | truth > limits[2]))
    mtext("True derivative extends beyond the vertical scale near zero", side = 3, line = .1, cex = .7)
  legend(if (view == "curvature") "bottomright" else "topright",
         c(paste("True", tolower(quantity)), "Unrestricted", "Constrained",
           if (show.y) "Observed Y", if (show.weighted) "Weighted Y"),
         col = c("black", free.col, fit.col, if (show.y) "grey60", if (show.weighted) weighted.col),
         lty = c(1, 2, 4, if (show.y) NA, if (show.weighted) NA),
         lwd = c(1, 2, 2, if (show.y) NA, if (show.weighted) NA),
         pch = c(NA_integer_, NA_integer_, NA_integer_, if (show.y) 1L, if (show.weighted) 1L),
         cex = .75, bty = "o", bg = grDevices::adjustcolor("white", alpha.f = .9), box.col = NA)

}

manipulate(manipulate.plot(n, p, sf, ckertype, constraints, weighted, unweighted, smoothing, distance, view),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           p = slider(2, 5, 2, label = "Local Polynomial Order", step = 1, ticks = TRUE),
           sf = slider(0.1, 2.5, 0.5, step = 0.1, label = "Manual bandwidth scale factor (x)"),
           constraints = picker("none", "g'(x)>=0, g''(x)<=0, y<=g(x)", "g''(x)<=0, y<=g(x)", "g'(x)>=0, y<=g(x)", "y<=g(x)", "g'(x)>=0, g''(x)<=0", "g''(x)<=0", "g'(x)>=0"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           distance = picker("Weight deviation" = "weights",
                             "Fit deviation (regularized)" = "fits",
                             label = "Objective"),
           smoothing = picker("Manual" = "manual",
                              "Cross-validate bandwidth" = "bandwidth",
                              "Cross-validate bandwidth and degree" = "joint",
                              label = "Smoothing parameter selection"),
           view = picker("Frontier" = "frontier", "Frontier slope" = "slope",
                         "Frontier curvature" = "curvature", label = "Display"),
           unweighted = checkbox(TRUE, "Show unweighted Y"),
           weighted = checkbox(FALSE, "Show weighted Y"))

## Explore how bandwidths, kernel choice, sample size, and correlation
## affect a bivariate kernel copula or copula-density estimate.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
library(mnormt)

## Colour each facet by its mean height, with the base np surface opacity.
surface_colours <- function(z) {
  ramp <- grDevices::hcl.colors(1000L, "viridis")
  limits <- range(z, finite = TRUE)
  if (diff(limits) == 0)
    return(grDevices::adjustcolor(ramp[1L], alpha.f = 0.5))
  nr <- nrow(z)
  nc <- ncol(z)
  height <- (z[-1L, -1L] + z[-nr, -1L] + z[-1L, -nc] + z[-nr, -nc]) / 4
  index <- 1L + floor((length(ramp) - 1L) * (height - limits[1L]) / diff(limits))
  grDevices::adjustcolor(ramp[as.vector(index)], alpha.f = 0.5)
}

## Project the population mesh with the same axes and limits as the fit.
draw_population_mesh <- function(x, y, z, projection, col) {
  ## Keep a dense mesh from obscuring the fitted surface.
  wire.lwd <- min(2, 60 / max(length(x), length(y)))
  for (i in seq_along(y)) {
    lines(trans3d(x, rep(y[i], length(x)), z[, i], projection), col = col, lwd = wire.lwd)
  }
  for (i in seq_along(x)) {
    lines(trans3d(rep(x[i], length(y)), y, z[i, ], projection), col = col, lwd = wire.lwd)
  }
}

## Refit and redraw the selected copula object after a control changes.

manipulate.plot <- function(n, neval, rho, object, sf.x, sf.y, q.min, q.max, ckertype, ckerorder, theta, dgp, cv) {

  set.seed(42)

  mu <- rep(0, 2)
  Sigma <- matrix(rho, 2, 2)
  diag(Sigma) <- 1

  mydat <- rmnorm(n = n, mu, Sigma)

  mydat <- data.frame(x = mydat[, 1], y = mydat[, 2])

  grid.seq <- seq(q.min, q.max, length.out = neval)
  grid.dat <- cbind(grid.seq, grid.seq)

  ## Use distribution bandwidths for the CDF and density bandwidths for its density.
  is.cdf <- object %in% c("copula", "copula contour")
  select.bw <- if (is.cdf) npudistbw else npudensbw
  bw <- if (cv) {
    select.bw(~ x + y, data = mydat, ckertype = ckertype,
              ckerorder = ckerorder, bwscaling = TRUE)
  } else {
    select.bw(~ x + y, data = mydat, ckertype = ckertype, ckerorder = ckerorder,
              bandwidth.compute = FALSE, bwscaling = TRUE, bws = c(sf.x, sf.y))
  }

  copula <- npcopula(bws = bw, data = mydat, u = grid.dat)
  estimate <- matrix(copula$copula, neval, neval)
  reference <- NULL
  if (dgp) {
    ## Evaluate the Gaussian population at the requested probabilities.
    ## The fitted marginal quantiles depend on the sample.
    uv <- expand.grid(u = grid.seq, v = grid.seq)
    inside <- with(uv, u > 0 & u < 1 & v > 0 & v < 1)
    xy <- qnorm(as.matrix(uv[inside, ]))
    if (is.cdf) {
      ## On a boundary C(u,v) equals min(u,v).
      values <- pmin(uv$u, uv$v)
      values[inside] <- apply(xy, 1L, pmnorm, mean = mu, varcov = Sigma)
    } else {
      ## The Gaussian copula density is defined on the open unit square.
      values <- rep(NA_real_, nrow(uv))
      values[inside] <- exp(dmnorm(xy, mu, Sigma, log = TRUE) -
                            rowSums(dnorm(xy, log = TRUE)))
    }
    reference <- matrix(values, neval, neval)
  }

  if (endsWith(object, "contour")) {
    levels <- pretty(range(estimate, reference, finite = TRUE), n = 10)
    contour(grid.seq, grid.seq, estimate, levels = levels, col = "#3E3375",
            xlab = "u1", ylab = "u2",
            main = if (is.cdf) "Copula Contour" else "Copula Density Contour")
    if (dgp) {
      contour(grid.seq, grid.seq, reference, levels = levels, col = "#009D95", lty = 2, add = TRUE)
      legend("topleft", c("Kernel estimate", "Population"), col = c("#3E3375", "#009D95"),
             lty = c(1, 2), bg = "white", box.col = NA, cex = .8)
    }
  } else {
    grid.col <- grDevices::adjustcolor("#3E3375", alpha.f = .24)
    mesh.col <- grDevices::adjustcolor("#3E3375", alpha.f = .18)
    projection <- persp(grid.seq, grid.seq, estimate,
      xlab = "u1", ylab = "u2", zlab = if (is.cdf) "Copula" else "Copula Density",
      zlim = if (is.cdf) c(0, 1) else range(estimate, reference, finite = TRUE),
      theta = theta, ticktype = "detailed", col = surface_colours(estimate), border = grid.col,
      sub = sprintf("%s bandwidths (h.x = %.3g, h.y = %.3g), n = %d, rho = %.2f",
                    if (cv) "CV" else "Manual", bw$bandwidth$x[1], bw$bandwidth$x[2], n, rho))
    if (dgp) {
      draw_population_mesh(grid.seq, grid.seq, reference, projection, mesh.col)
      legend("topleft", c("Kernel estimate", "Population"), pch = c(22, NA),
             pt.bg = grDevices::adjustcolor("#009D95", alpha.f = .5),
             col = c(grid.col, mesh.col), lty = c(NA, 1), lwd = 2, bty = "n", cex = .8)
    }
  }

}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(n, neval, rho, object, sf.x, sf.y, q.min, q.max, ckertype, ckerorder, theta, dgp, cv),
           n = slider(100, 1000, 500, step = 100, label = "Number of estimation obs"),
           neval = slider(25, 100, 50, step = 25, label = "Evaluation points per axis"),
           rho = slider(-0.95, 0.95, 0.95, step = 0.05, label = "Correlation between x and y"),
           object = picker("copula", "copula contour", "copula density", "copula density contour", label = "Copula object to plot"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order (Gaussian/Epanechnikov)"),
           sf.x = slider(0.1, 2.5, 0.25, label = "Scale factor for x", step = 0.1, ticks = TRUE),
           sf.y = slider(0.1, 2.5, 0.25, label = "Scale factor for y", step = 0.1, ticks = TRUE),
           dgp = checkbox(FALSE, "Show population surface"),
           q.min = slider(0, 0.25, 0.01, label = "Lower quantile for cropping plot", step = 0.01, ticks = TRUE),
           q.max = slider(0.75, 1, .99, label = "Upper quantile for cropping plot", step = 0.01, ticks = TRUE),
           theta = slider(0, 360, 315, label = "Azimuthal viewing direction", step = 15, ticks = TRUE),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

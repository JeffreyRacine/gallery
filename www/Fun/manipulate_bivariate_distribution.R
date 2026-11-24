## Explore how bandwidths, kernel choice, sample size, and correlation
## affect a bivariate Rosenblatt-Parzen distribution estimate.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
library(MASS)

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

## Refit and redraw the distribution after a control changes.

manipulate.plot <- function(n, neval, rho, sf.x, sf.y, ckertype, ckerorder, theta, cv, population = FALSE) {

  set.seed(42)

  mu <- rep(0, 2)
  Sigma <- matrix(rho, 2, 2)
  diag(Sigma) <- 1

  mydat <- mvrnorm(n = n, mu, Sigma)
  x <- mydat[, 1]
  y <- mydat[, 2]

  x.eval <- seq(min(x) - sd(x), max(x) + sd(x), length.out = neval)
  y.eval <- seq(min(y) - sd(y), max(y) + sd(y), length.out = neval)

  if (cv) {
    bw <- npudistbw(~ x + y,
                    ckertype = ckertype,
                    ckerorder = ckerorder)
  } else {
    bw <- npudistbw(~ x + y,
                    ckertype = ckertype,
                    ckerorder = ckerorder,
                    bandwidth.compute = FALSE,
                    bwscaling = TRUE,
                    bws = c(sf.x, sf.y))
  }

  grid <- expand.grid(x = x.eval, y = y.eval)
  F.grid <- matrix(fitted(npudist(tdat = data.frame(x, y),
                                  edat = grid,
                                  bws = bw)),
                   neval, neval)

  reference <- NULL
  if (population) {
    ## At perfect correlation P(X <= x, Y <= y) = Phi(min(x, y)).
    values <- if (rho == 1) pnorm(pmin(grid$x, grid$y)) else
      mnormt::pmnorm(as.matrix(grid), mean = mu, varcov = Sigma)
    reference <- matrix(values, neval, neval)
  }
  ## Draw the population wireframe in the same projection as the estimated surface.
  mesh.col <- grDevices::adjustcolor("#3E3375", alpha.f = .18)
  grid.col <- grDevices::adjustcolor("#3E3375", alpha.f = .24)
  projection <- persp(x.eval, y.eval, F.grid, zlim = range(0, 1, F.grid, reference),
                      xlab = "x", ylab = "y", zlab = "Joint CDF", theta = theta, phi = 30,
                      ticktype = "detailed", col = surface_colours(F.grid), border = grid.col,
                      sub = sprintf("h.x = %.3g, h.y = %.3g, n = %d, rho = %.2f",
                                    bw$bandwidth$x[1], bw$bandwidth$x[2], n, rho))
  if (!is.null(reference)) {
    ## Keep a dense mesh from obscuring the fitted surface.
    wire.lwd <- min(2, 60 / neval)
    for (i in seq_len(neval)) {
      lines(trans3d(x.eval, rep(y.eval[i], neval), reference[, i], projection), col = mesh.col, lwd = wire.lwd)
      lines(trans3d(rep(x.eval[i], neval), y.eval, reference[i, ], projection), col = mesh.col, lwd = wire.lwd)
    }
  }
  legend("topleft", c("Kernel estimate", if (!is.null(reference)) "Population"),
         pch = c(22, if (!is.null(reference)) NA_integer_), pt.bg = grDevices::adjustcolor("#009D95", alpha.f = .5),
         col = c(grid.col, if (!is.null(reference)) mesh.col),
         lty = c(NA_integer_, if (!is.null(reference)) 1L), lwd = 2, bty = "n", cex = .8)

}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(n, neval, rho, sf.x, sf.y, ckertype, ckerorder, theta, cv, population),
           n = slider(100, 1000, 500, step = 100, label = "Number of estimation obs"),
           neval = slider(25, 100, 50, step = 25, label = "Evaluation points per axis"),
           rho = slider(0, 1, 0.1, step = 0.05, label = "Correlation between x and y"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order (Gaussian/Epanechnikov)"),
           sf.x = slider(0.1, 2.5, 1, label = "Scale factor for x", step = 0.1, ticks = TRUE),
           sf.y = slider(0.1, 2.5, 1, label = "Scale factor for y", step = 0.1, ticks = TRUE),
           theta = slider(0, 360, 0, label = "Azimuthal viewing direction", step = 15, ticks = TRUE),
           population = checkbox(FALSE, "Show population surface"),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

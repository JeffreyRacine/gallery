## Explore how bandwidths, kernel choice, sample size, and correlation
## affect a bivariate Rosenblatt-Parzen distribution estimate.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
library(MASS)

## Refit and redraw the distribution after a control changes.

manipulate.plot <- function(n, neval, rho, sf.x, sf.y, ckertype, ckerorder, theta, cv, population = TRUE) {

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
  projection <- persp(x.eval, y.eval, F.grid, zlim = range(0, 1, F.grid, reference),
                      xlab = "x", ylab = "y", zlab = "Joint CDF", theta = theta, phi = 30,
                      ticktype = "detailed", col = "lightblue", border = "grey55",
                      sub = sprintf("h.x = %.3g, h.y = %.3g, n = %d, rho = %.2f",
                                    bw$bandwidth$x[1], bw$bandwidth$x[2], n, rho))
  if (!is.null(reference)) {
    mesh <- unique(round(seq(1, neval, length.out = 11)))
    for (i in mesh) {
      lines(trans3d(x.eval, rep(y.eval[i], neval), reference[, i], projection), col = "firebrick3", lwd = 1.5)
      lines(trans3d(rep(x.eval[i], neval), y.eval, reference[i, ], projection), col = "firebrick3", lwd = 1.5)
    }
  }
  legend("topleft", c("Kernel estimate", if (!is.null(reference)) "Population"),
         pch = c(22, if (!is.null(reference)) NA_integer_), pt.bg = "lightblue",
         col = c("grey45", if (!is.null(reference)) "firebrick3"),
         lty = c(NA_integer_, if (!is.null(reference)) 1L), lwd = 1.5, bty = "n", cex = .8)

}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(n, neval, rho, sf.x, sf.y, ckertype, ckerorder, theta, cv, population),
           n = slider(100, 1000, 500, step = 100, label = "Number of estimation obs"),
           neval = slider(25, 100, 50, step = 25, label = "Number of evaluation obs"),
           rho = slider(0, 1, 0.1, step = 0.05, label = "Correlation between x and y"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order"),
           sf.x = slider(0.1, 2.5, 1, label = "Scale factor for x", step = 0.1, ticks = TRUE),
           sf.y = slider(0.1, 2.5, 1, label = "Scale factor for y", step = 0.1, ticks = TRUE),
           theta = slider(0, 360, 0, label = "Azimuthal viewing direction", step = 15, ticks = TRUE),
           population = checkbox(TRUE, "Show population surface"),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

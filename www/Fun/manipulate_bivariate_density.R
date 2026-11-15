## Explore how bandwidths, kernel choice, sample size, and correlation
## affect a bivariate Rosenblatt-Parzen density estimate.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
library(MASS)

## Refit and redraw the density after a control changes.

manipulate.plot <- function(n, neval, rho, sf.x, sf.y, ckertype, ckerorder, theta, cv) {

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
    bw <- npudensbw(~ x + y,
                    ckertype = ckertype,
                    ckerorder = ckerorder)
  } else {
    bw <- npudensbw(~ x + y,
                    ckertype = ckertype,
                    ckerorder = ckerorder,
                    bandwidth.compute = FALSE,
                    bwscaling = TRUE,
                    bws = c(sf.x, sf.y))
  }

  f.grid <- matrix(fitted(npudens(tdat = data.frame(x, y),
                                  edat = expand.grid(x = x.eval, y = y.eval),
                                  bws = bw)),
                   neval, neval)

  persp(x.eval, y.eval, f.grid,
        sub = paste("h.x = ",
          formatC(bw$bw[1] * sd(x) * n^(-1 / (2 * ckerorder + 2)), format = "f", digits = 2),
          ", h.y = ",
          formatC(bw$bw[2] * sd(y) * n^(-1 / (2 * ckerorder + 2)), format = "f", digits = 2),
          ", n = ", n, ", rho = ", rho, sep = ""),
        theta = theta,
        phi = 30,
        ylab = "y",
        xlab = "x",
        zlab = "Joint PDF",
        ticktype = "detailed",
        col = "lightblue")

}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(n, neval, rho, sf.x, sf.y, ckertype, ckerorder, theta, cv),
           n = slider(100, 1000, 500, step = 100, label = "Number of estimation obs"),
           neval = slider(25, 100, 50, step = 25, label = "Number of evaluation obs"),
           rho = slider(0, 1, 0.1, step = 0.1, label = "Correlation between x and y"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order"),
           sf.x = slider(0.1, 2.5, 1, label = "Scale factor for x", step = 0.1, ticks = TRUE),
           sf.y = slider(0.1, 2.5, 1, label = "Scale factor for y", step = 0.1, ticks = TRUE),
           theta = slider(0, 360, 0, label = "Azimuthal viewing direction", step = 15, ticks = TRUE),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

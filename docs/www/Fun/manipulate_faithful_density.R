## Explore how bandwidths and kernel choice affect the bivariate
## Old Faithful density estimate.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
data(faithful)

## Refit and redraw the density after a control changes.

manipulate.plot <- function(neval, sf.x, sf.y, ckertype, ckerorder, theta, cv) {

  set.seed(42)

  n <- nrow(faithful)

  x <- faithful$eruptions
  y <- faithful$waiting

  x.eval <- seq(min(x) - sd(x), max(x) + sd(x), length.out = neval)
  y.eval <- seq(min(y) - sd(y), max(y) + sd(y), length.out = neval)

  bws <- c(sf.x * np:::EssDee(x) * n^(-1 / (2 * ckerorder + 2)),
           sf.y * np:::EssDee(y) * n^(-1 / (2 * ckerorder + 2)))

  f.grid <- matrix(npksum(txdat = data.frame(x, y),
                          exdat = expand.grid(x.eval, y.eval),
                          bws = bws,
                          bandwidth.divide = TRUE,
                          ckertype = ckertype,
                          ckerorder = ckerorder)$ksum / n,
                   neval, neval)

  if (cv) {
    bw <- npudensbw(~ x + y, ckertype = ckertype, ckerorder = ckerorder)
    sf.x <- bw$sfactor$x[1]
    sf.y <- bw$sfactor$x[2]
  }

  persp(x.eval, y.eval, f.grid,
        sub = paste("h.eruptions = ",
          formatC(sf.x * sd(x) * n^(-1 / (2 * ckerorder + 2)), format = "f", digits = 2),
          ", h.waiting = ",
          formatC(sf.y * sd(y) * n^(-1 / (2 * ckerorder + 2)), format = "f", digits = 2),
          ", n = ", n, sep = ""),
        theta = theta,
        phi = 30,
        ylab = "waiting",
        xlab = "eruptions",
        zlab = "Joint PDF",
        ticktype = "detailed",
        col = "lightblue")

}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(neval, sf.x, sf.y, ckertype, ckerorder, theta, cv),
           neval = slider(25, 150, 50, step = 25, label = "Number of evaluation obs"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order"),
           sf.x = slider(0.1, 2.5, 1, label = "Scale factor for x", step = 0.1, ticks = TRUE),
           sf.y = slider(0.1, 2.5, 1, label = "Scale factor for y", step = 0.1, ticks = TRUE),
           theta = slider(0, 360, 0, label = "Azimuthal viewing direction", step = 15, ticks = TRUE),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

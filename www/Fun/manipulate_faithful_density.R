## Explore how bandwidths and kernel choice affect the bivariate
## Old Faithful density estimate.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
data(faithful)

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

## Refit and redraw the density after a control changes.

manipulate.plot <- function(neval, sf.x, sf.y, ckertype, ckerorder, theta, cv) {

  set.seed(42)

  n <- nrow(faithful)

  x <- faithful$eruptions
  y <- faithful$waiting

  x.eval <- seq(min(x) - sd(x), max(x) + sd(x), length.out = neval)
  y.eval <- seq(min(y) - sd(y), max(y) + sd(y), length.out = neval)

  bw <- if (cv) {
    npudensbw(~ eruptions + waiting, data = faithful,
              ckertype = ckertype, ckerorder = ckerorder)
  } else {
    npudensbw(~ eruptions + waiting, data = faithful,
              ckertype = ckertype, ckerorder = ckerorder,
              bandwidth.compute = FALSE, bwscaling = TRUE, bws = c(sf.x, sf.y))
  }

  grid <- expand.grid(eruptions = x.eval, waiting = y.eval)
  f.grid <- matrix(fitted(npudens(bws = bw, tdat = faithful, edat = grid)), neval, neval)
  h <- bw$bandwidth$x

  persp(x.eval, y.eval, f.grid,
        sub = sprintf("%s bandwidths (h.eruptions = %.3g, h.waiting = %.3g), n = %d",
                      if (cv) "CV" else "Manual", h[1], h[2], n),
        theta = theta,
        phi = 30,
        ylab = "waiting",
        xlab = "eruptions",
        zlab = "Joint PDF",
        ticktype = "detailed",
        col = surface_colours(f.grid),
        border = grDevices::adjustcolor("#3E3375", alpha.f = .24))

}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(neval, sf.x, sf.y, ckertype, ckerorder, theta, cv),
           neval = slider(25, 150, 50, step = 25, label = "Evaluation points per axis"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order"),
           sf.x = slider(0.1, 2.5, 1, label = "Manual scale factor for eruptions", step = 0.1, ticks = TRUE),
           sf.y = slider(0.1, 2.5, 1, label = "Manual scale factor for waiting", step = 0.1, ticks = TRUE),
           theta = slider(0, 360, 0, label = "Azimuthal viewing direction", step = 15, ticks = TRUE),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

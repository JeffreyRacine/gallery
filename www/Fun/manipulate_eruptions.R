## Explore fixed and nearest-neighbour density estimates of the
## Old Faithful eruption-duration distribution.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
data(faithful)

## Refit and redraw the density and optional sample overlays.

manipulate.plot <- function(sf, nn, bwtype, ckertype, ckerorder, hist, rug, cv, cvtype) {

  x <- faithful$eruptions
  x.eval <- seq(min(x) - 0.5 * sd(x), max(x) + 0.5 * sd(x), length.out = 1000)
  n <- length(x)

  ## An adaptive radius excludes the observation itself. Tied times require
  ## at least as many neighbours as the largest tie group.
  min.adaptive.k <- max(table(x))
  if (!cv && bwtype == "adaptive_nn" && nn < min.adaptive.k) {
    plot.new()
    text(0.5, 0.5, sprintf("Tied eruption times give a zero adaptive bandwidth.\nChoose k of at least %d.", min.adaptive.k))
    return(invisible(NULL))
  }

  hist.max <- 0
  if (hist) hist.max <- max(hist(x, breaks = 20, plot = FALSE)$density)

  if (cv) {
    bw <- npudensbw(~x,
                    bwtype = bwtype,
                    bwmethod = cvtype,
                    ckertype = ckertype,
                    ckerorder = ckerorder)
  } else {
    bw <- npudensbw(~x,
                    bwtype = bwtype,
                    ckertype = ckertype,
                    ckerorder = ckerorder,
                    bandwidth.compute = FALSE,
                    bwscaling = TRUE,
                    bws = ifelse(bwtype == "fixed", sf, nn))
  }

  ## Use the same bandwidth object for the curve and its caption.
  f.kernel <- fitted(npudens(tdat = x, edat = x.eval, bws = bw))
  h <- bw$bandwidth$x[1L]
  bandwidth.label <- if (bwtype == "fixed") {
    sprintf("h = %.3g", h)
  } else {
    sprintf("k = %d", as.integer(h))
  }

  ylim <- c(min(hist.max, f.kernel), max(hist.max, f.kernel))

  plot(x.eval, f.kernel,
       ylim = ylim,
       type = "l",
       ylab = "Density",
       xlab = "Eruption length (minutes)",
       sub = sprintf("%s bandwidth (%s), n = %d", if (cv) "CV" else "Manual", bandwidth.label, n),
       lty = 1,
       col = "#3E3375")

  if (hist) hist(x, breaks = 20, freq = FALSE, add = TRUE, col = NA, lty = 3)

  if (rug) rug(x)
}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(sf, nn, bwtype, ckertype, ckerorder, hist, rug, cv, cvtype),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order (Gaussian/Epanechnikov)"),
           bwtype = picker("fixed", "adaptive_nn", "generalized_nn", label = "Bandwidth type"),
           sf = slider(0.1, 4.0, 1, label = "Scale factor (bwtype=\"fixed\")", step = 0.2, ticks = TRUE),
           nn = slider(2, 100, 25, label = "Kth nn (bwtype=*_nn)", step = 1, ticks = TRUE),
           hist = checkbox(FALSE, "Show histogram"),
           rug = checkbox(FALSE, "Show rug"),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"),
           cvtype = picker("cv.ml", "cv.ls", label = "Cross-validation method"))

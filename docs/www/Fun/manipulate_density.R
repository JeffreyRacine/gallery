## Compare fixed, generalized-nearest-neighbour, and
## adaptive-nearest-neighbour estimates of a chi-squared density.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.

## Refit and redraw the density, truth, and optional sample overlays.

manipulate.plot <- function(n, df, sf, nn, bwtype, ckertype, ckerorder, hist, rug, cv, cv.type, population = TRUE) {

  if (!cv && bwtype != "fixed" && nn >= n) {
    warning(paste("Knn bandwidth must be less than", n))
    nn <- n - 1
  }

  set.seed(42)
  x <- rchisq(n, df = df)
  x.eval <- seq(min(x) - 0.5 * sd(x), max(x) + 0.5 * sd(x), length.out = 1000)
  f.dgp <- dchisq(ifelse(x.eval < 0, 0, x.eval), df = df)

  hist.max <- 0
  if (hist) hist.max <- max(hist(x, breaks = 25, plot = FALSE)$density)

  if (cv) {
    bw <- npudensbw(~x,
                    bwtype = bwtype,
                    bwmethod = cv.type,
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

  ylim <- range(0, hist.max, f.kernel, f.dgp)

  plot(x.eval, f.kernel,
       ylim = ylim,
       type = "l",
       ylab = "Density",
       xlab = "Data",
       sub = sprintf("%s bandwidth (%s), n = %d", if (cv) "CV" else "Manual", bandwidth.label, n),
       lty = 1,
       col = "#3E3375")

  if (population) lines(x.eval, f.dgp, lty = 2, col = "black")

  legend("topright",
         c("Kernel Estimate", if (population) paste("Chi-square (df = ", df, ")", sep = "")),
         lty = c(1, if (population) 2),
         col = c("#3E3375", if (population) "black"),
         bty = "n",
         cex = 0.75)

  if (hist) hist(x, breaks = 25, freq = FALSE, col = NA, add = TRUE, lty = 3)

  if (rug) rug(x)
}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(n, df, sf, nn, bwtype, ckertype, ckerorder, hist, rug, cv, cv.type, population),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           df = slider(10, 120, 10, step = 10, label = "Chi-square degrees of freedom"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order (Gaussian/Epanechnikov)"),
           bwtype = picker("fixed", "adaptive_nn", "generalized_nn", label = "Bandwidth type"),
           sf = slider(0.1, 2.5, 1, label = "Scale factor (bwtype=\"fixed\")", step = 0.1, ticks = TRUE),
           nn = slider(2, 1000, 50, label = "Kth nn (bwtype=*_nn)", step = 1, ticks = TRUE),
           population = checkbox(TRUE, "Show population curve"),
           hist = checkbox(FALSE, "Show histogram"),
           rug = checkbox(FALSE, "Show rug"),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"),
           cv.type = picker("cv.ml", "cv.ls", label = "CV method"))

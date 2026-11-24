## Compare fixed, generalized-nearest-neighbour, and
## adaptive-nearest-neighbour estimates of a chi-squared distribution.

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.

## Refit and redraw the distribution, truth, and optional sample overlays.

manipulate.plot <- function(n, df, sf, nn, bwtype, ckertype, ckerorder, ecdf, rug, cv) {

  if (nn >= n) {
    warning(paste("Knn bandwidth must be less than", n))
    nn <- n - 1
  }

  set.seed(42)
  x <- sort(rchisq(n, df = df))
  x.eval <- seq(min(x) - 0.5 * sd(x), max(x) + 0.5 * sd(x), length.out = 100)
  F.dgp <- pchisq(ifelse(x.eval < 0, 0, x.eval), df = df)

  if (cv) {
    bw <- npudistbw(~x,
                    bwtype = bwtype,
                    ckertype = ckertype,
                    ckerorder = ckerorder)
  } else {
    bw <- npudistbw(~x,
                    bwtype = bwtype,
                    ckertype = ckertype,
                    ckerorder = ckerorder,
                    bandwidth.compute = FALSE,
                    bwscaling = TRUE,
                    bws = ifelse(bwtype == "fixed", sf, nn))
  }

  F.kernel <- fitted(npudist(tdat = x, edat = x.eval, bws = bw))

  plot(x.eval, F.kernel,
       ylim = c(0, 1),
       type = "l",
       ylab = "Distribution",
       xlab = "Data",
       sub = paste("Bandwidth = ", ifelse(bwtype == "fixed", formatC(bw$bw[1] * sd(x) * n^(-1 / (ckerorder + 1)), format = "f", digits = 2), bw$bw[1]), ", n = ", n, sep = ""),
       lty = 1,
       col = "#3E3375")

  lines(x.eval, F.dgp, lty = 2, col = "black")

  legend("topleft",
         c("Kernel Estimate", paste("Chi-square (df = ", df, ")", sep = "")),
         lty = c(1, 2),
         col = c("#3E3375", "black"),
         bty = "n",
         cex = 0.75)

  if (ecdf) {
    Fn <- ecdf(x)
    lines(x, Fn(x), lty = 3)
  }

  if (rug) rug(x)
}

## Expose the estimator controls in an interactive panel.

manipulate(manipulate.plot(n, df, sf, nn, bwtype, ckertype, ckerorder, ecdf, rug, cv),
           n = slider(100, 1000, 500, step = 100, label = "Number of observations"),
           df = slider(10, 120, 10, step = 10, label = "Chi-square degrees of freedom"),
           ckertype = picker("gaussian", "epanechnikov", "uniform", label = "Kernel function"),
           ckerorder = picker(2, 4, 6, 8, label = "Kernel order"),
           bwtype = picker("fixed", "adaptive_nn", "generalized_nn", label = "Bandwidth type"),
           sf = slider(0.1, 2.5, 1, label = "Scale factor (bwtype=\"fixed\")", step = 0.1, ticks = TRUE),
           nn = slider(2, 1000, 50, label = "Kth nn (bwtype=*_nn)", step = 1, ticks = TRUE),
           ecdf = checkbox(FALSE, "Show empirical distribution function"),
           rug = checkbox(FALSE, "Show rug"),
           cv = checkbox(FALSE, "Cross-validate smoothing parameters"))

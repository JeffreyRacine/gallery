# Sharp regression discontinuity: author package, then npreg.
# Requires np >= 0.80-1 and rdrobust. No package installation is performed.
# Run source("sharp_rd_inference.R") in R or RStudio to display the results.
# Results stay in rd_results; this script creates no folders or output files.
# References: CCT (2014), Econometrica; CCT (2015), R Journal.
# https://journal.r-project.org/articles/RJ-2015-004/
# Matched specification: Epanechnikov, p=1, q=2, MSE-RD bandwidth, HC0.
# HC0 and Epanechnikov are supported choices, not rdrobust's NN/triangular defaults.
library(np)
library(rdrobust)
stopifnot(packageVersion("np") >= "0.80.1")
options(np.messages = FALSE)
d <- read.csv(paste0(
  "https://raw.githubusercontent.com/rdpackages/rdrobust/",
  "7df239395c4afce2a58e22ef16a5817341683955/R/rdrobust_senate.csv"))
d <- d[complete.cases(d[c("vote", "margin")]), ]

# A. Author-package estimates and robust bias-corrected inference.
author <- rdrobust(y = d$vote, x = d$margin, c = 0, p = 1, q = 2,
                  kernel = "epanechnikov", bwselect = "mserd", vce = "hc0")
print(summary(author))
h <- author$bws["h", ]
b <- author$bws["b", ]
bandwidths <- data.frame(side = c("left", "right"), h, b)
print(bandwidths, row.names = FALSE)

# B. npreg fits and an explicit implementation of the same bias/HC0 formulas.
# The helper is included here so this script has no local-file dependencies.
# Local-linear robust bias correction, with a quadratic pilot and HC0 variance.
# The point estimate and second derivative are fitted by the public np API.
# Explicit equivalent weights implement the CCT/CCF covariance formula;
# np's ordinary se() uses a different residual convention.
np_rbc_hc0 <- function(x, y, at, h, b) {
  stopifnot(length(x) == length(y), all(is.finite(c(x, y, at, h, b))),
            length(at) == 1L, h > 0, b > 0)
  z <- x - at
  fit <- np::npreg(txdat = z, tydat = y, exdat = 0, bws = h / sqrt(5),
    regtype = "ll", ckertype = "epanechnikov", ckerorder = 2,
    bwtype = "fixed", bwscaling = FALSE, se = FALSE)
  pilot <- np::npreg(txdat = z, tydat = y, exdat = 0, bws = b / sqrt(5),
    regtype = "lp", degree = 2, bernstein.basis = FALSE,
    gradients = TRUE, gradient.order = 2, ckertype = "epanechnikov",
    ckerorder = 2, bwtype = "fixed", bwscaling = FALSE, se = FALSE)
  # Centered/scaled designs keep the small coefficient calculations well conditioned.
  R <- cbind(1, z / h)
  Q <- cbind(1, z / b, (z / b)^2)
  wh <- pmax(1 - (z / h)^2, 0)
  wb <- pmax(1 - (z / b)^2, 0)
  P <- solve(crossprod(R, R * wh), t(R * wh))
  B <- solve(crossprod(Q, Q * wb), t(Q * wb))
  ell <- P[1, ]
  moment2 <- sum(ell * z^2)
  ell_bc <- ell - moment2 * B[3, ] / b^2
  residual_p <- y - as.numeric(R %*% (P %*% y))
  residual_q <- y - as.numeric(Q %*% (B %*% y))
  conventional <- as.numeric(fitted(fit))
  corrected <- conventional - moment2 * as.numeric(np::gradients(pilot)) / 2
  stopifnot(abs(conventional - sum(ell * y)) < 1e-7,
            abs(corrected - sum(ell_bc * y)) < 1e-7)
  list(estimate = conventional, corrected = corrected,
       se = sqrt(sum((ell * residual_p)^2)),
       se_rb = sqrt(sum((ell_bc * residual_q)^2)),
       influence = ell_bc * residual_q)
}


sides <- list(d$margin < 0, d$margin >= 0)
fits <- lapply(1:2, function(s) {
  use <- sides[[s]]
  np_rbc_hc0(d$margin[use], d$vote[use], at = 0, h = h[s], b = b[s])
})
estimate <- fits[[2]]$estimate - fits[[1]]$estimate
corrected <- fits[[2]]$corrected - fits[[1]]$corrected
se_conventional <- sqrt(sum(vapply(fits, function(f) f$se^2, 0)))
se_robust <- sqrt(sum(vapply(fits, function(f) f$se_rb^2, 0)))
ci <- corrected + c(-1, 1) * qnorm(.975) * se_robust
p_value <- 2 * pnorm(-abs(corrected / se_robust))
comparison <- data.frame(
  quantity = c("Conventional estimate", "Bias-corrected estimate", "Conventional SE",
               "Robust SE", "Robust CI lower", "Robust CI upper", "Robust p-value"),
  author = c(author$Estimate[1, ], author$ci["Robust", ], author$pv["Robust", 1]),
  np = c(estimate, corrected, se_conventional, se_robust, ci, p_value))
comparison$absolute_difference <- abs(comparison$author - comparison$np)
stopifnot(max(comparison$absolute_difference) < 1e-7)
print(comparison, digits = 8, row.names = FALSE)
rd_results <- list(data = d, author = author, bandwidths = bandwidths,
                   comparison = comparison, session_info = sessionInfo())

# Display conventional np curves and the two identical RBC effect intervals.
gx <- list(seq(-25, 0, length.out = 151), seq(0, 25, length.out = 151))
gy <- lapply(1:2, function(s) as.numeric(fitted(npreg(
  txdat = d$margin[sides[[s]]], tydat = d$vote[sides[[s]]], exdat = gx[[s]],
  bws = h[s] / sqrt(5), regtype = "ll", ckertype = "epanechnikov",
  ckerorder = 2, bwtype = "fixed", bwscaling = FALSE, se = FALSE))))
if (interactive() || dev.cur() > 1L) local({
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  par(mfrow = c(1, 2), mar = c(5.7, 5.1, 3.4, 1.0), oma = c(2.0, 0, 0, 0))
  cols <- c("#2667A5", "#B24A35")
  plot(d$margin, d$vote, xlim = c(-25, 25), ylim = c(20, 80),
       pch = 16, cex = .5, col = adjustcolor("grey40", .25),
       xlab = "Previous Democratic victory margin", ylab = "Subsequent Democratic vote share (%)",
       main = "Senate elections: one-sided npreg fits")
  abline(v = 0, lty = 3, col = "grey50")
  for (s in 1:2) {
    lines(gx[[s]], gy[[s]], lwd = 3, col = cols[s])
    points(0, fits[[s]]$estimate, pch = 21, bg = "white", col = cols[s], cex = 1.2, lwd = 2)
  }
  legend("topleft", c("Previous loss", "Previous win"), col = cols, lty = 1, lwd = 3, bty = "n", cex = .85)
  plot(NA, xlim = range(0, ci) + c(-.8, .8), ylim = c(.4, 2.8), yaxt = "n",
       xlab = "Effect on vote share (percentage points)", ylab = "",
       main = "Robust bias-corrected 95% intervals")
  abline(v = 0, col = "grey50", lty = 3)
  axis(2, at = c(1, 2), labels = c("np + HC0", "rdrobust"), las = 1, cex.axis = .85)
  segments(author$ci["Robust", 1], 2, author$ci["Robust", 2], 2, lwd = 3, col = cols[1])
  segments(ci[1], 1, ci[2], 1, lwd = 3, col = cols[2])
  points(c(author$Estimate[1, "tau.bc"], corrected), c(2, 1), pch = 19, col = cols, cex = 1.3)
  mtext(sprintf("Estimate %.3f; 95%% CI [%.3f, %.3f]; two-sided p = %.3g", corrected, ci[1], ci[2], p_value),
        side = 1, outer = TRUE, line = .5, cex = .85)
}) else message('Run source("sharp_rd_inference.R") in R or RStudio to display the figure.')
invisible(rd_results)

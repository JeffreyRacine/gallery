## Known support bounds with the default Gaussian kernel (np 0.80-1).
## Source this file to fit and plot all six seed-42 examples.
## Save the plot with:
## png("density_bounds.png", width = 1800, height = 1400, res = 180)
## plot_density_bounds(bounds_examples, main = "One sample | n = 250 | seed = 42")
## dev.off()
## The separate 100-draw Gallery averages are not run by this quickstart.

library(np)
options(np.messages = FALSE)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
n <- 250L
seed <- 42L
search_seed <- 100000L + seed
designs <- c("proportion", "duration", "gaussian")
bounds_examples <- list()

for (design in designs) {
  bounds <- switch(design, proportion = c(0, 1),
                   duration = c(0, Inf), gaussian = c(-Inf, Inf))
  yy <- switch(design, proportion = seq(-.2, 1.2, length.out = 281),
               duration = seq(-.8, 8, length.out = 221),
               gaussian = seq(-4.5, 4.5, length.out = 201))
  inside <- yy >= bounds[1] & yy <= bounds[2]

  ## Unconditional: the same sample, separate CVML bandwidth searches.
  set.seed(seed)
  y <- switch(design, proportion = runif(n),
              duration = rexp(n), gaussian = rnorm(n))
  set.seed(search_seed); npseed(search_seed)
  b0 <- npudensbw(dat = data.frame(y), bwmethod = "cv.ml", nmulti = 5)
  set.seed(search_seed); npseed(search_seed)
  b1 <- npudensbw(dat = data.frame(y), bwmethod = "cv.ml", nmulti = 5,
                  ckerbound = "fixed", ckerlb = bounds[1], ckerub = bounds[2])
  u0 <- fitted(npudens(bws = b0, tdat = data.frame(y), edat = data.frame(y = yy)))
  ## Public evaluation is inside the declared support. Zero extension is
  ## an explicit plotting convention; no in-support estimates are changed.
  u1 <- numeric(length(yy))
  u1[inside] <- fitted(npudens(bws = b1, tdat = data.frame(y),
                             edat = data.frame(y = yy[inside])))
  tu <- switch(design, proportion = dunif(yy),
               duration = dexp(yy), gaussian = dnorm(yy))

  ## Conditional: one continuous X and one continuous Y, default LC.
  set.seed(seed)
  x <- switch(design, proportion = runif(n),
              duration = rexp(n), gaussian = rnorm(n))
  y <- switch(design,
    proportion = {a <- .8 * (2*x - 1); u <- runif(n)
                  2*u / ((1-a) + sqrt((1-a)^2 + 4*a*u))},
    duration = rexp(n, rate = 1 / (1 + .5*x)),
    gaussian = rnorm(n, mean = x))
  ## Display the conditional density at the population median of X.
  x0 <- switch(design, proportion = .5, duration = qexp(.5), gaussian = 0)
  grid <- data.frame(x = rep(x0, length(yy)), y = yy)
  set.seed(search_seed); npseed(search_seed)
  b0c <- npcdensbw(xdat = data.frame(x), ydat = data.frame(y),
                   bwmethod = "cv.ml", nmulti = 5)
  set.seed(search_seed); npseed(search_seed)
  b1c <- npcdensbw(xdat = data.frame(x), ydat = data.frame(y),
                   bwmethod = "cv.ml", nmulti = 5,
                   cxkerbound = "fixed", cxkerlb = bounds[1], cxkerub = bounds[2],
                   cykerbound = "fixed", cykerlb = bounds[1], cykerub = bounds[2])
  c0 <- fitted(npcdens(bws = b0c, txdat = data.frame(x), tydat = data.frame(y),
                      exdat = grid["x"], eydat = grid["y"], proper = FALSE))
  c1 <- numeric(length(yy))
  c1[inside] <- fitted(npcdens(bws = b1c, txdat = data.frame(x), tydat = data.frame(y),
                              exdat = grid[inside, "x", drop = FALSE],
                              eydat = grid[inside, "y", drop = FALSE], proper = FALSE))
  tc <- switch(design,
    proportion = (1 + .8*(2*x0 - 1)*(2*yy - 1)) * inside,
    duration = dexp(yy, rate = 1 / (1 + .5*x0)), gaussian = dnorm(yy, mean = x0))

  if (design == "gaussian") {
    ## Test the estimator separately from bandwidth-search rounding.
    same <- npcdens(bws = c(b0c$ybw, b0c$xbw),
                    txdat = data.frame(x), tydat = data.frame(y),
                    exdat = grid["x"], eydat = grid["y"], proper = FALSE,
                    cxkerbound = "fixed", cxkerlb = -Inf, cxkerub = Inf,
                    cykerbound = "fixed", cykerlb = -Inf, cykerub = Inf)
    stopifnot(identical(u0, u1), identical(c0, fitted(same)))
    print(c(unconditional_difference = max(abs(u0 - u1)),
            conditional_same_bandwidth = max(abs(c0 - fitted(same))),
            conditional_separate_cvml = max(abs(c0 - c1))))
  }
  bounds_examples[[design]] <- list(y = yy, bounds = bounds, x0 = x0,
    unconditional = data.frame(truth = tu, ordinary = u0, fixed = u1),
    conditional = data.frame(truth = tc, ordinary = c0, fixed = c1))
}

plot_density_bounds <- function(examples, main = "One sample",
                                subtitle = "One fitted estimate per curve",
                                ylimits = NULL) {
  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mfrow = c(2, 3), cex = 1, mar = c(4, 4, 3.5, .8), oma = c(0, 0, 6.5, 0))
  cols <- c("#222222", "#D55E00", "#0072B2")
  titles <- c(proportion = "Proportion: two endpoints",
              duration = "Duration: one endpoint", gaussian = "Gaussian: no finite endpoint")
  for (family in c("unconditional", "conditional")) for (design in names(examples)) {
    z <- examples[[design]]; v <- z[[family]]
    inside <- z$y >= z$bounds[1] & z$y <= z$bounds[2]
    ylim <- if (is.null(ylimits)) c(0, max(v)*1.07) else ylimits[[family]][[design]]
    plot(z$y, v$truth, type = "n", ylim = ylim,
         xlab = "Value of Y", ylab = "Density", main = titles[design], cex.main = .9)
    mtext(if (family == "unconditional") "Unconditional" else
            sprintf("Conditional at X = %.2f", z$x0), side = 3, line = .3, cex = .85)
    if (is.finite(z$bounds[1])) rect(min(z$y), 0, z$bounds[1], par("usr")[4],
                                   col = "#F0F0F0", border = NA)
    if (is.finite(z$bounds[2])) rect(z$bounds[2], 0, max(z$y), par("usr")[4],
                                   col = "#F0F0F0", border = NA)
    ## Break at support endpoints rather than draw a spurious sloping join.
    for (ix in split(seq_along(z$y), cumsum(c(TRUE, diff(inside) != 0)))) {
      lines(z$y[ix], v$truth[ix], col = cols[1], lwd = 2.4)
      lines(z$y[ix], v$fixed[ix], col = cols[3], lwd = 2.4, lty = 3)
    }
    lines(z$y, v$ordinary, col = cols[2], lwd = 2, lty = 2)
    if (design == "gaussian") lines(z$y, v$fixed, col = cols[3], lwd = 2.4, lty = 3)
  }
  mtext(main, side = 3, outer = TRUE, line = 3.5, font = 2, cex = 1.25)
  mtext(subtitle, side = 3, outer = TRUE, line = 2, cex = .9)
  top <- par("omi")[3] / par("din")[2]
  par(fig = c(0, 1, 1-top, 1), new = TRUE, mar = rep(0, 4), oma = rep(0, 4))
  plot.new()
  legend("bottom", c("True density", "Ordinary Gaussian kernel", "Gaussian kernel with fixed support"),
         col = cols, lty = c(1, 2, 3), lwd = 2.4, bty = "n", horiz = TRUE, cex = .9)
}

plot_density_bounds(bounds_examples, main = sprintf("One sample | n = %d | seed = %d", n, seed))

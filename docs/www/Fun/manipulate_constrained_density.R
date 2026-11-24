## Source in RStudio. The examples follow ?np::npuniden.sc.
## Du, Parmeter and Racine (2024), "Shape-Constrained Kernel PDF and PMF
## Estimation", Statistica Sinica 34, 257–289. doi:10.5705/ss.202021.0112
library(manipulate)
library(np)

constrained_density_demo <- function(example, n, smoothing, scale, distance,
                                     lower, upper, extra, extend, match.mass, view, show.rug, population = TRUE) {
  ramp <- grDevices::hcl.colors(256L, "viridis")
  free.col <- ramp[35L]
  fit.col <- ramp[130L]

  set.seed(42)
  shape <- switch(example, mono.incr = c(5, 1), mono.decr = c(1, 5),
                  convex = c(.75, .75), `log-convex` = c(.75, .75))
  if (is.null(shape)) {
    x <- sort(rnorm(n))
    a <- -Inf
    b <- Inf
    truth <- dnorm(x)
  } else {
    x <- sort(rbeta(n, shape[1], shape[2]))
    a <- 0
    b <- 1
    truth <- dbeta(x, shape[1], shape[2])
  }
  bounded <- example == "density"
  if (bounded && upper < lower)
    stop("Choose an upper density bound at least as large as the lower bound.")

  ## Select the unrestricted bandwidth on the same support as the final fit.
  h <- if (smoothing == "manual") scale * sd(x) else
    npuniden.boundary(X = x, a = a, b = b, bwmethod = "cv.ls")$h
  used.distance <- distance
  fit <- withCallingHandlers(
    npuniden.sc(X = x, h = h, a = a, b = b, constraint = example,
      lb = if (bounded) lower, ub = if (bounded) upper,
      function.distance = distance == "fits", integral.equal = match.mass,
      num.grid = extra, extend.range = extend),
    warning = function(w) {
      if (grepl("restarting with function.distance=TRUE", conditionMessage(w), fixed = TRUE))
        used.distance <<- "fits"
    })

  ## The bounds hold at constraint nodes, including any added grid points.
  ## The graph uses the ordered observations. Log-shape derivatives are
  ## derivatives of the log density.
  solved <- isTRUE(fit$solve.QP)
  note <- sprintf("n = %d, h = %.3g", n, h)
  detail <- character(0)
  if (!solved) {
    note <- paste(note, "No constrained solution", sep = " | ")
  } else {
    change <- max(abs(fit$f.sc - fit$f))
    comparison <- if (change <= sqrt(.Machine$double.eps) * max(1, abs(fit$f)))
      "Density curves coincide at the plotted points" else sprintf("Largest density change = %.3g", change)
    note <- paste(note, comparison, sep = " | ")
    if (used.distance != distance) detail <- "Solver used fit deviation"
  }
  if (match.mass && bounded)
    detail <- c(detail, "Density bounds precede mass matching")

  old.par <- par(no.readonly = TRUE)
  on.exit(par(old.par), add = TRUE)
  both <- view == "both" && !bounded
  par(mfrow = c(1, if (both) 2 else 1), mar = c(3.8, 4.1, 2.3, .9),
      oma = c(if (length(detail)) 2.8 else 1.6, 0, 0, 0), mgp = c(2.2, .7, 0))
  draw <- function(raw, restricted, title, ylabel, reference = NULL, guides = NULL, interior = FALSE) {
    ## Beta curvature diverges at the endpoints. Keep the fits visible and
    ## indicate when the population curve runs beyond the displayed range.
    show.reference <- population && length(reference) > 0L
    ref.range <- if (interior) reference[x >= .1 & x <= .9] else reference
    values <- c(raw, if (solved) restricted, ref.range, guides)
    plot(x, raw, type = "n", main = title, xlab = "x", ylab = ylabel, ylim = range(values))
    if (length(guides)) abline(h = guides, lty = 3, col = "grey55")
    if (show.reference) lines(x, reference, col = "black")
    if (solved) lines(x, restricted, col = fit.col, lwd = 2)
    ## Draw the dashed line last so both colours remain visible on overlap.
    lines(x, raw, col = free.col, lty = 2, lwd = 2)
    if (show.reference && interior && any(reference > max(values) | reference < min(values)))
      mtext("Population curve extends beyond the vertical scale", side = 3, line = .1, cex = .65)
    if (show.rug) rug(x, col = "grey65")
    legend(if (example == "mono.incr") "topleft" else "topright",
           c("Unrestricted", if (solved) "Constrained", if (show.reference) "Population"),
           col = c(free.col, if (solved) fit.col, if (show.reference) "black"),
           lty = c(2, if (solved) 1, if (show.reference) 1),
           lwd = c(2, if (solved) 2, if (show.reference) 1), bty = "o", bg = grDevices::adjustcolor("white", alpha.f = .9), box.col = NA, cex = .75)
  }
  if (bounded || view != "restriction")
    draw(fit$f, fit$f.sc, if (bounded) "Density bounds on the constraint grid" else "Density",
         "Density", truth, if (bounded) c(lower, upper))
  if (!bounded && view != "density") {
    ylabel <- switch(example, mono.incr =, mono.decr = "First derivative",
                     `log-concave` =, `log-convex` = "Second derivative of log density",
                     "Second derivative")
    title <- if (example %in% c("mono.incr", "convex", "log-convex"))
      "Nonnegative derivative" else "Nonpositive derivative"
    ## For a beta density f, f' = f (log f)' and
    ## f'' = f {[(log f)']^2 + (log f)''}. Use (log f)'' itself for log shape.
    if (is.null(shape)) {
      deriv.truth <- if (example == "log-concave") rep(-1, n) else (x^2 - 1) * truth
    } else {
      score <- (shape[1] - 1) / x - (shape[2] - 1) / (1 - x)
      log.curvature <- -(shape[1] - 1) / x^2 - (shape[2] - 1) / (1 - x)^2
      deriv.truth <- switch(example,
        mono.incr =, mono.decr = truth * score,
        convex = truth * (score^2 + log.curvature),
        `log-convex` = log.curvature)
    }
    draw(fit$f.deriv, fit$f.sc.deriv, title, ylabel, deriv.truth, guides = 0,
         interior = example %in% c("convex", "log-convex"))
  }
  mtext(note, side = 1, outer = TRUE, line = .2, cex = .8)
  if (length(detail)) mtext(paste(detail, collapse = " | "), side = 1, outer = TRUE, line = 1.4, cex = .8)
  invisible(fit)
}

manipulate(
  constrained_density_demo(example, n, smoothing, scale, distance, lower, upper,
                           extra, extend, match.mass, view, show.rug, population),
  example = picker("Normal — density bounds" = "density",
                   "Beta(5, 1) — increasing" = "mono.incr",
                   "Beta(1, 5) — decreasing" = "mono.decr",
                   "Normal — concave (misspecified)" = "concave",
                   "Beta(0.75, 0.75) — convex" = "convex",
                   "Normal — log-concave" = "log-concave",
                   "Beta(0.75, 0.75) — log-convex" = "log-convex", label = "Example"),
  n = slider(100, 1000, initial = 500, step = 100, label = "Observations"),
  smoothing = picker("Manual" = "manual", "Cross-validate bandwidth" = "cv",
                     label = "Bandwidth selection"),
  scale = slider(.2, 1, initial = .25, step = .05, label = "Manual bandwidth (sample SDs)"),
  distance = picker("Fit deviation" = "fits", "Weight deviation" = "weights", label = "Objective"),
  lower = slider(0, .3, initial = .1, step = .05, label = "Lower bound (density bounds example)"),
  upper = slider(.1, .6, initial = .2, step = .05, label = "Upper bound (density bounds example)"),
  extra = slider(0, 100, initial = 0, step = 25, label = "Additional constraint points"),
  extend = slider(0, .2, initial = 0, step = .05, label = "Range extension for additional points"),
  match.mass = checkbox(FALSE, "Match unrestricted mass over the sampled range"),
  view = picker("Density and restriction" = "both", "Density" = "density",
                "Restriction only" = "restriction", label = "Display"),
  population = checkbox(TRUE, "Show population curve"),
  show.rug = checkbox(FALSE, "Show sample rug"))

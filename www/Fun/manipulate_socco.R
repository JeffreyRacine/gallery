## Explore how Southern Ocean conditional densities, distributions,
## means, and quantiles change with the predictors and bandwidths.
## This code was written with Sonali Das during a CSIR visit in April 2016.

## We are grateful to SOCCO for their assistance and for making the
## data available (Southern Ocean Carbon & Climate Observatory, socco.org.za).

library(manipulate)
library(np)
options(np.tree = "auto")
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.
load("data.RData")

## Integrate tabulated values by the trapezoidal rule.
integrate.trapezoidal <- function(x, y) {
  n <- length(x)
  if (is.unsorted(x)) {
    order.x <- order(x)
    y <- y[order.x]
    x <- x[order.x]
  }

  index <- seq_len(n)[-1]
  int.vec <- numeric(length(x))
  int.vec[index] <- cumsum((x[index] - x[index - 1]) *
    (y[index] + y[index - 1]) / 2)
  int.vec[n]
}

## Evaluate both conditional functions at the selected predictor quantiles.

manipulate.plot <- function(sf.co2f, sf.chl, sf.sal, sf.temp, sf.mld,
                            xq.chl, xq.sal, xq.temp, xq.mld,
                            yq.min.co2f, yq.max.co2f,
                            foo.name,
                            quantile.co2f) {

  ckertype <- "gaussian"

  neval <- 1000

  if (foo.name == "Leg 1 SANAE50") foo.data <- foo.leg1.50
  if (foo.name == "Leg 1 SANAE51") foo.data <- foo.leg1.51
  if (foo.name == "Leg 1 SANAE52") foo.data <- foo.leg1.52
  if (foo.name == "Leg 1 SANAE53") foo.data <- foo.leg1.53
  if (foo.name == "Leg 1 SANAE54") foo.data <- foo.leg1.54
  if (foo.name == "Leg 1 Pooled") foo.data <- foo.leg1
  if (foo.name == "Leg 6 SANAE52") foo.data <- foo.leg6.52
  if (foo.name == "Leg 6 SANAE53") foo.data <- foo.leg6.53
  if (foo.name == "Leg 6 SANAE54") foo.data <- foo.leg6.54
  if (foo.name == "Leg 6 Pooled") foo.data <- foo.leg6
  if (foo.name == "Leg 1 and Leg 6 Pooled") foo.data <- foo.pooled

  ## Extend the response grid to include density beyond the observed range.

  CO2f_sst.er <- with(foo.data, extendrange(CO2f_sst, f = 0.25))

  CO2f_sst.seq <- with(foo.data, seq(CO2f_sst.er[1], CO2f_sst.er[2], length.out = neval))

  newdata <- with(foo.data, data.frame(CO2f_sst = CO2f_sst.seq,
    Chl_conc = rep(uocquantile(Chl_conc, xq.chl), neval),
    Salt_tsg = rep(uocquantile(Salt_tsg, xq.sal), neval),
    Temp_intake = rep(uocquantile(Temp_intake, xq.temp), neval),
    MLD = rep(uocquantile(MLD, xq.mld), neval)))

  f <- fitted(npcdens(tydat = foo.data$CO2f_sst,
    txdat = data.frame(foo.data$Chl_conc, foo.data$Salt_tsg, foo.data$Temp_intake, foo.data$MLD),
    eydat = newdata$CO2f_sst,
    exdat = data.frame(newdata$Chl_conc, newdata$Salt_tsg, newdata$Temp_intake, newdata$MLD),
    bwscaling = TRUE,
    cykertype = ckertype,
    cxkertype = ckertype,
    bws = c(sf.co2f, sf.chl, sf.sal, sf.temp, sf.mld)))

  cdf_fit <- fitted(npcdist(tydat = foo.data$CO2f_sst,
    txdat = data.frame(foo.data$Chl_conc, foo.data$Salt_tsg, foo.data$Temp_intake, foo.data$MLD),
    eydat = newdata$CO2f_sst,
    exdat = data.frame(newdata$Chl_conc, newdata$Salt_tsg, newdata$Temp_intake, newdata$MLD),
    bwscaling = TRUE,
    cykertype = ckertype,
    cxkertype = ckertype,
    bws = c(sf.co2f, sf.chl, sf.sal, sf.temp, sf.mld)))


  ## Approximate the conditional mean by integrating over the extended response grid.
  mean.CO2f <- integrate.trapezoidal(CO2f_sst.seq, CO2f_sst.seq * f)

  ## For an interior probability, mark the first grid crossing of the conditional CDF.
  ## A Gaussian smoother has unbounded tails at probabilities zero and one.
  i <- match(TRUE, cdf_fit >= quantile.co2f)
  quantile.label <- "outside evaluation grid"
  cond.quantile.CO2f <- NA_real_
  if (quantile.co2f == 0 || quantile.co2f == 1) {
    quantile.label <- if (quantile.co2f == 0) "-Inf" else "+Inf"
  } else if (!is.na(i) && (i > 1L || cdf_fit[1L] == quantile.co2f)) {
    cond.quantile.CO2f <- CO2f_sst.seq[i]
    quantile.label <- sprintf("%.1f (mu atm)", cond.quantile.CO2f)
  }

  par(mfrow = c(2, 1))

  legend.dat <- with(foo.data, formatC(c(Chl_conc = uocquantile(Chl_conc, xq.chl),
    Salt_tsg = uocquantile(Salt_tsg, xq.sal),
    Temp_intake = uocquantile(Temp_intake, xq.temp),
    MLD = uocquantile(MLD, xq.mld)),
  format = "f",
  digits = 2))

  ## Conditional PDF plot

  legend.txt <- c(paste("Chl_conc = ", legend.dat[1], " (millivolts)", sep = ""),
    paste("Salt_tsg = ", legend.dat[2], " (PSU)", sep = ""),
    paste("Temp_intake = ", legend.dat[3], " (C)", sep = ""),
    paste("MLD = ", legend.dat[4], " (meters)", sep = ""),
    sprintf("Conditional mean = %.1f (mu atm)", mean.CO2f))

  ylim <- c(0, max(f))
  xlim <- with(foo.data, c(uocquantile(CO2f_sst, yq.min.co2f),
    uocquantile(CO2f_sst, yq.max.co2f)))

  with(foo.data, plot(f ~ CO2f_sst.seq,
    ylab = "Conditional PDF",
    xlab = "CO2f_sst (mu atm)",
    type = "l",
    ylim = ylim,
    xlim = xlim,
    main = foo.name,
    sub = paste("(", dim(foo.data)[1], " observations)", sep = ""),
    lty = 1, col = "#3E3375", lwd = 2))

  with(foo.data, rug(CO2f_sst, col = "lightgrey", quiet = TRUE))

  abline(v = mean.CO2f, col = "grey", lty = 2, lwd = 2)

  legend("topleft", legend.txt, cex = 0.8, lty = c(NA, NA, NA, NA, 2), col = c(NA, NA, NA, NA, "grey"), lwd = c(NA, NA, NA, NA, 2), bty = "n")

  ## Conditional CDF plot

  legend.txt <- c(paste("Chl_conc = ", legend.dat[1], " (millivolts)", sep = ""),
    paste("Salt_tsg = ", legend.dat[2], " (PSU)", sep = ""),
    paste("Temp_intake = ", legend.dat[3], " (C)", sep = ""),
    paste("MLD = ", legend.dat[4], " (meters)", sep = ""),
    sprintf("Conditional quantile (p = %.1f): %s", quantile.co2f, quantile.label))

  ylim <- c(0, 1)

  with(foo.data, plot(cdf_fit ~ CO2f_sst.seq,
    ylab = "Conditional CDF",
    xlab = "CO2f_sst (mu atm)",
    type = "l",
    ylim = ylim,
    xlim = xlim,
    sub = paste("(", dim(foo.data)[1], " observations)", sep = ""),
    lty = 1, col = "#3E3375", lwd = 2))

  with(foo.data, rug(CO2f_sst, col = "lightgrey", quiet = TRUE))

  if (is.finite(cond.quantile.CO2f)) abline(v = cond.quantile.CO2f, col = "grey", lty = 2, lwd = 2)

  legend("topleft", legend.txt, cex = 0.8, lty = c(rep(NA, 4), if (is.finite(cond.quantile.CO2f)) 2 else NA), col = c(NA, NA, NA, NA, "grey"), lwd = c(NA, NA, NA, NA, 2), bty = "n")

}

## Expose the predictor and bandwidth controls in an interactive panel.
manipulate(manipulate.plot(sf.co2f, sf.chl, sf.sal, sf.temp, sf.mld,
                           xq.chl, xq.sal, xq.temp, xq.mld,
                           yq.min.co2f, yq.max.co2f,
                           foo.name,
                           quantile.co2f),
           sf.co2f = slider(0.1, 0.5, .25, label = "CO2f_sst Scale factor", step = 0.05, ticks = TRUE),
           sf.chl = slider(0.1, 0.5, .25, label = "Chl_conc Scale factor", step = 0.05, ticks = TRUE),
           sf.sal = slider(0.1, 0.5, .25, label = "Salt_tsg Scale factor", step = 0.05, ticks = TRUE),
           sf.temp = slider(0.1, 0.5, .25, label = "Temp_intake Scale factor", step = 0.05, ticks = TRUE),
           sf.mld = slider(0.1, 0.5, .25, label = "MLD Scale factor", step = 0.05, ticks = TRUE),
           foo.name = picker("Leg 1 SANAE50",
               "Leg 1 SANAE51",
               "Leg 1 SANAE52",
               "Leg 1 SANAE53",
               "Leg 1 SANAE54",
               "Leg 1 Pooled",
               "Leg 6 SANAE52",
               "Leg 6 SANAE53",
               "Leg 6 SANAE54",
               "Leg 6 Pooled",
               "Leg 1 and Leg 6 Pooled",
               label = "Data"),
           xq.chl = slider(0.20, 0.80, 0.5, label = "Chl_conc quantile", step = 0.05, ticks = TRUE),
           xq.sal = slider(0.20, 0.80, 0.5, label = "Salt_tsg quantile", step = 0.05, ticks = TRUE),
           xq.temp = slider(0.20, 0.80, 0.5, label = "Temp_intake quantile", step = 0.05, ticks = TRUE),
           xq.mld = slider(0.20, 0.80, 0.5, label = "MLD quantile", step = 0.05, ticks = TRUE),
           yq.min.co2f = slider(0, 0.5, 0.05, label = "Plot lower quantile", step = 0.05, ticks = TRUE),
           yq.max.co2f = slider(0.5, 1, 0.95, label = "Plot upper quantile", step = 0.05, ticks = TRUE),
           quantile.co2f = slider(0, 1, 0.5, label = "Probability for conditional quantile ", step = 0.1, ticks = TRUE))

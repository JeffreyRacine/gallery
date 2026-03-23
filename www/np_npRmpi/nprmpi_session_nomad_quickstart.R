rm(list = ls())

## Minimal modern npRmpi NOMAD example.
##
## The intended workflow is:
## 1. initialize MPI once,
## 2. use the same nomad = TRUE shortcut available in np,
## 3. inspect the normalized shortcut metadata,
## 4. quit cleanly at the end.

if (!requireNamespace("crs", quietly = TRUE)) {
  stop(
    "This quickstart uses nomad = TRUE, which requires the 'crs' package ",
    "for NOMAD degree search. Install it with install.packages('crs')."
  )
}

library(npRmpi)

npRmpi.init(nslaves = 1)

set.seed(7)
n <- 120
x <- runif(n, -1, 1)
y <- x + 0.4 * x^2 + rnorm(n, sd = 0.18)
dat <- data.frame(y, x)

fit <- npreg(y ~ x, data = dat, nomad = TRUE, degree.max = 2L, nmulti = 1L)

fit$bws$nomad.shortcut
summary(fit)

plot(dat$x, dat$y, cex = 0.35, col = "grey")
o <- order(dat$x)
lines(dat$x[o], fitted(fit)[o], col = 2, lwd = 2)

npRmpi.quit()

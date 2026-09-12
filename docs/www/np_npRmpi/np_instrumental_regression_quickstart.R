## Minimal np instrumental-regression example.
##
## This mirrors the basic one-endogenous-regressor setup used in the
## package demos while keeping the first run compact.

library(np)

## Build a small one-endogenous-regressor example with one instrument.
set.seed(42)
n <- 80
v <- rnorm(n, sd = 0.27)
eps <- rnorm(n, sd = 0.05)
u <- -0.5 * v + eps
w <- rnorm(n)
z <- 0.2 * w + v
y <- z^2 + u
iv_dat <- data.frame(y, z, w)

## Fit through the 0.80-1 formula/data interface.
fit_iv <- npregiv(y ~ z | w,
  data = iv_dat,
  method = "Tikhonov",
  nmulti = 1)

## Inspect the selected structural fit and its training residuals.
summary(fit_iv)
head(fitted(fit_iv))
head(residuals(fit_iv))

## Use the dedicated IV plot controls for the fitted structural function.
plot(fit_iv, data.overlay = TRUE, data.rug = TRUE)

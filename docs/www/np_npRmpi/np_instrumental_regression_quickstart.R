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

## Fit the nonparametric IV regression.
fit_iv <- npregiv(y = y, z = z, w = w, method = "Tikhonov", nmulti = 1)

## Inspect the fitted IV object.
summary(fit_iv)

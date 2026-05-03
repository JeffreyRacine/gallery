## Minimal crs instrumental-regression example.
##
## This is a compact first run for spline-based IV estimation.

library(crs)

## Build a small IV example with one endogenous regressor and one instrument.
set.seed(42)
n <- 100
v <- rnorm(n, sd = 0.27)
eps <- rnorm(n, sd = 0.05)
u <- -0.5 * v + eps
w <- rnorm(n)
z <- 0.2 * w + v
y <- z^2 + u

## Fit the spline IV model.
fit_iv <- crsiv(
  y = y,
  z = z,
  w = w,
  method = "Landweber-Fridman",
  cv = "exhaustive",
  nmulti = 1,
  cv.threshold = 0
)

## Inspect the fitted IV object.
summary(fit_iv)

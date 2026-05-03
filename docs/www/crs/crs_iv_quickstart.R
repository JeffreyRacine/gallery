## Minimal crs instrumental-regression example.
##
## This is a compact first run for spline-based IV estimation.

library(crs)

set.seed(42)
n <- 100
v <- rnorm(n, sd = 0.27)
eps <- rnorm(n, sd = 0.05)
u <- -0.5 * v + eps
w <- rnorm(n)
z <- 0.2 * w + v
y <- z^2 + u

fit_iv <- crsiv(
  y = y,
  z = z,
  w = w,
  method = "Landweber-Fridman",
  cv = "exhaustive",
  nmulti = 1,
  cv.threshold = 0
)

summary(fit_iv)

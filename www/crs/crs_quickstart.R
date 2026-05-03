## Minimal crs spline-regression example.
##
## This is the smallest useful workflow:
## 1. fit a spline model,
## 2. inspect the summary,
## 3. optionally move on to plotting or tighter search control.

library(crs)
options(crs.messages = FALSE)

## Generate a simple nonlinear surface with two predictors.
set.seed(42)
n <- 250
x1 <- runif(n)
x2 <- runif(n)
y <- sin(2 * pi * x1) + x2 + rnorm(n, sd = 0.2)
dat <- data.frame(y, x1, x2)

## Fit the spline model and inspect the summary.
fit <- crs(y ~ x1 + x2, data = dat)

summary(fit)

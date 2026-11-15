## Estimate a bivariate conditional mean g(x1, x2) with splines.

library(crs)
options(crs.messages = FALSE)

## Generate a simple nonlinear surface with two predictors.
set.seed(42)
n <- 250
x1 <- runif(n)
x2 <- runif(n)
y <- sin(2 * pi * x1) + x2 + rnorm(n, sd = 0.2)
dat <- data.frame(y, x1, x2)

## Fit the spline model, inspect it, then let plot.crs() build the surface.
fit <- crs(y ~ x1 + x2, data = dat)

summary(fit)
plot(fit, perspective = TRUE, view = "fixed")

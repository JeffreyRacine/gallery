## Estimate E(Y | X, Z) = X^T beta + g(Z).

library(np)
options(np.messages = FALSE)

## Build a small partially linear data-generating setup.
set.seed(42)
n <- 200
x1 <- rnorm(n)
z <- runif(n)
y <- 1 + 2 * x1 + sin(2 * pi * z) + rnorm(n, sd = 0.2)
dat <- data.frame(y, x1, z)

## Fit the partially linear model.
fit <- npplreg(y ~ x1 | z, data = dat)

## Inspect the fitted semiparametric object.
summary(fit)

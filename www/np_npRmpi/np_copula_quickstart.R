## Minimal np copula example.
##
## This uses the direct formula interface and lets npcopula() build
## the corresponding marginal distribution bandwidth object internally.

library(np)
library(MASS)

set.seed(42)
n <- 1000
rho <- 0.95
Sigma <- matrix(c(1, rho, rho, 1), 2, 2)

## Simulate a simple bivariate sample with strong dependence.
dat <- as.data.frame(mvrnorm(n = n, mu = c(0, 0), Sigma = Sigma))
names(dat) <- c("x", "y")

## Let npcopula() create a small default probability grid.
copula_fit <- npcopula(~ x + y, data = dat, neval = 20)

## Inspect the fitted copula object and the retained bandwidth object.
summary(copula_fit)
summary(attr(copula_fit, "bws"))

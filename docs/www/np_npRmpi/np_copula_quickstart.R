## Minimal np copula example.
##
## This estimates a copula on a small probability grid after building
## the corresponding marginal distribution bandwidth object.

library(np)
library(MASS)

set.seed(42)
n <- 1000
rho <- 0.95
Sigma <- matrix(c(1, rho, rho, 1), 2, 2)

## Simulate a simple bivariate sample with strong dependence.
dat <- as.data.frame(mvrnorm(n = n, mu = c(0, 0), Sigma = Sigma))
names(dat) <- c("x", "y")

## Evaluate the copula on a small probability grid.
u_grid <- data.frame(
  x = seq(0, 1, length.out = 10),
  y = seq(0, 1, length.out = 10)
)

## Build the marginal distribution object, then compute the copula.
bw <- npudistbw(~ x + y, data = dat)
copula_fit <- npcopula(bws = bw, data = dat, u = u_grid)

## Inspect both the marginal bandwidths and the fitted copula object.
summary(bw)
summary(copula_fit)

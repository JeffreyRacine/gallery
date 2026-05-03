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
dat <- as.data.frame(mvrnorm(n = n, mu = c(0, 0), Sigma = Sigma))
names(dat) <- c("x", "y")

u_grid <- data.frame(
  x = seq(0, 1, length.out = 10),
  y = seq(0, 1, length.out = 10)
)

bw <- npudistbw(~ x + y, data = dat)
copula_fit <- npcopula(bws = bw, data = dat, u = u_grid)

summary(bw)
summary(copula_fit)

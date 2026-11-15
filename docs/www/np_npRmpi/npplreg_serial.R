## Serial counterpart to npplreg_npRmpi.R.
## The fitted objects should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

## Simulate linear X effects and a nonlinear Z effect.

set.seed(42)

n <- 1000

x1 <- rnorm(n)
x2 <- rbinom(n, 5, .3)

z1 <- rbinom(n, 2, .3)
z2 <- rnorm(n)

y <- 1 + x1 + x2 + z1 + sin(z2) + rnorm(n)

x2 <- ordered(x2)
z1 <- ordered(z1)

## Estimate E(Y | X, Z) = X^T beta + g(Z).

t <- system.time(bw <- npplregbw(formula = y ~ x1 + x2 | z1 + z2))

summary(bw)

t <- t + system.time(pl <- npplreg(bws = bw))

summary(pl)

cat("Elapsed time =", t[3], "\n")

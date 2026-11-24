## Test a partially linear conditional-mean specification.

library(np)

## Under the null, X enters linearly while Z enters through an unknown function.
set.seed(42)
n <- 120L
dat <- data.frame(x1 = rnorm(n), x2 = rnorm(n), z = runif(n, -1, 1))
noise <- with(dat, (0.45 + 0.30 * z^2) * rnorm(n))
dat$y_null <- with(dat, 0.8 * x1 - 0.6 * x2 + sin(pi * z) + noise)

## Curvature in x1 violates the partially linear restriction.
dat$y_alt <- with(dat, y_null + 1.5 * (x1^2 - 1))

## The test accepts either a fitted object or its bandwidth object.
pl_null <- npplreg(y_null ~ x1 + x2 | z,
  regtype = "ll", data = dat)
pl_alt_bw <- npplregbw(y_alt ~ x1 + x2 | z,
  regtype = "ll", data = dat)
pl_null_test <- nppltest(pl_null)
pl_alt_test <- nppltest(pl_alt_bw)

summary(pl_null_test)
summary(pl_alt_test)

## At seed 42, retain the null and reject the alternative at 5%.
stopifnot(pl_null_test$P > 0.05, pl_alt_test$P < 0.05)

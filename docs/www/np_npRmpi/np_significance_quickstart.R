rm(list = ls())

## Minimal np significance-testing example.
##
## The idea is to fit a model with one irrelevant regressor and then
## ask whether the nonparametric significance test detects that.

library(np)
options(np.messages = FALSE)

set.seed(42)
n <- 200
z <- factor(rbinom(n, 1, 0.5))
x1 <- rnorm(n)
x2 <- runif(n, -2, 2)
y <- x1 + x2 + rnorm(n)
dat <- data.frame(z, x1, x2, y)

fit <- npreg(
  y ~ z + x1 + x2,
  regtype = "ll",
  bwmethod = "cv.aic",
  data = dat
)

test_out <- npsigtest(fit)

summary(fit)
summary(test_out)

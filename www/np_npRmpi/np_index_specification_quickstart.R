## Test continuous and binary single-index specifications.

library(np)

## Build linear-index nulls and off-index interaction alternatives.
set.seed(42)
n <- 160L
dat <- data.frame(x1 = rnorm(n), x2 = rnorm(n))
index <- with(dat, x1 + 0.6 * x2)
off_index <- with(dat, x2 - 0.6 * x1)

dat$y_null <- index + 0.45 * sin(index) +
  (0.6 + 0.2 * abs(off_index)) * rnorm(n)
dat$y_alt <- dat$y_null + 1.8 * index * off_index
dat$choice_alt <- rbinom(n, 1, plogis(index + 1.8 * index * off_index))
dat$choice_null <- rbinom(n, 1, plogis(index))

## Fit Ichimura models and test the fitted object or its bandwidth object.
ich_null <- npindex(y_null ~ x1 + x2,
  method = "ichimura", data = dat)
ich_alt <- npindex(y_alt ~ x1 + x2,
  method = "ichimura", data = dat)
ich_null_test <- npindextest(ich_null)
ich_alt_test <- npindextest(ich_alt$bws)

## Repeat for Klein--Spady binary-choice models.
ks_null <- npindex(choice_null ~ x1 + x2,
  method = "kleinspady", data = dat)
ks_alt <- npindex(choice_alt ~ x1 + x2,
  method = "kleinspady", data = dat)
ks_null_test <- npindextest(ks_null)
ks_alt_test <- npindextest(ks_alt$bws)

summary(ich_null_test)
summary(ich_alt_test)
summary(ks_null_test)
summary(ks_alt_test)

## At seed 42, retain both nulls and reject both alternatives at 5%.
stopifnot(
  ich_null_test$P > 0.05,
  ich_alt_test$P < 0.05,
  ks_null_test$P > 0.05,
  ks_alt_test$P < 0.05)

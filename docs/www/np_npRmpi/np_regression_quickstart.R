## Minimal np regression example.
##
## The intended workflow is:
## 1. compute a bandwidth object,
## 2. fit the regression estimator,
## 3. inspect the result and a simple fitted curve.

library(np)
options(np.messages = FALSE)

data(cps71, package = "np")
dat <- cps71[, c("logwage", "age")]

bw <- npregbw(logwage ~ age, data = dat, regtype = "ll", bwmethod = "cv.aic")
fit <- npreg(bws = bw, data = dat)

summary(bw)
summary(fit)

plot(fit)

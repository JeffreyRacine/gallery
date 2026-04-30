## Minimal np density-estimation example.
##
## The intended workflow is:
## 1. compute a bandwidth object,
## 2. fit the density estimator,
## 3. inspect the result.

library(np)
options(np.messages = FALSE)

data(faithful, package = "datasets")
dat <- data.frame(waiting = faithful$waiting)

bw <- npudensbw(~ waiting, data = dat, bwmethod = "cv.ml")
fhat <- npudens(bws = bw, data = dat)

summary(bw)
summary(fhat)

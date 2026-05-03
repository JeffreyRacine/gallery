## Minimal np density-estimation example.
##
## The intended workflow is:
## 1. compute a bandwidth object,
## 2. fit the density estimator,
## 3. inspect the result.

library(np)
options(np.messages = FALSE)

## Start with one variable so the density workflow is easy to read.
data(faithful, package = "datasets")
dat <- data.frame(waiting = faithful$waiting)

## Select the smoothing parameter, then fit the density.
bw <- npudensbw(~ waiting, data = dat, bwmethod = "cv.ml")
fhat <- npudens(bws = bw, data = dat)

## Review the bandwidth choice and the fitted density object.
summary(bw)
summary(fhat)

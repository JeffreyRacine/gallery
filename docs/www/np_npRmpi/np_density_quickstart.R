## Estimate the unconditional density f(y).

library(np)
options(np.messages = FALSE)

## Use one variable to isolate the density workflow.
data(faithful, package = "datasets")
dat <- data.frame(waiting = faithful$waiting)

## Select the smoothing parameter, then fit the density.
bw <- npudensbw(~waiting, data = dat, bwmethod = "cv.ml")
fhat <- npudens(bws = bw, data = dat)

## Review the bandwidth choice and the fitted density object.
summary(bw)
summary(fhat)

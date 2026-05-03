## Minimal np distribution example.
##
## This mirrors the usual density workflow but targets the
## unconditional distribution function instead.

library(np)
options(np.messages = FALSE)

## Mirror the basic density setup, but target the distribution instead.
data(faithful, package = "datasets")
dat <- data.frame(waiting = faithful$waiting)

## Select the bandwidth, then fit the unconditional distribution.
bw <- npudistbw(~ waiting, data = dat, nmulti = 1)
Fhat <- npudist(bws = bw, data = dat)

## Review the smoothing choice and the fitted distribution object.
summary(bw)
summary(Fhat)

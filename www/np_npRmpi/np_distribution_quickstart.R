## Minimal np distribution example.
##
## This mirrors the usual density workflow but targets the
## unconditional distribution function instead.

library(np)
options(np.messages = FALSE)

data(faithful, package = "datasets")
dat <- data.frame(waiting = faithful$waiting)

bw <- npudistbw(~ waiting, data = dat, nmulti = 1)
Fhat <- npudist(bws = bw, data = dat)

summary(bw)
summary(Fhat)


## Minimal np conditional-density example.
##
## This keeps the first run small enough to be practical while still
## showing the standard two-step workflow:
## 1. compute a bandwidth object,
## 2. fit the conditional-density estimator.

library(np)
options(np.messages = FALSE)

## Keep the first run small enough that the two-step workflow stays quick.
data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

## Select the bandwidth first, then fit the conditional density.
bw <- npcdensbw(eruptions ~ waiting, data = dat, nmulti = 1)
fhat <- npcdens(bws = bw, data = dat)

## Review both the smoothing choice and the fitted object.
summary(bw)
summary(fhat)

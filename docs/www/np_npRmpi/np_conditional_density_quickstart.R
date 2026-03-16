rm(list = ls())

## Minimal np conditional-density example.
##
## This keeps the first run small enough to be practical while still
## showing the standard two-step workflow:
## 1. compute a bandwidth object,
## 2. fit the conditional-density estimator.

library(np)
options(np.messages = FALSE)

data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

bw <- npcdensbw(eruptions ~ waiting, data = dat, nmulti = 1)
fhat <- npcdens(bws = bw, data = dat)

summary(bw)
summary(fhat)


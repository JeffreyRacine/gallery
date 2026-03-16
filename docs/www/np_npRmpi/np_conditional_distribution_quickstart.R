rm(list = ls())

## Minimal np conditional-distribution example.
##
## This uses a small first run so the standard two-step workflow stays
## copyable and practical.

library(np)
options(np.messages = FALSE)

data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

bw <- npcdistbw(eruptions ~ waiting, data = dat, nmulti = 1)
Fhat <- npcdist(bws = bw, data = dat)

summary(bw)
summary(Fhat)


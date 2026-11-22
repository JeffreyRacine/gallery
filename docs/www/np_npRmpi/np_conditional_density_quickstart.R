## Estimate the conditional density f(y | x).

library(np)
options(np.messages = FALSE)

## Keep the first run small enough that the two-step workflow stays quick.
data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

## Select the bandwidth first, then fit the conditional density.
bw <- npcdensbw(eruptions ~ waiting, data = dat)
fhat <- npcdens(bws = bw, data = dat)

## Review both the smoothing choice and the fitted object.
summary(bw)
summary(fhat)

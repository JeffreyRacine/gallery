## Minimal np conditional-distribution example.
##
## This uses a small first run so the standard two-step workflow stays
## copyable and practical.

library(np)
options(np.messages = FALSE)

## Work on a smaller slice so the first run stays easy to inspect.
data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

## Select the bandwidth, then fit the conditional distribution.
bw <- npcdistbw(eruptions ~ waiting, data = dat, nmulti = 1)
Fhat <- npcdist(bws = bw, data = dat)

## Review the bandwidth object and the fitted distribution.
summary(bw)
summary(Fhat)

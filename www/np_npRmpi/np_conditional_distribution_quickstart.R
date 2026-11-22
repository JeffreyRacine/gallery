## Estimate the conditional distribution F(y | x).

library(np)
options(np.messages = FALSE)

## Use a smaller slice to keep the first bandwidth search brief.
data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

## Select the bandwidth, then fit the conditional distribution.
bw <- npcdistbw(eruptions ~ waiting, data = dat)
Fhat <- npcdist(bws = bw, data = dat)

## Review the bandwidth object and the fitted distribution.
summary(bw)
summary(Fhat)

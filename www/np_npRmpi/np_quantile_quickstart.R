## Minimal np quantile-regression example.
##
## The key idea is to compute/select the conditional distribution once
## and then extract one or more quantiles from it.

library(np)
options(np.messages = FALSE)

## Keep the first quantile run compact and reproducible.
data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

## Build one conditional-distribution fit and request several quantiles.
qfit <- npqreg(eruptions ~ waiting,
               data = dat,
               tau = c(0.25, 0.50, 0.75),
               nmulti = 1)

## Review the bandwidth choice and one representative fitted quantile.
summary(qfit$bws)
summary(qfit)

## Plot the overlaid fitted quantile curves.
plot(qfit)

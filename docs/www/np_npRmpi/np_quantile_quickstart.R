## Minimal np quantile-regression example.
##
## The key idea is to compute a conditional-distribution bandwidth once
## and then reuse it for more than one quantile.

library(np)
options(np.messages = FALSE)

data(faithful, package = "datasets")
dat <- faithful[seq_len(120), c("eruptions", "waiting")]

bw <- npcdistbw(eruptions ~ waiting, data = dat, nmulti = 1)
q25 <- npqreg(bws = bw, tau = 0.25)
q50 <- npqreg(bws = bw, tau = 0.50)
q75 <- npqreg(bws = bw, tau = 0.75)

summary(bw)
summary(q50)

plot(dat$waiting, dat$eruptions, cex = 0.35, col = "grey")
o <- order(dat$waiting)
lines(dat$waiting[o], q25$quantile[o], col = 2, lty = 2, lwd = 2)
lines(dat$waiting[o], q50$quantile[o], col = 4, lty = 1, lwd = 2)
lines(dat$waiting[o], q75$quantile[o], col = 2, lty = 3, lwd = 2)

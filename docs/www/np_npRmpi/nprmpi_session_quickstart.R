## Minimal modern npRmpi example.
##
## The intended workflow is:
## 1. initialize MPI once in session/spawn mode,
## 2. write ordinary np-style code,
## 3. quit cleanly at the end.

library(npRmpi)

npRmpi.init(nslaves = 1)

set.seed(1)
x <- runif(200)
y <- sin(2 * pi * x) + rnorm(200, sd = 0.2)
dat <- data.frame(y, x)

bw <- npregbw(y ~ x, regtype = "ll", bwmethod = "cv.ls", data = dat)
fit <- npreg(bws = bw, data = dat)

summary(bw)
summary(fit)

plot(dat$x, dat$y, cex = 0.35, col = "grey")
o <- order(dat$x)
lines(dat$x[o], fitted(fit)[o], col = 2, lwd = 2)

npRmpi.quit()

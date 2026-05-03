## Minimal modern npRmpi example.
##
## The intended workflow is:
## 1. initialize MPI once in session/spawn mode,
## 2. write ordinary np-style code,
## 3. quit cleanly at the end.

library(npRmpi)

## Initialize once, then work as if this were an ordinary np script.
npRmpi.init(nslaves = 1)

set.seed(1)
x <- runif(200)
y <- sin(2 * pi * x) + rnorm(200, sd = 0.2)
dat <- data.frame(y, x)

## Fit the bandwidth and regression objects.
bw <- npregbw(y ~ x, regtype = "ll", bwmethod = "cv.ls", data = dat)
fit <- npreg(bws = bw, data = dat)

## Review the objects, plot the fit, then exit cleanly.
summary(bw)
summary(fit)

plot(fit)

npRmpi.quit()

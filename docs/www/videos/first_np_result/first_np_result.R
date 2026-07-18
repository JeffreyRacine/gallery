## Your first np result.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(cps71, package = "np")

fit_first <- npreg(logwage ~ age, data = cps71)
summary(fit_first$bws)
plot(fit_first, main = "A first np regression")

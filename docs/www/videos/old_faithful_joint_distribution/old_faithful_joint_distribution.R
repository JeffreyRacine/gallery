## Old Faithful joint-distribution short.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(faithful, package = "datasets")

fit_udist <- npudist(~ eruptions + waiting, data = faithful)
summary(fit_udist$bws)
plot(fit_udist, renderer = "rgl")

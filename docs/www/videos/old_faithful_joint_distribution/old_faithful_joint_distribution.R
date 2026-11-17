## Old Faithful joint-distribution short.

library(np)
data(faithful, package = "datasets")

fit_udist <- npudist(~ eruptions + waiting, data = faithful)
summary(fit_udist$bws)
plot(fit_udist, renderer = "rgl")

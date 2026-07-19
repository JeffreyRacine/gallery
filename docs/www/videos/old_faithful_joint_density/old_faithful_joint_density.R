## Old Faithful joint-density short.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(faithful, package = "datasets")

fit_udens <- npudens(~ eruptions + waiting, data = faithful)
summary(fit_udens$bws)
plot(fit_udens, renderer = "rgl")

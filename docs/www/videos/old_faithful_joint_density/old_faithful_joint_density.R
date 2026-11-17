## Old Faithful joint-density short.

library(np)
data(faithful, package = "datasets")

fit_udens <- npudens(~ eruptions + waiting, data = faithful)
summary(fit_udens$bws)
plot(fit_udens, renderer = "rgl")

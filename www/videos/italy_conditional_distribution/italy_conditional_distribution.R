## Italy conditional-distribution short.

library(np)
data(Italy, package = "np")

class(Italy$year)
fit_cdist <- npcdist(gdp ~ year, data = Italy)
summary(fit_cdist$bws)
plot(fit_cdist, view = "fixed", theta = 90, phi = 45)

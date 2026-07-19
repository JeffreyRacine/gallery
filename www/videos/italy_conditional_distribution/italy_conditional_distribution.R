## Italy conditional-distribution short.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(Italy, package = "np")

class(Italy$year)
fit_cdist <- npcdist(gdp ~ year, data = Italy)
summary(fit_cdist$bws)
plot(fit_cdist, view = "fixed", theta = 90, phi = 45)

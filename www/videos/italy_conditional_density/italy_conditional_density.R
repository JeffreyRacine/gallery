## Italy conditional-density short.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(Italy, package = "np")

class(Italy$year)
fit_cdens <- npcdens(gdp ~ year, data = Italy)
summary(fit_cdens$bws)
plot(fit_cdens, view = "fixed", theta = 90, phi = 45)

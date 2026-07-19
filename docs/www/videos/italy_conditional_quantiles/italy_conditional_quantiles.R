## Italy conditional-quantile short.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(Italy, package = "np")

class(Italy$year)
fit_qreg <- npqreg(gdp ~ year,
                   data = Italy,
                   tau = c(0.25, 0.50, 0.75))
summary(fit_qreg$bws)
plot(fit_qreg)

library(np)
data(cps71, package = "np")

## Use the shortest modern LP route.
## nomad = "auto" uses exhaustive search for p = 1 and NOMAD otherwise.
fit_lp <- npreg(logwage ~ age, data = cps71, nomad = "auto")

## Plot first, then inspect the fitted object in text form.
plot(fit_lp)
summary(fit_lp)

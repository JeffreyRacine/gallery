library(np)
data(cps71, package = "np")

## Use the shortest modern LP route: fit directly with nomad = TRUE.
fit_lp <- npreg(logwage ~ age, data = cps71, nomad = TRUE)

## Plot first, then inspect the fitted object in text form.
plot(fit_lp)
summary(fit_lp)

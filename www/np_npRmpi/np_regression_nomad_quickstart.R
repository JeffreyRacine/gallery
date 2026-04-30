library(np)
data(cps71, package = "np")

fit_lp <- npreg(logwage ~ age, data = cps71, nomad = TRUE)
plot(fit_lp)
summary(fit_lp)

## Old Faithful automatic local-polynomial regression and bootstrap bands.
## Verified with the public CRAN np 0.70-5 build.

library(np)
data(faithful, package = "datasets")

fit_npreg <- npreg(waiting ~ eruptions, data = faithful, nomad = "auto")
summary(fit_npreg$bws)

options(plot.par.mfrow = FALSE)
par(mfrow = c(2, 2))

plot(fit_npreg, errors = "bootstrap", band = "all", B = 9999)
plot(fit_npreg,
     errors = "bootstrap", band = "all", B = 9999,
     gradients = TRUE, gradient_order = 1)
plot(fit_npreg,
     errors = "bootstrap", band = "all", B = 9999,
     gradients = TRUE, gradient_order = 2)
plot(fit_npreg,
     errors = "bootstrap", band = "all", B = 9999,
     gradients = TRUE, gradient_order = 3)


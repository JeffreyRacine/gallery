## Old Faithful automatic local-polynomial regression and bootstrap bands.

library(np)
data(faithful, package = "datasets")

fit_npreg <- npreg(waiting ~ eruptions, data = faithful, nomad = "auto")
summary(fit_npreg$bws)

options(plot.par.mfrow = FALSE)
par(mfrow = c(2, 2))

plot(fit_npreg, errors = "bootstrap", band = "all")
plot(fit_npreg,
     errors = "bootstrap", band = "all",
     gradients = TRUE, gradient_order = 1)
plot(fit_npreg,
     errors = "bootstrap", band = "all",
     gradients = TRUE, gradient_order = 2)
plot(fit_npreg,
     errors = "bootstrap", band = "all",
     gradients = TRUE, gradient_order = 3)

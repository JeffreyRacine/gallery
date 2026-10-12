## Compare local-constant and local-linear kernel regressions.
## Data: 1971 Canadian Census sample supplied by Aman Ullah; see
## Pagan and Ullah (1999), Nonparametric Econometrics.

library(np)
data(cps71, package = "np")

## Fit the default local-constant model and display its fitted curve.
model.lc <- npreg(logwage ~ age, data = cps71)
plot(model.lc)

## Fit a local-linear model, then add its curve in sample order.
model.ll <- npreg(logwage ~ age,
  regtype = "ll",
  data = cps71)
age.order <- order(cps71$age)
lines(cps71$age[age.order], fitted(model.ll)[age.order],
  col = 2, lty = 2)

legend("topleft",
  c("Local constant", "Local linear"),
  lty = c(1, 2),
  col = c(1, 2),
  bty = "n")

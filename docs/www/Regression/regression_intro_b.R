## Compare derivatives from local-constant and local-linear regressions.
## Data: 1971 Canadian Census sample supplied by Aman Ullah; see
## Pagan and Ullah (1999), Nonparametric Econometrics.

library(np)
data(cps71, package = "np")

## Request derivatives when fitting the local-constant model.
model.lc <- npreg(logwage ~ age,
  gradients = TRUE,
  data = cps71)

## Draw both derivative estimates against ordered ages.
age.order <- order(cps71$age)
plot(cps71$age[age.order], gradients(model.lc)[age.order],
  ylab = "Derivative",
  col = 1,
  lty = 1,
  type = "l")

model.ll <- npreg(logwage ~ age,
  regtype = "ll",
  gradients = TRUE,
  data = cps71)
lines(cps71$age[age.order], gradients(model.ll)[age.order],
  col = 2, lty = 2)

legend("topleft",
  c("Local constant", "Local linear"),
  lty = c(1, 2),
  col = c(1, 2),
  bty = "n")

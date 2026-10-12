## Explore the current plot interface for a fitted regression object.
## Data: 1971 Canadian Census sample supplied by Aman Ullah; see
## Pagan and Ullah (1999), Nonparametric Econometrics.

library(np)
data(cps71, package = "np")

## Fit once; plot() constructs the requested uncertainty and gradient views.
model.ll <- npreg(logwage ~ age,
  regtype = "ll",
  data = cps71)

## Compare asymptotic and bootstrap uncertainty summaries.
plot(model.ll, errors = "asymptotic")
plot(model.ll, errors = "bootstrap")
plot(model.ll, errors = "bootstrap", band = "all")

## Request the corresponding derivative view directly from plot().
plot(model.ll, errors = "bootstrap", band = "all", gradients = TRUE)

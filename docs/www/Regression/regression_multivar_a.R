## Fit and plot a mixed-data multivariate kernel regression.
## Data: 1976 U.S. Current Population Survey sample supplied by Jeffrey M.
## Wooldridge; see Wooldridge (2000), Introductory Econometrics.

library(np)
data(wage1, package = "np")

## Combine one factor with two numeric predictors in a local-linear fit.
model <- npreg(lwage ~ female + educ + exper,
  regtype = "ll",
  data = wage1)

## Compare asymptotic and bootstrap partial-regression views.
plot(model, errors = "asymptotic")
plot(model, errors = "bootstrap")
plot(model, errors = "bootstrap", band = "all")

## Request derivative partial views from the same fitted object.
plot(model, errors = "bootstrap", band = "all", gradients = TRUE)

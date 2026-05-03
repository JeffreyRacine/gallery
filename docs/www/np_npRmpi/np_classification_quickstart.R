## Minimal np classification / conditional-mode example.
##
## This keeps the first run compact while still showing the basic
## nonparametric classification route.

library(np)
data(birthwt, package = "MASS")

## Class the discrete fields the way the estimator expects them.
birthwt$low <- factor(birthwt$low)
birthwt$smoke <- factor(birthwt$smoke)
birthwt$race <- factor(birthwt$race)

## Fit the conditional-mode classifier on a small practical formula.
fit <- npconmode(low ~ smoke + race + age + lwt, data = birthwt, nmulti = 1)

## Inspect the fitted object, then the implied confusion matrix.
summary(fit)
fit$confusion.matrix

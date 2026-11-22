## Estimate class probabilities p_y(x) and the conditional mode m(x).

library(np)
data(birthwt, package = "MASS")

## Class the discrete fields the way the estimator expects them.
birthwt$low <- factor(birthwt$low)
birthwt$smoke <- factor(birthwt$smoke)
birthwt$race <- factor(birthwt$race)

## Fit the conditional-mode classifier on a small practical formula.
fit <- npconmode(low ~ smoke + race + age + lwt, data = birthwt)

## Inspect the fitted object, then the implied confusion matrix.
summary(fit)
fit$confusion.matrix

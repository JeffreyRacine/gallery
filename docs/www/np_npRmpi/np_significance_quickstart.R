## Test whether an irrelevant factor contributes to g(x).

library(np)
options(np.messages = FALSE)

## Generate one relevant and one irrelevant regressor on purpose.
set.seed(42)
n <- 200
z <- factor(rbinom(n, 1, 0.5))
x1 <- rnorm(n)
x2 <- runif(n, -2, 2)
y <- x1 + x2 + rnorm(n)
dat <- data.frame(z, x1, x2, y)

## Fit the model before asking the significance question.
fit <- npreg(y ~ z + x1 + x2,
  regtype = "ll",
  bwmethod = "cv.aic",
  data = dat)

## Test the fitted regression using the default bootstrap settings.
test_out <- npsigtest(fit)

summary(fit)
summary(test_out)

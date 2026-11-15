## Test a linear conditional-mean model against a nonparametric alternative.

library(np)
options(np.messages = FALSE)

## Simulate nonlinear data, then fit an intentionally simple linear model.
set.seed(42)
n <- 120
x <- runif(n, -2, 2)
y <- x + x^2 + rnorm(n, sd = 0.25)

model_ols <- lm(y ~ x, x = TRUE, y = TRUE)
X <- data.frame(x = x)

## Compare the parametric model to the nonparametric alternative.
test_out <- npcmstest(model = model_ols,
  xdat = X,
  ydat = y,
  B = 99,
  nmulti = 1)

## Inspect both the linear fit and the specification test.
summary(model_ols)
summary(test_out)

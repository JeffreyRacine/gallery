## Minimal np model-specification test example.
##
## The idea is to fit a simple linear model to nonlinear data and then
## ask whether the parametric specification looks too restrictive.

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
  nmulti = 1)

## Inspect both the linear fit and the specification test.
summary(model_ols)
summary(test_out)

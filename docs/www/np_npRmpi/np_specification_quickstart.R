rm(list = ls())

## Minimal np model-specification test example.
##
## The idea is to fit a simple linear model to nonlinear data and then
## ask whether the parametric specification looks too restrictive.

library(np)
options(np.messages = FALSE)

set.seed(42)
n <- 120
x <- runif(n, -2, 2)
y <- x + x^2 + rnorm(n, sd = 0.25)

model_ols <- lm(y ~ x, x = TRUE, y = TRUE)
X <- data.frame(x = x)

test_out <- npcmstest(
  model = model_ols,
  xdat = X,
  ydat = y,
  nmulti = 1
)

summary(model_ols)
summary(test_out)

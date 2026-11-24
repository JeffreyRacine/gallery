## Constrain both first partial derivatives of a tensor-basis spline so that
## lower <= partial g(x1, x2) / partial xj <= upper at the training points.

library(crs)
library(quadprog)

set.seed(42)

n <- 1000

x.min <- -5
x.max <- 5

## Bounds for both first partial derivatives.
lower <- -0.1
upper <- 0.1

## Simulate the response and keep it first in the modeling data frame.

x1 <- runif(n, x.min, x.max)
x2 <- runif(n, x.min, x.max)

y <- sin(sqrt(x1^2 + x2^2)) / sqrt(x1^2 + x2^2) + rnorm(n, sd = .1)

data.train <- data.frame(y, x1, x2)

rm(y, x1, x2)

model.unres <- crs(y ~ x1 + x2,
                   deriv = 1,
                   data = data.train,
                   basis = "tensor")

model.gradient.unres <- model.unres$deriv.mat

summary(model.unres)

## Construct response-scaled first-derivative constraint operators.

Aymat.res.x1 <- crshat(model.unres, y = data.train$y, output = "constraint",
                       deriv = 1, deriv.index = 1)
Aymat.res.x2 <- crshat(model.unres, y = data.train$y, output = "constraint",
                       deriv = 1, deriv.index = 2)

## Stack lower and upper restrictions for both partial derivatives.
Amat <- cbind(Aymat.res.x1,
              -Aymat.res.x1,
              Aymat.res.x2,
              -Aymat.res.x2)

rm(Aymat.res.x1, Aymat.res.x2)

bvec <- c(rep(lower, n),
          -rep(upper, n),
          rep(lower, n),
          -rep(upper, n))


## Find the observation weights satisfying the restrictions.
QP.output <- solve.QP(Dmat = diag(n), dvec = rep(1, n), Amat = Amat, bvec = bvec)

rm(Amat, bvec)

p.hat <- QP.output$solution

## Reuse the fitted spline basis and knots with the reweighted responses.
data.trans <- data.frame(y = p.hat * data.train$y, data.train[, 2:ncol(data.train), drop = FALSE])

model.res <- crs(y ~ x1 + x2, cv = "none",
                 degree = model.unres$degree,
                 segments = model.unres$segments,
                 knots = model.unres$knots,
                 basis = model.unres$basis,
                 data = data.trans,
                 deriv = 1)

## Create perspective plots of the constrained and unconstrained surfaces.

par(mfrow = c(1, 2))

plot(model.unres, perspective = TRUE, view = "fixed",
     main = "Unconstrained Regression Spline",
     zlab = "Conditional Expectation")

plot(model.res, perspective = TRUE, view = "fixed",
     main = "Constrained Regression Spline",
     sub = "-0.1 <= g'(x1,x2) <= 0.1",
     zlab = "Conditional Expectation")

par(mfrow = c(1, 1))

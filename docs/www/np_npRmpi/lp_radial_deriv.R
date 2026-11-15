## Constrain both partial derivatives of g(x) using the weighting method
## of Du, Parmeter, and Racine (2013, Statistica Sinica).

library(np)
library(quadprog)
options(np.tree = "auto", np.messages = FALSE)
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.

ckertype <- "epanechnikov"
p <- 1

if (p < 1) stop("first derivatives require degree >= 1")

## Simulate a noisy radial conditional mean.
n <- 2500
x1 <- runif(n, -5, 5)
x2 <- runif(n, -5, 5)
y <- sin(sqrt(x1^2 + x2^2)) / sqrt(x1^2 + x2^2) + rnorm(n, sd = .1)

X <- data.frame(x1, x2)
formula.glp <- formula(y ~ x1 + x2)
lp.data <- data.frame(y = y, X)

## Bound each partial derivative; the limits may vary with x.
lower <- rep(-0.1, n)
upper <- rep(0.1, n)

## Select bandwidths for the specified local-polynomial degree.
lp.bw <- npregbw(formula.glp,
  data = lp.data,
  regtype = "lp",
  degree = rep.int(as.integer(p), NCOL(X)),
  degree.select = "manual",
  bernstein.basis = TRUE,
  ckertype = ckertype)

## Each call supplies A_j = t(H_j) * y for a derivative constraint.
A.deriv.1 <- npreghat(bws = lp.bw,
  txdat = X,
  y = y,
  output = "constraint",
  s = c(1L, 0L))
A.deriv.2 <- npreghat(bws = lp.bw,
  txdat = X,
  y = y,
  output = "constraint",
  s = c(0L, 1L))
p.u <- rep(1, n)

## Find weights nearest one subject to sum(p) = n and both derivative bounds.
p.hat <- solve.QP(Dmat = diag(n),
                  dvec = rep(1, n),
                  Amat = cbind(rep(1, n), A.deriv.1, -A.deriv.1, A.deriv.2, -A.deriv.2),
                  bvec = c(n, lower, -upper, lower, -upper),
                  meq = 1)$solution

if (isTRUE(all.equal(p.u, p.hat))) warning("constraints not binding")

## Evaluate the unrestricted and constrained conditional means on a grid.
n.eval <- 50

x1.seq <- seq(min(x1), max(x1), length.out = n.eval)
x2.seq <- seq(min(x2), max(x2), length.out = n.eval)

X.eval <- expand.grid(x1 = x1.seq, x2 = x2.seq)

H.eval <- npreghat(bws = lp.bw,
  txdat = X,
  exdat = X.eval,
  output = "matrix")

fit.unres <- drop(H.eval %*% y)
fit.res <- drop(H.eval %*% (y * p.hat))

fitted.unres <- matrix(fit.unres, n.eval, n.eval)
fitted.res <- matrix(fit.res, n.eval, n.eval)

zlim.res.unres <- c(min(fit.unres, fit.res), max(fit.unres, fit.res))

pdf(file = "lp_radial_deriv_unres.pdf")
persp(x1.seq, x2.seq, fitted.unres,
  col = "lightgrey", ticktype = "detailed", xlab = "X1", ylab = "X2",
  zlab = "Conditional expectation", zlim = zlim.res.unres,
  theta = 300, phi = 30)
dev.off()

pdf(file = "lp_radial_deriv_res.pdf")
persp(x1.seq, x2.seq, fitted.res,
  col = "lightgrey", ticktype = "detailed", xlab = "X1", ylab = "X2",
  zlab = "Conditional expectation", zlim = zlim.res.unres,
  theta = 300, phi = 30)
dev.off()

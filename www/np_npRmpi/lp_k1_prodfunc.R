## Constrain g(x) >= y, g^(1)(x) >= 0, and g^(2)(x) <= 0 using the
## production-function method of Du, Parmeter, and Racine (2013).

library(np)
library(quadprog)
options(np.tree = "auto", np.messages = FALSE)
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.

ckertype <- "epanechnikov"
p <- 2

## Simulate observations below a concave, increasing frontier.
n <- 2500
x <- sort(runif(n))
dgp <- sqrt(x)
y <- dgp - abs(rnorm(n, sd = .1))
y <- ifelse(y >= 0, y, 0)

X <- data.frame(x)

formula.glp <- formula(y ~ x)
lp.data <- data.frame(y = y, X)

## One entry per predictor specifies each derivative operator.
gradient.vec.1 <- c(1)
gradient.vec.2 <- c(2)

if (any(c(gradient.vec.1, gradient.vec.2) > p)) {
  stop("the derivative order exceeds the local-polynomial degree")
}

## Select bandwidths for the fixed degree, then build the hat operators.
lp.bw <- npregbw(formula.glp,
  data = lp.data,
  regtype = "lp",
  degree = rep.int(as.integer(p), NCOL(X)),
  degree.select = "manual",
  bernstein.basis = TRUE,
  ckertype = ckertype)

H.mean <- npreghat(bws = lp.bw,
  txdat = X,
  output = "matrix")

## Keep H for fitted values; output = "constraint" returns t(H_s) * y.
p.u <- rep(1, n)

A <- npreghat(bws = lp.bw,
  txdat = X,
  y = y,
  output = "constraint")
A.deriv.1 <- npreghat(bws = lp.bw,
  txdat = X,
  y = y,
  output = "constraint",
  s = as.integer(gradient.vec.1))
A.deriv.2 <- npreghat(bws = lp.bw,
  txdat = X,
  y = y,
  output = "constraint",
  s = as.integer(gradient.vec.2))

## Impose sum(p) = n, A^T p >= y, A_1^T p >= 0, and A_2^T p <= 0.
p.hat <- solve.QP(Dmat = diag(n),
                  dvec = rep(1, n),
                  Amat = cbind(rep(1, n), A, A.deriv.1, -A.deriv.2),
                  bvec = c(n, y, rep(0, n), rep(0, n)),
                  meq = 1)$solution

if (isTRUE(all.equal(p.u, p.hat))) warning("constraints not binding")

## Apply the unrestricted and reweighted hat operators.
fit.unres <- drop(H.mean %*% y)
fit.res <- drop(H.mean %*% (y * p.hat))

## Compare the frontier, both fits, and the translated responses y * p.hat.
pdf(file = "lp_k1_prodfunc.pdf")

ylim <- c(min(dgp, fit.unres, fit.res, y),
          max(dgp, fit.unres, fit.res, y))

plot(x, y, cex = .25, ylab = "g(x)", ylim = ylim, col = "grey")
points(x, y * p.hat, col = "orange", cex = 0.25)
lines(x, dgp, col = 1, lty = 1)
lines(x, fit.unres, col = 2, lty = 1, lwd = 2)
lines(x, fit.res, col = 3, lty = 1, lwd = 2)

legend("topleft",
       c("DGP", "Unconstrained", "Constrained"),
       lty = c(1, 1, 1),
       col = 1:3,
       bty = "n",
       cex = 0.75)

plot(x, y, cex = .25, ylab = "g(x)", ylim = ylim, col = "grey")
lines(x, dgp, col = 1, lty = 1)
lines(x, fit.unres, col = 2, lty = 1, lwd = 2)
lines(x, fit.res, col = 3, lty = 1, lwd = 2)

legend("topleft",
       c("DGP", "Unconstrained", "Constrained"),
       lty = c(1, 1, 1),
       col = 1:3,
       bty = "n",
       cex = 0.75)

dev.off()

## Constrain l(x) <= g^(s)(x) <= u(x) using the weighting method of
## Du, Parmeter, and Racine (2013, Statistica Sinica).

library(np)
library(quadprog)
options(np.tree = "auto", np.messages = FALSE)
## Current releases use "auto" to enable trees for Epanechnikov/uniform kernels.
## Use TRUE/FALSE only when assessing the impact for this problem.

build_manual_lp_bw <- function(formula, data, degree, ckertype) {
  npregbw(formula,
    data = data,
    regtype = "lp",
    degree = as.integer(degree),
    degree.select = "manual",
    bernstein.basis = TRUE,
    ckertype = ckertype)
}

build_nomad_lp_bw <- function(formula, data, degree.max, ckertype) {
  if (!requireNamespace("crs", quietly = TRUE)) {
    stop("Automatic LP degree search uses npregbw(..., nomad = \"auto\"), ",
      "which currently requires the 'crs' package.")
  }

  npregbw(formula,
    data = data,
    regtype = "lp",
    ckertype = ckertype,
    ## nomad = "auto" uses exhaustive search for p = 1 and NOMAD otherwise.
    nomad = "auto",
    degree.max = as.integer(degree.max))
}

ckertype <- "epanechnikov"

## Use a nonnegative degree, or set p < 0 for joint degree-bandwidth search.
p <- 1

## One entry per predictor specifies the derivative order being constrained.
gradient.vec <- c(0)

## Add n.eval grid points if the restrictions should also hold off-sample.
n.eval <- 0
n <- 2500

## The limits are constant here, but l(x) and u(x) may vary with x.
lower <- rep(-1, n + n.eval)
upper <- rep(1, n + n.eval)

## Simulate a noisy conditional mean.
x <- sort(runif(n))
dgp <- cos(2 * pi * x)
y <- dgp + sd(dgp) * rnorm(n, sd = 0.5)

X <- data.frame(x)

## Build the bandwidth object manually or by joint degree-bandwidth search.
formula.glp <- formula(y ~ x)
lp.data <- data.frame(y = y, X)

lp.bw <- if (p >= 0) {
  build_manual_lp_bw(formula = formula.glp,
    data = lp.data,
    degree = rep.int(as.integer(p), NCOL(X)),
    ckertype = ckertype)
} else {
  build_nomad_lp_bw(formula = formula.glp,
    data = lp.data,
    degree.max = 10L,
    ckertype = ckertype)
}

p <- as.integer(lp.bw$degree)

if (any(gradient.vec > p)) {
  stop("the derivative order exceeds the local-polynomial degree")
}

H.mean <- npreghat(bws = lp.bw,
  txdat = X,
  output = "matrix")

## Keep H for fitted values; output = "constraint" returns t(H_s) * y.
A <- npreghat(bws = lp.bw,
  txdat = X,
  y = y,
  output = "constraint",
  s = if (any(gradient.vec > 0)) as.integer(gradient.vec) else NULL)

p.u <- rep(1, n)

## Add off-sample constraints when an evaluation grid is requested.
if (n.eval > 0) {
  x.eval <- seq(min(x), max(x), length.out = n.eval)
  X.eval <- data.frame(x = x.eval)
  A.eval <- npreghat(bws = lp.bw,
    txdat = X,
    exdat = X.eval,
    y = y,
    output = "constraint",
    s = if (any(gradient.vec > 0)) as.integer(gradient.vec) else NULL)
}


## Find weights nearest one subject to sum(p) = n and l <= A^T p <= u.
if (n.eval == 0) {
  p.hat <- solve.QP(Dmat = diag(n),
                    dvec = p.u,
                    Amat = cbind(p.u, A, -A),
                    bvec = c(n, lower, -upper),
                    meq = 1)$solution
} else {
  p.hat <- solve.QP(Dmat = diag(n),
                    dvec = p.u,
                    Amat = cbind(p.u, A, A.eval, -A, -A.eval),
                    bvec = c(n, lower, -upper),
                    meq = 1)$solution
}

if (isTRUE(all.equal(p.u, p.hat))) warning("constraints not binding")

## Apply the unrestricted and reweighted hat operators.
fit.unres <- drop(H.mean %*% y)
fit.res <- drop(H.mean %*% (y * p.hat))

## Compare the DGP, both fits, and the translated responses y * p.hat.
pdf(file = "lp_k1.pdf")

ylim <- c(min(dgp, fit.unres, fit.res, y),
          max(dgp, fit.unres, fit.res, y))

subtext <- paste("n = ", n, ", local polynomial order = ", p, ", derivative order s = ", gradient.vec, sep = "")

plot(x, y, cex = .25, ylab = "g(x)", ylim = ylim, col = "grey", sub = subtext)
points(x, y * p.hat, col = "orange", cex = 0.25)
lines(x, dgp, col = 1, lty = 1)
lines(x, fit.unres, col = 2, lty = 1, lwd = 2)
lines(x, fit.res, col = 3, lty = 1, lwd = 2)
lines(x, lower[seq_len(n)], lty = 1, col = "lightgrey")
lines(x, upper[seq_len(n)], lty = 1, col = "lightgrey")

legend("bottomleft",
       c("DGP", "Unconstrained", "Constrained"),
       lty = c(1, 1, 1),
       col = 1:3,
       bty = "n",
       cex = 0.75)

plot(x, y, cex = .25, ylab = "g(x)", ylim = ylim, col = "grey", sub = subtext)
lines(x, dgp, col = 1, lty = 1)
lines(x, fit.unres, col = 2, lty = 1, lwd = 2)
lines(x, fit.res, col = 3, lty = 1, lwd = 2)
lines(x, lower[seq_len(n)], lty = 1, col = "lightgrey")
lines(x, upper[seq_len(n)], lty = 1, col = "lightgrey")

legend("bottomleft",
       c("DGP", "Unconstrained", "Constrained"),
       lty = rep(1, 3),
       col = 1:3,
       bty = "n",
       cex = 0.75)

dev.off()

## $Id: lp_k1_prodfunc.R,v 1.5 2013/12/04 13:01:19 jracine Exp jracine $

## We illustrate constrained kernel estimation using the local
## polynomial estimator where the constraints are \hat g(x) \ge y,
## \hat g^(1)(x) \ge 0, and \hat g^(2) \le 0, conditions satisfied by
## a production function (see Du, P. and C. Parmeter and J.S. Racine
## (2013), "Nonparametric Kernel Regression with Multiple Predictors
## and Multiple Shape Constraints," Statistica Sinica, Volume 23,
## Number 3, 1343-1372).

## Load required packages, set options.

library(np)
library(quadprog)
options(np.tree=TRUE,np.messages=FALSE)

## Set the kernel function.

ckertype <- "epanechnikov"

## Set the order of the local polynomial

p <- 2

## Simulate a sample of data from a production function.

n <- 2500
x <- sort(runif(n))
dgp <- sqrt(x)
y <- dgp - abs(rnorm(n,sd=.1))
y <- ifelse(y>=0,y,0)

## X (data frame of regressors) and y are passed below, so if you add
## extra regressors simply add them to X.

X <- data.frame(x)

formula.glp <- formula(y~x)
lp.data <- data.frame(y = y, X)

## Gradient vec contains one entry for each variable. With multiple
## predictors all entries except the index of the variable whose
## gradient is to be constrained must be zero. If a non-zero entry is
## 1, the first derivative is constrained, 2 the second and so on.

gradient.vec.1 <- c(1)
gradient.vec.2 <- c(2)

if(any(c(gradient.vec.1,gradient.vec.2) > p)) stop(" the order of the gradient being restricted exceeds the order of the local polynomial")

## Generate the cross-validated bandwidths optimal for the fixed order
## of the local polynomial, then build the required hat operators.

lp.bw <- npregbw(
  formula.glp,
  data = lp.data,
  regtype = "lp",
  degree = rep.int(as.integer(p), NCOL(X)),
  degree.select = "manual",
  bernstein.basis = TRUE,
  ckertype = ckertype
)

H.mean <- npreghat(
  bws = lp.bw,
  txdat = X,
  output = "matrix"
)
H.deriv.1 <- npreghat(
  bws = lp.bw,
  txdat = X,
  output = "matrix",
  s = as.integer(gradient.vec.1)
)
H.deriv.2 <- npreghat(
  bws = lp.bw,
  txdat = X,
  output = "matrix",
  s = as.integer(gradient.vec.2)
)

## Create the uniform weights p.u and matrices for which H %*% (y * p)
## delivers the constrained local polynomial estimator and its
## derivatives.

p.u <- rep(1,n)

A <- t(H.mean) * y
A.deriv.1 <- t(H.deriv.1) * y
A.deriv.2 <- t(H.deriv.2) * y

## Solve the quadratic program. The function solve.QP in the quadprog
## package solves the problem min (p-p.u)'(p-p.u) subject to the
## constraints Amat^T p >= bvec. Note that we construct Amat to
## contain the constraints a) the weights sum to n (rep(1,n)), b) A^T
## p >= lower, and c) -A^Tp >= -upper (here A^T = \hat g(x|p)). Note
## that the argument meq=1 indicates that there is one equality
## constraint which occurs in the first row of Amat.

## For the production function we have constraints
## 1) sum p = n [rep(1,n)=n, meq=1]
## 2) \hat g(x|p) \ge y [A\ge y]
## 3) \hat g^(1)(x|p) \ge 0 [A.deriv.1 \ge rep(0,n)]
## 4) \hat g^(2)(x|p) \le 0 [-A.deriv.2 \ge rep(0,n)]

p.hat <- solve.QP(Dmat=diag(n),
                  dvec=rep(1,n),
                  Amat=cbind(rep(1,n),A,A.deriv.1,-A.deriv.2),
                  bvec=c(n,y,rep(0,n),rep(0,n)),
                  meq=1)$solution

if(!is.na(as.logical(all.equal(p.u,p.hat)))) warning(" constraints not binding")

## Compute the unconstrained and constrained fits

fit.unres <- drop(H.mean %*% y)
fit.res <- drop(H.mean %*% (y * p.hat))

## Plot the DGP, unrestricted, and restricted fits along with the
## constraints and data. We plot the y*p.hat (translated data) in
## orange

pdf(file="lp_k1_prodfunc.pdf")

ylim <- c(min(dgp,fit.unres,fit.res,y),
          max(dgp,fit.unres,fit.res,y))

plot(x,y,cex=.25,ylab="g(x)",ylim=ylim,col="grey")
points(x,y*p.hat,col="orange",cex=0.25)
lines(x,dgp,col=1,lty=1)
lines(x,fit.unres,col=2,lty=1,lwd=2)
lines(x,fit.res,col=3,lty=1,lwd=2)

legend("topleft",
       c("DGP","Unconstrained","Constrained"),
       lty=c(1,1,1),
       col=1:3,
       bty="n",
       cex=0.75)

plot(x,y,cex=.25,ylab="g(x)",ylim=ylim,col="grey")
lines(x,dgp,col=1,lty=1)
lines(x,fit.unres,col=2,lty=1,lwd=2)
lines(x,fit.res,col=3,lty=1,lwd=2)

legend("topleft",
       c("DGP","Unconstrained","Constrained"),
       lty=c(1,1,1),
       col=1:3,
       bty="n",
       cex=0.75)

dev.off()

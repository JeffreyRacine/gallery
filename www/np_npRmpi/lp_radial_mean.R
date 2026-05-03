## $Id: lp_radial_mean.R,v 1.4 2013/12/03 23:06:42 jracine Exp jracine $

## We illustrate constrained kernel estimation using the local
## polynomial estimator where the constraints are l(x) <= \hat g(x) <=
## u(x) (see Du, P. and C. Parmeter and J.S. Racine (2013),
## "Nonparametric Kernel Regression with Multiple Predictors and
## Multiple Shape Constraints," Statistica Sinica, Volume 23, Number
## 3, 1343-1372).

## Load required packages, set options.

library(np)
library(quadprog)
options(np.tree=TRUE,np.messages=FALSE)

## Set the kernel function.

ckertype <- "epanechnikov"

## Set the order of the local polynomial

p <- 1

## Simulate a sample of data. We can control signal/noise ratio by
## multiplying epsilon by sd(dgp), so rnorm(n,sd=...) can be set to
## sd=(.25,.5,1,2) which would yield an R-squared for the Oracle model
## of (.95,.8,.5,and .2).

n <- 2500
x1 <- runif(n,-5,5)
x2 <- runif(n,-5,5)
y <- sin(sqrt(x1^2+x2^2))/sqrt(x1^2+x2^2) + rnorm(n,sd=.1)

## X (data frame of regressors) and y are passed below, so if you add
## extra regressors simply add them to X here and be done.

X <- data.frame(x1,x2)
formula.glp <- formula(y~x1+x2)
lp.data <- data.frame(y = y, X)

## Set up bounds for the quadratic program. We are going to require
## the lower and upper constraints l(x) and u(x) for g(x). Here they
## are constant, but in general can depend on x.

lower <- rep(-0.5,n)
upper <- rep(0.5,n)

## Generate the cross-validated bandwidths optimal for the order of
## the local polynomial at hand.

lp.bw <- npregbw(formula.glp,
  data = lp.data,
  regtype = "lp",
  degree = rep.int(as.integer(p), NCOL(X)),
  degree.select = "manual",
  bernstein.basis = TRUE,
  ckertype = ckertype)

## Build the mean hat operator and the constraint matrix for H %*% (y * p).

H.train <- npreghat(bws = lp.bw,
  txdat = X,
  output = "matrix")

A <- t(H.train) * y
p.u <- rep(1,n)

## Solve the quadratic program. The function solve.QP in the quadprog
## package solves the problem min (p-p.u)'(p-p.u) subject to the
## constraints Amat^T p >= bvec. Note that we construct Amat to
## contain the constraints a) the weights sum to n (rep(1,n)), b) A^T
## p >= lower, and c) -A^Tp >= -upper (here A^T = \hat g(x|p)). Note
## that the argument meq=1 indicates that there is one equality
## constraint which occurs in the first row of Amat.

p.hat <- solve.QP(Dmat=diag(n),
                  dvec=p.u,
                  Amat=cbind(p.u,A,-A),
                  bvec=c(n,lower,-upper),
                  meq=1)$solution

if(!is.na(as.logical(all.equal(p.u,p.hat)))) warning(" constraints not binding")

## Create plots - require evaluation data

n.eval <- 50

x1.seq <- seq(min(x1),max(x1),length=n.eval)
x2.seq <- seq(min(x2),max(x2),length=n.eval)

X.eval <- expand.grid(x1=x2.seq,x2=x2.seq)

H.eval <- npreghat(bws = lp.bw,
  txdat = X,
  exdat = X.eval,
  output = "matrix")

fit.unres <- drop(H.eval %*% y)
fit.res <- drop(H.eval %*% (y * p.hat))

## Plot the unrestricted and restricted fits

fitted.unres <- matrix(fit.unres, n.eval, n.eval)
fitted.res <- matrix(fit.res, n.eval, n.eval)

## Next, create a 3D perspective plot of the PDF f

zlim.unres <- c(min(fit.unres),max(fit.unres))
zlim.res <- c(min(fit.res),max(fit.res))
zlim.res.unres <- c(min(fit.unres,fit.res),max(fit.unres,fit.res))

pdf(file="lp_radial_mean_unres.pdf")
persp(x1.seq, x2.seq, fitted.unres, col="lightgrey", ticktype="detailed",
           ylab="X2", xlab="X1", zlim=zlim.res.unres, zlab="Conditional Expectation", theta=300, phi=30)
dev.off()

pdf(file="lp_radial_mean_res.pdf")
persp(x1.seq, x2.seq, fitted.res, col="lightgrey", ticktype="detailed",
           ylab="X2", xlab="X1", zlim=zlim.res.unres, zlab="Conditional Expectation", theta=300, phi=30)
dev.off()

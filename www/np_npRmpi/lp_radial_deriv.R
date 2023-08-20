## $Id: lp_radial_deriv.R,v 1.5 2013/12/04 13:02:44 jracine Exp jracine $

## We illustrate constrained kernel estimation using the local
## polynomial estimator where the constraints are l(x) <= \hat g(x) <=
## u(x) (see Du, P. and C. Parmeter and J.S. Racine (2013),
## "Nonparametric Kernel Regression with Multiple Predictors and
## Multiple Shape Constraints," Statistica Sinica, Volume 23, Number
## 3, 1343-1372).

rm(list=ls())

## Load required packages, set options.

library(np)
library(quadprog)
library(crs)
options(np.tree=TRUE,np.messages=FALSE,crs.messages=FALSE)

## Set the kernel function.

ckertype <- "epanechnikov"

## Set the order of the local polynomial

p <- 1

if(p < 1) stop(" first derivatives required, polynomial order too low")

## Simulate a sample of data. We can control signal/noise ratio by
## multiplying epsilon by sd(dgp), so rnorm(n,sd=...) can be set to
## sd=(.25,.5,1,2) which would yield an R-squared for the Oracle model
## of (.95,.8,.5,and .2).

n <- 2500
x1 <- runif(n,-5,5)
x2 <- runif(n,-5,5)
y <- sin(sqrt(x1^2+x2^2))/sqrt(x1^2+x2^2) + rnorm(n,sd=.1)

## X (data frame of regressors) and y are passed below, so if you add
## extra regressors simply add them to X here and be done. W.glp is
## the generalized polynomial (i.e. Taylor series with potentially
## different degrees for each predictor), and formula.glp is the
## formula fed to npglpreg() to obtain cross-validated local
## polynomial bandwidths.

X <- data.frame(x1,x2)
formula.glp <- formula(y~x1+x2)
W <- crs:::W.glp(xdat=X,
                 degree=rep(p,NCOL(X)),
                 Bernstein=TRUE)

W.deriv.1 <- crs:::W.glp(xdat=X,
                         degree=rep(p,NCOL(X)),
                         gradient.vec = c(1,0),
                         Bernstein=TRUE)
W.deriv.2 <- crs:::W.glp(xdat=X,
                         degree=rep(p,NCOL(X)),
                         gradient.vec = c(0,1),
                         Bernstein=TRUE)

## Can modify W.glp in the future to return zeros here (NOMAD)

W.deriv.1[,1] <- 0
W.deriv.2[,1] <- 0

## Set up bounds for the quadratic program. We are going to require
## the lower and upper constraints l(x) and u(x) for g(x). Here they
## are constant, but in general can depend on x.

lower <- rep(-0.1,n)
upper <- rep(0.1,n)

## Generate the cross-validated bandwidths optimal for the order of
## the local polynomial at hand.

bws <- crs:::npglpreg(formula=formula.glp,
                      cv="bandwidth",
                      degree=rep(p,NCOL(X)),
                      ckertype=ckertype,
                      nmulti=min(NCOL(X),5))$bws

## Generate the matrix of kernel weights using data-driven bandwidths
## that are optimal for the unconstrained model.

K <- npksum(txdat=X,
            bws=bws,
            ckertype=ckertype,
            return.kernel.weights=TRUE)$kw

## Create the uniform weights p.u and matrix A for which t(A)%*%p is
## the constrained local polynomial estimator \hat g(x|p).

A <- sapply(1:n,function(i){W[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
A.deriv.1 <- sapply(1:n,function(i){W.deriv.1[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
A.deriv.2 <- sapply(1:n,function(i){W.deriv.2[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
p.u <- rep(1,n)

## Solve the quadratic program. The function solve.QP in the quadprog
## package solves the problem min (p-p.u)'(p-p.u) subject to the
## constraints Amat^T p >= bvec. Note that we construct Amat to
## contain the constraints a) the weights sum to n (rep(1,n)), b) A^T
## p >= lower, and c) -A^Tp >= -upper (here A^T = \hat g(x|p)). Note
## that the argument meq=1 indicates that there is one equality
## constraint which occurs in the first row of Amat.

p.hat <- solve.QP(Dmat=diag(n),
                  dvec=rep(1,n),
                  Amat=cbind(rep(1,n),A.deriv.1,-A.deriv.1,A.deriv.2,-A.deriv.2),
                  bvec=c(n,lower,-upper,lower,-upper),
                  meq=1)$solution

if(!is.na(as.logical(all.equal(p.u,p.hat)))) warning(" constraints not binding")

## Create plots - require evaluation data

n.eval <- 50

x1.seq <- seq(min(x1),max(x1),length=n.eval)
x2.seq <- seq(min(x2),max(x2),length=n.eval)

X.eval <- expand.grid(x1=x2.seq,x2=x2.seq)

W.eval <- crs:::W.glp(xdat=X,
                      exdat=X.eval,
                      degree=rep(p,NCOL(X)),
                      Bernstein=TRUE)

K <- npksum(txdat=X,
            exdat=X.eval,
            bws=bws,
            ckertype=ckertype,
            return.kernel.weights=TRUE)$kw

A <- sapply(1:nrow(X.eval),function(i){W.eval[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})

fit.unres <- t(A)%*%p.u
fit.res <- t(A)%*%p.hat

## Plot the unrestricted and restricted fits

fitted.unres <- matrix(fit.unres, n.eval, n.eval)
fitted.res <- matrix(fit.res, n.eval, n.eval)

## Next, create a 3D perspective plot of the PDF f

zlim.unres <- c(min(fit.unres),max(fit.unres))
zlim.res <- c(min(fit.res),max(fit.res))
zlim.res.unres <- c(min(fit.unres,fit.res),max(fit.unres,fit.res))

pdf(file="lp_radial_deriv_unres.pdf")
persp(x1.seq, x2.seq, fitted.unres, col="lightgrey", ticktype="detailed", 
           ylab="X2", xlab="X1", zlim=zlim.res.unres, zlab="Conditional Expectation", theta=300, phi=30)
dev.off()

pdf(file="lp_radial_deriv_res.pdf")
persp(x1.seq, x2.seq, fitted.res, col="lightgrey", ticktype="detailed", 
           ylab="X2", xlab="X1", zlim=zlim.res.unres, zlab="Conditional Expectation", theta=300, phi=30)

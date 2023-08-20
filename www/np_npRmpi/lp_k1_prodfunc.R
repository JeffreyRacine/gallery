## $Id: lp_k1_prodfunc.R,v 1.5 2013/12/04 13:01:19 jracine Exp jracine $

## We illustrate constrained kernel estimation using the local
## polynomial estimator where the constraints are \hat g(x) \ge y,
## \hat g^(1)(x) \ge 0, and \hat g^(2) \le 0, conditions satisfied by
## a production function (see Du, P. and C. Parmeter and J.S. Racine
## (2013), "Nonparametric Kernel Regression with Multiple Predictors
## and Multiple Shape Constraints," Statistica Sinica, Volume 23,
## Number 3, 1343-1372).

rm(list=ls())

## Load required packages, set options.

library(np)
library(quadprog)
library(crs)
options(np.tree=TRUE,np.messages=FALSE,crs.messages=FALSE)

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
## extra regressors simply add them to X. W.glp is the generalized
## polynomial (i.e. Taylor series with potentially different degrees
## for each predictor), and formula.glp is the formula fed to
## npglpreg() to obtain cross-validated local polynomial bandwidths.

X <- data.frame(x)

formula.glp <- formula(y~x)

## Gradient vec contains one entry for each variable. With multiple
## predictors all entries except the index of the variable whose
## gradient is to be constrained must be zero. If a non-zero entry is
## 1, the first derivative is constrained, 2 the second and so on.

gradient.vec.1 <- c(1)
gradient.vec.2 <- c(2)

if(any(c(gradient.vec.1,gradient.vec.2) > p)) stop(" the order of the gradient being restricted exceeds the order of the local polynomial")

## W is the matrix for the local polynomial estimator, W.deriv.1 and
## W.deriv.2 the matrices for the derivatives.

W <- crs:::W.glp(xdat=X,
                 degree=rep(p,NCOL(X)),
                 Bernstein=TRUE)

W.deriv.1 <- crs:::W.glp(xdat=X,
                         degree=rep(p,NCOL(X)),
                         gradient.vec = gradient.vec.1,
                         Bernstein=TRUE)
W.deriv.2 <- crs:::W.glp(xdat=X,
                         degree=rep(p,NCOL(X)),
                         gradient.vec = gradient.vec.2,
                         Bernstein=TRUE)

W.deriv.1[,1] <- 0
W.deriv.2[,1] <- 0

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
## the constrained local polynomial estimator \hat g(x|p), A.deriv.1
## for which t(A.deriv.1)%*%p is the first derivative, and A.deriv.2
## for which t(A.deriv.2)%*%p is the second derivative.

p.u <- rep(1,n)

A <- sapply(1:n,function(i){W[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
A.deriv.1 <- sapply(1:n,function(i){W.deriv.1[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
A.deriv.2 <- sapply(1:n,function(i){W.deriv.2[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})

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

fit.unres <- t(A)%*%p.u
fit.res <- t(A)%*%p.hat

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

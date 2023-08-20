## $Id: lp_k1.R,v 1.3 2013/12/04 13:00:17 jracine Exp jracine $

## We illustrate constrained kernel estimation using the local
## polynomial estimator where the constraints are l(x) <= \hat
## g^(s)(x) <= u(x) (see Du, P. and C. Parmeter and J.S. Racine
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

## Set the order of the local polynomial. Setting p < 0 will determine
## the appropriate order via cross-validation a la Hall & Racine
## (2013). Note - for large n cross-validation for p and h can be
## slow.

p <- 1

## By default constraints are on the function (g^(s=0)(x|p)). Setting
## this to 1 imposes constraints on the first derivative, 2 the second
## and so forth. Here we have one predictor, but for > 1 predictor set
## e.g. c(0,1) to place a restriction on the first derivative of the
## second predictor. Note that the order of the polynomial p above
## must be >= the order of the derivative.

gradient.vec <- c(0)

## If n.eval > 0 then the constraints are set to hold on a grid of
## equally spaced points of length n.eval in addition to holding at
## the sample observations. n is the number of sample
## observations. n.eval can be quite large, it is n that binds as the
## weight vector being determined is of length n.

n.eval <- 0
n <- 2500

## Set up bounds for the quadratic program. We are going to require
## the lower and upper constraints l(x) and u(x) for g(x). Here they
## are constant, but in general can depend on x.

lower <- rep(-1,n+n.eval)
upper <- rep(1,n+n.eval)

## Simulate a sample of data. We can control signal/noise ratio by
## multiplying epsilon by sd(dgp), so rnorm(n,sd=...) can be set to
## sd=(.25,.5,1,2) which would yield an R-squared for the Oracle model
## of (.95,.8,.5,and .2).

x <- sort(runif(n))
dgp <- cos(2*pi*x)
y <- dgp + sd(dgp)*rnorm(n,sd=0.5)

## X (data frame of regressors) and y are passed below, so if you add
## extra regressors simply add them to X (and x.eval if n.eval > 0)
## here and be done.

X <- data.frame(x)

## Generate the cross-validated bandwidths optimal for the order of
## the local polynomial at hand.

formula.glp <- formula(y~x)

model.glp <- crs:::npglpreg(formula=formula.glp,
                            cv=ifelse(p>=0,"bandwidth","degree-bandwidth"),
                            degree=ifelse(p>=0,rep(p,NCOL(X)),rep(0,NCOL(X))),
                            ckertype=ckertype,
                            nmulti=min(NCOL(X),5))

bws <- model.glp$bws
p <- model.glp$degree

if(any(gradient.vec > p)) stop(" the order of the gradient being restricted exceeds the order of the local polynomial")

## The function W.glp is the generalized polynomial (i.e. Taylor
## series with potentially different degrees for each predictor, using
## the Bernstein polynomial), and formula.glp is the formula fed to
## npglpreg() to obtain cross-validated local polynomial bandwidths.

W <- crs:::W.glp(xdat=X,
                 degree=rep(p,NCOL(X)),
                 Bernstein=TRUE)

if(any(gradient.vec>0)) {
  W.gradient <- crs:::W.glp(xdat=X,
                            degree=rep(p,NCOL(X)),
                            gradient.vec = gradient.vec,
                            Bernstein=TRUE)
  W.gradient[,1] <- 0
} else {
  W.gradient <- W ## can we avoid copy?
}

if(n.eval>0) {
  x.eval <- seq(min(x),max(x),length=n.eval)
  X.eval <- data.frame(x=x.eval)
  if(any(gradient.vec>0)) {
    W.eval <- crs:::W.glp(xdat=X,
                          exdat=X.eval,
                          degree=rep(p,NCOL(X)),
                          gradient.vec = gradient.vec,
                          Bernstein=TRUE)
    W.eval[,1] <- 0    
  } else {
    W.eval <- crs:::W.glp(xdat=X,
                          exdat=X.eval,
                          degree=rep(p,NCOL(X)),
                          Bernstein=TRUE)
  }
}

## Generate the matrix of kernel weights using data-driven bandwidths
## that are optimal for the unconstrained model.

K <- npksum(txdat=X,
            bws=bws,
            ckertype=ckertype,
            return.kernel.weights=TRUE)$kw

A <- sapply(1:n,function(i){W.gradient[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})

## Create the uniform weights p.u and matrix A for which t(A)%*%p is
## the constrained local polynomial estimator \hat g(x|p).

p.u <- rep(1,n)

## If n.eval > 0 the compute the evaluation kernel weights and
## associated matrix for the fit on the evaluation data.

if(n.eval>0) {
  K.eval <- npksum(txdat=X,
                   exdat=X.eval,
                   bws=bws,
                   ckertype=ckertype,
                   return.kernel.weights=TRUE)$kw
  A.eval <- sapply(1:n.eval,function(i){W.eval[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K.eval[,i]*W)))%*%t(W)*y*K.eval[,i]})
}


## Solve the quadratic program. The function solve.QP in the quadprog
## package solves the problem min (p-p.u)'(p-p.u) subject to the
## constraints Amat^T p >= bvec. Note that we construct Amat to
## contain the constraints a) the weights sum to n (rep(1,n)), b) A^T
## p >= lower, and c) -A^Tp >= -upper (here A^T = \hat g(x|p)). Note
## that the argument meq=1 indicates that there is one equality
## constraint which occurs in the first row of Amat.

if(n.eval==0) {
  p.hat <- solve.QP(Dmat=diag(n),
                    dvec=p.u,
                    Amat=cbind(p.u,A,-A),
                    bvec=c(n,lower,-upper),
                    meq=1)$solution
} else {
  p.hat <- solve.QP(Dmat=diag(n),
                    dvec=p.u,
                    Amat=cbind(p.u,A,A.eval,-A,-A.eval),
                    bvec=c(n,lower,-upper),
                    meq=1)$solution
}

if(!is.na(as.logical(all.equal(p.u,p.hat)))) warning(" constraints not binding")

## Compute the unconstrained and constrained estimators.

if(any(gradient.vec>0)) {
  A <- sapply(1:n,function(i){W[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
}

fit.unres <- t(A)%*%p.u
fit.res <- t(A)%*%p.hat

## Plot the DGP, unrestricted, and restricted fits along with the
## constraints and data. We plot the y*p.hat (translated data) in
## orange

pdf(file="lp_k1.pdf")

ylim <- c(min(dgp,fit.unres,fit.res,y),
          max(dgp,fit.unres,fit.res,y))

subtext <- paste("n = ",n,", local polynomial order = ",p,", derivative order s = ",gradient.vec,sep="")

plot(x,y,cex=.25,ylab="g(x)",ylim=ylim,col="grey",sub=subtext)
points(x,y*p.hat,col="orange",cex=0.25)
lines(x,dgp,col=1,lty=1)
lines(x,fit.unres,col=2,lty=1,lwd=2)
lines(x,fit.res,col=3,lty=1,lwd=2)
lines(x,lower[1:n],lty=1,col="lightgrey")
lines(x,upper[1:n],lty=1,col="lightgrey")

legend("bottomleft",
       c("DGP","Unconstrained","Constrained"),
       lty=c(1,1,1),
       col=1:3,
       bty="n",
       cex=0.75)

plot(x,y,cex=.25,ylab="g(x)",ylim=ylim,col="grey",sub=subtext)
lines(x,dgp,col=1,lty=1)
lines(x,fit.unres,col=2,lty=1,lwd=2)
lines(x,fit.res,col=3,lty=1,lwd=2)
lines(x,lower[1:n],lty=1,col="lightgrey")
lines(x,upper[1:n],lty=1,col="lightgrey")

legend("bottomleft",
       c("DGP","Unconstrained","Constrained"),
       lty=rep(1,3),
       col=1:3,
       bty="n",
       cex=0.75)

dev.off()

## $Id: lp_k1.R,v 1.3 2013/12/04 13:00:17 jracine Exp jracine $

## We illustrate constrained kernel estimation using the local
## polynomial estimator where the constraints are l(x) <= \hat
## g^(s)(x) <= u(x) (see Du, P. and C. Parmeter and J.S. Racine
## (2013), "Nonparametric Kernel Regression with Multiple Predictors
## and Multiple Shape Constraints," Statistica Sinica, Volume 23,
## Number 3, 1343-1372).

## Load required packages, set options.

library(np)
library(quadprog)
options(np.tree=TRUE,np.messages=FALSE)

build_manual_lp_bw <- function(formula, data, degree, ckertype) {
  npregbw(
    formula,
    data = data,
    regtype = "lp",
    degree = as.integer(degree),
    degree.select = "manual",
    bernstein.basis = TRUE,
    ckertype = ckertype
  )
}

build_nomad_lp_bw <- function(formula, data, degree.max, ckertype, nmulti) {
  if (!requireNamespace("crs", quietly = TRUE)) {
    stop(
      "Automatic LP degree search uses npregbw(..., nomad = TRUE), ",
      "which currently requires the 'crs' package."
    )
  }

  npregbw(
    formula,
    data = data,
    regtype = "lp",
    ckertype = ckertype,
    nomad = TRUE,
    degree.max = as.integer(degree.max),
    nmulti = as.integer(nmulti)
  )
}

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

## Generate the local-polynomial bandwidth object using the current
## npregbw()/npreghat() route. Setting p < 0 triggers automatic
## degree-and-bandwidth search via nomad = TRUE.

formula.glp <- formula(y~x)
lp.data <- data.frame(y = y, X)

lp.bw <- if (p >= 0) {
  build_manual_lp_bw(
    formula = formula.glp,
    data = lp.data,
    degree = rep.int(as.integer(p), NCOL(X)),
    ckertype = ckertype
  )
} else {
  build_nomad_lp_bw(
    formula = formula.glp,
    data = lp.data,
    degree.max = 10L,
    ckertype = ckertype,
    nmulti = min(NCOL(X), 5L)
  )
}

bws <- lp.bw$bw
p <- as.integer(lp.bw$degree)

if(any(gradient.vec > p)) stop(" the order of the gradient being restricted exceeds the order of the local polynomial")

H.mean <- npreghat(
  bws = lp.bw,
  txdat = X,
  output = "matrix"
)
H.object <- if(any(gradient.vec > 0)) {
  npreghat(
    bws = lp.bw,
    txdat = X,
    output = "matrix",
    s = as.integer(gradient.vec)
  )
} else {
  H.mean
}

A <- t(H.object) * y

## Create the uniform weights p.u and matrix A for which t(A)%*%p is
## the constrained local polynomial estimator \hat g(x|p).

p.u <- rep(1,n)

## If n.eval > 0 the compute the evaluation kernel weights and
## associated matrix for the fit on the evaluation data.

if(n.eval>0) {
  x.eval <- seq(min(x),max(x),length=n.eval)
  X.eval <- data.frame(x=x.eval)
  H.eval <- npreghat(
    bws = lp.bw,
    txdat = X,
    exdat = X.eval,
    output = "matrix",
    s = if(any(gradient.vec > 0)) as.integer(gradient.vec) else NULL
  )
  A.eval <- t(H.eval) * y
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

fit.unres <- drop(H.mean %*% y)
fit.res <- drop(H.mean %*% (y * p.hat))

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

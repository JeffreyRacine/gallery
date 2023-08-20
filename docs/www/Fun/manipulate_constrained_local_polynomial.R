## $Id: manipulate_constrained_local_polynomial.R,v 1.28 2014/04/21 08:35:32 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the bandwidth, frequency of
## the underlying DGP, number of observations, and lower and upper
## bounds for the constrained estimator outlined in Du, Parmeter and
## Racine (2013) "Nonparametric Kernel Regression with Multiple
## Predictors and Multiple Shape Constraints" (Statistica Sinica).

rm(list=ls())
require(manipulate)
require(np)
require(crs)
options(np.tree=TRUE)
require(quadprog)

## Call the manipulate function on a plot object
manipulate.plot <- function(n,dgp.frequency,p,gradient,bw,ckertype,lower,upper,weighted,cv) {

  if(gradient > p) stop(" order of polynomial < gradient specified")

  if(lower > upper) {
    lower <- upper - 0.01
  }

  if(identical(lower,upper)) {
    lower <- upper -0.01
  }

  set.seed(42)

  x <- sort(runif(n))
  dgp <- function(x) {dgp<- sin(dgp.frequency*pi*x);dgp/sd(dgp)}
  y <- dgp(x) + rnorm(n,sd=.5)

  if(cv) {
    model <- npglpreg(y~x,ckertype=ckertype,nmulti=2)
    bw <- model$bws
    p <- model$degree
  }

  plot(x,y,
       cex=0.2,
       col="black",
       ylab="Y",
       xlab="X",
       main="Constrained Local Polynomial Regression",
         sub=paste("Bandwidth = ",format(bw,digits=3,format="f"),
         ", polynomial order = ",p,
         ", n = ",n,
         ", upper = ",formatC(upper,format="f",digits=1),
         ", lower = ",formatC(lower,format="f",digits=1),
         sep=""))

  lines(x,dgp(x),lty=1,col=1)

  if(gradient==0) {
    abline(h=lower,lty=2,col=1)
    abline(h=upper,lty=2,col=1)
  }

  ## Estimate the unrestricted model

  W.gradient <- W <- crs:::W.glp(xdat=x,
                                 degree=p)

  if(any(gradient>0)) {
    W.gradient <- crs:::W.glp(xdat=x,
                              degree=p,
                              gradient = gradient)
  }

  K <- npksum(txdat=x,
              bws=bw,
              ckertype=ckertype,
              return.kernel.weights=TRUE)$kw
  
  p.u <- rep(1,n)

  A.mean <- A <- sapply(1:n,function(i){W.gradient[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})

  ## Compute the unrestricted model/object being constrained

  object.unres <- fitted.unres <- t(A)%*%p.u

  if(any(gradient>0)) {
    A.mean <- sapply(1:n,function(i){W[i,,drop=FALSE]%*%chol2inv(chol(t(W)%*%(K[,i]*W)))%*%t(W)*y*K[,i]})
    fitted.unres <- t(A.mean)%*%p.u  
  }

  ## Solve the quadratic programming problem. We branch to avoid
  ## imposing nonbinding constraints (solve.QP will handle these cases
  ## but it imposes unnecessary (slack) variables).

  if(all(object.unres >= lower & object.unres <= upper)) {
    p.hat <- p.u
  } else if(all(object.unres >= lower)) {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(-A),
                          bvec=c(-rep(upper,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(all(object.unres <= upper)) {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A),
                          bvec=c(rep(lower,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A,-A),
                          bvec=c(rep(lower,n),-rep(upper,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  }

  ## Compute the restricted model

  fitted.res <- t(A.mean)%*%p.hat

  ## Plot the unrestricted and restricted models and restricted y
  
  lines(x,fitted.unres,lty=2,col=2,lwd=2)
  lines(x,fitted.res,col=4,lty=4,lwd=3)

  if(weighted) points(x,y*p.hat,col="orange",cex=0.35)

  legend("topleft",
         c(paste("DGP: sin(",dgp.frequency,"*pi*x)",sep=""),"Unconstrained Estimate","Constrained Estimate","Weighted Y","Actual Y"),
         col=c(1,2,4,"orange","black"),
         lwd=c(1,2,3,NA,NA),
         lty=c(1,2,4,NA,NA),
         pch=c(NA,NA,NA,1,1),
         cex=0.75,
         bty="n")

}

manipulate(manipulate.plot(n,dgp.frequency,p,gradient,bw,ckertype,lower,upper,weighted,cv),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           dgp.frequency=slider(1,4,2,label="DGP frequency (a*pi*x)",step=1,ticks=TRUE),
           p=slider(0,5,1,label="Local Polynomial Order",step=1,ticks=TRUE),
           gradient=picker(0,1,2,label="s (order of derivative)"),
           ckertype=picker("epanechnikov","gaussian","uniform",label="Kernel function"),
           bw=slider(0.01,0.1,0.04,step=0.01,label="Bandwidth"),
           lower=slider(-10,10,-1.5,step=0.5,label="Lower bound"),
           upper=slider(-10,10,1.5,step=0.5,label="Upper bound"),
           weighted=checkbox(FALSE, "Show weighted Y"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

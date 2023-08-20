## $Id: manipulate_constrained_spline.R,v 1.18 2014/01/12 12:15:39 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the spline degree, number of
## segments frequency of the underlying DGP, number of observations,
## and lower and upper bounds for the constrained estimator outlined
## in Du, Parmeter and Racine (2013) "Nonparametric Kernel Regression
## with Multiple Predictors and Multiple Shape Constraints"
## (Statistica Sinica)

rm(list=ls())
require(manipulate)
require(crs)
require(quadprog)

## Call the manipulate function on a plot object

manipulate.plot <- function(n,spline.degree,spline.segments,dgp.frequency,lower,upper,weighted,cv) {

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

  ## For below y must be in the first column.

  data.train <- data.frame(y,x)

  rm(x,y)

  ## Estimate the unrestricted model.

  if(cv) {

    model.unres <- crs(y~x,
                       degree=spline.degree,
                       segments=spline.segments,
                       nmulti=2,
                       basis="tensor",
                       data=data.train)

    spline.degree <- model.unres$degree
    spline.segments <- model.unres$segments

  } else {

    model.unres <- crs(y~x,
                       cv="none",
                       degree=spline.degree,
                       segments=spline.segments,
                       basis="tensor",
                       data=data.train)
  }

  with(data.train,plot(x,y,
                       cex=0.25,
                       col="lightgrey",
                       ylab="Y",
                       xlab="X",
                       main="Constrained B-spline Regression",
                       sub=paste("Spline degree = ",spline.degree,", spline segments = ",spline.segments,", n = ",n,", upper = ",formatC(upper,format="f",digits=1),", lower = ",formatC(lower,format="f",digits=1),sep="")))

  with(data.train,lines(x,dgp(x),lty=1,col=1))

  abline(h=lower,lty=2,col=1)
  abline(h=upper,lty=2,col=1)  

  ## Plot the unrestricted model.
  
  with(data.train,lines(x,fitted(model.unres),lty=2,col=2,lwd=2))

  ## Get the model weights. Note each column must be multiplied by y.
  
  B <- model.matrix(model.unres$model.lm)
  Aymat <- t(B%*%chol2inv(chol(t(B)%*%B))%*%t(B))*data.train$y
  
  ## Solve the quadratic programming problem,

  QP.output <- solve.QP(Dmat=diag(1,n,n),
                        dvec=rep(1,n),
                        Amat=cbind(Aymat,-Aymat),
                        bvec=c(rep(lower,n),-rep(upper,n)))

  ## Get the solution.

  p.hat <- QP.output$solution

  ## Estimate the restricted model.

  data.trans <- data.frame(y=p.hat*data.train$y,data.train[,2:ncol(data.train),drop=FALSE])

  model.res <- crs(y~x,cv="none",
                   degree=model.unres$degree,
                   segments=model.unres$segments,
                   basis=model.unres$basis,                                  
                   data=data.trans)
  
  ## Plot the restricted model.

  with(data.train,lines(x,fitted(model.res),col=4,lty=4,lwd=2))

  if(weighted) with(data.train,points(x,y*p.hat,col="orange",cex=0.35))

  legend("topleft",
         c(paste("DGP: sin(",dgp.frequency,"*pi*x)",sep=""),"Unconstrained Estimate","Constrained Estimate","Weighted Y","Actual Y"),
         col=c(1,2,4,"orange","black"),
         lwd=c(1,2,2,NA,NA),
         lty=c(1,2,4,NA,NA),
         pch=c(NA,NA,NA,1,1),
         cex=0.75,
         bty="n")

}

manipulate(manipulate.plot(n,spline.degree,spline.segments,dgp.frequency,lower,upper,weighted,cv),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           dgp.frequency=slider(1,4,2,label="DGP frequency (a*pi*x)",step=1,ticks=TRUE),
           spline.degree=slider(0,10,5,label="B-spline degree",step=1,ticks=TRUE),
           spline.segments=slider(1,10,4,label="B-spline segments",step=1,ticks=TRUE),
           lower=slider(-1.5,1.5,-1.5,step=0.1,label="Lower bound"),
           upper=slider(-1.5,1.5,1.5,step=0.1,label="Upper bound"),
           weighted=checkbox(FALSE, "Show weighted Y"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

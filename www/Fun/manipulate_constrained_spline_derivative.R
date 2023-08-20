## $Id: manipulate_constrained_spline_derivative.R,v 1.13 2014/01/12 12:15:44 jracine Exp jracine $

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

manipulate.plot <- function(n,spline.degree,spline.segments,dgp.frequency,lower,upper,deriv.order,which.plot,cv) {

  if(lower > upper) {
    lower <- upper - 0.01
  }

  if(identical(lower,upper)) {
    lower <- upper -0.01
  }

  set.seed(42)

  x <- sort(runif(n))
  dgp <- function(x) {sin(dgp.frequency*pi*x)}
  dgp.partial.1 <- function(x) {dgp.frequency*pi*cos(dgp.frequency*pi*x)}
  dgp.partial.2 <- function(x) {-dgp.frequency^2*pi^2*sin(dgp.frequency*pi*x)}    
  y <- dgp(x) + rnorm(n,sd=.5*sd(dgp(x)))

  ## For below y must be in the first column

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

  if(which.plot=="Conditional mean and Partial derivative") {
    par(mfrow=c(2,1))
  } else {
    par(mfrow=c(1,1))
  }

  ## Estimate the unrestricted model

  model.unres <- crs(y~x,
                     cv="none",
                     deriv=deriv.order,
                     degree=spline.degree,
                     segments=spline.segments,
                     basis="tensor",
                     data=data.train)

  ## Grab the derivative

  model.gradient.unres <- model.unres$deriv.mat

  ## For partial derivatives we need to do a bit more work...

  B <- crs:::prod.spline(x=data.train[,-1],
                         K=cbind(model.unres$degree,model.unres$segments),
                         basis=model.unres$basis)
  
  B.x <- crs:::prod.spline(x=data.train[,-1],
                           K=cbind(model.unres$degree,model.unres$segments),
                           basis=model.unres$basis,
                           deriv.index=1,
                           deriv=deriv.order)  

  ## Get the model weights. Note - each column must be multiplied by
  ## y.
  
  Aymat <- t(B.x%*%chol2inv(chol(t(B)%*%B))%*%t(B))*data.train$y
  
  ## Solve the quadratic programming problem

  QP.output <- solve.QP(Dmat=diag(n),
                        dvec=rep(1,n),
                        Amat=cbind(Aymat,-Aymat),
                        bvec=c(rep(lower,n),-rep(upper,n)))

  ## Get the solution and update the uniform weights

  p.hat <- QP.output$solution

  ## Estimate the restricted model

  data.trans <- data.frame(y=p.hat*data.train$y,data.train[,2:ncol(data.train),drop=FALSE])

  model.res <- crs(y~x,cv="none",
                   deriv=deriv.order,
                   degree=model.unres$degree,
                   segments=model.unres$segments,
                   basis=model.unres$basis,                                  
                   data=data.trans)
  
  ## Plot the dgp, restricted, and unrestricted models
  
  if(which.plot=="Conditional mean" || which.plot=="Conditional mean and Partial derivative") {

    ylim <- with(data.train,c(min(y,dgp(x),fitted(model.unres),fitted(model.res)),
                              max(y,dgp(x),fitted(model.unres),fitted(model.res))))
    
    with(data.train,plot(x,y,
                         cex=0.25,
                         col="lightgrey",
                         ylab="Y",
                         xlab="X",
                         ylim=ylim,
                         main="Constrained B-spline Regression",
                         sub=paste("Spline degree = ",spline.degree,", spline segments = ",spline.segments,", n = ",n,", upper = ",formatC(upper,format="f",digits=1),", lower = ",formatC(lower,format="f",digits=1),sep="")))
    
    with(data.train,lines(x,dgp(x),lty=1,col=1))
    
    legend("topleft",
           c(paste("DGP: sin(",dgp.frequency,"*pi*x)",sep=""),"Unconstrained Estimate","Constrained Estimate"),
           col=c(1,2,4),
           lwd=c(1,2,2),
           lty=c(1,2,4),
           cex=0.75,
           bty="n")
    
    with(data.train,lines(x,fitted(model.unres),lty=2,col=2,lwd=2))
    with(data.train,lines(x,fitted(model.res),col=4,lty=4,lwd=2))
         
  }

  if(which.plot=="Partial derivative" || which.plot=="Conditional mean and Partial derivative") {

    if(deriv.order==1) {
      deriv.vec <- with(data.train,dgp.partial.1(x))
    } else {
      deriv.vec <- with(data.train,dgp.partial.2(x))
    }

    ylim=c(min(deriv.vec,model.unres$deriv.mat[,1],model.res$deriv.mat[,1]),
      max(deriv.vec,model.unres$deriv.mat[,1],model.res$deriv.mat[,1]))
    
    with(data.train,plot(x,deriv.vec,
                         ylab="Derivative",
                         xlab="X",
                         ylim=ylim,
                         main="Constrained B-spline Derivative",
                         sub=paste("Spline degree = ",spline.degree,", spline segments = ",spline.segments,", n = ",n,", upper = ",formatC(upper,format="f",digits=2),", lower = ",formatC(lower,format="f",digits=2),sep=""),type="l",lty=1,col=1))
    
    with(data.train,lines(x,model.unres$deriv.mat[,1],lty=2,col=2),lwd=2)
    with(data.train,lines(x,model.res$deriv.mat[,1],lty=4,col=4),lwd=2)    

    if(deriv.order==0) {
      abline(h=lower,lty=2,col=1)
      abline(h=upper,lty=2,col=1)
    }
    
    legend("topleft",
           c(paste("True Derivative (order ",deriv.order,")",sep=""),"Unconstrained Derivative","Constrained Derivative"),
           col=c(1,2,4),
           lwd=c(1,2,2),
           lty=c(1,2,4),
           cex=0.75,
           bty="n")

  }

}

manipulate(manipulate.plot(n,spline.degree,spline.segments,dgp.frequency,lower,upper,deriv.order,which.plot,cv),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           deriv.order=picker(1,2,label="Order of derivative"),
           which.plot=picker("Conditional mean","Partial derivative","Conditional mean and Partial derivative",label="Function to plot"),           
           dgp.frequency=slider(1,4,2,label="DGP frequency (a*pi*x)",step=1,ticks=TRUE),
           spline.degree=slider(0,10,5,label="B-spline degree",step=1,ticks=TRUE),
           spline.segments=slider(1,10,2,label="B-spline segments",step=1,ticks=TRUE),
           lower=slider(-150,150,-10,step=1,label="Lower bound"),
           upper=slider(-150,150,10,step=1,label="Upper bound"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

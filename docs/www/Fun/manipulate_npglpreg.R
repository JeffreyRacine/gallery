## $Id: manipulate_npglpreg.R,v 1.8 2013/12/07 22:33:56 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the polynomial order,
## bandwidth, degree of the underlying DGP, and number of observations
## for the estimator detailed in Hall & Racine (2013) "Infinite-order
## cross-validated local polynomial regression.

rm(list=ls())
require(manipulate)
require(crs)
options(np.tree=TRUE)

## Call the manipulate function on a plot object

manipulate.plot <- function(n,poly.order,sf,dgp.degree,cv.bws) {

  set.seed(42)

  x <- sort(runif(n,-2,2))
  dgp <- function(x) {dgp<-rowSums(poly(x,dgp.degree));dgp/sd(dgp)}
  y <- dgp(x) + rnorm(n,sd=.5)


  if(!cv.bws) {
    subtext <- paste("Local polynomial order = ", poly.order,", scale factor = ",sf,", n = ",n,sep="")
  } else {
    model <- npglpreg(y~x,ckertype="epanechnikov",nmulti=2)
    subtext <- paste("Cross-validated bandwidth = ",formatC(model$bws,digits=3,format="f"),", cross-validated order = ",model$degree,sep="")
  }
  
  plot(x,y,
       cex=0.25,
       col="lightgrey",
       ylab="Y",
       xlab="X",
       main="\"Infinite-Order\" Local Polynomial Regression",
       sub=subtext)

  lines(x,dgp(x),lty=2,col=2)
  if(cv.bws) {
    lines(x,fitted(model),lty=1,col=1)
  } else {
    lines(x,fitted(npglpreg(y~x,ckertype="epanechnikov",cv="none",degree=poly.order,bws=sf*sd(x)*n^{-1/5})),lty=1,col=1)
  }

  legend("topleft",
         c(paste("DGP (degree ",dgp.degree," polynomial)",sep=""),"Kernel Estimate"),
         col=c(2,1),
         lwd=c(1,1),
         lty=c(2,1),
         cex=0.75,
         bty="n")

}

manipulate(manipulate.plot(n,poly.order,sf,dgp.degree,cv.bws),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           dgp.degree=slider(1,10,4,label="DGP polynomial order",step=1,ticks=TRUE),
           poly.order=slider(0,15,4,label="Local polynomial order",step=1,ticks=TRUE),
           sf=slider(0.5,50,50,label="Scale factor",step=1,ticks=TRUE),
           cv.bws=checkbox(FALSE, "Cross-validate bandwidth and polynomial order"))

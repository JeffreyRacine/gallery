## $Id: manipulate_npglpreg_sin.R,v 1.3 2013/12/07 22:33:59 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the polynomial order,
## bandwidth, frequency of the underlying DGP, and number of observations
## for the estimator detailed in Hall & Racine (2013) "Infinite-order
## cross-validated local polynomial regression.

rm(list=ls())
require(manipulate)
require(crs)
require(np)
options(np.tree=TRUE)

## Call the manipulate function on a plot object

manipulate.plot <- function(n,poly.order,sf,dgp.frequency) {

  set.seed(42)

  x <- sort(runif(n))
  dgp <- function(x) {dgp<- sin(dgp.frequency*pi*x);dgp/sd(dgp)}
  y <- dgp(x) + rnorm(n,sd=.5)

  plot(x,y,
       cex=0.25,
       col="lightgrey",
       ylab="Y",
       xlab="X",
       main="\"Infinite-Order\" Local Polynomial Regression",
       sub=paste("Local polynomial order = ", poly.order,", scale factor = ",sf,", n = ",n,sep=""))

  lines(x,dgp(x),lty=2,col=2)
  lines(x,fitted(npglpreg(y~x,cv="none",degree=poly.order,ckertype="epanechnikov",bws=sf*sd(x)*n^{-1/5})),lty=1,col=1)

  legend("topleft",
         c(paste("DGP (frequency a = ",dgp.frequency," (i.e. sin(a*pi*x)))",sep=""),"Kernel Estimate"),
         col=c(2,1),
         lwd=c(1,1),
         lty=c(2,1),
         cex=0.75,
         bty="n")

}

manipulate(manipulate.plot(n,poly.order,sf,dgp.frequency),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           dgp.frequency=slider(1,4,2,label="DGP frequency (a*pi*x)",step=1,ticks=TRUE),
           poly.order=slider(0,15,6,label="Local polynomial order",step=1,ticks=TRUE),
           sf=slider(0.5,50,50,label="Scale factor",step=1,ticks=TRUE))

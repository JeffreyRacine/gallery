## $Id: manipulate_faithful_density.R,v 1.4 2014/01/12 12:15:47 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the bandwidth for a bivariate
## Rosenblatt-Parzen kernel density estimator to gauge the impact on
## bias and variance and change the kernel function. You can also set
## the kernel function, order of the kernel function, number of
## observations, and correleation among the variables.

rm(list=ls())
require(manipulate)
require(np)
options(np.tree=TRUE)
data(faithful)

## Write a function to do plotting and accept arguments...

manipulate.plot <- function(neval,sf.x,sf.y,ckertype,ckerorder,theta,cv) {

  set.seed(42)

  n <- nrow(faithful)

  x <- faithful$eruptions
  y <- faithful$waiting

  x.eval <- seq(min(x)-sd(x),max(x)+sd(x),length=neval)
  y.eval <- seq(min(y)-sd(y),max(y)+sd(y),length=neval)

  bws <- c(sf.x*np:::EssDee(x)*n^{-1/(2*ckerorder+2)},
           sf.y*np:::EssDee(y)*n^{-1/(2*ckerorder+2)})

  f.grid <- matrix(npksum(txdat=data.frame(x,y),
                          exdat=expand.grid(x.eval,y.eval),
                          bws=bws,
                          bandwidth.divide=TRUE,
                          ckertype=ckertype,
                          ckerorder=ckerorder)$ksum/n,
                   neval,neval)

  if(cv) {
    bw <- npudensbw(~x+y,ckertype=ckertype,ckerorder=ckerorder)
    sf.x <- bw$sfactor$x[1]
    sf.y <- bw$sfactor$x[2]
  }
   
  persp(x.eval,y.eval,f.grid,
        sub=paste("h.eruptions = ",
          formatC(sf.x*sd(x)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", h.waiting = ",
          formatC(sf.y*sd(y)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", n = ",n,sep=""),
        theta=theta,
        phi=30,
        ylab="waiting",
        xlab="eruptions",
        zlab="Joint PDF",
        ticktype="detailed",
        col="lightblue")

}

## Call the manipulate function on the above function

manipulate(manipulate.plot(neval,sf.x,sf.y,ckertype,ckerorder,theta,cv),
           neval=slider(25,150,50,step=25,label="Number of evaluation obs"),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           ckerorder=picker(2,4,6,8,label="Kernel order"),
           sf.x=slider(0.1,2.5,1,label="Scale factor for x",step=0.1,ticks=TRUE),
           sf.y=slider(0.1,2.5,1,label="Scale factor for y",step=0.1,ticks=TRUE),
           theta=slider(0,360,0,label="Azimuthal viewing direction",step=15,ticks=TRUE),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

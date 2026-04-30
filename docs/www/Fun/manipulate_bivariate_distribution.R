## $Id: manipulate_bivariate_distribution.R,v 1.4 2014/01/12 12:24:24 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the bandwidth for a bivariate
## Rosenblatt-Parzen kernel distribution estimator to gauge the impact on
## bias and variance and change the kernel function. You can also set
## the kernel function, order of the kernel function, number of
## observations, and correleation among the variables.

require(manipulate)
require(np)
options(np.tree=TRUE)
require(MASS)

## Write a function to do plotting and accept arguments...

manipulate.plot <- function(n,neval,rho,sf.x,sf.y,ckertype,ckerorder,theta,cv) {

  set.seed(42)

  mu <- rep(0,2)
  Sigma <- matrix(rho,2,2)
  diag(Sigma) <- 1

  mydat <- mvrnorm(n=n, mu, Sigma)
  x <- mydat[,1]
  y <- mydat[,2]

  x.eval <- seq(min(x)-sd(x),max(x)+sd(x),length=neval)
  y.eval <- seq(min(y)-sd(y),max(y)+sd(y),length=neval)

  if(cv) {
    bw <- npudistbw(~x+y,
                    ckertype=ckertype,
                    ckerorder=ckerorder)
  } else {
    bw <- npudistbw(~x+y,
                    ckertype=ckertype,
                    ckerorder=ckerorder,
                    bandwidth.compute=FALSE,
                    bwscaling=TRUE,
                    bws=c(sf.x,sf.y))
  }

  F.grid <- matrix(fitted(npudist(tdat=data.frame(x,y),
                                  edat=expand.grid(x=x.eval,y=y.eval),
                                  bws=bw)),
                   neval,neval)

  persp(x.eval,y.eval,F.grid,
        sub=paste("h.x = ",
          formatC(bw$bw[1]*sd(x)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", h.y = ",
          formatC(bw$bw[2]*sd(y)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", n = ",n,", rho = ",rho,sep=""),
        theta=theta,
        phi=30,
        zlim=c(0,1),
        ylab="y",
        xlab="x",
        zlab="Joint CDF",
        ticktype="detailed",
        col="lightblue")

}

## Call the manipulate function on the above function

manipulate(manipulate.plot(n,neval,rho,sf.x,sf.y,ckertype,ckerorder,theta,cv),
           n=slider(100,1000,500,step=100,label="Number of estimation obs"),
           neval=slider(25,100,50,step=25,label="Number of evaluation obs"),
           rho=slider(0,1,0.1,step=0.1,label="Correlation between x and y"),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           ckerorder=picker(2,4,6,8,label="Kernel order"),
           sf.x=slider(0.1,2.5,1,label="Scale factor for x",step=0.1,ticks=TRUE),
           sf.y=slider(0.1,2.5,1,label="Scale factor for y",step=0.1,ticks=TRUE),
           theta=slider(0,360,0,label="Azimuthal viewing direction",step=15,ticks=TRUE),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

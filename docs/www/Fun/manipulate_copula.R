## $Id: manipulate_copula.R,v 1.12 2014/01/12 12:15:45 jracine Exp jracine $

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
require(mnormt)

## No Zero Denominator, used in C code for kernel estimation...
  
NZD <- function(a) {
  sapply(1:NROW(a), function(i) {if(a[i] < 0) min(-.Machine$double.xmin,a[i]) else max(.Machine$double.xmin,a[i])})
}

## Write a function to do plotting and accept arguments...

manipulate.plot <- function(n,neval,rho,object,sf.x,sf.y,q.min,q.max,ckertype,ckerorder,theta,dgp,cv) {

  set.seed(42)

  mu <- rep(0,2)
  Sigma <- matrix(rho,2,2)
  diag(Sigma) <- 1

  mydat <- rmnorm(n=n, mu, Sigma)

  mydat <- data.frame(x=mydat[,1],y=mydat[,2])
  x <- mydat$x
  y <- mydat$y

  grid.seq <- seq(q.min,q.max,length=neval)
  grid.dat <- cbind(grid.seq,grid.seq)

  if(cv) {
    if(object=="copula" || object=="copula contour") {
      bw <- npudistbw(~x+y,ckertype=ckertype,ckerorder=ckerorder,bwscaling=TRUE)
    } else {
      bw <- npudensbw(~x+y,ckertype=ckertype,ckerorder=ckerorder,bwscaling=TRUE)
    }
    sf.x <- bw$sfactor$x[1]
    sf.y <- bw$sfactor$x[2]
  }

  if(object=="copula" || object=="copula contour") {
    bw <- npudistbw(~x+y,
                    bandwidth.compute=FALSE,
                    bwscaling=TRUE,
                    ckertype=ckertype,
                    ckerorder=ckerorder,
                    bws=c(sf.x,sf.y))
  } else {
    bw <- npudensbw(~x+y,
                    bandwidth.compute=FALSE,
                    bwscaling=TRUE,
                    ckertype=ckertype,
                    ckerorder=ckerorder,
                    bws=c(sf.x,sf.y))
  }

  copula <- npcopula(bws=bw,data=mydat,u=grid.dat)

  if(object=="copula") {
    persp(grid.seq,grid.seq,matrix(copula$copula,neval,neval),
          sub=paste("h.x = ",
          formatC(sf.x*sd(x)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", h.y = ",
          formatC(sf.y*sd(y)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", n = ",n,", rho = ",formatC(rho,digits=2,format="f"),sep=""),
          ticktype="detailed",
          xlab="u1",
          ylab="u2",
          zlab="Copula",
          zlim=c(0,1),
          theta=theta,
          border="black",
          col=FALSE)
    if(dgp) {
      F <-   F <- sapply(1:(neval**2),function(i){pmnorm(cbind(copula$x,copula$y)[i,],mu,Sigma)})
      par(new=TRUE)
      persp(grid.seq,grid.seq,matrix(F,neval,neval),
            ticktype="detailed",
            xlab="",
            ylab="",
            zlab="",
            col=FALSE,
            theta=theta,
            lty=2,
            border="red")
    }
  }
  if(object=="copula contour") {
    contour(grid.seq,grid.seq,matrix(copula$copula,neval,neval),xlab="u1",ylab="u2",main="Copula Contour")
    if(dgp) {
      F <-   F <- sapply(1:(neval**2),function(i){pmnorm(cbind(copula$x,copula$y)[i,],mu,Sigma)})
      contour(grid.seq,grid.seq,matrix(F,neval,neval),xlab="u1",ylab="u2",main="Copula Contour",col=2,lty=2,add=TRUE)
    }
  }
  if(object=="copula density") {
    persp(grid.seq,grid.seq,matrix(copula$copula,neval,neval),
          sub=paste("h.x = ",
          formatC(sf.x*sd(x)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", h.y = ",
          formatC(sf.y*sd(y)*n^{-1/(2*ckerorder+2)},format="f",digits=2),
          ", n = ",n,", rho = ",rho,sep=""),
          ticktype="detailed",
          xlab="u1",
          ylab="u2",
          zlab="Copula Density",
          theta=theta,
          col=FALSE,
          border="black")
    if(dgp) {
      f <-   f <- sapply(1:(neval**2),function(i){dmnorm(cbind(copula$x,copula$y)[i,],mu,Sigma)})
      f <- f/NZD(dnorm(copula$x)*dnorm(copula$y))
      par(new=TRUE)
      persp(grid.seq,grid.seq,matrix(f,neval,neval),
            col=FALSE,
            theta=theta,
            lwd=.25,
            box=FALSE,
            axes=FALSE,
            lty=2,
            border="red")
    }
  }    
  if(object=="copula density contour") {
    contour(grid.seq,grid.seq,matrix(copula$copula,neval,neval),xlab="u1",ylab="u2",main="Copula Density Contour")
    if(dgp) {
      f <-   f <- sapply(1:(neval**2),function(i){dmnorm(cbind(copula$x,copula$y)[i,],mu,Sigma)})
      f <- f/NZD(dnorm(copula$x)*dnorm(copula$y))      
      contour(grid.seq,grid.seq,matrix(f,neval,neval),xlab="u1",ylab="u2",main="Copula Contour",col=2,lty=2,add=TRUE)
    }
  }

}

## Call the manipulate function on the above function

manipulate(manipulate.plot(n,neval,rho,object,sf.x,sf.y,q.min,q.max,ckertype,ckerorder,theta,dgp,cv),
           n=slider(100,1000,500,step=100,label="Number of estimation obs"),
           neval=slider(25,100,50,step=25,label="Number of evaluation obs"),
           rho=slider(-0.95,0.95,0.95,step=0.05,label="Correlation between x and y"),
           object=picker("copula","copula contour","copula density","copula density contour",label="Copula object to plot"),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           ckerorder=picker(2,4,6,8,label="Kernel order"),
           sf.x=slider(0.1,2.5,0.25,label="Scale factor for x",step=0.1,ticks=TRUE),
           sf.y=slider(0.1,2.5,0.25,label="Scale factor for y",step=0.1,ticks=TRUE),
           dgp=checkbox(FALSE, "Show data generating process (red)"),
           q.min=slider(0,0.25,0.01,label="Lower quantile for cropping plot",step=0.01,ticks=TRUE),
           q.max=slider(0.75,1,.99,label="Upper quantile for cropping plot",step=0.01,ticks=TRUE),                      
           theta=slider(0,360,315,label="Azimuthal viewing direction",step=15,ticks=TRUE),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

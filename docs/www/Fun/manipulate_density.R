## $Id: manipulate_density.R,v 1.25 2014/03/31 02:41:29 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' and `pickers' where the user can set the bandwidth
## for univariate Rosenblatt-Parzen, adaptive, generalized, and knn
## kernel density estimates to gauge the impact on bias and
## variance. You can also modify the kernel function, order of the
## kernel function, and whether to use fixed, generalized_nn, or
## adaptive_nn bandwidths. As well you can change the degrees of
## freedom of the underlying chi-square distribution along with the
## number of observations. We also plot the true density for
## comparison purposes.

require(manipulate)
require(np)
options(np.tree=TRUE)

## Write a function to do plotting and accept arguments... doing so
## allows multiple plot calls (e.g. overlay histogram etc.) which
## cannot otherwise be done with the manipulate function.

manipulate.plot <- function(n,df,sf,nn,bwtype,ckertype,ckerorder,hist,rug,cv,cv.type) {

  if(nn >= n) {
    warning(paste("Knn bandwidth must be less than",n))
    nn <- n-1
  }

  set.seed(42)
  x <- rchisq(n,df=df)
  x.eval <- seq(min(x)-0.5*sd(x),max(x)+0.5*sd(x),length=1000)
  f.dgp <- dchisq(ifelse(x.eval<0,0,x.eval),df=df)

  hist.max <- 0
  if(hist) hist.max <- max(hist(x,breaks=25,plot=FALSE)$density)

  if(cv) {
    bw <- npudensbw(~x,
                    bwtype=bwtype,
                    bwmethod=cv.type,
                    ckertype=ckertype,
                    ckerorder=ckerorder)
  } else {
    bw <- npudensbw(~x,
                    bwtype=bwtype,
                    ckertype=ckertype,
                    ckerorder=ckerorder,
                    bandwidth.compute=FALSE,
                    bwscaling=TRUE,
                    bws=ifelse(bwtype=="fixed",sf,nn))
  }

  f.kernel <- fitted(npudens(tdat=x,edat=x.eval,bws=bw))

  ylim <- c(0,max(hist.max,f.kernel,f.dgp))

  plot(x.eval,f.kernel,
       ylim=ylim,
       type="l",
       ylab="Density",
       xlab="Data",
       sub=paste(ifelse(bwtype=="fixed",paste("Bandwidth = ",formatC(bw$bw[1]*sd(x)*n^{-1/(2*ckerorder+1)},format="f",digits=2),sep=""),paste("Kth nearest neighbor = ",bw$bw[1],sep="")),", n = ",n,sep=""),
       lty=1,
       col=1)

  lines(x.eval,f.dgp,lty=2,col=2)

  legend("topright",
         c("Kernel Estimate",paste("Chi-square (df = ",df,")",sep="")),
         lty=c(1,2),
         col=c(1,2),
         bty="n",
         cex=0.75)

  if(hist) hist(x,breaks=25,freq=FALSE,col=NA,add=TRUE,lty=3)

  if(rug) rug(x)
}

## Call the manipulate function on the above function

manipulate(manipulate.plot(n,df,sf,nn,bwtype,ckertype,ckerorder,hist,rug,cv,cv.type),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           df=slider(10,120,10,step=10,label="Chi-square degrees of freedom"),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           ckerorder=picker(2,4,6,8,label="Kernel order"),
           bwtype=picker("fixed","adaptive_nn","generalized_nn",label="Bandwidth type"),
           sf=slider(0.1,2.5,1,label="Scale factor (bwtype=\"fixed\")",step=0.1,ticks=TRUE),
           nn=slider(2,1000,50,label="Kth nn (bwtype=*_nn)",step=1,ticks=TRUE),
           hist=checkbox(FALSE, "Show histogram"),
           rug=checkbox(FALSE, "Show rug"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"),
           cv.type=picker("cv.ml","cv.ls",label="CV method"))

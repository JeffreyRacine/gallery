## $Id: manipulate_distribution.R,v 1.7 2014/01/12 12:15:46 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' and `pickers' where the user can set the bandwidth
## for univariate Rosenblatt-Parzen, adaptive, generalized, and knn
## kernel distribution estimates to gauge the impact on bias and
## variance. You can also modify the kernel function, order of the
## kernel function, and whether to use fixed, generalized_nn, or
## adaptive_nn bandwidths. As well you can change the degrees of
## freedom of the underlying chi-square distribution along with the
## number of observations. We also plot the true distribution for
## comparison purposes.

rm(list=ls())
require(manipulate)
require(np)
options(np.tree=FALSE)

## Write a function to do plotting and accept arguments... doing so
## allows multiple plot calls (e.g. overlay empirical distribution
## function etc.) which cannot otherwise be done with the manipulate
## function.

manipulate.plot <- function(n,df,sf,nn,bwtype,ckertype,ckerorder,ecdf,rug,cv) {

  if(nn >= n) {
    warning(paste("Knn bandwidth must be less than",n))
    nn <- n-1
  }

  set.seed(42)
  x <- sort(rchisq(n,df=df))
  x.eval <- seq(min(x)-0.5*sd(x),max(x)+0.5*sd(x),length=100)
  F.dgp <- pchisq(ifelse(x.eval<0,0,x.eval),df=df)

  if(cv) {
    bw <- npudistbw(~x,
                    bwtype=bwtype,
                    ckertype=ckertype,
                    ckerorder=ckerorder)
  } else {
    bw <- npudistbw(~x,
                    bwtype=bwtype,
                    ckertype=ckertype,
                    ckerorder=ckerorder,
                    bandwidth.compute=FALSE,
                    bwscaling=TRUE,
                    bws=ifelse(bwtype=="fixed",sf,nn))
  }

  F.kernel <- fitted(npudist(tdat=x,edat=x.eval,bws=bw))

  plot(x.eval,F.kernel,
       ylim=c(0,1),
       type="l",
       ylab="Distribution",
       xlab="Data",
       sub=paste("Bandwidth = ",ifelse(bwtype=="fixed",formatC(bw$bw[1]*sd(x)*n^{-1/(ckerorder+1)},format="f",digits=2),bw$bw[1]),", n = ",n,sep=""),
       lty=1,
       col=1)

  lines(x.eval,F.dgp,lty=2,col=2)

  legend("topleft",
         c("Kernel Estimate",paste("Chi-square (df = ",df,")",sep="")),
         lty=c(1,2),
         col=c(1,2),
         bty="n",
         cex=0.75)

  if(ecdf) {
    Fn <- ecdf(x)
    lines(x,Fn(x),lty=3)
  }

  if(rug) rug(x)
}

## Call the manipulate function on the above function

manipulate(manipulate.plot(n,df,sf,nn,bwtype,ckertype,ckerorder,ecdf,rug,cv),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           df=slider(10,120,10,step=10,label="Chi-square degrees of freedom"),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           ckerorder=picker(2,4,6,8,label="Kernel order"),
           bwtype=picker("fixed","adaptive_nn","generalized_nn",label="Bandwidth type"),
           sf=slider(0.1,2.5,1,label="Scale factor (bwtype=\"fixed\")",step=0.1,ticks=TRUE),
           nn=slider(2,1000,50,label="Kth nn (bwtype=*_nn)",step=1,ticks=TRUE),
           ecdf=checkbox(FALSE, "Show empirical distribution function"),
           rug=checkbox(FALSE, "Show rug"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"))

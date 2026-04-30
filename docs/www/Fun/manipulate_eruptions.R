## $Id: manipulate_eruptions.R,v 1.9 2016/10/18 11:22:55 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' and `pickers' where the user can set the bandwidth
## for univariate Rosenblatt-Parzen, adaptive, generalized, and knn
## kernel density estimates to gauge the impact on bias and
## variance. You can also modify the kernel function, order of the
## kernel function, and whether to use fixed, generalized_nn, or
## adaptive_nn bandwidths..

require(manipulate)
require(np)
options(np.tree=TRUE)
data(faithful)

## Write a function to do plotting and accept arguments... doing so
## allows multiple plot calls (e.g. overlay histogram etc.) which
## cannot otherwise be done with the manipulate function.

manipulate.plot <- function(sf,nn,bwtype,ckertype,ckerorder,hist,rug,cv,cvtype) {

  x <- faithful$eruptions
  x.eval <- seq(min(x)-0.5*sd(x),max(x)+0.5*sd(x),length=1000)
  n <- length(x)

  if(nn >= n) {
    warning(paste("Knn bandwidth must be less than",n))
    nn <- n-1
  }

  hist.max <- 0
  if(hist) hist.max <- max(hist(x,breaks=20,plot=FALSE)$density)

  if(cv) {
    bw <- npudensbw(~x,
                    bwtype=bwtype,
                    bwmethod=cvtype,
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

  ylim <- c(min(hist.max,f.kernel),max(hist.max,f.kernel))

  plot(x.eval,f.kernel,
       ylim=ylim,
       type="l",
       ylab="Density",
       xlab="Eruption length (minutes)",
       sub=paste(ifelse(bwtype=="fixed",paste("Bandwidth = ",formatC(ifelse(cv,bw$bw[1],sf*sd(x)*n^{-1/(2*ckerorder+1)}),format="f",digits=3),sep=""),paste("Kth nearest neighbor = ",ifelse(cv,bw$bw[1],nn),sep="")),", n = ",n,sep=""),
       lty=1,
       col=1)

  if(hist) hist(x,breaks=20,freq=FALSE,add=TRUE,col=NA,lty=3)

  if(rug) rug(x)
}

## Call the manipulate function on the above function

manipulate(manipulate.plot(sf,nn,bwtype,ckertype,ckerorder,hist,rug,cv,cvtype),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           ckerorder=picker(2,4,6,8,label="Kernel order"),
           bwtype=picker("fixed","adaptive_nn","generalized_nn",label="Bandwidth type"),
           sf=slider(0.1,4.0,1,label="Scale factor (bwtype=\"fixed\")",step=0.2,ticks=TRUE),
           nn=slider(2,100,25,label="Kth nn (bwtype=*_nn)",step=1,ticks=TRUE),
           hist=checkbox(FALSE, "Show histogram"),
           rug=checkbox(FALSE, "Show rug"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"),
           cvtype=picker("cv.ml","cv.ls",label="Cross-validation method"))

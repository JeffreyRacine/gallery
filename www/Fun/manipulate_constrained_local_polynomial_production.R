## $Id: manipulate_constrained_local_polynomial_production.R,v 1.19 2014/04/27 08:19:38 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the bandwidth, number of
## observations, and types of constraints for the constrained
## estimator outlined in Du, Parmeter and Racine (2013) "Nonparametric
## Kernel Regression with Multiple Predictors and Multiple Shape
## Constraints" (Statistica Sinica).

## Note - for undersmoothed functions it is possible that the
## analytical derivative of the estimator \hat g(x) (i.e. were one to
## compute d \hat g(x)/dx) can differ from that delivered by the local
## polynomial estimator (\hat delta(x)). In this case, imposing
## constraints on derivatives may still result in \hat g(x|p)
## appearing to violate the imposed constraint. Any such divergence
## will vanish as the bandwidth increases.

rm(list=ls())
require(manipulate)
require(np)
options(np.tree=TRUE,np.messages=FALSE)
require(quadprog)

build_manual_lp_bw <- function(formula, data, degree, bw = NULL, ckertype, bandwidth.compute = TRUE) {
  args <- list(
    formula,
    data = data,
    regtype = "lp",
    degree = as.integer(degree),
    degree.select = "manual",
    bernstein.basis = TRUE,
    ckertype = ckertype,
    bandwidth.compute = bandwidth.compute
  )

  if (!is.null(bw))
    args$bws <- bw

  do.call(npregbw, args)
}

build_nomad_lp_bw <- function(formula, data, degree.start, degree.min, degree.max, ckertype, nmulti) {
  if (!requireNamespace("crs", quietly = TRUE)) {
    stop(
      "Automatic LP degree search uses npregbw(..., nomad = TRUE), ",
      "which currently requires the 'crs' package."
    )
  }

  npregbw(
    formula,
    data = data,
    regtype = "lp",
    ckertype = ckertype,
    nomad = TRUE,
    degree.min = as.integer(degree.min),
    degree.max = as.integer(degree.max),
    degree.start = as.integer(degree.start),
    nmulti = as.integer(nmulti)
  )
}

## Call the manipulate function on a plot object
manipulate.plot <- function(n,p,bw,ckertype,constraints,weighted,unweighted,cv,cv.complexity) {

  set.seed(42)
  npseed(42)  

  x <- sort(runif(n))
  dgp <- function(x) {dgp <- sqrt(x)}
  y <- dgp(x) - abs(rnorm(n,sd=.1))
  y <- ifelse(y>=0,y,0)
  lp.data <- data.frame(y = y, x = x)

  if(cv) {
    lp.bw <- if(cv.complexity == "bandwidth") {
      build_manual_lp_bw(
        formula = y ~ x,
        data = lp.data,
        degree = p,
        ckertype = ckertype,
        bandwidth.compute = TRUE
      )
    } else {
      build_nomad_lp_bw(
        formula = y ~ x,
        data = lp.data,
        degree.start = p,
        degree.min = 2L,
        degree.max = 7L,
        ckertype = ckertype,
        nmulti = 1L
      )
    }
    bw <- lp.bw$bw[1L]
    p <- as.integer(lp.bw$degree[1L])
  } else {
    lp.bw <- build_manual_lp_bw(
      formula = y ~ x,
      data = lp.data,
      degree = p,
      bw = bw,
      ckertype = ckertype,
      bandwidth.compute = FALSE
    )
  }

  plot(x,dgp(x),
       ylab="Y",
       xlab="X",
       main="Constrained Local Polynomial Regression",
       sub=paste("Bandwidth = ",format(bw,digits=3,format="f"),
         ", polynomial order = ",p,
         ", n = ",n,
         sep=""),
       type="l",
       lty=1,
       col=1)

  if(unweighted) points(x,y,col=1,cex=0.2)

  ## Estimate the unrestricted model

  H.mean <- npreghat(
    bws = lp.bw,
    txdat = data.frame(x = x),
    output = "matrix"
  )
  H.deriv.1 <- npreghat(
    bws = lp.bw,
    txdat = data.frame(x = x),
    output = "matrix",
    s = 1L
  )
  H.deriv.2 <- npreghat(
    bws = lp.bw,
    txdat = data.frame(x = x),
    output = "matrix",
    s = 2L
  )

  A <- t(H.mean) * y
  A.deriv.1 <- t(H.deriv.1) * y
  A.deriv.2 <- t(H.deriv.2) * y
  
  p.u <- rep(1,n)

  ## For the production function we have constraints
  ## 1) \hat g(x|p) \ge y [A\ge y]
  ## 2) \hat g^(1)(x|p) \ge 0 [A.deriv.1 \ge rep(0,n)]
  ## 3) \hat g^(2)(x|p) \le 0 [-A.deriv.2 \ge rep(0,n)]

  if(constraints=="g'(x)>=0, y<=g(x)") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A,A.deriv.1),
                          bvec=c(y,rep(0,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(constraints=="g''(x)<=0, y<=g(x)") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A,-A.deriv.2),
                          bvec=c(y,rep(0,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(constraints=="y<=g(x)") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A),
                          bvec=y)
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(constraints=="g'(x)>=0, g''(x)<=0, y<=g(x)") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A,A.deriv.1,-A.deriv.2),
                          bvec=c(y,rep(0,n),rep(0,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(constraints=="g'(x)>=0, g''(x)<=0") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A.deriv.1,-A.deriv.2),
                          bvec=c(rep(0,n),rep(0,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(constraints=="g''(x)<=0") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(-A.deriv.2),
                          bvec=c(rep(0,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else if(constraints=="g'(x)>=0") {
    QP.output <- solve.QP(Dmat=diag(n),
                          dvec=rep(1,n),
                          Amat=cbind(A.deriv.1),
                          bvec=c(rep(0,n)))
    if(is.nan(QP.output$value)) stop(" solve.QP failed. Try smoother curve (larger bandwidths or polynomial order)")
    p.hat <- QP.output$solution
  } else {
    p.hat <- p.u
  }
  
  ## Get the solution and estimate the unrestricted and restricted models

  fitted.unres <- drop(H.mean %*% y)
  fitted.res <- drop(H.mean %*% (y * p.hat))

  ## Plot the unrestricted and restricted models and restricted y
  
  lines(x,fitted.unres,lty=2,col=2,lwd=2)
  lines(x,fitted.res,col=4,lty=4,lwd=3)

  if(weighted) points(x,y*p.hat,col="orange",cex=0.35)

  legend("topleft",
         c("DGP","Unconstrained Estimate","Constrained Estimate","Weighted Y","Actual Y"),
         col=c(1,2,4,"orange","black"),
         lwd=c(1,2,3,NA,NA),
         lty=c(1,2,4,NA,NA),
         pch=c(NA,NA,NA,1,1),
         cex=0.75,
         bty="n")

}

manipulate(manipulate.plot(n,p,bw,ckertype,constraints,weighted,unweighted,cv,cv.complexity),
           n=slider(100,1000,500,step=100,label="Number of observations"),
           p=slider(2,5,2,label="Local Polynomial Order",step=1,ticks=TRUE),
           bw=slider(0.01,0.1,0.04,step=0.01,label="Bandwidth"),
           constraints=picker("none","g'(x)>=0, g''(x)<=0, y<=g(x)", "g''(x)<=0, y<=g(x)", "g'(x)>=0, y<=g(x)", "y<=g(x)", "g'(x)>=0, g''(x)<=0", "g''(x)<=0", "g'(x)>=0"),
           ckertype=picker("gaussian","epanechnikov","uniform",label="Kernel function"),
           weighted=checkbox(FALSE, "Show weighted Y"),
           unweighted=checkbox(TRUE, "Show unweighted Y"),
           cv=checkbox(FALSE, "Cross-validate smoothing parameters"),
           cv.complexity=picker("bandwidth","degree-bandwidth",label="Cross-validate target"))

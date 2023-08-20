## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can control the levels of the
## predictor variables and modify the amount of local averaging
## undertaken. This application of nonparametric methods showcases how
## the conditional mean is derived from a conditional density estimate
## and how conditional quantiles are derived from a conditional
## distribution estimate. The impact of changing the predictors can be
## readily assessed. This code was written during a visit to CSIR to
## work with Sonali Das during April 2016.

## We are grateful to SOCCO for their assistance and for making the
## data available (Southern Ocean Carbon & Climate Observatory
## (socco.org.za)

rm(list=ls())
require(manipulate)
require(np)
options(np.tree=TRUE)
load("data.RData")

## Function for quick computation of univariate integral

integrate.trapezoidal <- function(x,y) {

  ## This function will compute the integral using the Newton-Cotes
  ## trapezoidal rule and the cumsum function.

  n <- length(x)
  if(x.unsorted <- is.unsorted(x)) {
    rank.x <- rank(x)
    order.x <- order(x)
    y <- y[order.x]
    x <- x[order.x]
  }

  int.vec <- numeric(length(x))
  int.vec[2:n] <- cumsum((x[2:n] - x[2:n-1]) * (y[2:n] + y[2:n-1]) / 2)

  return(int.vec[n])

}

## Call the manipulate function on a plot object

manipulate.plot <- function(sf.co2f,sf.chl,sf.sal,sf.temp,sf.mld,
                            xq.chl,xq.sal,xq.temp,xq.mld,
                            yq.min.co2f,yq.max.co2f,
                            foo.name,
                            quantile.co2f) {

    ckertype <- "gaussian"

    neval <- 1000

    if(foo.name == "Leg 1 SANAE50") foo.data <- foo.leg1.50
    if(foo.name == "Leg 1 SANAE51") foo.data <- foo.leg1.51
    if(foo.name == "Leg 1 SANAE52") foo.data <- foo.leg1.52
    if(foo.name == "Leg 1 SANAE53") foo.data <- foo.leg1.53
    if(foo.name == "Leg 1 SANAE54") foo.data <- foo.leg1.54
    if(foo.name == "Leg 1 Pooled") foo.data <- foo.leg1
    if(foo.name == "Leg 6 SANAE52") foo.data <- foo.leg6.52
    if(foo.name == "Leg 6 SANAE53") foo.data <- foo.leg6.53
    if(foo.name == "Leg 6 SANAE54") foo.data <- foo.leg6.54
    if(foo.name == "Leg 6 Pooled") foo.data <- foo.leg6
    if(foo.name == "Leg 1 and Leg 6 Pooled") foo.data <- foo.pooled

    ## Extendrange for accurate integration when conditional PDF s
    ## non-zero at boundary of support

    CO2f_sst.er <- with(foo.data,extendrange(CO2f_sst,f=0.25))

    CO2f_sst.seq <- with(foo.data,seq(CO2f_sst.er[1],CO2f_sst.er[2],length=neval))

    newdata <- with(foo.data,data.frame(CO2f_sst=CO2f_sst.seq,
                                        Chl_conc=rep(uocquantile(Chl_conc,xq.chl),neval),
                                        Salt_tsg=rep(uocquantile(Salt_tsg,xq.sal),neval),
                                        Temp_intake=rep(uocquantile(Temp_intake,xq.temp),neval),
                                        MLD=rep(uocquantile(MLD,xq.mld),neval)))
    
    f <- fitted(npcdens(tydat=foo.data$CO2f_sst,
                        txdat=data.frame(foo.data$Chl_conc,foo.data$Salt_tsg,foo.data$Temp_intake,foo.data$MLD),
                        eydat=newdata$CO2f_sst,
                        exdat=data.frame(newdata$Chl_conc,newdata$Salt_tsg,newdata$Temp_intake,newdata$MLD),
                        bwscaling=TRUE,
                        cykertype=ckertype,
                        cxkertype=ckertype,
                        bws=c(sf.co2f,sf.chl,sf.sal,sf.temp,sf.mld)))

    F <- fitted(npcdist(tydat=foo.data$CO2f_sst,
                        txdat=data.frame(foo.data$Chl_conc,foo.data$Salt_tsg,foo.data$Temp_intake,foo.data$MLD),
                        eydat=newdata$CO2f_sst,
                        exdat=data.frame(newdata$Chl_conc,newdata$Salt_tsg,newdata$Temp_intake,newdata$MLD),
                        bwscaling=TRUE,
                        cykertype=ckertype,
                        cxkertype=ckertype,
                        bws=c(sf.co2f,sf.chl,sf.sal,sf.temp,sf.mld)))


    mean.CO2f <- formatC(integrate.trapezoidal(CO2f_sst.seq,CO2f_sst.seq*f),format="f",digits=1)

    ## Compute the median from the CDF using Nelson's quasi-inverse

    cond.quantile.CO2f <-  formatC(min(CO2f_sst.seq[F>=quantile.co2f]),format="f",digits=1)
    with(foo.data,if(cond.quantile.CO2f < min(CO2f_sst)) cond.quantile.CO2f <- min(CO2f_sst))
    with(foo.data,if(cond.quantile.CO2f > max(CO2f_sst)) cond.quantile.CO2f <- max(CO2f_sst))
    
    par(mfrow=c(2,1))

    legend.dat <- with(foo.data,formatC(c(Chl_conc=uocquantile(Chl_conc,xq.chl),
                                          Salt_tsg=uocquantile(Salt_tsg,xq.sal),
                                          Temp_intake=uocquantile(Temp_intake,xq.temp),
                                          MLD=uocquantile(MLD,xq.mld)),
                                        format="f",
                                        digits=2))

    ## Conditional PDF plot
    
    legend.txt <- c(paste("Chl_conc = ",legend.dat[1]," (millivolts)",sep=""),
                    paste("Salt_tsg = ",legend.dat[2]," (PSU)",sep=""),
                    paste("Temp_intake = ",legend.dat[3]," (C)",sep=""),
                    paste("MLD = ",legend.dat[4]," (meters)",sep=""),
                    paste("Conditional mean = ", mean.CO2f," (mu atm)",sep=""))
    
    ylim <- c(0,max(f))
    xlim <- with(foo.data,c(uocquantile(CO2f_sst,yq.min.co2f),
                            uocquantile(CO2f_sst,yq.max.co2f)))
    
    with(foo.data,plot(f~CO2f_sst.seq,
                       ylab="Conditional PDF",
                       xlab="CO2f_sst (mu atm)",
                       type="l",
                       ylim=ylim,
                       xlim=xlim,
                       main=foo.name,
                       sub=paste("(",dim(foo.data)[1]," observations)",sep=""),
                       lty=1,col=1,lwd=2))
    
    with(foo.data,rug(CO2f_sst,col="lightgrey",quiet=TRUE))

    abline(v=mean.CO2f,col="grey",lty=2,lwd=2)

    legend("topleft",legend.txt,cex=0.8,lty=c(NA,NA,NA,NA,2),col=c(NA,NA,NA,NA,"grey"),lwd=c(NA,NA,NA,NA,2),bty="n")

    ## Conditional CDF plot
    
    legend.txt <- c(paste("Chl_conc = ",legend.dat[1]," (millivolts)",sep=""),
                    paste("Salt_tsg = ",legend.dat[2]," (PSU)",sep=""),
                    paste("Temp_intake = ",legend.dat[3]," (C)",sep=""),
                    paste("MLD = ",legend.dat[4]," (meters)",sep=""),
                    paste("Conditional ",formatC(100*quantile.co2f,format="f",digits=0),"th quantile = ", cond.quantile.CO2f," (mu atm)",sep=""))
    
    ylim <- c(0,1)
    
    with(foo.data,plot(F~CO2f_sst.seq,
                       ylab="Conditional CDF",
                       xlab="CO2f_sst (mu atm)",
                       type="l",
                       ylim=ylim,
                       xlim=xlim,
                       sub=paste("(",dim(foo.data)[1]," observations)",sep=""),
                       lty=1,col=1,lwd=2))
    
    with(foo.data,rug(CO2f_sst,col="lightgrey",quiet=TRUE))
    
    abline(v=cond.quantile.CO2f,col="grey",lty=2,lwd=2)

    legend("topleft",legend.txt,cex=0.8,lty=c(NA,NA,NA,NA,2),col=c(NA,NA,NA,NA,"grey"),lwd=c(NA,NA,NA,NA,2),bty="n")

}

manipulate(manipulate.plot(sf.co2f,sf.chl,sf.sal,sf.temp,sf.mld,
                           xq.chl,xq.sal,xq.temp,xq.mld,
                           yq.min.co2f,yq.max.co2f,
                           foo.name,
                           quantile.co2f),
           sf.co2f=slider(0.1,0.5,.25,label="CO2f_sst Scale factor",step=0.05,ticks=TRUE),
           sf.chl=slider(0.1,0.5,.25,label="Chl_conc Scale factor",step=0.05,ticks=TRUE),           
           sf.sal=slider(0.1,0.5,.25,label="Salt_tsg Scale factor",step=0.05,ticks=TRUE),
           sf.temp =slider(0.1,0.5,.25,label="Temp_intake Scale factor",step=0.05,ticks=TRUE),
           sf.mld=slider(0.1,0.5,.25,label="MLD Scale factor",step=0.05,ticks=TRUE),
           foo.name=picker("Leg 1 SANAE50",
               "Leg 1 SANAE51",
               "Leg 1 SANAE52",
               "Leg 1 SANAE53",
               "Leg 1 SANAE54",
               "Leg 1 Pooled",
               "Leg 6 SANAE52",
               "Leg 6 SANAE53",
               "Leg 6 SANAE54",
               "Leg 6 Pooled",
               "Leg 1 and Leg 6 Pooled",
               label="Data"),
           xq.chl=slider(0.20,0.80,0.5,label="Chl_conc quantile",step=0.05,ticks=TRUE),           
           xq.sal=slider(0.20,0.80,0.5,label="Salt_tsg quantile",step=0.05,ticks=TRUE),
           xq.temp =slider(0.20,0.80,0.5,label="Temp_intake quantile",step=0.05,ticks=TRUE),
           xq.mld=slider(0.20,0.80,0.5,label="MLD quantile",step=0.05,ticks=TRUE),
           yq.min.co2f=slider(0,0.5,0.05,label="Plot lower quantile",step=0.05,ticks=TRUE),
           yq.max.co2f=slider(0.5,1,0.95,label="Plot upper quantile",step=0.05,ticks=TRUE),
           quantile.co2f=slider(0,1,0.5,label="Probability for conditional quantile ",step=0.1,ticks=TRUE))
           

rm(list=ls())

## In this illustration we compare the classical local constant and
## local linear estimators with the method of Hall and Racine (2013,
## "Infinite Order Cross-Validated Local Polynomial Regression")

set.seed(42)

## Set the number of optimization restarts from different random
## initial values

nmulti <- 1

## Set the degree of the DGP (orthogonal polynomial)

degree <- 4

## Set the degree of the (overspecified) polynomial

large.poly.order <- 15

## Simulate data

n <- 500
x <- sort(runif(n,-2,2))
dgp <- function(x) {dgp<-rowSums(poly(x,degree));dgp/sd(dgp)}
y <- dgp(x) + rnorm(n,sd=.5)

## Plot the data

plot(x,y,cex=.25,col="grey")

## Load the crs package

require(crs)

## Estimate the model cross-validating both the degree and bandwidth
## (default)

model <- npglpreg(y~x,nmulti=nmulti,degree.max=10)

## Fix the order of the polynomial then cross-validate the bandwidth
## (common values are 0 for the `local constant', 1 for the `local
## linear', and try a large fixed value for comparison purposes

model.lc <- npglpreg(y~x,cv="bandwidth",degree=0,nmulti=nmulti)
model.ll <- npglpreg(y~x,cv="bandwidth",degree=1,nmulti=nmulti)
model.poly <- npglpreg(y~x,cv="bandwidth",degree=large.poly.order,nmulti=nmulti)

## Plot the results (DGP, Oracle LS fit, Nonparametric fit, local
## constant, local linear etc.)

lines(x,lm.fit<-fitted(lm(y~poly(x,degree))),col=2,lty=2,lwd=2)
lines(x,glp.fit<-fitted(model),col=3,lty=3,lwd=2)
lines(x,fitted(model.lc),col=4,lty=4,lwd=2)
lines(x,fitted(model.ll),col=5,lty=5,lwd=2)
lines(x,fitted(model.poly),col=6,lty=6,lwd=2)
legend("top",
       c("Oracle",
         paste("GLP (h=",formatC(model$bws,format="f",digits=2),", p=",model$degree,")",sep=""),
         paste("LC (h=",formatC(model.lc$bws,format="f",digits=2),", p=",model.lc$degree,")",sep=""),
         paste("LL (h=",formatC(model.ll$bws,format="f",digits=2),", p=",model.ll$degree,")",sep=""),
         paste("LP (h=",formatC(model.poly$bws,format="f",digits=2),", p=",model.poly$degree,")",sep="")),
       col=2:6,
       lty=2:6,
       lwd=rep(2,5))

## Plot results (Oracle LS fit, Nonparametric fit only)

plot(x,y,cex=.25,col="grey")
lines(x,dgp(x),col="grey",lty=1,lwd=1)
lines(x,lm.fit<-fitted(lm(y~poly(x,degree))),col=2,lty=2,lwd=2)
lines(x,glp.fit<-fitted(model),col=3,lty=3,lwd=2)
legend("top",c("DGP","Oracle","GLP"),col=1:3,lty=1:3,lwd=c(1,2,2))

cbind(lm.fit,glp.fit)[seq(1,n,by=100),]

summary(model)


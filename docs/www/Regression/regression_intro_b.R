## Here is a simple illustration to help you get started with
## univariate kernel regression and derivative estimation.

## First, let's grab some data from the np package

## Load the np package

library(np)

## Load the cps71 dataset contained in the np package

data(cps71)

## Fit a (default) local constant model and compute the derivatives
## (since we do not explicitly call npregbw() which conducts
## least-squares cross-validated bandwidth selection by default it is
## automatically invoked when we call npreg())

model.lc <- npreg(logwage~age,gradients=TRUE,data=cps71)

## Plot the estimated derivatives (the colors and linetypes allow us
## to distinguish different plots on the same figure). Note that the
## function `gradients' is specific to the np package and works only
## when the argument `gradients=TRUE' is invoked when calling npreg()

plot(cps71$age,gradients(model.lc),
     ylab="Derivative",
     col=1,
     lty=1,
     type="l")

## Fit a local linear model (we use the arguments regtype="ll" to do
## this)

model.ll <- npreg(logwage~age,regtype="ll",gradients=TRUE,data=cps71)

## Plot the fitted values with a different color and linetype

age.order <- order(cps71$age)
lines(cps71$age[age.order],gradients(model.ll)[age.order],col=2,lty=2)

## Add a legend

legend("topleft",
       c("Local Constant","Local Linear"),
       lty=c(1,2),
       col=c(1,2),
       bty="n")

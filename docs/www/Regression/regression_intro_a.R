## Here is a simple illustration to help you get started with
## univariate kernel regression.

## First, let's grab some data from the np package

## Load the np package

library(np)

## Load the cps71 dataset contained in the np package

data(cps71)

## Fit a (default) local constant model (since we do not explicitly
## call npregbw() which conducts least-squares cross-validated
## bandwidth selection by default it is automatically invoked when we
## call npreg())

model.lc <- npreg(logwage~age,data=cps71)

## Plot the local-constant fit. By default the plot method overlays the
## observed data, so we do not have to draw the raw sample first.

plot(model.lc)

## Fit a local linear model (we use the arguments regtype="ll" to do
## this)

model.ll <- npreg(logwage~age,regtype="ll",data=cps71)

## Add the local-linear fit with a different color and linetype

age.order <- order(cps71$age)
lines(cps71$age[age.order],fitted(model.ll)[age.order],col=2,lty=2)

## Add a legend

legend("topleft",
       c("Local Constant","Local Linear"),
       lty=c(1,2),
       col=c(1,2),
       bty="n")

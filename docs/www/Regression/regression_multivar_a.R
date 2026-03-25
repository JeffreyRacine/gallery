rm(list=ls())

## Here is a simple illustration to help you get started with
## multivariate kernel regression and plotting via R's `plot' function
## (which calls the np function `npplot')

## First, let's grab some data from the np package

## Load the np package

library(np)

## Load the wage1 dataset contained in the np package

data(wage1)

## Attach the data so that the variables `lwage', `female', `educ' and
## `exper' can be called directly

attach(wage1)

## Fit a local linear model (since we do not explicitly call npregbw()
## which conducts least-squares cross-validated bandwidth selection by
## default it is automatically invoked when we call npreg()). Here we
## have a `factor' (female) and two `numeric' predictors (educ and
## exper - see ?wage1 for details)

model <- npreg(lwage~female+educ+exper,regtype="ll")

## model will be an object of class `npreg'. The generic R function
## `plot' will call `npplot' when it is deployed on an object of this
## type (see ?npplot for details on supported npplot
## arguments). Calling plot on a npreg object allows you to do some
## tedious things without having to write code such as including
## confidence intervals as the following example demonstrates. Note
## also that we do not explicitly have to specify `gradients=TRUE' in
## the call to npreg() as plot (npplot) will take care of this for
## us. Below we use the asymptotic standard error estimates and then
## take +- 1.96 standard error)

plot(model,plot.errors.method="asymptotic",plot.errors.style="band")

## We might also wish to use bootstrapping instead (here we bootstrap
## the standard errors and then take +- 1.96 standard error)

plot(model,plot.errors.method="bootstrap",plot.errors.style="band")

## Alternately, we might compare the modern pointwise, Bonferroni, and
## simultaneous bootstrap error bounds on the same plot.

plot(model,plot.errors.method="bootstrap",plot.errors.type="all",plot.errors.style="band")

## Note that adding the argument `gradients=TRUE' to the plot call
## will automatically plot the derivatives instead

plot(model,plot.errors.method="bootstrap",plot.errors.type="all",plot.errors.style="band",gradients=TRUE)

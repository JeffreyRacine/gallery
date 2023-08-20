## $Id: manipulate_wage1.R,v 1.2 2013/03/03 12:07:24 jracine Exp jracine $

## This file uses the `manipulate' package to create a dynamic plot
## with `sliders' where the user can set the off-axis variable
## quantiles for the local linear regression estimator using the
## `wage1' data.

rm(list=ls())
require(manipulate)
require(np)

## Load the wage1 data which contains the precomputed bandwidth object
## `bw.all'

data(wage1)

## Call the manipulate function on a plot object

manipulate(plot(bw.all,
                common.scale=common.scale,
                plot.errors.method="asymptotic",
                plot.errors.style="band",
                xq=c(0.5,0.5,educ,exper,tenure)),
           common.scale=picker(TRUE,FALSE,label="Common Scale for Y Axes"),
           educ=slider(0,1,0.5,label="Education Quantile",step=0.1,ticks=TRUE),
           exper=slider(0,1,0.5,label="Experience Quantile",step=0.1,ticks=TRUE),
           tenure=slider(0,1,0.5,label="Tenure Quantile",step=0.1,ticks=TRUE))

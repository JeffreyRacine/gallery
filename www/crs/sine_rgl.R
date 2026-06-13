## This illustration considers a product sine function and plots the
## results by constructing a 3D real-time rendering plot using OpenGL.
## Best viewed in RStudio: the interactive surface appears in the
## Viewer pane rather than the Plot pane.

require(crs)
options(rgl.useNULL = TRUE)
options(rgl.printRglwidget = TRUE)
require(rgl)

set.seed(42)

## Set the number of observations and number of multistarts.

n <- 1000
nmulti <- 1

x1 <- runif(n,0,1)
x2 <- runif(n,0,1)

dgp <- sin(pi*(x1+x2))^4*sin(pi*x1)^2

y <- dgp + rnorm(n,sd=.1)

model <- crs(y~x1+x2,
             complexity="degree-knots",
             knots="uniform",
             deriv=1,
             cv.func="cv.aic",
             nmulti=nmulti)

summary(model)

## Let plot.crs() construct the interactive rgl surface and support rug.

plot(model,perspective=TRUE,renderer="rgl",data_rug=TRUE)

## You could animate the results for 15 seconds using the line
## play3d(spin3d(axis=c(0,0,1), rpm=5), duration=15)
## By default you can manually rotate the figure by dragging the plot
## via your mouse/keypad

## Note - to plot an rgl figure first get it oriented how you want
## (i.e. resize, rotate etc.) and then call rgl.postscript to create,
## i.e., a PDF of your graphic as in
## rgl.postscript("foo.pdf","pdf"). Or better still,
## rgl.snapshot("foo.png") for a png that can be called directly in
## LaTeX via \includegraphics[scale=.6]{foo.png}

## For Quarto or R Markdown, place the call in a regular R chunk such
## as the following illustration:
## ```{r}
## x <- rnorm(100); y <- rnorm(100); z <- rnorm(100)
## plot3d(x, y, z)
## ```

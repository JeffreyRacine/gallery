## Estimate a product-sine conditional mean g(x1, x2) and display the
## fitted spline as an interactive OpenGL surface in the RStudio Viewer.

library(crs)
options(rgl.useNULL = TRUE)
options(rgl.printRglwidget = TRUE)
library(rgl)

set.seed(42)

n <- 1000

x1 <- runif(n, 0, 1)
x2 <- runif(n, 0, 1)

dgp <- sin(pi * (x1 + x2))^4 * sin(pi * x1)^2

y <- dgp + rnorm(n, sd = .1)

model <- crs(y ~ x1 + x2,
             complexity = "degree-knots",
             knots = "uniform",
             deriv = 1,
             cv.func = "cv.aic")

summary(model)

## Draw the fitted surface and the observed support.
plot(model, perspective = TRUE, renderer = "rgl", data_rug = TRUE)

## Drag to rotate, scroll to zoom, or animate for 15 seconds with:
## play3d(spin3d(axis = c(0, 0, 1), rpm = 5), duration = 15)
## After choosing a view, rgl.snapshot("sine.png") saves a raster image.

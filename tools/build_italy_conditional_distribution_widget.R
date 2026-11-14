## Rebuild the landing-page WebGL widget from the Gallery project root.

options(rgl.useNULL = TRUE, rgl.printRglwidget = FALSE, np.messages = FALSE)

library(np)
library(htmlwidgets)
library(rgl)

if (packageVersion("np") != package_version("0.80-3")) {
  stop("Rebuild this release artifact with np 0.80-3.")
}

data("Italy_Updated", package = "np")

Fhat <- npcdist(gdp ~ year, data = Italy_Updated)
widget <- plot(Fhat,
  renderer = "rgl",
  zlab = "F(gdp|year)",
  theta = 300,
  phi = 10,
  data.rug = TRUE)

stopifnot(inherits(widget, "rglWebGL"), inherits(widget, "htmlwidget"))

## Reuse the distribution bandwidths to trace the conditional median.
tau <- 0.5
Qhat <- npqreg(bws = Fhat$bws, tau = tau, data = Italy_Updated)
year_grid <- data.frame(
  year = ordered(levels(Italy_Updated$year),
    levels = levels(Italy_Updated$year)))
year_num <- as.numeric(as.character(year_grid$year))
cond_quantile <- drop(predict(Qhat, newdata = year_grid))

surface_widget <- widget
plot3d(surface_widget)
lines3d(year_num, cond_quantile, 0, color = "grey45", lwd = 1.5)
lines3d(year_num, cond_quantile, tau, color = "grey45", lwd = 1)
widget <- rglwidget()

## Retain np's high-DPI rendering hook on the augmented scene.
widget$jsHooks <- surface_widget$jsHooks

widget$sizingPolicy$browser$fill <- TRUE
widget$sizingPolicy$browser$padding <- 0

widget_path <- "www/widgets/italy_conditional_distribution.html"

htmlwidgets::saveWidget(
  widget,
  widget_path,
  selfcontained = TRUE,
  title = "Italian regional GDP conditional distribution"
)

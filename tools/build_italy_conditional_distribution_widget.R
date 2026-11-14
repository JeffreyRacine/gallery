## Rebuild the landing-page WebGL widget from the Gallery project root.

options(rgl.useNULL = TRUE, rgl.printRglwidget = FALSE, np.messages = FALSE)

library(np)
library(htmlwidgets)

if (packageVersion("np") != package_version("0.80-3")) {
  stop("Rebuild this release artifact with np 0.80-3.")
}

data("Italy_Updated", package = "np")

Fhat <- npcdist(gdp ~ year, data = Italy_Updated)
widget <- plot(Fhat,
  renderer = "rgl",
  zlab = "F(gdp|year)")

stopifnot(inherits(widget, "rglWebGL"), inherits(widget, "htmlwidget"))

widget$sizingPolicy$browser$fill <- TRUE
widget$sizingPolicy$browser$padding <- 0

widget_path <- "www/widgets/italy_conditional_distribution.html"

htmlwidgets::saveWidget(
  widget,
  widget_path,
  selfcontained = TRUE,
  title = "Italian regional GDP conditional distribution"
)

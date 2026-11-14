## Interactive conditional distribution of Italian regional GDP per capita.

library(np)
data("Italy_Updated")

## Estimate F(gdp | year), then open the WebGL surface in RStudio's Viewer.
Fhat <- npcdist(gdp ~ year, data = Italy_Updated)
plot(Fhat, renderer = "rgl", zlab = "F(gdp|year)")

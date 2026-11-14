## Interactive conditional distribution of Italian regional GDP per capita.

library(np)
library(rgl)
data("Italy_Updated")
# With np < 0.80-3, use data("Italy") and data = Italy below.
# np 0.80-2 requires the snake-case spelling data_rug = TRUE.

## Estimate F(gdp | year), then face its floor projection toward the viewer.
Fhat <- npcdist(gdp ~ year, data = Italy_Updated)
widget <- plot(Fhat, renderer = "rgl", zlab = "F(gdp|year)",
  theta = 300, phi = 10, data.rug = TRUE)

## Reuse its bandwidths to estimate a conditional quantile without a new search.
tau <- 0.5 # Use 0.25 for the conditional first quartile, and so forth.
Qhat <- npqreg(bws = Fhat$bws, tau = tau, data = Italy_Updated)
# Optional: plot(Qhat) draws the conditional quantile.
# plot(Qhat, gradients = TRUE) draws its marginal effect, \Delta Q / \Delta year.
year_grid <- data.frame(
  year = ordered(levels(Italy_Updated$year),
    levels = levels(Italy_Updated$year)))
year_num <- as.numeric(as.character(year_grid$year))
cond_quantile <- drop(predict(Qhat, newdata = year_grid))

## Trace the selected quantile at F = tau and project it onto the floor.
plot3d(widget)
lines3d(year_num, cond_quantile, 0, color = "grey45", lwd = 1.5)
lines3d(year_num, cond_quantile, tau, color = "grey45", lwd = 1)
rglwidget()

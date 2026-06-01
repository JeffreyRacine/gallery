## Minimal np location-scale quantile example.
##
## Fit several location-scale quantiles in one call, then inspect the
## selected bandwidth state and compare the fitted curves.

library(np)
options(np.messages = FALSE)

## Keep the first location-scale run compact and reproducible.
data(Italy, package = "np")

## Fit several conditional quantiles using the location-scale route.
qfit <- nplsqreg(gdp ~ ordered(year),
                 data = Italy,
                 tau = c(0.25, 0.50, 0.75),
                 nmulti = 1)

## Review the selected search state and fitted object.
summary(qfit$bws)
summary(qfit)

## Predict the median at the observed design points.
qmed <- predict(qfit, tau = 0.50)
head(qmed)

## Plot the fitted location-scale quantile curves.
plot(qfit)

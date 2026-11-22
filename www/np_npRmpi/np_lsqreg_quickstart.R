## Estimate several location-scale conditional quantiles Q_tau(x).

library(np)
options(np.messages = FALSE)

## Keep the first location-scale run compact and reproducible.
data(Italy, package = "np")

## Fit several conditional quantiles using the location-scale route.
qfit <- nplsqreg(gdp ~ ordered(year),
                 data = Italy,
                 tau = c(0.25, 0.50, 0.75))

## Review the selected search state and fitted object.
summary(qfit$bws)
summary(qfit)

## Predict the stored median without repeating bandwidth selection.
qmed <- predict(qfit, tau = 0.50)
head(qmed)

## Plot the fitted location-scale quantile curves.
plot(qfit)

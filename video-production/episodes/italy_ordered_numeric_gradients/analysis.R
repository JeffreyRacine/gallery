## Italy ordered-factor versus numeric gradient short.
## Last verified with the public CRAN np 0.70-5 build.

library(np)
data(Italy, package = "np")

# The bundled data correctly stores year as an ordered factor.
class(Italy$year)

# Re-express the same displayed years as numeric for comparison.
italy_numeric <- transform(
  Italy,
  year = as.numeric(as.character(year))
)
class(italy_numeric$year)

fit_ordered <- npreg(gdp ~ year, data = Italy)
fit_numeric <- npreg(gdp ~ year, data = italy_numeric)

summary(fit_ordered$bws)
summary(fit_numeric$bws)

options(plot.par.mfrow = FALSE)
par(mfrow = c(2, 2))

plot(fit_ordered,
     main = "Ordered year: fitted mean",
     xlab = "Year", ylab = "GDP")
plot(fit_numeric,
     main = "Numeric year: fitted mean",
     xlab = "Year", ylab = "GDP")
plot(fit_ordered, gradients = TRUE,
     main = "Ordered year: finite difference",
     xlab = "Year")
plot(fit_numeric, gradients = TRUE,
     main = "Numeric year: derivative",
     xlab = "Year")

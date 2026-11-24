## Plot the Leg 1 measurements and map each variable by its pooled deciles.
library(maps)
load("data.RData")

foo <- foo.leg1.50
plot(CO2f_sst ~ Chl_conc,
     data = foo,
     ylab = "Mean fCO2",
     xlab = "Chlorophyll-a",
     type = "b")


## Offset overlapping cruise tracks in longitude for display.
lon.adjust <- 1
foo.leg1.51$Lon <- foo.leg1.51$Lon - lon.adjust
foo.leg1.52$Lon <- foo.leg1.52$Lon + lon.adjust
foo.leg1.53$Lon <- foo.leg1.53$Lon - 2 * lon.adjust
foo.leg1.54$Lon <- foo.leg1.54$Lon + 2 * lon.adjust

foo <- rbind(foo.leg1.50,
             foo.leg1.51,
             foo.leg1.52,
             foo.leg1.53,
             foo.leg1.54)

foo <- na.omit(subset(foo, CruiseLeg == 1))

plot_leg_map <- function(z, title, end.colour) {
  ## The points and colour key use the same ten bins and colours.
  breaks <- quantile(z, (0:10) / 10)
  colours <- colorRampPalette(c("black", "lightblue", "yellow", end.colour),
                             interpolate = "spline")(10L)
  bins <- cut(z, breaks, include.lowest = TRUE, labels = FALSE)
  trips <- sort(unique(foo$Trip))
  symbols <- 20L + seq_along(trips)

  map(database = "world", regions = c("antarctica", "south africa"),
      xlim = c(-30, 40), ylim = c(-75, -25), fill = TRUE,
      col = "lightgrey", resolution = 0, bg = "white")
  box()
  points(foo$Lon, foo$Lat, bg = colours[bins], pch = symbols[match(foo$Trip, trips)],
         cex = .5, col = NA)
  legend("topleft", trips, pch = symbols, bty = "n", cex = .5)
  axis(1)
  axis(2)
  grid()
  title(main = title, xlab = "Longitude", ylab = "Latitude")

  edges <- seq(-65, -50, length.out = length(breaks))
  rect(-20, head(edges, -1L), -15, tail(edges, -1L), border = NA, col = colours)
  text(-20.2, edges, labels = formatC(breaks, format = "f", digits = 2), cex = .8, pos = 2)
}

plot_leg_map(foo$Chl_conc, "Chlorophyll-a Leg 1", "green")
plot_leg_map(foo$CO2f_sst, "fCO2 Leg 1", "purple")
plot_leg_map(foo$Salt_tsg, "Salinity Leg 1", "orange")
plot_leg_map(foo$Temp_intake, "Temperature Leg 1", "red")
plot_leg_map(foo$MLD, "MLD Leg 1", "maroon")

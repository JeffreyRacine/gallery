## Plot a local-linear conditional mean with bootstrap uncertainty bands.

library(np)
options(np.messages = FALSE)

data(cps71, package = "np")

## Fit a simple local-linear regression object.
model.ll <- npreg(logwage ~ age, regtype = "ll", data = cps71)

## Save one example plot so the script works in non-interactive sessions too.
plot_path <- file.path(tempdir(), "np_plotting_quickstart.png")
png(plot_path, width = 700, height = 500)
plot_data <- plot(model.ll,
  errors = "bootstrap",
  bootstrap = "inid",
  band = "all",
  output = "plot-data")
dev.off()

## Extract the curve and pointwise limits from the bootstrap run shown above.
curve_data <- as.data.frame(plot_data, band = "pointwise")

## Report the saved image and the rows available for further work.
cat("Saved plot to:", plot_path, "\n")
cat("Plot-data rows:", nrow(curve_data), "\n")

## Minimal np plotting and interval example.
##
## This fits a simple local-linear model and then shows the
## modern bootstrap plotting route with all interval/band types.

library(np)
options(np.messages = FALSE)

data(cps71, package = "np")

## Fit a simple local-linear regression object.
model.ll <- npreg(logwage ~ age, regtype = "ll", data = cps71)

## Save one example plot so the script works in non-interactive sessions too.
plot_path <- file.path(tempdir(), "np_plotting_quickstart.png")
png(plot_path, width = 700, height = 500)
plot(model.ll,
  errors = "bootstrap",
  bootstrap = "inid",
  band = "all")
dev.off()

## Inspect the same plot geometry without drawing or refitting.
plot_data <- plot(model.ll, output = "data")
curve_data <- as.data.frame(plot_data)

## Report the saved image and the rows available for further work.
cat("Saved plot to:", plot_path, "\n")
cat("Plot-data rows:", nrow(curve_data), "\n")

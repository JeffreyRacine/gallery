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
  plot.errors.method = "bootstrap",
  plot.errors.boot.method = "inid",
  plot.errors.type = "all"
)
dev.off()

## Report where the rendered image landed.
cat("Saved plot to:", plot_path, "\n")

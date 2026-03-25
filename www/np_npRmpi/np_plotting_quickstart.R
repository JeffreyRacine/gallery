rm(list = ls())

## Minimal np plotting and interval example.
##
## This fits a simple local-linear model and then shows the
## modern bootstrap plotting route with all interval/band types.

library(np)
options(np.messages = FALSE)

data(cps71, package = "np")

model.ll <- npreg(logwage ~ age, regtype = "ll", data = cps71)

plot_path <- file.path(tempdir(), "np_plotting_quickstart.png")
png(plot_path, width = 700, height = 500)
plot(
  model.ll,
  plot.errors.method = "bootstrap",
  plot.errors.boot.method = "inid",
  plot.errors.boot.num = 9999,
  plot.errors.type = "all"
)
dev.off()

cat("Saved plot to:", plot_path, "\n")

rm(list = ls())

## Minimal np plotting and interval example.
##
## This fits a simple model, saves one asymptotic-interval plot, and
## shows the prediction route on a small evaluation grid.

library(np)
options(np.messages = FALSE)

data(cps71, package = "np")

fit <- npreg(
  logwage ~ age,
  regtype = "ll",
  bwmethod = "cv.aic",
  gradients = TRUE,
  data = cps71
)

plot_path <- file.path(tempdir(), "np_plotting_quickstart.png")
png(plot_path, width = 700, height = 500)
plot(fit, plot.errors.method = "asymptotic", plot.errors.style = "band")
dev.off()

pred_grid <- data.frame(age = seq(20, 60, by = 10))
predict(fit, newdata = pred_grid)

cat("Saved plot to:", plot_path, "\n")


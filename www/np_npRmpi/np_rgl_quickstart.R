## Minimal interactive np plotting example using the rgl renderer.
##
## If you are working on a headless system, you may want:
## options(rgl.useNULL = TRUE)

library(np)

if (!requireNamespace("rgl", quietly = TRUE)) {
  stop("Install the 'rgl' package to use renderer = \"rgl\".")
}

data(wage1, package = "np")

fit_rgl <- npreg(
  lwage ~ educ + exper,
  regtype = "ll",
  data = wage1
)

plot(
  fit_rgl,
  view = "fixed",
  renderer = "rgl",
  plot.data.overlay = FALSE,
  plot.errors.method = "asymptotic",
  plot.rug = TRUE
)

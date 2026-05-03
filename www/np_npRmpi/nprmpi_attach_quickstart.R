## Minimal attach-mode npRmpi example.
##
## Launch with a pre-created MPI world, for example:
##   mpiexec -env R_PROFILE_USER "" -env R_PROFILE "" -n 2 \
##     Rscript --no-save nprmpi_attach_quickstart.R

library(npRmpi)

## Initialize under an already-created MPI world.
npRmpi.init(mode = "attach")

if (mpi.comm.rank(0L) == 0L) {
  ## Build the data and fit on the coordinator rank.
  set.seed(1)
  x <- runif(200)
  y <- sin(2 * pi * x) + rnorm(200, sd = 0.2)
  dat <- data.frame(y, x)

  bw <- npregbw(y ~ x, regtype = "ll", bwmethod = "cv.ls", data = dat)
  fit <- npreg(bws = bw, data = dat)

  ## Inspect the fitted objects, then shut down cleanly.
  summary(bw)
  summary(fit)

  npRmpi.quit(mode = "attach")
}

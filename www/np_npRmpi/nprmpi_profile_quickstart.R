rm(list = ls())

## Minimal profile/manual-broadcast npRmpi example.
##
## Launch with an explicit profile source, for example:
##   RPROFILE=$(Rscript --no-save -e 'cat(system.file("Rprofile", package="npRmpi"))')
##   mpiexec -env R_PROFILE_USER "$RPROFILE" -env R_PROFILE "" -n 2 \
##     Rscript --no-save nprmpi_profile_quickstart.R

invisible(mpi.bcast.cmd(np.mpi.initialize(), caller.execute = TRUE))

set.seed(1)
x <- runif(200)
y <- sin(2 * pi * x) + rnorm(200, sd = 0.2)
dat <- data.frame(y, x)

invisible(mpi.bcast.Robj2slave(dat))

invisible(mpi.bcast.cmd(
  bw <- npregbw(y ~ x, regtype = "ll", bwmethod = "cv.ls", data = dat),
  caller.execute = TRUE
))

invisible(mpi.bcast.cmd(
  fit <- npreg(bws = bw, data = dat),
  caller.execute = TRUE
))

summary(bw)
summary(fit)

invisible(mpi.bcast.cmd(mpi.quit(), caller.execute = TRUE))

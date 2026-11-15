## Manual-broadcast counterpart to npudensml_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npudensml_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

## Draw a sample from a standard normal density, then broadcast it.

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

n <- 2500

mydat <- data.frame(x = rnorm(n))
mpi.bcast.Robj2slave(mydat)

## Select the bandwidth for f(x) by likelihood cross-validation.

t <- system.time(mpi.bcast.cmd(bw <- npudensbw(~x,
                                               bwmethod = "cv.ml",
                                               data = mydat),
                               caller.execute = TRUE))

summary(bw)

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

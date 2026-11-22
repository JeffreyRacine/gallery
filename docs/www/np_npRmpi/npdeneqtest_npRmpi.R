## Manual-broadcast counterpart to npdeneqtest_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npdeneqtest_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

## Draw two samples from the same reference density, then broadcast them.

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

n <- 1000

sample.A <- data.frame(x = rnorm(n))
sample.B <- data.frame(x = rnorm(n))

mpi.bcast.Robj2slave(sample.A)
mpi.bcast.Robj2slave(sample.B)

## Test whether the two samples have the same density.

t <- system.time(mpi.bcast.cmd(output <- npdeneqtest(sample.A, sample.B),
                               caller.execute = TRUE))

output

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

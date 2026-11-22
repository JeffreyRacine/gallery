## Manual-broadcast counterpart to npsdeptest_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npsdeptest_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

## Generate a stationary AR(1) series from supplied innovations.
ar.series <- function(phi, epsilon) {
  n <- length(epsilon)
  series <- numeric(n)
  series[1] <- epsilon[1] / (1 - phi)
  for (i in seq_len(n)[-1]) {
    series[i] <- phi * series[i - 1] + epsilon[i]
  }
  series
}

n <- 2000

yt <- ar.series(0.95, rnorm(n))

mpi.bcast.Robj2slave(yt)

## Test the simulated series for serial dependence.

t <- system.time(mpi.bcast.cmd(output <- npsdeptest(yt,
                                                    lag.num = 2,
                                                    method = "summation"),
                               caller.execute = TRUE))

output

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

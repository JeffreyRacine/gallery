## Manual-broadcast counterpart to npindexich_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npindexich_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

## Simulate a continuous-response single-index model, then broadcast it.

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

n <- 2500

x1 <- runif(n, min = -1, max = 1)
x2 <- runif(n, min = -1, max = 1)
y <- x1 - x2 + rnorm(n)
mydat <- data.frame(x1, x2, y)
rm(y, x1, x2)

mpi.bcast.Robj2slave(mydat)

## Estimate an Ichimura single-index model with a continuous response.

t <- system.time(mpi.bcast.cmd(bw <- npindexbw(formula = y ~ x1 + x2,
                                               data = mydat),
                               caller.execute = TRUE))

summary(bw)

t <- t + system.time(mpi.bcast.cmd(model <- npindex(bws = bw,
                                                    gradients = TRUE),
                                   caller.execute = TRUE))

summary(model)

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

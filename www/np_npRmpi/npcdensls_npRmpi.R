## Manual-broadcast counterpart to npcdensls_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npcdensls_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

## Simulate correlated continuous data and broadcast the data frame.

library(MASS)

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

n <- 500

rho <- 0.25
mu <- c(0, 0)
Sigma <- matrix(c(1, rho, rho, 1), 2, 2)
draws <- mvrnorm(n = n, mu, Sigma)
mydat <- data.frame(x = draws[, 2], y = draws[, 1])

mpi.bcast.Robj2slave(mydat)

## Estimate f(y | x) using least-squares cross-validation.

t <- system.time(mpi.bcast.cmd(bw <- npcdensbw(y ~ x,
                                               bwmethod = "cv.ls",
                                               data = mydat),
                               caller.execute = TRUE))

summary(bw)

t <- t + system.time(mpi.bcast.cmd(model <- npcdens(bws = bw),
                                   caller.execute = TRUE))

summary(model)

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

## Manual-broadcast counterpart to npregllaic_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npregllaic_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

## Generate data and broadcast it to all slave nodes in the form of a
## data frame

set.seed(42)

n <- 1000

x <- runif(n)
z1 <- rbinom(n, 1, .5)
z2 <- rbinom(n, 1, .5)
y <- cos(2 * pi * x) + z1 + rnorm(n, sd = .25)
z1 <- factor(z1)
z2 <- factor(z2)
mydat <- data.frame(y, x, z1, z2)
rm(x, y, z1, z2)

mpi.bcast.Robj2slave(mydat)

## Estimate g(x) = E(Y | X = x) by local-linear AIC cross-validation.

t <- system.time(mpi.bcast.cmd(bw <- npregbw(y ~ x + z1 + z2,
                                             regtype = "ll",
                                             bwmethod = "cv.aic",
                                             data = mydat),
                               caller.execute = TRUE))

summary(bw)

t <- t + system.time(mpi.bcast.cmd(model <- npreg(bws = bw,
                                                  data = mydat),
                                   caller.execute = TRUE))

summary(model)

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

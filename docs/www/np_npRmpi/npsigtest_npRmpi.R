## Manual-broadcast counterpart to npsigtest_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npsigtest_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

## Significance testing with z irrelevant

n <- 500

z <- factor(rbinom(n, 1, .5))
x1 <- rnorm(n)
x2 <- runif(n, -2, 2)
y <- x1 + x2 + rnorm(n)
mydat <- data.frame(z, x1, x2, y)
rm(z, x1, x2, y)

mpi.bcast.Robj2slave(mydat)

t <- system.time(mpi.bcast.cmd(model <- npreg(y ~ z + x1 + x2,
                                              regtype = "ll",
                                              bwmethod = "cv.aic",
                                              data = mydat),
                               caller.execute = TRUE))

## Test whether the irrelevant factor z contributes to g(x).

t <- t + system.time(mpi.bcast.cmd(output <- npsigtest(model),
                               caller.execute = TRUE))

output

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

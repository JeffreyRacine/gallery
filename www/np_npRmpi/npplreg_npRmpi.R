## Manual-broadcast counterpart to npplreg_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npplreg_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

## Simulate linear X effects and a nonlinear Z effect, then broadcast them.

mpi.bcast.cmd(set.seed(42),
              caller.execute = TRUE)

n <- 1000

x1 <- rnorm(n)
x2 <- rbinom(n, 5, .3)

z1 <- rbinom(n, 2, .3)
z2 <- rnorm(n)

y <- 1 + x1 + x2 + z1 + sin(z2) + rnorm(n)

x2 <- ordered(x2)
z1 <- ordered(z1)

mpi.bcast.Robj2slave(x1)
mpi.bcast.Robj2slave(x2)
mpi.bcast.Robj2slave(z1)
mpi.bcast.Robj2slave(z2)
mpi.bcast.Robj2slave(y)

## Estimate E(Y | X, Z) = X^T beta + g(Z).

t <- system.time(mpi.bcast.cmd(bw <- npplregbw(formula = y ~ x1 + x2 | z1 + z2),
                               caller.execute = TRUE))

summary(bw)

t <- t + system.time(mpi.bcast.cmd(pl <- npplreg(bws = bw),
                                   caller.execute = TRUE))

summary(pl)

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

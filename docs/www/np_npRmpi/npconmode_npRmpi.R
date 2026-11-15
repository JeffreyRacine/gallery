## Manual-broadcast counterpart to npconmode_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npconmode_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

library(MASS)
data(birthwt)

birthwt$low <- factor(birthwt$low)
birthwt$smoke <- factor(birthwt$smoke)
birthwt$race <- factor(birthwt$race)
birthwt$ht <- factor(birthwt$ht)
birthwt$ui <- factor(birthwt$ui)
birthwt$ftv <- ordered(birthwt$ftv)

mpi.bcast.Robj2slave(birthwt)

## Fit the conditional-mode model directly on the workers and let
## npconmode() handle the internal bandwidth-selection step.
t <- system.time(mpi.bcast.cmd(model <- npconmode(low ~ smoke +
                                                   race +
                                                   ht +
                                                   ui +
                                                   ftv +
                                                   age +
                                                   lwt,
                                                   data = birthwt),
                               caller.execute = TRUE))

summary(model)

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

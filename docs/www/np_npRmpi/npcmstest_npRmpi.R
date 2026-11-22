## Manual-broadcast counterpart to npcmstest_serial.R.
## Place npRmpi's installed Rprofile in the working or home directory.
## Example: mpirun -np 2 R CMD BATCH npcmstest_npRmpi.R

## Initialize master and slaves.

mpi.bcast.cmd(np.mpi.initialize(),
              caller.execute = TRUE)

## Suppress progress messages in batch output; remove this line to retain them.

mpi.bcast.cmd(options(np.messages = FALSE),
              caller.execute = TRUE)

mpi.bcast.cmd(data("oecdpanel"),
              caller.execute = TRUE)

model_data <- transform(oecdpanel,
  oecd = factor(oecd),
  year = factor(year))

model <- lm(growth ~ oecd +
            year +
            initgdp +
            I(initgdp^2) +
            I(initgdp^3) +
            I(initgdp^4) +
            popgro +
            inv +
            humancap +
            I(humancap^2) +
            I(humancap^3) - 1,
            data = model_data,
            x = TRUE,
            y = TRUE)

X <- model_data[c("oecd", "year", "initgdp", "popgro", "inv", "humancap")]
y <- model_data$growth

mpi.bcast.Robj2slave(model)
mpi.bcast.Robj2slave(X)
mpi.bcast.Robj2slave(y)

## Loose search tolerances keep this comparison brief; use the defaults
## for substantive work.

t <- system.time(mpi.bcast.cmd(output <- npcmstest(model = model,
                                                   xdat = X,
                                                   ydat = y,
                                                   ftol = 0.01,
                                                   tol = 0.01),
                               caller.execute = TRUE))

output

cat("Elapsed time =", t[3], "\n")

## Stop the MPI workers cleanly.

mpi.bcast.cmd(mpi.quit(),
              caller.execute = TRUE)

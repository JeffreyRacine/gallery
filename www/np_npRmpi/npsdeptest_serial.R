## Serial counterpart to npsdeptest_npRmpi.R.
## The test results should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

set.seed(42)

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

n <- 500

yt <- ar.series(0.95, rnorm(n))

## Test the simulated series for serial dependence.

t <- system.time(output <- npsdeptest(yt,
                                      lag.num = 2,
                                      method = "summation"))

output

cat("Elapsed time =", t[3], "\n")

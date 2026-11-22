## Serial counterpart to npdeneqtest_npRmpi.R.
## The test results should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

## Draw two samples from the same reference density.

set.seed(42)

n <- 1000

sample.A <- data.frame(x = rnorm(n))
sample.B <- data.frame(x = rnorm(n))

## Test whether the two samples have the same density.

t <- system.time(output <- npdeneqtest(sample.A, sample.B))

output

cat("Elapsed time =", t[3], "\n")

## Serial counterpart to npudensml_npRmpi.R.
## The bandwidths should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

## Draw a sample from a standard normal density.

set.seed(42)

n <- 2500

mydat <- data.frame(x = rnorm(n))

## Select the bandwidth for f(x) by likelihood cross-validation.

t <- system.time(bw <- npudensbw(~x,
                                 bwmethod = "cv.ml",
                                 data = mydat))

summary(bw)

cat("Elapsed time =", t[3], "\n")

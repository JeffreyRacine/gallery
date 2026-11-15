## Serial counterpart to npindexich_npRmpi.R.
## The fitted objects should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

## Simulate a continuous-response single-index model.

set.seed(42)

n <- 2500

x1 <- runif(n, min = -1, max = 1)
x2 <- runif(n, min = -1, max = 1)
y <- x1 - x2 + rnorm(n)
mydat <- data.frame(x1, x2, y)
rm(y, x1, x2)

## Estimate an Ichimura single-index model with a continuous response.

t <- system.time(bw <- npindexbw(formula = y ~ x1 + x2,
                                 data = mydat))

summary(bw)

t <- t + system.time(model <- npindex(bws = bw,
                                      gradients = TRUE))

summary(model)

cat("Elapsed time =", t[3], "\n")

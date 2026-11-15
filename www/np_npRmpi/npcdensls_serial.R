## Serial counterpart to npcdensls_npRmpi.R.
## The fitted objects should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

library(MASS)

set.seed(42)

n <- 500

rho <- 0.25
mu <- c(0, 0)
Sigma <- matrix(c(1, rho, rho, 1), 2, 2)
draws <- mvrnorm(n = n, mu, Sigma)
mydat <- data.frame(x = draws[, 2], y = draws[, 1])

## Estimate f(y | x) using least-squares cross-validation.

t <- system.time(bw <- npcdensbw(y ~ x,
                                 bwmethod = "cv.ls",
                                 data = mydat))

summary(bw)

t <- t + system.time(model <- npcdens(bws = bw))

summary(model)

cat("Elapsed time =", t[3], "\n")

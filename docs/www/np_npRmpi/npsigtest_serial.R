## Serial counterpart to npsigtest_npRmpi.R.
## The test results should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

set.seed(42)

## Significance testing with z irrelevant

n <- 500

z <- factor(rbinom(n, 1, .5))
x1 <- rnorm(n)
x2 <- runif(n, -2, 2)
y <- x1 + x2 + rnorm(n)
mydat <- data.frame(z, x1, x2, y)
rm(z, x1, x2, y)

t <- system.time(model <- npreg(y ~ z + x1 + x2,
                                regtype = "ll",
                                bwmethod = "cv.aic",
                                data = mydat))


## Test whether the irrelevant factor z contributes to g(x).

t <- t + system.time(output <- npsigtest(model))

output

cat("Elapsed time =", t[3], "\n")

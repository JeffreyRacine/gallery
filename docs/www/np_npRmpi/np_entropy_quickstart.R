## Test whether two univariate samples have the same density.

library(np)
options(np.messages = FALSE)

## Generate two samples from the same reference distribution.
set.seed(1234)
n <- 300
x <- rnorm(n)
y <- rnorm(n)

## Run a compact first test without bootstrap overhead.
test_out <- npunitest(x, y, bootstrap = FALSE)

## Inspect the test summary.
summary(test_out)

## Minimal np entropy/testing example.
##
## This uses the univariate density-equality test because it is a
## compact, fast first run.

library(np)
options(np.messages = FALSE)

## Generate two simple samples so the test output is easy to interpret.
set.seed(1234)
n <- 300
x <- rnorm(n)
y <- rnorm(n)

## Run a compact first test without bootstrap overhead.
test_out <- npunitest(x, y, bootstrap = FALSE)

## Inspect the test summary.
summary(test_out)

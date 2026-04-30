## Minimal np entropy/testing example.
##
## This uses the univariate density-equality test because it is a
## compact, fast first run.

library(np)
options(np.messages = FALSE)

set.seed(1234)
n <- 300
x <- rnorm(n)
y <- rnorm(n)

test_out <- npunitest(x, y, bootstrap = FALSE)

summary(test_out)

## Minimal np smooth-probability example.
##
## This is a compact route for estimating a smooth probability function
## on unordered discrete support.

library(np)
options(np.messages = FALSE)

set.seed(42)
X <- factor(sample(0:2, 100, replace = TRUE, prob = c(0.25, 0.45, 0.30)))

fit <- npudens(~ X, ukertype = "aitchisonaitken", bwmethod = "cv.ml")

summary(fit)
tapply(fitted(fit), X, mean)

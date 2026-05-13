## This is the serial version of npconmode_npRmpi.R for comparison
## purposes. Study the differences between this file and its MPI
## counterpart for insight about your own problems.

library(np)
options(np.messages=FALSE)

library(MASS)
data(birthwt)

birthwt$low <- factor(birthwt$low)
birthwt$smoke <- factor(birthwt$smoke)
birthwt$race <- factor(birthwt$race)
birthwt$ht <- factor(birthwt$ht)
birthwt$ui <- factor(birthwt$ui)
birthwt$ftv <- ordered(birthwt$ftv)

## Fit the conditional-mode model directly and let npconmode()
## handle the internal bandwidth-selection step.
t <- system.time(model <- npconmode(low ~ smoke +
  race +
  ht +
  ui +
  ftv +
  age +
  lwt,
  data = birthwt))

summary(model)

cat("Elapsed time =", t[3], "\n")

## Serial counterpart to npconmode_npRmpi.R.
## The fitted objects should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

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

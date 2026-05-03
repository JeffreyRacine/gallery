## Minimal np smooth-resampling example.
##
## This draws a smooth resample from a fitted unconditional density by
## resampling observations and then drawing from the associated kernel.

library(np)
options(np.messages = FALSE)

set.seed(42)
data(faithful, package = "datasets")
dat <- faithful[seq_len(120), "waiting", drop = FALSE]

bw <- npudensbw(~ waiting, data = dat, bwmethod = "cv.ml")
fit <- npudens(bws = bw, data = dat)

n <- nrow(dat)
i_boot <- sample.int(n, size = n, replace = TRUE)
waiting_boot <- rnorm(n, mean = dat$waiting[i_boot], sd = bw$bw)
boot_dat <- data.frame(waiting = waiting_boot)
fit_boot <- npudens(bws = bw, data = boot_dat)

summary(fit)
summary(fit_boot)

rbind(
  original = quantile(dat$waiting, probs = c(0.1, 0.5, 0.9)),
  resample = quantile(waiting_boot, probs = c(0.1, 0.5, 0.9))
)

## Minimal np conditional-density resampling example.
##
## This draws a smooth resample from a fitted conditional density by
## resampling with x-kernel weights and then drawing from the
## corresponding Gaussian kernels.

library(np)
options(np.messages = FALSE)

set.seed(42)
data(faithful, package = "datasets")
dat <- faithful[seq_len(80), c("eruptions", "waiting")]

## Fit the original conditional density on a compact subsample.
bw <- npcdensbw(eruptions ~ waiting, data = dat, nmulti = 1)
fit <- npcdens(bws = bw, data = dat)

n <- nrow(dat)
y_boot <- numeric(n)
x_boot <- numeric(n)

## Resample with x-kernel weights, then jitter using the fitted bandwidths.
for (j in seq_len(n)) {
  p <- dnorm((dat$waiting[j] - dat$waiting) / bw$xbw[1])
  p <- p / sum(p)
  j_boot <- sample.int(n, size = 1, replace = TRUE, prob = p)
  y_boot[j] <- rnorm(1, mean = dat$eruptions[j_boot], sd = bw$ybw[1])
  x_boot[j] <- rnorm(1, mean = dat$waiting[j_boot], sd = bw$xbw[1])
}

## Refit the same conditional-density object on the smooth resample.
boot_dat <- data.frame(eruptions = y_boot, waiting = x_boot)
fit_boot <- npcdens(bws = bw, data = boot_dat)

## Compare the fitted objects and one simple dependence summary.
summary(fit)
summary(fit_boot)

c(original_cor = cor(dat$waiting, dat$eruptions),
  resample_cor = cor(boot_dat$waiting, boot_dat$eruptions))

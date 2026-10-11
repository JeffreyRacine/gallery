# Fan, Hsu, Lieli and Zhang (2022), JBES 40(1), 313-327.
# https://doi.org/10.1080/07350015.2020.1811102
# Research illustration: authors' simulated DGP, not the birth-weight application.
# Requires np and hdm. No package installation or hdcate dependency.
# Exp(1) weights are chosen explicitly: paper Assumption 4.1; hdcate's "bayes"
# option. They differ from the N(1,1) implementation illustrated in the paper.
# Reference checks and isolated repairs are documented in the accompanying
# README.md and reference_verification.zip; this script needs no hdcate package.
library(np)
library(hdm)
options(np.messages = FALSE)
out <- 'np_crossfit_cate_results'
dir.create(out, showWarnings = FALSE)
n <- 500L; p <- 100L; K <- 5L; B <- 1999L
at <- seq(-1, 1, by = .02)
seeds <- c(data=20261011L, folds=20261012L, nuisance=20261013L, multiplier=20261014L)

# Same draws and generator as microfan1/hdcate, pinned commit
# 76b084d99aa8c5dbeaafd3680bac7dfedd3a6a54, R/simulation_data.R (GPL >= 3).
set.seed(seeds['data'])
X <- matrix(rnorm(n*p), n, p)
epsilon <- rnorm(n)
index <- .5*rowSums(X[, (p-3):p])
probability <- exp(index)/(1+exp(index))
D <- ifelse(probability > runif(n), 1, 0)
Y <- D*(10 + rowSums(X[, 1:4]) + epsilon)
dat <- data.frame(Y, D, X)
# Y(0)=0, Y(1)=10+X1+...+X4+epsilon, so CATE conditional on X2 is 10+X2.
set.seed(seeds['folds'])
folds <- split(sample.int(n), rep(seq_len(K), each=n/K))
h <- 1.06*sd(dat$X2)*n^(-2/7) # Paper's full-sample undersmoothing rule.
y_formula <- reformulate(paste0('X', seq_len(p)), response='Y')
d_formula <- reformulate(paste0('X', seq_len(p)), response='D')
score <- propensity <- numeric(n)
fold_curves <- fold_variances <- matrix(NA_real_, length(at), K)

# The paper's cross-fitted estimate averages K held-out local-linear curves.
# Pooling all cross-fitted scores in one regression is a different finite-sample fit.
set.seed(seeds['nuisance'])
for (k in seq_len(K)) {
  message('Nuisance estimation and npreg, fold ', k, '/', K)
  held <- folds[[k]]; train <- dat[-held, ]; test <- dat[held, ]
  ps <- rlassologit(d_formula, data=train)
  untreated <- rlasso(y_formula, data=train[train$D == 0, ])
  treated <- rlasso(y_formula, data=train[train$D == 1, ])
  e <- as.numeric(predict(ps, test, type='response'))
  m0 <- as.numeric(predict(untreated, test)); m1 <- as.numeric(predict(treated, test))
  stopifnot(all(is.finite(e)), all(e > 0 & e < 1))
  propensity[held] <- e # No propensity clipping or trimming.
  score[held] <- m1-m0 + test$D*(test$Y-m1)/e - (1-test$D)*(test$Y-m0)/(1-e)
  fit <- npreg(txdat=test$X2, tydat=score[held], exdat=at, bws=h,
    regtype='ll', ckertype='gaussian', ckerorder=2, bwtype='fixed',
    bwscaling=FALSE, se=FALSE)
  fold_curves[, k] <- as.numeric(fitted(fit))
  w <- dnorm(outer(at, test$X2, '-')/h)
  f <- rowMeans(w)/h
  residuals <- sweep(matrix(score[held], length(at), length(held), byrow=TRUE),
                     1, fold_curves[, k], '-')
  fold_variances[, k] <- rowMeans(residuals^2*w^2)/(h*f^2)
}
estimate <- rowMeans(fold_curves)
# Average fold variances, then take square root: paper Section 3.3, p.19.
se <- sqrt(rowMeans(fold_variances)/(n*h))
stopifnot(all(is.finite(se)), all(se > 0))

# Explicit second-stage multiplier refits: random weights change BOTH the local
# design and score moments. Nuisance estimates and bandwidth remain fixed.
# Ordinary np SEs / plot bands are not this causal-inference construction.
set.seed(seeds['multiplier'])
weights <- t(matrix(rexp(B*n), B, n, byrow=TRUE))
bootstrap <- matrix(0, length(at), B)
for (k in seq_len(K)) {
  message('Positive multiplier refits, fold ', k, '/', K)
  held <- folds[[k]]
  u <- outer(at, dat$X2[held], function(a, x) (x-a)/h)
  w <- dnorm(u); xi <- weights[held, , drop=FALSE]
  s0 <- w %*% xi; s1 <- (w*u) %*% xi; s2 <- (w*u^2) %*% xi
  t0 <- w %*% (xi*score[held]); t1 <- (w*u) %*% (xi*score[held])
  determinant <- s0*s2-s1^2
  stopifnot(all(is.finite(determinant)), all(s0 > 0), all(determinant > 0))
  bootstrap <- bootstrap + (s2*t0-s1*t1)/determinant/K
}
stopifnot(all(is.finite(bootstrap))) # No omitted or redrawn multipliers.
maxima <- apply(abs(sweep(sweep(bootstrap, 1, estimate, '-'), 1, se, '/')), 2, max)
critical <- unname(quantile(maxima, .95))
curve <- data.frame(x=at, truth=10+at, estimate, se,
  point_lower=estimate-qnorm(.975)*se, point_upper=estimate+qnorm(.975)*se,
  simultaneous_lower=estimate-critical*se, simultaneous_upper=estimate+critical*se)
summary <- data.frame(n, p, K, B, bandwidth=h, multipliers='Exp(1)',
  grid_points=length(at), critical_95=critical,
  min_propensity=min(propensity), max_propensity=max(propensity))
print(summary, digits=10)
write.csv(curve, file.path(out, 'cate_curve.csv'), row.names=FALSE)
write.csv(summary, file.path(out, 'summary.csv'), row.names=FALSE)
saveRDS(list(data=dat, folds=folds, score=score, propensity=propensity, seeds=seeds,
  h=h, fold_curves=fold_curves, fold_variances=fold_variances, bootstrap=bootstrap,
  maxima=maxima, curve=curve, summary=summary), file.path(out, 'replication.rds'))
capture.output(sessionInfo(), file=file.path(out, 'sessionInfo.txt'))

png(file.path(out, 'crossfit_cate.png'), width=1600, height=1050, res=160)
par(mar=c(5.2, 4.8, 4.3, 1.2), las=1, bty='l', cex=.95)
plot(at, estimate, type='n', ylim=range(curve[, c('simultaneous_lower', 'simultaneous_upper')]),
  xlab=expression('Effect modifier '*X[2]), ylab='Conditional average treatment effect',
  main='Doubly robust CATE with cross-fitting',
  sub=sprintf('n = 500; 5 folds; 1,999 Exp(1) draws; 95%% grid critical value = %.3f', critical))
polygon(c(at, rev(at)), c(curve$simultaneous_lower, rev(curve$simultaneous_upper)),
        col='#dcecf7', border=NA)
lines(at, curve$point_lower, col='#4682a9', lty=3, lwd=1.5)
lines(at, curve$point_upper, col='#4682a9', lty=3, lwd=1.5)
lines(at, estimate, col='#145580', lwd=2.7)
lines(at, 10+at, col='#ad493b', lwd=2, lty=2)
legend('topleft', c('npreg final-stage estimate', 'Known CATE: 10 + X2',
  '95% pointwise intervals', '95% simultaneous grid band'),
  col=c('#145580', '#ad493b', '#4682a9', '#dcecf7'), lty=c(1, 2, 3, 1),
  lwd=c(2.7, 2, 1.5, 9), bty='n', cex=.87)
mtext('Fan-Hsu-Lieli-Zhang methodology; author-package simulation', side=3, line=.35, cex=.84)
dev.off()
# This one sample verifies arithmetic, not repeated-sampling coverage. Bands
# approximate uniform inference by a maximum on 101 fixed evaluation points.
# Identification still requires unconfoundedness and overlap; smoothing alone
# supplies neither. Nuisance-rate and undersmoothing conditions remain essential.

# Doubly robust CATE: reproducibility and reference verification

This accompanies the Gallery's [Doubly Robust Treatment Effects](../../../doubly_robust_cate.html) example. Source the standalone [np_crossfit_cate.R](np_crossfit_cate.R) in R or RStudio to generate the data, print the summary and display the figure. Results remain in the `cate_results` object, including `cate_results$curve` and `cate_results$summary`; no folders or output files are created. The script requires `np` and `hdm`. No patched reference package is needed to run that example.

## Method and choices

Reference: Fan, Hsu, Lieli and Zhang (2022), *Estimation of Conditional Average Treatment Effects with High-Dimensional Data*, JBES 40(1), 313–327, [DOI](https://doi.org/10.1080/07350015.2020.1811102). Page references use the [July 2021 preprint, version 5](https://arxiv.org/abs/1908.02399v5).

- Author-package simulation: n=500, 100 independent Gaussian covariates, five balanced random folds, and conditioning variable X2. The true CATE is 10+X2. Propensity and outcome functions use disjoint independent covariates in this generator, so this is a computational illustration rather than a confounding stress test. It is not the paper's empirical maternal-smoking replication.
- Keep the authors' `hdm::rlassologit` and `hdm::rlasso` nuisance fits, trained outside the fold supplying each score. All 100 covariates enter the nuisance formulas.
- Average five separate held-out local-linear curves, as in equation (3). A pooled regression of cross-fitted scores is a different finite-sample construction.
- Gaussian kernel and explicit paper bandwidth `1.06*sd(X2)*n^(-2/7)`, calculated on the full sample. The software's `bw.nrd0` default uses a different constant/scale. Folds are supplied explicitly rather than generated with the package's outcome-stratified `caret::createFolds` default.
- Average the fold variance estimates before taking a square root (Section 3.3, p.19); standard errors divide that sigma by `sqrt(n*h)`.
- Use 1,999 **Exp(1)** multiplier draws and weighted second-stage refits with fixed nuisances, folds and bandwidth. The same observation-level weights are shared across the 101 grid points, −1:1 by .02. This is not a fixed-covariance Gaussian-maximum simulation.
- Seeds: data 20261011; folds 20261012; nuisance fits 20261013; multipliers 20261014. No seed search was performed. The exponential choice was made after the Gaussian failure diagnosis below and is disclosed explicitly.

Cross-fitting and double robustness do not establish identification without unconfoundedness and overlap. Uniform inference also needs the paper's rate, regularity and undersmoothing conditions. Numerical agreement in this one sample is not repeated-sampling coverage evidence. The displayed polygon joins intervals for visualization; calibration uses a maximum on 101 fixed points.

## Verified result

| Quantity | Value |
|---|---:|
| Bandwidth | 0.186776439420311 |
| Two-sided 95% grid critical value | 2.85522462238 |
| Maximum np/reference fold-fit difference | 2.13e−14 |
| Maximum independently reconstructed sigma difference | 2.22e−15 |
| Maximum simultaneous-band endpoint difference | 1.24e−14 |
| Held-out fitted propensity range | [0.0138943, 0.9750913] |
| Failed or discarded exponential draws | 0 |

The known curve falls within the entire band in this sample. Download [curve values](cate_curve.csv), [summary](comparison_summary.csv), [fold comparisons](point_parity.csv), [weighted-fit checks](multiplier_draw_parity.csv) and [standalone checks](standalone_parity.csv).

## Reference repairs

The reference source is [microfan1/hdcate](https://github.com/microfan1/hdcate/tree/76b084d99aa8c5dbeaafd3680bac7dfedd3a6a54), pinned commit `76b084d99aa8c5dbeaafd3680bac7dfedd3a6a54`, version 0.1.0. The [patch](hdcate_repairs.patch) changes only `R/hdcate_r6_class.R`:

1. **Bandwidth indexing:** use `self$data` instead of unbound `data`, and pass the actual `subsample_idx` to the bandwidth routine. Numeric, rule-of-thumb and plug-in helper branches are checked; the worked example uses numeric h.
2. **Cross-fit variance:** replace the average of fold SDs with the square root of the average fold variances. A controlled pair of SDs 1 and 3 gives sqrt(5), compared with the original 2; the actual-data reconstruction is also checked.
3. **Two-sided bands:** use the already-computed absolute-maximum critical value at both endpoints. Previously the code copied the one-sided endpoints. A controlled four-draw example gives radius 18.5 at 95%, compared with original 2.85; multiple alpha values are checked.
4. **Failed draws:** stop at non-finite multiplier fits, identifying the draw and distribution, rather than allowing `quantile(..., na.rm=TRUE)` to remove them. The default multiplier distribution is unchanged; there is no automatic fallback.

Original and repaired method bodies were checked both from source and after installation from built tarballs. Full cross-fitted estimation, independent local-linear moments, variance and exponential-weight band calculations also agree. This is focused verification, not a comprehensive package audit or release qualification. No np, npRmpi or locpol implementation was modified, and no issue or PR has been submitted to the authors.

## Why select exponential weights explicitly?

Assumption 4.1 permits independent multipliers with mean 1, variance 1 and sub-exponential tails. Exp(1) meets these requirements. The illustrated uniform-band algorithm instead uses N(1,1). Negative Gaussian weights can make a local weighted least-squares objective indefinite, so its argmin does not exist in that draw. The positive-definite `locpol` solver returns missing fits in those cases.

For the fixed example and seeds above, Gaussian weights produced 379 invalid fold/grid/draw cells, involving 49 of 1,999 draws. After the first three repairs but before the failure guard, the reference's critical value was 4.37037092915; independent reconstruction matches it only after discarding those 49 draws. This conditions the resampling distribution on successful fits. Solving stationary equations at indefinite designs produces a different value, but is not a valid repair of the stated argmin. The final guard stops at Gaussian draw 20 instead. See the [retained diagnostic summary](normal_multiplier_diagnostic_summary.csv).

The package already implements unnormalized Exp(1) weights under its R6 `"bayes"` option:

```r
model$inference(sig_level=.05, boot_method="bayes", n_rep_boot=1999)
```

The exported `HDCATE.inference()` wrapper hard-codes normal weights, so the R6 call is necessary. The completed comparison selects exponential weights in both implementations, keeping the data, folds, bandwidth, nuisance fits and point estimates unchanged. Every exponential draw is retained. This choice is permitted by the general assumption, but differs from the specifically illustrated Gaussian algorithm. The smaller critical value is not evidence of better coverage; that requires a repeated-sampling study.

## Reproduce the reference checks

Download and extract [reference_verification.zip](reference_verification.zip). It contains unmodified upstream source, the isolated patched copy, built source tarballs, the retained hdm 0.3.2 tarball, validation scripts, numerical receipts and a SHA-256 manifest. It excludes installed libraries and large fitted objects. Package copyright and license files are retained with their sources. The source archive's SHA-256 is `ea562d3e9b572149649f0424147bd6e69447aee536fe4a6f0d2e94bcbbc40288`.

With `np`, `hdm` and `hdcate`'s other dependencies (`locpol`, `caret`, `R6`, `KernSmooth`) available, run inside the extracted `reference_verification` directory:

```sh
R_BIN="$(command -v R)" RSCRIPT_BIN="$(command -v Rscript)" bash scripts/reproduce.sh
```

This optional verification workflow installs the retained hdm and original/patched hdcate tarballs into bundle-local libraries, executes original/repaired source and installed witnesses, runs the repaired reference comparison, then runs and checks the standalone np script. The verification harness explicitly captures its in-memory results and plot in the bundle; ordinary use of the example creates no files. Temporary files and outputs also stay in the bundle. No system library is modified. The original-code witnesses expect the recorded defective behavior; a passing witness is not a claim that the original estimator is correct.

The original verification used R 4.6.1, np 0.80-1, hdm 0.3.2, locpol 0.9.0 and pinned hdcate 0.1.0. See [sessionInfo.txt](sessionInfo.txt). Matching these versions helps reproduce numerical receipts; the checks are not a guarantee for every future version. `R CMD build` and `R CMD INSTALL` were run; `R CMD check --as-cran` was not.

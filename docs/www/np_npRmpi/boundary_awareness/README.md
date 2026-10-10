# Density support illustrations

Reproducible examples for `np` 0.80-1, prepared October 10, 2026.
The [quickstart](../np_density_bounds_quickstart.R) generates the six seed-42
fits and `seed42_n250.png`. It uses only public package calls. Its comments
show how to save the plot. The other figures and CSV files summarize the
separate Monte Carlo experiment described below; sourcing the quickstart does
not launch that experiment.

The two main figures have matching panels, evaluation points, and axis limits:

- `seed42_n250.png`: **one sample**, n = 250, seed 42; one fit per curve.
- `mean100_n250.png`: **average of 100 simulations**, n = 250 per sample,
  seeds 42--141; pointwise averages of separately fitted densities.
- [mean100_curves_n250.csv](mean100_curves_n250.csv): the plotted average
  curves, truth, sample count, and shared panel limits. Conditional curves
  are evaluated at the population median of X, not at a sample-dependent X.

The average figure uses the retained Monte Carlo fits; samples are not pooled,
and there is no new bandwidth selection. It displays bias, not MISE: MISE
averages the squared-error integral of each separate fit and includes variance.

## Designs and estimation

| Design | Unconditional Y | Conditional X | Conditional Y given X = x | Fixed support on each continuous side |
|---|---|---|---|---|
| Proportion | Uniform(0,1) | Uniform(0,1) | Density 1 + 0.8(2x-1)(2y-1), 0 <= y <= 1 | [0,1] |
| Duration | Exponential, mean 1 | Exponential, mean 1 | Exponential, mean 1 + 0.5x | [0,Inf) |
| Gaussian | Normal(0,1) | Normal(0,1) | Normal(x,1) | (-Inf,Inf) |

All fits use second-order Gaussian kernels, fixed bandwidths, likelihood
cross-validation (`bwmethod = "cv.ml"`), and five optimizer multistarts.
Conditional fits use the default local-constant estimator with `proper = FALSE`.
There is no beta kernel, degree selection, clipping, or post-estimation
normalization. The ordinary specification omits support arguments; the other
uses the stated fixed bounds. Bandwidths are selected separately.

For each family/design/sample-size cell, n is 100 or 250 and there are 100
paired draws. This gives 1,200 pairs and 2,400 fits. Replication r uses sample
seed 41+r and optimizer seed 100041+r. Both `set.seed()` and `npseed()` are
reset before each optimizer call. R's RNG settings are Mersenne-Twister,
Inversion, and Rejection. The quickstart contains the exact sample-generation
calls for r = 1, including the inverse CDF for the conditional proportion.
Samples and optimizer seeds are shared within pairs. The displayed seed and
simulation design were specified before running the experiment.

## Loss and interpretation

Unconditional ISE is the integral of squared density error over the whole real
line. Conditional ISE is the population-X expectation of that Y integral.
Y has Lebesgue integration weights, and X has its population distribution
weights. Neither empirical extrema nor training observations define the loss
domain. The plotting grid is not used to approximate the loss by an unweighted
mean of squared errors.

Fixed-support fits are extended by zero outside their declared support for
plotting and scoring; public package predictions are taken inside the support.
No in-support values are changed. The ordinary estimator's leakage outside the
true support contributes to its loss. Average gains remain positive in every
finite-boundary cell when only in-support loss is counted.

- [summary.csv](summary.csv): cell means, percentage reductions, paired gains,
  Monte Carlo standard errors, win fractions, and integration diagnostics.
- [per_fit.csv](per_fit.csv): all 2,400 fitted-procedure loss records and
  numerical diagnostics. `ise` is the final loss used in the summary;
  the final conditional calculation uses 320 population-X quadrature nodes.
- [infinite_bounds_selectors.csv](infinite_bounds_selectors.csv): seed-42
  CVML/CVLS checks at both sample sizes, including the conditional CVLS warning.

Paired gain is ordinary ISE minus fixed-support ISE. Its Monte Carlo standard
error is the sample standard deviation of the 100 differences divided by 10.
These standard errors measure Monte Carlo uncertainty, not uncertainty in an
individual fitted density. Gaussian sign-based win fractions in the raw files
reflect rounding differences and should be treated as numerical ties.

The average fitted curves describe bias, whereas mean ISE includes variance.
Uniform Y is particularly favorable to a known-support estimator: a large
bandwidth approaches the exact uniform density. These examples do not imply
the same magnitude of gain for other densities or uncertain endpoints.

## Numerical checks

All 1,200 expected pairs completed, without warnings or failed main fits.
Public fitted values were checked against Gaussian-kernel algebra for all
2,400 fits; the largest absolute difference was below 7.53e-9. S3 `predict()`
replay matched the original predictions exactly. The algebra was used to
speed integration, not to replace the fitted estimator.

Ordinary-fit Y integrals use analytic Gaussian-mixture products over the full
real line. Bounded-fit integrals use composite Gauss-Legendre quadrature,
checked at orders 8 and 16, with panels no wider than one bandwidth or one
data unit. Exponential tail truncation has a retained squared-error remainder
bound of at most 1.27e-14.

Conditional X integration transforms Gauss-Legendre probability nodes through
the true X quantile function, targeting the whole probability interval (0,1).
There is no selected tail trimming. Orders 80, 160, and 320 were compared;
the largest change in a cell's mean ISE from 160 to 320 was 3.21e-6.
The worst-converging fit per design/sample-size/policy was also checked at 640.
Individual difficult Gaussian fits have larger integration variation; the two
Gaussian support specifications still coincide for this comparison.

At common bandwidths, fixed infinite bounds gave exactly the ordinary
predictions in all 400 Gaussian pairs. Independently selected CVML fits were
identical unconditionally and differed by at most 6.30e-8 conditionally.
Conditional CVLS is different: explicit infinite response bounds invoke a
finite quadrature surrogate and issue a warning. The two seed-42 probes gave
maximum prediction differences of 0.00593 and 0.00637. Omit support arguments
when there are no finite endpoints.

For these fixed-bandwidth LC conditional fits, a common query-centered
X-boundary normalization cancels from the conditional-density ratio. The
direct shape correction illustrated here acts on Y. Kernel-mass correction
does not itself enforce unit integral in the evaluation variable; no
`proper = TRUE` adjustment was applied.

## Provenance

The Monte Carlo used R 4.6.1 and np 0.80-1 built from source archive SHA-256
`917f895603ec195d6b9b7278a8338412baaa2c2d241a922dae0e284905bcdc90`.
The source archive, full simulation scripts, original samples, bandwidth
objects, and verification receipts are retained in the author's research
archive `lpdensity/boundary_awareness_illustrations_20261010`.
The Gallery quickstart was separately run against the installed np 0.80-1.
Changing the BLAS, platform, or optimizer implementation may change separately
optimized fits at numerical precision. These illustrations are not a package
release-qualification claim.

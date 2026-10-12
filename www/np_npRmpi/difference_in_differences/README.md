# Reproducibility and sensitivity: composition-robust DiD with np

The [standalone script](np_composition_did.R) is the reader-facing route. It
freshly estimates Gaussian local-constant `npconmode` propensities and Gaussian
local-linear `npreg` outcome regressions, selects every bandwidth, and prints
the four-outcome comparison. It requires only `np` and R's standard packages.
Run it with `source("np_composition_did.R")`; all results remain in `did_results`.

This is a same-data robustness check of the empirical application in
[Sant’Anna and Xu (2026)](https://doi.org/10.1016/j.jeconom.2025.106147),
*Difference-in-Differences with compositional changes*, Journal of Econometrics
253, 106147. The data originate in Sequeira (2016), *Corruption, trade costs,
and gains from tariff liberalization: Evidence from Southern Africa*, American
Economic Review 106(10), 3029–3063. The authors' [open manuscript](https://psantanna.com/files/DiD_CC.pdf)
and [reference repository](https://github.com/pedrohcgs/comp_did) describe the
underlying design and estimator.

## Data and computational choices

The data are read from `data/sequeira_bribes.rda` at upstream revision
`894bd65a952c30f01a4e0005efba4cb335065eb7`. The xz-compressed R object is downloaded
and decompressed entirely in memory. No upstream executable code or saved
nuisance arrays are loaded. The [author provenance record](author_provenance.json)
identifies the archived repository used in the investigation.

The script makes the archived correction `lba_value[2783] <- 0`, recodes
`monitor` and `psi`, creates `log(tonnage + 1)`, and uses the same complete-case
filter, including the clearing-agent and industry fields used by the original
application. The 1,084 retained row identities match the research example.
Treatment/time cell counts, ordered 11, 10, 01, 00, are 120, 56, 824, 84.
There are 131 four-digit HS-code clusters; the largest has 550 observations.

Each outcome has two continuous covariates scaled to [0,1] and nine unordered
factors. The continuous shipment measure varies with the outcome; the first two
outcomes share their entire predictor design and reuse one propensity fit.
The source lists the variables explicitly.

- Propensities use Gaussian LC conditional probabilities. `npcdensbw` selects
  separate predictor bandwidths and class-response smoothing by CVML, with two
  starts. Seeds are `852000 + 100 * design`, for designs 1, 3 and 4. Predictors
  use Li–Racine unordered kernels; the class response uses normalized
  Aitchison–Aitken smoothing. Each probability prediction deletes its own row
  while holding the selected bandwidths fixed.
- Outcome regressions use Gaussian LL fits, with one continuous bandwidth and
  one unordered bandwidth shared across all four cells. Pooled leave-one-out
  squared error chooses these parameters. The two declared starts are (0.8,0.8)
  and (0.35,0.25); Nelder–Mead works on log(h), logit(lambda), with maxit 250 and
  reltol 1e-7. The continuous parameter retains the original comparison's
  halfwidth units, so the public np bandwidth is h/sqrt(5). Undefined candidate
  objectives are recorded with a declared infeasibility value of 1e8; a final
  fit requires convergence and finite predictions. No failed final stage is
  replaced with another estimator.
- Probabilities are clipped to [0.01,0.99] without renormalizing, following the
  archived application. The unmodified raw probabilities are retained.
- The normalized composition-robust ATT and its influence contributions are
  calculated explicitly in R. The treated/post outcome regression cancels from
  this score, although its observations still enter the pooled bandwidth loss.
- Inference uses 9,999 Mammen cluster multipliers per outcome, seed 1234 and the
  original draw order. The interquartile range of the perturbations divided by
  the standard-normal interquartile range gives the clustered standard error.
  Bandwidths and nuisance estimates stay fixed. Reported intervals are normal
  95% intervals from that scale; no new finite-sample coverage claim follows.

## What changes relative to the authors' implementation?

The main propensity learner is a conditional class-probability estimator rather
than local multinomial-logit likelihood. It has a different bandwidth structure
and response-class smoothing. The continuous kernel is Gaussian, whereas the
reference application uses Epanechnikov. The outcome fits retain the shared
local-linear structure, with freshly selected bandwidths. The Gaussian choice
is an explicit robustness specification, not a restriction of np.

The archived reference's unordered kernel used distances between numeric labels
where the paper describes equality/mismatch weights. The isolated reference
comparison corrected that discrepancy; the original sources and published
results remain preserved. The np fits use their standard unordered kernels.
Numerical handling of locally singular regressions can differ as well.

All four main estimates have the published sign. Three differ by at most about
half the corresponding published clustered SE. The shipment-value estimate is
smaller and log-bribe significance changes. These are the disclosed differences
within the broad agreement; neither saved propensity values nor target ATT
values enter any bandwidth objective.

## Retained sensitivity comparisons

The main Gaussian specification was selected for illustration after a bounded
comparison. The [sensitivity table](sensitivity_table.md) reports all six paired
np estimator/kernel specifications and the explicitly added mixed-kernel arm.
[main_results.csv](main_results.csv) retains every score comparison, including
stage-isolation arms using published outcome bandwidths. Only rows with
`stage = fresh_outcomes` estimate both stages' bandwidths anew.

Shared-bandwidth Epanechnikov LC indicator regressions were closest to the
archived clipped propensity arrays among complete np families (mean RMSE
0.1454). Gaussian LC `npconmode` had RMSE 0.1874, but gave the more useful complete
ATT comparison. The archived arrays are a descriptive reference, not true
probabilities: matching them more closely does not ensure a closer ATT table.
See [propensity_ranking.csv](propensity_ranking.csv).

The paired Epanechnikov outcome fit for shipment value had eleven required
counterfactual predictions with zero total kernel weight, despite a converged
bandwidth selector. The Epanechnikov LC and LL conditional-probability selectors
failed for the tonnage predictor design with invalid raw objectives. Those
failures remain visible; no row was filled using a different kernel. The
separately declared mixed arm uses Epanechnikov LC indicator propensities and
Gaussian outcomes for all four rows; it completes but reverses the small
shipment-value point estimate.

An optimizer-only reference experiment changed the outer propensity search
from Nelder–Mead to BFGS, leaving the Epanechnikov kernel, inner local
multinomial fit, start and tolerances unchanged. Shipment value returned code 0;
its objective was slightly larger than the retained code-10 Nelder–Mead value.
The other two distinct designs reached the declared 30-minute limit. Thus BFGS
resolved that convergence code for one design, without establishing a general
solution or identifying the kernel as the cause. See [reference_BFGS.csv](reference_BFGS.csv).

The original 29-attempt ledger contains 24 raw zero exits, three statistical
failures and two timeouts. The [job ledger](job_status.csv) preserves all attempts.
The mixed-kernel arm combines already fitted components and adds no fit attempt.

## Numerical verification and records

The earlier research check passed 634 independent comparisons, with maximum
absolute discrepancy 4.32e-11. These include literal LC product-kernel sums,
selected full-rank weighted-QR predictions and the independent ATT/influence
calculation against the reference package. Twenty selected rank/conditioning
checks remain explicitly unproved; they are not counted as passes. See
[independent_checks.csv](independent_checks.csv). This is focused evidence for
the example, not package release qualification.

The Gallery script is additionally checked by fresh execution through the
ordinary installed np package, from an empty working directory. The
[standalone parity table](standalone_parity.csv) compares its row identities,
propensities, outcome predictions, outcome bandwidths, ATT and clustered SE
with the retained research run. The full refit took 132.6 seconds on the
verification workstation with one math-library thread. Maximum ATT and clustered
SE differences were 2.95e-9 and 8.38e-10; all checked nuisance differences were
below 1e-8, and the displayed four-decimal table is unchanged.
[comparison.csv](comparison.csv) contains its
numerical output; [sessionInfo.txt](sessionInfo.txt) records the environment.

The [research archive](research_archive.zip) retains the frozen full-nuisance
study and the preceding empirical comparison, including fit records, exact
source tarballs, original plans, code, full reports and SHA-256 manifests.
Its original host launchers and private-installation paths describe the
research environment; use the standalone Gallery script for the portable main
example. The archive supports inspection of the broader investigation without
making those host-specific workflows prerequisites for this example.

One original reference text log (job 28) was accidentally replaced by a partial
copy during early synchronization. The complete numerical RDS, timing,
convergence and raw zero-exit receipt remain independently retained. The
archived report identifies this provenance limitation. No other fit record was
overwritten, and the original numerical evidence is preserved unchanged here.

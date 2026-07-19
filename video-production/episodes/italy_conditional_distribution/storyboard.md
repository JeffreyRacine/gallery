# Italy Conditional-Distribution Short

Date: 2026-07-18
Status: camera, narration, silent animatic, and pronunciation approved;
scratch-only narrated master ready for Jeffrey review

## Contract

- Principal task: fit and plot the conditional distribution of Italian
  regional GDP across ordered year levels with `npcdist()`.
- Single takeaway: integrating a conditional density produces a conditional
  distribution; at each GDP value, the surface estimates the share at or below
  that value conditional on the ordered year.
- Public function: `npcdist()`.
- Canonical object: `fit_cdist`.
- Target duration: approximately 25 seconds.
- Proposed private Cove cue: `N P see dist`.
- Canonical future placement: **Examples -> Video Demos**, linked from a
  central relationship block on **Density, Distribution, Quantiles**.

## Installed-build proof

- Installed package: public CRAN `np` 0.70-5 from the campaign-local library.
- Dataset: bundled `Italy`, 1,008 observations for 21 regions across 48
  ordered year levels, 1951-1998.
- Randomness: none; no seed is needed.
- Five fresh installed runs including plotting: 3.046-3.655 seconds; median
  3.083 seconds.
- Exact parity across all five fresh runs for selected bandwidths, objective,
  and fitted conditional distributions.
- Selected ordered-year lambda: `0.6879269`.
- Selected continuous-GDP bandwidth: `0.3073657`.
- Objective: `0.08860405`.
- Unexpected warnings/errors: none.

## Exact script

```r
library(np)
data(Italy, package = "np")

class(Italy$year)
fit_cdist <- npcdist(gdp ~ year, data = Italy)
summary(fit_cdist$bws)
plot(fit_cdist, view = "fixed", theta = 90, phi = 45)
```

## Camera recommendation

The 3 x 3 installed-fit study covers theta 70/80/90 and phi 35/45/55. The
recommended fixed base-renderer camera is 90/45. It matches the approved
conditional-density episode, keeps the CDF rise legible, and makes the pair
feel like two views of the same fitted distributional structure. The surface
does not rotate.

## Storyboard

| Time | Visual | On-screen code/message | Purpose |
|---|---|---|---|
| 0.0-2.5 s | Finished fixed CDF surface at 90/45 | “Density accumulated” | Lead with the result and relationship |
| 2.2-4.5 s | Actual full RStudio window | Source, Console, and Plot panes | Preserve the approved interface grammar |
| 4.2-8.0 s | Ordered-year and data emphasis | `class(Italy$year)` -> `ordered/factor` | Preserve the data-type point |
| 7.7-12.0 s | Fit line emphasis | `fit_cdist <- npcdist(gdp ~ year, data = Italy)` | Show the one-call workflow |
| 11.7-15.0 s | Compact bandwidth summary | ordered lambda and GDP bandwidth | Connect the estimator to mixed-type smoothing |
| 14.7-19.5 s | Fixed surface close-up with a vertical CDF reading cue | “Share at or below this GDP value” | Explain what the CDF surface means |
| 19.2-22.0 s | Return to the actual full RStudio window | fitted plot visible | Re-establish the real environment |
| 21.7-25.0 s | Series outro | `npcdist()` · Gallery -> Examples -> Video Demos | Leave the function and canonical route |

## Narration draft

> Integrating the conditional density produces the conditional distribution.
> Here, for each ordered year, the surface gives the estimated share of Italian
> regions with per-capita GDP at or below each value. One `npcdist()` call
> estimates the whole conditional distribution. Invert the conditional
> distribution at a chosen probability and you obtain a conditional quantile. The full
> script is on Gallery Video Demos.

Public text keeps `npcdist()`; only the private voice prompt substitutes
`N P see dist`.

## Risks and review points

- The CDF surface is inherently less dramatic than the density surface; the
  narration and one reading cue must make its meaning immediate.
- The axis label is “Conditional Distribution”; do not describe the surface as
  a density or as a probability at a point.
- The inversion bridge belongs in plain language here; the exact
  definition belongs on the linked method page.
- “Integrating the conditional density” states a population identity. The
  Video Demos description and linked method block must make clear that
  `npcdens()` and `npcdist()` perform separate, target-specific bandwidth
  selection; integrating the fitted density need not reproduce the directly
  estimated distribution.
- The 90/45 camera and narration were approved on 2026-07-18.
- The silent animatic and private `N P see dist` pronunciation probe were
  approved on 2026-07-18. The complete continuous Cove take is now assembled
  over the unchanged visual stream for narrated review.

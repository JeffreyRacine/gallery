# Italy Conditional-Quantile Short

Date: 2026-07-18
Status: installed script and default plot proved; storyboard, narration,
supporting-description scope, and pronunciation rule approved; complete
narration capture authorized

## Contract

- Principal task: extract and plot the 25th, 50th, and 75th conditional
  quantiles of Italian regional GDP with `npqreg()`.
- Single takeaway: a conditional quantile is the generalized inverse of the
  conditional distribution at a chosen probability `tau`.
- Public function: `npqreg()`.
- Canonical object: `fit_qreg`.
- Target duration: approximately 25 seconds.
- Approved private Cove rule: say N, P, and Q as three letters, then say `reg`
  as one syllable that rhymes exactly with `egg` and ends in a hard `g`.
- Canonical future placement: **Examples -> Video Demos**, immediately after
  the matched `npcdist()` episode.

## Installed-build proof

- Installed package: public CRAN `np` 0.70-5 from the campaign-local library.
- Dataset: bundled `Italy`, 1,008 observations for 21 regions across 48
  ordered year levels, 1951-1998.
- Requested probabilities: `0.25`, `0.50`, and `0.75`.
- Randomness: none; no seed is needed.
- Five fresh installed runs including plotting: 2.910-3.521 seconds; median
  2.921 seconds.
- Exact parity across all five fresh runs for selected bandwidths, objective,
  and the 1,008 x 3 fitted-quantile matrix.
- The selected `xbw`, `ybw`, and objective exactly match the proved
  `npcdist()` fit because `npqreg()` selects and inverts that conditional
  distribution estimator.
- Unexpected warnings/errors: none.

## Exact script

```r
library(np)
data(Italy, package = "np")

class(Italy$year)
fit_qreg <- npqreg(gdp ~ year,
                   data = Italy,
                   tau = c(0.25, 0.50, 0.75))
summary(fit_qreg$bws)
plot(fit_qreg)
```

## Storyboard

| Time | Visual | On-screen code/message | Purpose |
|---|---|---|---|
| 0.0-2.5 s | Finished three-quantile plot | “Three probabilities, three conditional quantiles” | Lead with the result |
| 2.2-4.5 s | Actual full RStudio window | Source, Console, and Plot panes | Preserve the approved interface grammar |
| 4.2-7.5 s | `tau` vector emphasis | `tau = c(0.25, 0.50, 0.75)` | Establish the requested probabilities |
| 7.2-12.0 s | Fit line emphasis | `fit_qreg <- npqreg(...)` | Show the one-call inverse-CDF workflow |
| 11.7-15.3 s | Plain-language relationship card | “Choose tau -> invert the fitted conditional distribution” | Explain direct inversion without crowding the short with equations |
| 15.0-19.7 s | Plot close-up with line-style labels | 25th · 50th · 75th | Read the lower, middle, and upper distribution |
| 19.4-22.0 s | Return to the actual full RStudio window | complete quantile plot visible | Re-establish the real environment |
| 21.7-25.0 s | Series outro | `npqreg()` · Gallery -> Examples -> Video Demos | Leave the function and canonical route |

## Narration draft

> Choose a probability, tau, and invert the fitted conditional distribution.
> The result is the GDP value where that distribution reaches tau. Here, one
> `npqreg()` call directly traces the 25th, 50th, and 75th conditional
> quantiles across Italy's ordered years. The curves show the lower, middle,
> and upper parts of the distribution. The full script is on Gallery Video
> Demos.

Public text keeps `npqreg()`; the private voice prompt uses `N P Q-reg` with
the approved rule that `reg` rhymes exactly with `egg`.

## Gallery description distinction

Keep the short itself to direct conditional-distribution inversion. The entry
description and linked method block state that `npqreg()` is the
distribution-based route: it selects bandwidths for the conditional-
distribution target, estimates that distribution, and then inverts it at the
requested tau values using the generalized-inverse definition. `nplsqreg()` is
a distinct, regression-based location-scale quantile method. Do not suggest
that the two methods estimate quantiles through the same object or criterion.

## Risks and review points

- The default plot includes 48 boxplots and three quantile curves. It is
  information-rich but remains legible at 1920 x 1080; the embedded-size frame
  needs explicit review.
- The video should say “invert the conditional distribution,” while the linked page
  supplies the generalized-inverse definition and its continuous-CDF identity.
- The mean relationship and the contrast with `nplsqreg()` belong in the
  description/linked method block, not as second tasks inside this short.

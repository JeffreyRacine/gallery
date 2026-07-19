# Italy Ordered-Factor And Numeric Gradients Review Packet

Status: retained review packet documenting the scratch-only approval state.
The installed proof, uninterrupted Cove narration, aligned captions, and
narrated review were subsequently approved for Gallery publication.

## Recommended episode

**Title:** Variable type determines smoothing and gradients

**Single takeaway:** Give a predictor the R class that represents its
statistical meaning. `np` then recognizes the type and automatically carries it
through kernel choice, cross-validation, plotting, and gradient interpretation.

The paired Italy example is unusually effective because the displayed year
values and response data are unchanged. Only the representation of `year`
changes: the bundled `Italy$year` is an ordered factor, while `italy_numeric`
stores the same years as numeric values.

## Exact candidate script

```r
library(np)
data(Italy, package = "np")

# The bundled data correctly stores year as an ordered factor.
class(Italy$year)

# Re-express the same displayed years as numeric for comparison.
italy_numeric <- transform(
  Italy,
  year = as.numeric(as.character(year))
)
class(italy_numeric$year)

fit_ordered <- npreg(gdp ~ year, data = Italy)
fit_numeric <- npreg(gdp ~ year, data = italy_numeric)

summary(fit_ordered$bws)
summary(fit_numeric$bws)

options(plot.par.mfrow = FALSE)
par(mfrow = c(2, 2))

plot(fit_ordered,
     main = "Ordered year: fitted mean",
     xlab = "Year", ylab = "GDP")
plot(fit_numeric,
     main = "Numeric year: fitted mean",
     xlab = "Year", ylab = "GDP")
plot(fit_ordered, gradients = TRUE,
     main = "Ordered year: finite difference",
     xlab = "Year")
plot(fit_numeric, gradients = TRUE,
     main = "Numeric year: derivative",
     xlab = "Year")
```

The two gradient calls deliberately omit `ylab`. The installed plotting method
therefore supplies the statistically meaningful labels
`Delta gdp / Delta year` and `d gdp / d year`; labelling both lower panels
merely `GDP` would conceal the contrast.

No seed is required: the data, bandwidth selection, fitted values, gradients,
and plot are deterministic in the verified public build.

## Installed-build proof

- Host: M2Studio, Apple Silicon, macOS Tahoe 26.5.2.
- R: 4.6.1, arm64.
- BLAS: Apple Accelerate.
- Package: public CRAN `np` 0.70-5 in the campaign-local library.
- Dataset: `np::Italy`, 1,008 observations.
- Bundled class: `ordered` / `factor`.
- Comparison class: `numeric`; the displayed year values are identical.
- Ordered fit: Li–Racine ordered kernel, cross-validated categorical smoothing
  parameter `lambda = 0.7046791824993954`.
- Numeric fit: second-order Gaussian continuous kernel, cross-validated
  bandwidth `h = 3.33748801545691`.
- Ordered gradient: adjacent ordered-level fitted difference. At the first
  level, the package uses the available neighboring level.
- Numeric gradient: analytic derivative of the continuously smoothed
  regression estimator.
- Five installed repetitions: ordered fit 0.066--0.071 seconds; numeric fit
  0.121--0.130 seconds.
- Bandwidths, fitted values, and gradients were exactly identical across all
  five repetitions; all five PNGs were byte-identical.
- No unexpected warnings, messages, errors, or graphics failures occurred.

## Narrated 25-second storyboard

| Time | Frame | Purpose |
|---:|---|---|
| 0.0--2.9 | Finished four-panel result | Show the visible destination immediately. |
| 2.6--5.7 | Full RStudio context | Establish that this is an ordinary installed workflow. |
| 5.3--9.4 | Ordered-factor and numeric class cards | Isolate the one user decision: represent the variable correctly. |
| 9.1--14.1 | Two-column propagation map | Show class → kernel → cross-validation → plot → gradient. |
| 13.8--16.8 | Upper fitted-mean panels | Contrast level-specific and continuously smoothed fits. |
| 16.4--19.9 | Lower gradient panels | Contrast adjacent-level Delta and analytic derivative. |
| 19.6--22.3 | Full RStudio return | End with the complete reproducible experience. |
| 22.0--25.2 | Function and Gallery route | Close on `npreg()` and Examples → Video Demos. |

The computation is fast enough to show honestly. No condensation label is
needed.

## Narration draft (59 words)

> Give a predictor its correct R class, and np carries that meaning through the
> analysis. With year ordered, cross-validation tunes a discrete Li–Racine
> kernel; the fitted values are level-specific, and Delta is an adjacent-level
> difference. With year numeric, it tunes a continuous Gaussian kernel and
> returns an analytic derivative. Give the variable the right class; np handles
> the rest.

Private Cove cues:

- `np`: “enn pee.”
- Li–Racine: “Lee Ruh-seen.”
- Begin immediately with “Give”; no pre-roll, restart, or warm-up sound.

## Proposed Gallery description

The bundled `Italy` data stores `year` as an ordered factor. `npreg()` therefore
recognizes an ordered categorical predictor, uses the Li–Racine ordered kernel,
and cross-validates its categorical smoothing parameter. Its fitted plot is
level-specific, and its gradient is a finite difference between adjacent
ordered levels.

The comparison data frame contains the same displayed years stored as numeric
values. Without any estimator switch, `npreg()` recognizes a continuous
predictor, uses a second-order Gaussian kernel, cross-validates a continuous
bandwidth, draws a smooth fitted curve, and computes an analytic derivative.
The two analyses answer different questions: the appropriate representation is
determined by the meaning of the predictor, not by which plot looks smoother.

This automatic type propagation extends beyond this example: once variables
are represented correctly, the relevant `np` methods carry their types into
kernel construction, data-driven smoothing selection, estimation, prediction,
plotting, gradients, and uncertainty calculations where supported. The linked
books and papers provide the full kernel and cross-validation treatment.

## Review risks and choices

- The phrase “categorical gradient” is technically broad; this episode is
  specifically about an **ordered** categorical predictor and its adjacent-level
  finite difference.
- The categorical smoothing parameter `lambda` and continuous bandwidth `h`
  are on different scales and should not be compared numerically. The page can
  report both, but the narration should not invite a magnitude comparison.
- Converting `year` to numeric is pedagogical here. It does not imply that
  ordered factors should generally be coerced to numeric; users must choose the
  class that matches the variable's meaning.
- The proposed narration deliberately omits bandwidth values, kernel formulas,
  and optimizer details to preserve the short's one takeaway.

## Review gate

Jeffrey approved the exact script, class-propagation visual, 59-word narration,
and the terminology “adjacent-level difference” versus “analytic derivative.”
He then approved the narrated review and explicitly authorized the Gallery
production tranche, commit, and push on 2026-07-19.

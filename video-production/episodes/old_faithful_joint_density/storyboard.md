# Old Faithful Joint-Density Short

Date: 2026-07-18
Status: script, visual grammar, narration, captions, and publication approved

## Contract

- Principal task: estimate and explore the bivariate joint density of eruption
  duration and waiting time with `npudens()`.
- Single takeaway: target-specific smoothing reveals two distinct eruption
  cycles, and the surface is interactive in RStudio's Viewer.
- Public function: `npudens()`.
- Canonical object: `fit_udens`.
- Duration: 27 seconds.
- Private Cove cue: `N P U dense`.
- Placement: **Examples -> Video Demos**.

## Exact script

```r
library(np)
data(faithful, package = "datasets")

fit_udens <- npudens(~ eruptions + waiting, data = faithful)
summary(fit_udens$bws)
plot(fit_udens, renderer = "rgl")
```

## Storyboard

| Stage | Visual | Purpose |
|---|---|---|
| Result | Finished two-peak surface | Lead with the recognizable result |
| Context | Actual full RStudio window | Establish the working environment |
| Data | 272 observations and two numeric variables | Explain the compact input |
| Fit | `npudens()` and bandwidth summary | Show target-specific smoothing |
| Viewer | Large interactive surface | Demonstrate rotate, zoom, and resize |
| Return | Full RStudio window | Re-establish the real interface |
| Outro | Function and Gallery route | Make reproduction immediate |

The retained narration is one uninterrupted Cove response. There is no
word-level splice or time-stretched speech.

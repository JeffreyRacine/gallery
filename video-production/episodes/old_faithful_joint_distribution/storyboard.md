# Old Faithful Joint-Distribution Short

Date: 2026-07-18
Status: script, corrected hybrid frame, visual grammar, narration, captions,
and publication approved

## Contract

- Principal task: estimate and explore the bivariate joint distribution of
  eruption duration and waiting time with `npudist()`.
- Single takeaway: the cumulative surface is estimated directly with
  target-specific smoothing and is interactive in RStudio's Viewer.
- Public function: `npudist()`.
- Canonical object: `fit_udist`.
- Duration: 29 seconds.
- Private Cove cue: `N P U dist`.
- Placement: **Examples -> Video Demos**.

## Exact script

```r
library(np)
data(faithful, package = "datasets")

fit_udist <- npudist(~ eruptions + waiting, data = faithful)
summary(fit_udist$bws)
plot(fit_udist, renderer = "rgl")
```

## Storyboard

| Stage | Visual | Purpose |
|---|---|---|
| Result | Finished cumulative surface | Lead with the recognizable result |
| Context | Corrected full RStudio hybrid | Keep stylized code inside its own stage |
| Data | Same 272 observations | Link the density/distribution pair |
| Fit | `npudist()` and bandwidth summary | Show target-specific smoothing |
| Viewer | Large interactive surface | Demonstrate rotate, zoom, and resize |
| Return | Full RStudio window | Re-establish the real interface |
| Outro | Function and Gallery route | Make reproduction immediate |

The retained narration is one uninterrupted Cove response. There is no
word-level splice or time-stretched speech.

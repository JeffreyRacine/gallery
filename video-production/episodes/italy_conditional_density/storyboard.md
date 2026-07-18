# Italy Conditional-Density Short

Date: 2026-07-18
Status: silent grammar and pronunciation approved; narrated review cut prepared;
not a Gallery promotion candidate

## Contract

- Principal task: fit and plot the conditional density of regional Italian GDP
  across ordered year levels with `npcdens()`.
- Single takeaway: a conditional density reveals the evolution from a mainly
  unimodal postwar distribution toward a pronounced two-peak distribution,
  rather than reducing the relationship to an average.
- Public function: `npcdens()`.
- Canonical object: `fit_cdens`.
- Target duration: approximately 25 seconds.
- Canonical future placement: **Examples -> Video Demos**, linked from
  **Density, Distribution, Quantiles**.

## Installed-build proof

- Installed package: public CRAN `np` 0.70-5 from the campaign-local library.
- Dataset: bundled `Italy`, 1,008 observations for 21 regions across 48 years,
  1951-1998.
- Data classes: `gdp` numeric; `year` is pre-cast `ordered/factor`.
- Randomness: none; no seed is needed.
- Five fresh installed runs including plotting: 2.733-2.765 seconds; median
  2.745 seconds.
- Exact parity across all five runs:
  - ordered-year lambda: `0.6135078`;
  - GDP bandwidth: `0.5708786`;
  - objective: `-2643.904`.
- Unexpected warnings/errors: none; every run ended in `PROOF_OK`.

## Exact script

Source: `analysis.R`

```r
library(np)
data(Italy, package = "np")

class(Italy$year)
fit_cdens <- npcdens(gdp ~ year, data = Italy)
summary(fit_cdens$bws)
plot(fit_cdens, view = "fixed", theta = 90, phi = 45)
```

Jeffrey approved the fixed `theta = 90`, `phi = 45` camera on 2026-07-18.

## Camera study

The first 3 x 3 contact sheet covers theta 70/80/90 and phi 35/45/55:

- `proof/italy_cdens_fixed_angle_contact_sheet.png`

The refined sheet covers theta 85/90/95 and phi 40/45/50:

- `proof/italy_cdens_fixed_angle_refinement.png`

Approved camera: `theta = 90`, `phi = 45`. Relative to 80/45, the conditional
density axis separates more cleanly from the surface while the later second
ridge remains prominent. The video uses one fixed perspective throughout; the
multi-angle sheets remain diagnostic evidence only.

## Storyboard

| Time | Visual | On-screen code/message | Purpose |
|---|---|---|---|
| 0.0-2.5 s | Finished fixed-renderer surface at the reviewed angle | “From one peak to two” | Lead with the substantive result |
| 2.2-4.5 s | Actual full RStudio window | Source, Console, and Plot panes visible | Preserve the approved environment grammar |
| 4.2-8.0 s | Controlled Source-pane emphasis | `data(Italy)` and `class(Italy$year)` | Establish the bundled panel and ordered-factor fact |
| 7.7-12.0 s | Fit line in Source/Console | `fit_cdens <- npcdens(gdp ~ year, data = Italy)` | Show the one-call estimator workflow |
| 11.7-15.0 s | Plot line and compact summary emphasis | ordered lambda and continuous GDP bandwidth | Show that both variable types receive appropriate smoothing |
| 14.7-19.2 s | Surface close-up, with early and later ordered levels indicated without color-only encoding | “Observed ordered year levels” | Make the distributional change legible and avoid continuous-time language |
| 18.9-21.5 s | Return to actual full RStudio window and fitted plot | no unrelated UI | Re-establish the real working environment |
| 21.2-25.0 s | Restrained series outro | `npcdens()` · Gallery -> Examples -> Video Demos | Leave the public function and canonical route |

## Narration draft

Source: `narration/public.txt` (59 words).

> Per-capita GDP across 21 Italian regions begins mainly unimodal after the
> war. Here, year is an ordered factor, so `npcdens()` smooths across observed
> year levels. Across later years, two clear peaks emerge, corresponding to the
> wealthier North and less wealthy South. One call reveals the whole conditional
> density, not merely an average. The full script is on Gallery Video Demos.

The phrase “corresponding to” describes the substantive regional split without
claiming that the estimator identifies a causal mechanism.

## Frame sketches

- First frame: the full surface at the reviewed fixed angle, large enough for
  both ridges to read at embedded size; concise text label above the plot.
- Type frame: `year` shown explicitly as `ordered/factor`, paired with the text
  “48 observed ordered levels.”
- Fit frame: only the canonical `fit_cdens <- npcdens(...)` line is emphasized.
- Result frame: paired labels or arrows for early and later ordered levels;
  never rely on surface color alone.
- Final frame: `npcdens()` on the left and **Gallery -> Examples -> Video
  Demos** on the right, matching Candidate A's corrected grammar.

## Risks and review points

- The approved perspective is fixed at 90/45; do not rotate it or substitute
  an interactive renderer in this episode.
- Base `persp` year and density labels can overlap at some angles. The final
  frame crop and text scale need embedded-size review.
- `year` must always be described as an ordered factor or ordered year levels,
  not a continuous-time covariate.
- Cove's private production cue is `N P see dense`; public text always remains
  `npcdens()`. Run the short cue in context before the full narration take.
- The North/South interpretation is descriptive, not causal.
- The installed fit is fast enough to show honestly; no computation
  condensation is currently necessary.

## Review artifacts

- Silent video: `review/silent-animatic.mp4`
- Narrated video: `review/narrated-prototype.mp4`
- Contact sheet: `review/contact-sheet.png`
- Duration: exactly 25.000 seconds at 1920 x 1080 and 30 fps.
- Motion grammar: restrained 0.35-second dissolves between static frames; the
  approved 90/45 surface never rotates.
- Actual-interface grammar: the animatic uses a fresh Italy-specific RStudio
  capture before and after the controlled close-ups.
- Narration: one continuous Cove response, microphone muted, trimmed to 24.02
  seconds, normalized to -16.5 LUFS integrated with -1.5 dBTP true peak, and
  padded with silence through the 25-second outro.
- Pronunciation retake: private `you knee modal` cue corrects only the spoken
  `unimodal`; the public script, captions, and transcript remain unchanged.
- Review boundary: Jeffrey approved the pronunciation probe and silent visual;
  the complete narrated cut still requires listening review before promotion.

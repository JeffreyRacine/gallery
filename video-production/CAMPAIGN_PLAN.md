# Gallery onboarding and analytical-video campaign

Last updated: 2026-07-18
Status: Candidate A is the approved template; the Italy conditional-density
narrated prototype is approved; the conditional-distribution camera,
narration, quantile visual, and linked mathematical block are approved. No
Gallery push or Italy public promotion is authorized.

## Product path

The mandatory newcomer path remains:

1. install R and then RStudio;
2. install `np` and obtain a fast first result;
3. import and correctly classify the user's own mixed-type data.

Optimized BLAS and `npRmpi` session mode are optional only after the serial
baseline succeeds.

The canonical video library is **Examples -> Video Demos**, beside
**Interactive Demos**. Entries are collapsed by default. Start Here and method
pages link to canonical entries instead of duplicating full players.

## Approved episode grammar

Candidate A established the standing visual template:

1. show the finished result immediately;
2. establish the actual full RStudio interface;
3. use controlled close-ups for legibility;
4. return to the full RStudio window near the end;
5. finish with the public function and **Gallery -> Examples -> Video Demos**.

Use restrained 0.35-second dissolves. Code, summary values, axes, and captions
must remain legible at the embedded size. Do not rely on color alone.

Use the built-in Cove voice with a private phonetic prompt and a public text
source. Public code, captions, transcript, and Gallery prose always use actual
function spelling. The microphone remains muted during system-audio capture.
The private cue for `unimodal` is `you knee modal`, spoken smoothly as
“you-knee-modal”; the public word remains `unimodal`.

Seeds are included only when an episode invokes randomness. The standing seed
is `set.seed(42)`. Deterministic bundled-data episodes omit a seed.

## Distributional Italy sequence

The first analytical iteration deliberately broadens the series beyond
regression:

1. conditional density with `npcdens()`;
2. conditional distribution with `npcdist()`;
3. conditional quantiles with `npqreg()`.

For density and distribution, `Italy$year` is already an ordered factor. It is
described as 48 observed ordered year levels, never as a continuously measured
time covariate. The substantive pattern is a mainly unimodal postwar regional
GDP distribution evolving toward two peaks corresponding to the wealthier
North and less wealthy South; this is descriptive, not causal.

The conditional-density episode uses:

```r
fit_cdens <- npcdens(gdp ~ year, data = Italy)
plot(fit_cdens, view = "fixed", theta = 90, phi = 45)
```

The fixed base renderer is intentional. Base `theta`/`phi` values do not map to
`rgl` camera angles, and the approved 90/45 surface must never be presented as
repeated rotation. The private Cove cue for `npcdens()` is `N P see dense`.

The matched distribution/quantile pair should make the underlying relationships
explicit without overloading either short:

1. integrating $f(y\mid x)$ gives $F(y\mid x)$;
2. $q_\tau(x)=\inf\{y:F(y\mid x)\geq\tau\}$ inverts the conditional
   distribution at probability $\tau$; and
3. the regression function is the conditional-density-weighted mean,
   $E[Y\mid X=x]=\int y f(y\mid x)\,dy$.

The two videos use the first two relationships in plain language. A compact
**How the four targets connect** block on **Density, Distribution, Quantiles**
is the approved mathematical source of truth, linked from Video Demos. For a
continuous conditional distribution at the requested quantile, it may also
state $F(q_\tau(x)\mid x)=\tau$; the generalized inverse remains the standing
definition for distributions with jumps or flat regions.

For the conditional-distribution episode, the approved camera is the fixed
base renderer at `theta = 90`, `phi = 45`; the approved private Cove cue is
`N P see dist`; and the narration says, “Invert the conditional distribution
at a chosen probability and you obtain a conditional quantile.” The
conditional-quantile episode uses the installed default `npqreg()` plot with
the 25th, 50th, and 75th conditional-quantile curves over the observed
per-year boxplots.

## Balanced catalogue after the Italy iteration

Subsequent independently reviewable episodes should cover:

- automatic local-polynomial mixed-data regression with joint degree,
  bandwidth, and categorical-lambda selection;
- conditional density/distribution families and conditional quantiles;
- gradients, distinguishing derivatives from Delta-labelled categorical
  finite differences;
- pointwise, simultaneous, and Bonferroni bootstrap bands;
- significance testing with the correct non-causal null interpretation;
- serial `np` and `npRmpi` session-mode parity, honest repeated timing, and
  clean teardown;
- a deliberate mix of fixed/base and `rgl` rendering where each is clearest.

## Review and promotion gates

- Every episode freezes its script and manifest, runs from the exact installed
  public build, and retains logs, result proof, timing, captions, transcript,
  and media validation.
- A successful script or draft render is only a local signal, not public
  validation.
- Jeffrey reviews narrated media and placement before any `www/` promotion.
- Before promotion, show the exact file inventory, sizes, checksums, and
  rendered Gallery diff.
- Commit locally only when authorized; never push or publish without Jeffrey's
  explicit approval.
- Do not edit `np`, `npRmpi`, or `crs` implementation files in this campaign.

## Immediate sequence

1. Review the scratch-only `npcdist()` silent animatic and Cove pronunciation
   probe authorized on 2026-07-18.
2. After that review, capture the complete `npcdist()` narration and assemble
   the narrated review master.
3. Prepare the conditional-quantile silent animatic using the approved default
   `npqreg()` plot.
4. Freeze framework version 1 after those three episodes have converged.
5. Continue the own-data and balanced analytical catalogue in small review
   tranches.

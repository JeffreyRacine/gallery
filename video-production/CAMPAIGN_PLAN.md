# Gallery onboarding and analytical-video campaign

Last updated: 2026-07-19
Status: Candidate A is the approved template. The first-result, three-part
Italy distributional sequence, Old Faithful unconditional pair, and automatic
local-polynomial regression episode are public. The Italy ordered-factor versus
numeric-gradient episode and its uninterrupted Cove narration join the public
catalogue in the approved 2026-07-19 tranche.

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

The population identities must not be presented as an instruction to derive
one fitted object mechanically from another. `npreg()`, `npcdens()`, and
`npcdist()` select smoothing for the conditional mean, conditional density,
and conditional distribution targets respectively. Consequently, numerically
integrating a fitted conditional-density surface need not reproduce the
separately optimized conditional-distribution estimate. `npqreg()` uses the
underlying conditional-distribution bandwidth selection because it inverts
that fitted distribution. State this distinction in the Video Demos
description and linked mathematical block; the first density/distribution
videos already display their own selected smoothing values.

For the conditional-distribution episode, the approved camera is the fixed
base renderer at `theta = 90`, `phi = 45`; the approved private Cove cue is
`N P see dist`; and the narration says, “Invert the conditional distribution
at a chosen probability and you obtain a conditional quantile.” The
conditional-quantile episode uses the installed default `npqreg()` plot with
the 25th, 50th, and 75th conditional-quantile curves over the observed
per-year boxplots. Its private Cove rule says N, P, and Q as three letters,
then `reg` as the one-syllable sound that rhymes exactly with `egg` and ends in
a hard `g`. Jeffrey approved the comparison “Egg. Reg. N P Q-reg. One N P
Q-reg call.” The video stays focused on
direct conditional-distribution inversion; the supporting description, not
the narration, distinguishes this distribution-based route from the separate
regression-based location-scale `nplsqreg()` method.

## Balanced catalogue after the gradient iteration

The public or publication-authorized catalogue now covers conditional density,
conditional distribution, direct conditional quantiles, unconditional joint
density/distribution, automatic local-polynomial degree/bandwidth selection,
first through third derivatives, three bootstrap variability-band types, and
the distinction between analytic derivatives and Delta-labelled ordered
finite differences. It deliberately mixes fixed/base and `rgl` rendering.

Remaining independently reviewable episodes should cover:

- genuinely multivariable mixed-data NOMAD selection of degree, continuous
  bandwidths, and categorical smoothing parameters;
- significance testing with the correct non-causal null interpretation;
- serial `np` and `npRmpi` session-mode parity, honest repeated timing, and
  clean teardown.

## Old Faithful unconditional pair

The approved pair uses the 272 observations in `datasets::faithful`:

1. `npudens(~ eruptions + waiting, data = faithful)` estimates the joint
   density and reveals the familiar two-cycle structure;
2. `npudist(~ eruptions + waiting, data = faithful)` estimates the joint
   distribution directly.

Both episodes use `renderer = "rgl"` to show an interactive surface in
RStudio's Viewer. The video explains that users can rotate, zoom, and resize
the widget. Density and distribution retain distinct selected bandwidths
because smoothing is optimized for each target. Neither deterministic episode
uses a seed.

The underlying source bundle retains editable SVG frames, sanitized RStudio
and Viewer assets, continuous narration masters, exact public scripts,
captions, transcripts, installed results, repeated-run proof, render scripts,
and checksum manifests. Raw captures and rejected voice takes remain outside
Git.

## Old Faithful automatic local-polynomial regression and uncertainty

The approved review candidate uses:

```r
library(np)
data(faithful, package = "datasets")

fit_npreg <- npreg(waiting ~ eruptions, data = faithful, nomad = "auto")
summary(fit_npreg$bws)

options(plot.par.mfrow = FALSE)
par(mfrow = c(2, 2))
plot(fit_npreg, errors = "bootstrap", band = "all", B = 9999)
plot(fit_npreg, errors = "bootstrap", band = "all", B = 9999,
     gradients = TRUE, gradient_order = 1)
plot(fit_npreg, errors = "bootstrap", band = "all", B = 9999,
     gradients = TRUE, gradient_order = 2)
plot(fit_npreg, errors = "bootstrap", band = "all", B = 9999,
     gradients = TRUE, gradient_order = 3)
```

The public CRAN `np` 0.70-5 build selects degree 4 and fixed bandwidth
`556.863008` through the recent, recommended `nomad = "auto"` pathway. For
this inexpensive one-predictor degree lattice, `auto` uses exhaustive degree
search with Powell bandwidth optimization to avoid a missed global optimum;
NOMAD remains the automatic route for larger search surfaces. Do not describe
this particular fit as an explicit NOMAD search.

Five seedless installed `B = 9999` repetitions produced identical selections
and byte-identical four-panel graphics without warnings or messages. The
example contrasts the selected higher-order local polynomial with the
first-result episode's default local-constant (`regtype = "lc"`, degree-zero
equivalent) fit without implying that either specification is universally
best. No seed is required.

The approved 29-second video leads with the completed 2-by-2 result and shows
the fitted relationship plus derivative orders 1--3. The accompanying page
distinguishes pointwise, simultaneous, and Bonferroni bootstrap variability
bounds and retains the smoothing-bias caveat. The full computation is shown;
no condensation label is required.

## Italy ordered-factor and numeric gradients

The approved comparison keeps the `Italy` response observations and displayed
year values fixed while changing only the R class of `year`:

```r
fit_ordered <- npreg(gdp ~ year, data = Italy)
fit_numeric <- npreg(gdp ~ year, data = italy_numeric)
```

The bundled ordered-factor representation automatically invokes the
Li–Racine ordered kernel, cross-validates `lambda = 0.7046792`, produces
level-specific fitted values, and reports an adjacent-ordered-level finite
difference. The numeric representation automatically invokes a second-order
Gaussian kernel, cross-validates `h = 3.337488`, produces a smooth fitted
curve, and reports an analytic derivative.

The page emphasizes that `lambda` and `h` have different meanings and scales.
The comparison is not a recommendation to coerce ordered variables: users must
represent each predictor according to its substantive meaning. Once classified
correctly, `np` propagates the type through kernels, cross-validation,
estimation, plotting, and gradients without a separate estimator switch.

Five seedless installed repetitions were exactly identical for bandwidths,
fitted values, gradients, and graphics. The approved 25-second narrated video
uses one uninterrupted Cove response and retains public spellings in its
captions and transcript.

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

1. Continue with a genuinely multivariable NOMAD example or significance
   testing as the next small review tranche.
2. Complete the other remaining serial analytical example.
3. Retain the `npRmpi` session-mode comparison until the remaining serial
   analytical examples are established.

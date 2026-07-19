# Gallery video production sources

This directory is the version-controlled source for the Gallery instructional
video series. It keeps the approved visual grammar, exact analysis scripts,
sanitized visual assets, narration masters, captions, manifests, render tools,
and compact proof needed to update an episode without reconstructing the
workflow from memory.

It is not a Quarto content directory and is not copied into `docs/`. Public
media and accessibility files live under `www/videos/` only after their review
gate is approved.

## Source-of-truth contract

- `episodes/<id>/analysis.R` is the authoritative R script.
- `episodes/<id>/narration/public.txt` is the authoritative spoken wording.
- `episodes/<id>/captions/captions.en.vtt` is manually aligned and retains
  public R spelling, even when a private phonetic cue is used for synthesis.
- `episodes/<id>/manifest.yml` freezes package build, data, runtime, result,
  renderer, camera, timing, placement, and review status.
- `episodes/<id>/frames/source/` and `assets/` are the editable visual source.
- `episodes/<id>/render/` recreates generated frames and media under ignored
  `build/` directories.
- An episode-specific sync script copies only an approved bundle into `www/`;
  check mode detects drift without writing.

## Retention boundary

Tracked here:

- canonical scripts and manifests;
- sanitized screen and plot assets;
- editable SVG frame sources;
- final normalized narration masters and approved pronunciation probes;
- manually reviewed captions and transcripts;
- compact decision, numerical, accessibility, and media proof;
- approved final public media or compact review media.

Kept outside Git:

- raw system-audio and screen recordings;
- rejected narration takes and splice experiments;
- R package libraries and tarballs;
- temporary browser/RStudio profiles;
- generated PNG frame caches and duplicate intermediate renders.

The external campaign tree is not invisible: `archive-manifests/` records every
scratch artifact by relative path, size, SHA-256, retention class, and canonical
Gallery destination when one exists. This honors the original rule that raw
recordings and editing history remain outside the production repository while
making the complete campaign auditable.

`proof/source-inventory.tsv` is the exact compact-source inventory, excluding
the inventory itself so it can be regenerated deterministically.

## Current episodes

- `first_np_result`: approved template and public bundle.
- `italy_conditional_density`: approved conditional-density episode and public
  bundle.
- `italy_conditional_distribution`: approved conditional-distribution episode
  and public bundle.
- `italy_conditional_quantiles`: approved direct conditional-quantile episode
  and public bundle.
- `old_faithful_joint_density`: approved unconditional joint-density episode
  with an interactive RStudio Viewer surface and public bundle.
- `old_faithful_joint_distribution`: approved direct unconditional
  joint-distribution episode with an interactive RStudio Viewer surface and
  public bundle.
- `old_faithful_automatic_local_polynomial`: approved narrated review and
  assembled publication tranche for automatic degree/bandwidth selection,
  derivative orders 1--3, and three bootstrap variability-band types.
- `italy_ordered_numeric_gradients`: approved comparison showing how ordered
  versus numeric predictor classes automatically determine kernels,
  cross-validation targets, fitted plotting, and finite-difference versus
  analytic-gradient semantics.

See `CAMPAIGN_PLAN.md` for the durable series decisions and next sequence.

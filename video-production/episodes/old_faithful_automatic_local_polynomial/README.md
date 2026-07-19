# Old Faithful automatic local-polynomial regression

Status: statistical framing, complete seedless script, visual grammar, and
continuous Cove narration approved by Jeffrey on 2026-07-19. Jeffrey approved
the exact rendered website tranche and authorized its commit and publication
on 2026-07-19.

The episode uses the recommended `nomad = "auto"` convenience route to select
the local-polynomial degree and bandwidth for the Old Faithful waiting-time
relationship. In this inexpensive one-predictor problem the automatic policy
uses exhaustive degree search with Powell bandwidth optimization; the public
CRAN `np` 0.70-5 build selects degree 4 and bandwidth 556.863008247459.

Four panels show the fitted conditional mean and derivative orders 1--3 with
pointwise, simultaneous, and Bonferroni bootstrap variability bounds.

Raw system-audio captures, the campaign library, and temporary render caches
remain outside Git. This directory retains the exact public script, editable
frames, sanitized assets, continuous narration master, accessibility files,
seedless installed proof, and approved review media.

Run the scripts under `render/` to rebuild the frames and media. Run
`render/sync_public_bundle.sh --check` to verify that the public bundle matches
the production source exactly.

# Old Faithful joint distribution

Status: script, corrected hybrid RStudio frame, interactive-renderer grammar,
continuous Cove narration, captions, and public promotion approved by Jeffrey
on 2026-07-18.

The episode estimates the bivariate joint distribution of eruption duration
and waiting time in `datasets::faithful`. The distribution is estimated
directly with smoothing selected for the cumulative target; it is not created
by integrating the preceding fitted joint-density object. `renderer = "rgl"`
opens the surface in RStudio's Viewer.

Raw screen and system-audio captures remain outside Git. This directory keeps
the exact public script, sanitized assets, editable frames, continuous
narration master, accessibility files, installed-build proof, and approved
review media.

Run `render/render_frames.sh`, `render/render_silent_animatic.sh`, and
`render/render_narrated_review.sh` to rebuild the compact review media. Run
`render/sync_public_bundle.sh --check` to test the promoted public bundle.

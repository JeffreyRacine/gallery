# Gallery Update Roadmap

## Role

This is a revised execution plan for updating the gallery after reviewing the
first draft from a stricter engineering and risk-control perspective.

Inputs:

- `/Users/jracine/Development/CRAN_DELTA_AUDIT_2026-03-24.md`
- current gallery source under `/Users/jracine/Development/Gallery_website`

Goal:

- make the gallery more informative and easier to navigate,
- surface the most helpful current package capabilities,
- preserve the existing breadth of advice and examples,
- minimize regression risk and collateral documentation drift.

## Critique Of The First Draft

The first draft was directionally sound, but too broad for a safe rollout.

### 1. The phases were too large

Several proposed phases mixed:

- new content creation,
- homepage routing changes,
- manifest changes,
- reference-surface rewrites,
- and method-page edits

in a way that increases blast radius. That is a content analogue of changing
API, routing, and rendering in one tranche.

### 2. It lacked hard acceptance criteria

The first draft described desired outcomes, but not the exact validation gates
required before declaring a tranche safe.

Without gates, the likely failure mode is:

- improved prose locally,
- hidden drift elsewhere,
- or broken routing/render only discovered later.

### 3. It proposed homepage surfacing before asset proof

Promoting new routes such as `crsiv` before the supporting quickstarts exist and are proven
would create “promised routes” instead of actual routes.

The safer order is:

1. create the route,
2. validate it,
3. then promote it.

### 4. It treated all method pages as one tranche

Touching:

- `kernel_primer.qmd`
- `np_npRmpi.qmd`
- `density_distribution_quantiles.qmd`
- `semiparametric_models.qmd`
- `mpi_large_data.qmd`
- `crs.qmd`

in one broad pass is too much surface area. These pages are high-traffic and
semantically different. They should not be bundled.

### 5. It did not define current-routing invariants tightly enough

A safe gallery plan needs explicit rules for what current-routing pages may say.
For example:

- current-routing pages should prefer current package surfaces,
- legacy scripts may remain,
- but legacy names should not be the first route unless intentionally labeled as
  archival or comparison material.

That rule needs to be explicit before editing pages such as
`function_index.qmd`.

### 6. It under-specified source-of-truth boundaries

The first draft correctly valued `data/quickstarts_manifest.csv`, but it did not
fully separate:

- quickstart metadata source of truth,
- page narrative source of truth,
- package-surface source of truth.

Without that, drift is likely to reappear.

### 7. It lacked rollback-friendly tranche design

For a documentation site with many routing pages, the safe default is:

- small tranche,
- one user-facing risk axis,
- easy revert,
- immediately re-renderable,
- easy to review diff.

The first draft was too editorially bundled.

## Revised Operating Principles

This revised plan uses the following hard rules.

### 1. One-risk-axis-per-tranche

Each tranche may change only one of:

- add a new quickstart route,
- promote existing routes on entry pages,
- modernize current-routing/reference language,
- add method-page callouts,
- relabel legacy breadth surfaces.

### 2. No promotion before proof

Do not promote a route on `index.qmd`, `primer.qmd`, or similar pages until:

1. the underlying quickstart/script exists,
2. the metadata entry exists if needed,
3. the route renders cleanly,
4. the script has passed a small local smoke.

### 3. Keep navigation stable unless evidence demands change

Do not change `_quarto.yml` sidebar structure in the first rollout. The current
task-oriented navigation is already a strength. Improve page content first.

### 4. Preserve breadth explicitly

Do not delete broad/legacy/comparison materials simply because modern routes are
being promoted. Instead:

- keep them,
- label them,
- demote them only in routing priority, not by removal.

### 5. Current-routing language must prefer current package surfaces

On current-routing pages:

- prefer current vignette names,
- prefer current startup/help routes,
- prefer `plot()` over stale `npplot`-first wording when routing users,
- prefer `npRmpi.init()` / `npRmpi.quit()` over older operational names.

Legacy script comments may remain historically faithful when not acting as the
main routing surface.

### 6. Every tranche must be render-safe and reviewable

Each tranche should produce a small, legible diff that a human can review
without scanning the whole site.

## Source-Of-Truth Map

### Quickstart assets

Source of truth:

- `www/**` quickstart script files
- `data/quickstarts_manifest.csv`

Derived surfaces:

- `quickstarts.qmd`
- `code_catalog.qmd`

Rule:

- do not hand-copy quickstart code into pages when the script can be sourced
  from `www/`.

### Current package discovery references

Source of truth:

- package vignettes/help/startup surfaces in package repos

Derived gallery routing pages:

- `faq.qmd`
- `primer.qmd`
- `index.qmd`
- `function_index.qmd`
- method pages that point users to installed vignettes

Rule:

- gallery routing text must mirror current package-surface names.

### Legacy/comparison breadth

Source of truth:

- historical scripts in `www/`
- legacy pages such as `legacy_materials.qmd`

Rule:

- keep these available, but label them as comparison/legacy/advanced where
  needed.

## Required Validation Gates

Every tranche touching gallery source should pass:

1. `shellcheck` on any touched shell scripts
2. `/Users/jracine/Development/Gallery_website/gallery_hygiene_lint.sh`
3. `quarto render` in `/Users/jracine/Development/Gallery_website`

Additional gates by tranche type:

### If a tranche changes package-routing text

Run:

- `/Users/jracine/Development/package_gallery_sync_audit.sh`

### If a tranche changes current release-facing gallery routes substantially

Prefer:

- `/Users/jracine/Development/release_preflight.sh --render-gallery <touched package set>`

### If a tranche adds or changes quickstart scripts

Run a small smoke for each new/changed quickstart using the corresponding local
packages before promotion. If a dedicated wrapper does not yet exist, use small
ad hoc `Rscript` runs and record the commands in the commit summary.

## Reformulated Plan

### Tranche 0: Define Invariants, Not Content

Goal:

- lock the rules before editing high-traffic pages

Files:

- this roadmap only

Outcome:

- execution order, source-of-truth boundaries, and validation gates are frozen

Why first:

- prevents editorial drift during later implementation.

### Tranche 1: Add Missing Quickstart Assets Only

Goal:

- create the missing high-value routes before surfacing them

Candidates:

1. `www/crs/crs_iv_quickstart.R`
2. optional later:
   - `www/crs/crs_ivderiv_quickstart.R`

Files allowed in this tranche:

- new quickstart scripts
- `data/quickstarts_manifest.csv`

Files not touched in this tranche:

- `index.qmd`
- `primer.qmd`
- `function_index.qmd`
- method pages

Validation:

- quickstart-local smoke runs
- `quarto render`
- `gallery_hygiene_lint.sh`

Why this order:

- it proves the routes before any promotion.

### Tranche 2: Promote Existing And Newly-Proven Routes On Entry Pages Only

Goal:

- improve discoverability from the first click

Files:

- `index.qmd`
- `primer.qmd`

Allowed changes:

- highlight blocks
- “current featured capabilities” copy
- direct links to already-proven quickstarts

Not allowed:

- sidebar restructuring
- method-page rewrites
- reference-page rewrites

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`
- `package_gallery_sync_audit.sh` if package-routing text changes

Why isolated:

- homepage/chooser changes have the highest visibility and should remain small.

### Tranche 3: Quickstart/Code Catalog Promotion Only

Goal:

- make the quickstart and code-library pages reflect the new priorities without
  altering broader method narratives yet

Files:

- `quickstarts.qmd`
- `code_catalog.qmd`

Allowed changes:

- feature ordering
- headings/callouts
- labels that distinguish:
  - modern default route,
  - advanced route,
  - legacy comparison route

Not allowed:

- edits to method pages
- edits to reference routing

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`

### Tranche 4: Current-Routing Reference Cleanup Only

Goal:

- clean up routing language without mixing in new quickstarts or entry-page work

Primary file:

- `function_index.qmd`

Possible additions:

- `np.kernels`
- `np.options`
- `npreghat` / `npcdenshat` family as advanced-helper routes
- stronger `crsiv` / `crsivderiv` routing
- current `npRmpi.init()` / `npRmpi.quit()` routing

Specific correction:

- replace or soften stale `npplot`-first routing language on current-routing
  surfaces

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`
- `package_gallery_sync_audit.sh`

Why isolated:

- reference pages can silently propagate stale package language if bundled with
  broader content edits.

### Tranche 5A: `np` Method-Page Callouts

Goal:

- make current `np` capabilities easier to notice without broad site churn

Files:

- `kernel_primer.qmd`
- `np_npRmpi.qmd`
- `density_distribution_quantiles.qmd`
- `semiparametric_models.qmd`

Allowed emphasis:

- `nomad = TRUE`
- joint LP degree/bandwidth selection
- where to go from classic bandwidth-object workflow to newer LP workflow
- optional advanced pointers to `np.options` and `np.kernels`

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`
- `package_gallery_sync_audit.sh`

### Tranche 5B: `npRmpi` Operational Method-Page Callouts

Goal:

- keep MPI guidance operational and current

Files:

- `mpi_large_data.qmd`
- possibly a small synchronized note in `np_npRmpi.qmd` if needed

Allowed emphasis:

- session/spawn as current interactive route where appropriate
- attach/profile role distinction
- LP `nomad = TRUE` after `npRmpi.init(...)`

Not allowed:

- new broad script libraries in the same tranche

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`

### Tranche 5C: `crs` Method-Page Callouts

Goal:

- elevate the modern public `crs` story without disturbing kernel pages

Files:

- `crs.qmd`
- optionally `spline_primer.qmd`

Allowed emphasis:

- `crs_getting_started`
- `crsiv`
- `crsivderiv`
- constrained vs IV vs basic spline entry paths

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`
- `package_gallery_sync_audit.sh` if vignette-routing text changes

### Tranche 6: Legacy/Comparison Labeling Pass

Goal:

- preserve breadth while reducing ambiguity

Files:

- `code_catalog.qmd`
- any page listing older serial/MPI comparison scripts

Allowed changes:

- add labels such as:
  - modern default
  - current quickstart
  - advanced route
  - older comparison script

Not allowed:

- deleting breadth material unless explicitly obsolete and unused

Validation:

- `quarto render`
- `gallery_hygiene_lint.sh`

## Recommended Immediate Next Move

The safest highest-ROI implementation order is:

1. Tranche 1: add `crs_iv_quickstart.R`
2. Tranche 2: update `index.qmd` and `primer.qmd`
3. Tranche 3: update `quickstarts.qmd` and `code_catalog.qmd`
4. Tranche 4: modernize `function_index.qmd`

That sequence gives the biggest discoverability improvement with the lowest
chance of routing regressions or site-wide collateral damage.

## Non-Goals For The First Rollout

Do not include these in the first gallery modernization pass:

1. sidebar/navigation restructuring in `_quarto.yml`
2. broad visual redesign
3. full rewrite of legacy pages
4. large-scale pruning of script libraries
5. simultaneous editing of all method pages

These are classic sources of documentation churn without commensurate user
benefit.

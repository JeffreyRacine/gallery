# Gallery Update Roadmap

## Purpose

Turn the recent package modernization into a clearer gallery experience without
losing the breadth that already serves:

- first-time users,
- working applied users who want code immediately,
- advanced users who need route/method-specific guidance,
- package users who still benefit from older scripts and reference material.

This roadmap is derived from:

- `/Users/jracine/Development/CRAN_DELTA_AUDIT_2026-03-24.md`
- the current gallery source tree in
  `/Users/jracine/Development/Gallery_website`

## North Star

The gallery should be:

1. informative,
2. easy to navigate,
3. explicit about what is new and helpful in the current package generation,
4. still broad enough to serve users with very different needs and levels of
   experience.

The right design principle is:

- \strong{surface the modern defaults early, preserve the broader library just
  behind them}.

## Current Strengths To Preserve

The current gallery already does several things well and should not be
reorganized destructively:

1. The sidebar is task-oriented rather than organized around old vignette names:
   `_quarto.yml`.
2. The home page already routes users by intent:
   `index.qmd`.
3. The quickstart manifest is a genuine single source of truth for current small
   runnable scripts:
   `data/quickstarts_manifest.csv`.
4. `npRmpi` operational guidance is already much better than older materials:
   `mpi_large_data.qmd`.
5. Breadth is retained through:
   - `code_catalog.qmd`
   - `function_index.qmd`
   - `runtime_and_scaling.qmd`
   - `data_preparation.qmd`
   - `legacy_materials.qmd`

Do not give up that breadth in the name of “cleanliness.” The gallery is more
useful because it serves both first-run and deeper follow-up needs.

## Main Gaps To Fix

### 1. New features exist, but are not yet prominent enough

The gallery already contains:

- `np` LP `nomad = TRUE` quickstart
- `npRmpi` session/attach/profile quickstarts
- `npRmpi` session LP `nomad = TRUE` quickstart

But these are not yet surfaced strongly enough on:

- `index.qmd`
- `primer.qmd`
- `quickstarts.qmd`
- `code_catalog.qmd`

Current users can find them, but they are not yet framed as major current
capabilities.

### 2. Some of the best new package surfaces are not routed at all

The gallery currently under-surfaces:

- `np.pairs`
- `np.kernels`
- `np.options`
- public `*hat` helper surfaces for advanced users
- `crsiv` / `crsivderiv` as a modern public `crs` story

### 3. `crs` is still under-featured relative to its current package surface

The gallery exposes spline basics and constrained examples, but the newer
installed-vignette/discovery work and the public IV surface are not yet
prominent enough.

### 4. Current-routing pages still contain some stale language

Notably:

- `function_index.qmd` still routes users through `npplot`, even though the
  current package surface is better described through `plot()` plus the newer
  documented helpers.

Legacy script comments may continue to mention old names when they are
historically faithful, but current-routing text should prefer current package
surfaces.

### 5. There are still missing “small first success” routes

Two especially useful candidates are not yet present as gallery quickstarts:

1. `np.pairs()` / `np.pairs.plot()`
2. `crsiv()` (and possibly a second derivative-focused `crsivderiv()` example)

These would give the gallery more visible coverage of genuine current package
deltas.

## Recommended Content Hierarchy

The gallery should explicitly separate four layers of use:

1. \strong{Start now}
   - smallest runnable scripts
   - package chooser
   - install/get-started
2. \strong{Modern featured capabilities}
   - current new or newly matured routes worth highlighting
3. \strong{Task-based method pages}
   - regression, density/distribution, entropy, semiparametrics, splines, MPI
4. \strong{Deep library / legacy breadth}
   - code catalog
   - function index
   - legacy materials
   - broader script tables

This keeps the site easy to enter without flattening everything into a shallow
“getting started only” gallery.

## Proposed Phases

### Phase 1: Surface The Current Highlights

Goal:

- make the major new package capabilities visible from the first click

Target files:

- `index.qmd`
- `primer.qmd`
- `quickstarts.qmd`
- `code_catalog.qmd`

Edits:

1. Add a short “Current Highlights” or “What’s New in Current Releases” section
   to `index.qmd`.
2. Add a matching smaller “If you want the newer features first” table/block to
   `primer.qmd`.
3. Promote these routes near the top of `quickstarts.qmd` and
   `code_catalog.qmd`:
   - `np`: automatic LP degree search via `nomad = TRUE`
   - `npRmpi`: session/spawn, attach, and profile workflows
   - `npRmpi`: session LP `nomad = TRUE`
   - `crs`: spline quickstart plus IV spline route once added
4. Keep the broader code library below; do not remove the existing tables.

Expected user outcome:

- a new user can see the modern current routes immediately
- a returning user can still reach the deeper library quickly

### Phase 2: Add Missing Featured Quickstarts

Goal:

- create small copyable entry points for the most meaningful new package
  capabilities not yet represented in the gallery

New quickstart candidates:

1. `np_pairs_quickstart.R`
   - minimal `np.pairs()` / `np.pairs.plot()` example
2. `crs_iv_quickstart.R`
   - minimal `crsiv()` example
3. optional follow-on:
   - `crs_ivderiv_quickstart.R` if the derivative route deserves separate
     treatment rather than a note on the same page

Likely file updates:

- new scripts under `www/np_npRmpi/` and `www/crs/`
- `data/quickstarts_manifest.csv`
- `quickstarts.qmd`
- `code_catalog.qmd`

Why these first:

- `np.pairs` is compact, visual, and clearly new
- `crsiv` is a meaningful public `crs` capability that is not yet surfaced well

### Phase 3: Strengthen Method Pages Without Losing Breadth

Goal:

- make the key method pages explicitly tell users what is modern and important

Priority pages:

- `kernel_primer.qmd`
- `np_npRmpi.qmd`
- `semiparametric_models.qmd`
- `density_distribution_quantiles.qmd`
- `mpi_large_data.qmd`
- `crs.qmd`

Edits:

1. `kernel_primer.qmd`
   - keep the basic bandwidth-object workflow
   - add a clearer boxed note that `nomad = TRUE` is a modern LP shortcut, not a
     replacement for the classic workflow
2. `np_npRmpi.qmd`
   - add a short “featured modern routes” section near the top
   - explicitly separate serial `np` from the “same workflow under MPI” handoff
3. `semiparametric_models.qmd`
   - explicitly note that semiparametric LP-capable families share the modern
     `nomad = TRUE` route
4. `density_distribution_quantiles.qmd`
   - call out that conditional density/distribution also participate in the new
     LP route
5. `mpi_large_data.qmd`
   - keep operational tone
   - add a short box clarifying that the same LP shortcut now survives after
     `npRmpi.init(...)`
6. `crs.qmd`
   - elevate `crsiv` / `crsivderiv`
   - add a short note about the installed getting-started vignette
   - keep constrained examples and `rgl` examples in place

### Phase 4: Modernize Current-Routing Reference Surfaces

Goal:

- reduce confusion on the “I know the function name” pages

Priority file:

- `function_index.qmd`

Edits:

1. Replace or soften current-routing references to `npplot`.
2. Add entries for:
   - `np.pairs`
   - `np.kernels`
   - `np.options`
   - `npreghat` / `npcdenshat` / related advanced helpers as an advanced route
   - `npRmpi.init` / `npRmpi.quit` as the startup surface
   - `crsiv` / `crsivderiv` with a stronger first-stop page
3. Distinguish:
   - current package help/discovery surface
   - historical script/library surface

Expected user outcome:

- users searching by function family get routed through the modern package
  surface instead of stale names

### Phase 5: Preserve Breadth By Explicit Layering

Goal:

- keep advanced and legacy material available without letting it overshadow the
  modern first route

Rules:

1. Keep `code_catalog.qmd` broad.
2. Keep `legacy_materials.qmd` as the place for old PDFs/route history.
3. Keep older comparison scripts in the catalog, but label them as:
   - historical comparison,
   - parity/reference,
   - or advanced route
4. Prefer wording such as:
   - “modern default”
   - “current first route”
   - “older but still useful comparison script”

This allows breadth without ambiguity.

## Highest-ROI Concrete Edits

If sequencing must be tight, the best order is:

1. `index.qmd`
2. `primer.qmd`
3. `data/quickstarts_manifest.csv`
4. add `np_pairs_quickstart.R`
5. add `crs_iv_quickstart.R`
6. `quickstarts.qmd`
7. `code_catalog.qmd`
8. `function_index.qmd`
9. `crs.qmd`
10. targeted method-page callouts (`kernel_primer.qmd`, `np_npRmpi.qmd`,
    `mpi_large_data.qmd`, `semiparametric_models.qmd`,
    `density_distribution_quantiles.qmd`)

## Suggested Messaging Themes

These are the themes worth repeating across the gallery:

1. `np`: modern automatic LP route
2. `npRmpi`: same style of workflow, now with clear modern operational modes
3. `crs`: splines plus IV/constrained routes, not just a spline afterthought
4. package vignettes are the installed first-run path; the gallery is the
   broader teaching surface

## Recommended Near-Term Deliverable

The best near-term gallery tranche is:

1. add homepage/chooser highlight blocks,
2. add `np.pairs` and `crsiv` quickstarts,
3. modernize `function_index.qmd`,
4. add short “modern feature” callouts to the highest-traffic method pages.

That would materially improve discoverability without requiring a full-site
rewrite.

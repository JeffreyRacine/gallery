# Gallery of Code

This repository contains the Quarto website for the `np`, `npRmpi`, and `crs` gallery hosted at [jeffreyracine.github.io/gallery](https://jeffreyracine.github.io/gallery/).

## What lives here

- Quarto website source in the repo root
- published site output in `docs/`
- static scripts and assets in `www/`
- source-backed quickstarts in `www/np_npRmpi/` and `www/crs/`, rendered inline on the site
- shared quickstart metadata in `data/quickstarts_manifest.csv`
- rendering helpers in `site_helpers.R`

The gallery is meant to be a user-facing front door: package chooser, worked examples, MPI guidance, FAQ routing, and code catalog. It is not intended to replace package reference manuals or package-owned release notes.

## Local workflow

Preview locally:

```bash
cd /Users/jracine/Development/Gallery_website
quarto preview
```

Render static output:

```bash
cd /Users/jracine/Development/Gallery_website
quarto render
```

## Maintenance notes

- keep the sidebar and top-level pages organized by user task, not by historical document names
- preserve `www/` assets unless they are intentionally retired
- prefer source-backed copyable code blocks on pages rather than duplicating code manually
- when a quickstart script changes, update the underlying file in `www/` first and let `quickstarts.qmd` / `code_catalog.qmd` pick it up at render time
- keep `data/quickstarts_manifest.csv` as the single source of truth for quickstart labels, routing text, and featured ordering
- keep package-specific canonical details in the package repos where practical
- use `quarto render` before publish so search metadata and inline source blocks stay current

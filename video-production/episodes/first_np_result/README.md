# Your first `np` result

Status: approved visual/narration template and locally committed public bundle;
not pushed.

This episode shows a newcomer that a complete installed-package result takes a
few ordinary R statements. It begins with the plot, briefly orients the viewer
inside a real sanitized RStudio window, uses close-ups for the essential code
and selected bandwidth, returns to RStudio, and ends at Gallery Video Demos.

## Rebuild

```sh
./render/render_frames.sh
./render/render_video.sh
./render/sync_public_bundle.sh --check
```

The expected public MP4 SHA-256 is
`e9b8abe6b9616c310230efbcfb314bd40babe3f0162a5f4e26ac7a4c32139a40`.
Generated files remain under ignored `build/`. Use
`sync_public_bundle.sh --write` only after a reviewed production change.

## Important decisions

- No seed is needed: the episode uses bundled data and performs no simulation
  or resampling.
- The private Cove cue for `npreg()` is `N P REYG`, with the hard g in
  regression. Public text always remains `npreg()`.
- The final route is **Gallery -> Examples -> Video Demos**, not Start Here.
- Raw Cove captures and superseded takes remain in the external campaign
  archive and are checksummed in the campaign artifact manifest.

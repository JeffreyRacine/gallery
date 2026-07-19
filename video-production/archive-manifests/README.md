# External campaign archive manifest

`campaign-scratch-artifacts.tsv` inventories the dated scratch tree used to
develop Candidate A and the Italy conditional-density review cut.
`old-faithful-scratch-artifacts.tsv` separately inventories the complete
scratch tree for the approved Old Faithful joint-density and
joint-distribution pair. Paths are relative to their scratch roots; no private
absolute path or file content is stored in either manifest.

Each row records bytes, SHA-256, retention class, and the canonical Gallery
destination when the artifact was selected or adapted for
`video-production/`. The manifest does not make ephemeral browser profiles,
package libraries, raw recordings, or rejected takes public; it makes their
retention and provenance auditable.

Regenerate from the development workspace with:

```sh
python3 ../framework/build_archive_manifest.py \
  SCRATCH_ROOT campaign-scratch-artifacts.tsv copied-artifacts.tsv
```

The Old Faithful inventory uses
`old-faithful-copied-artifacts.tsv` as its source-to-destination map.

The manifest is historical proof for the 2026-07-18 campaign. Rebuilding it
after the external scratch tree changes creates a new checksum state and should
be reviewed as such.

Current inventory: 781 files, 534,761,203 bytes. Forty-five source artifacts
have a canonical Gallery destination; 21 raw captures, two rejected takes, 100
installed-environment files, 309 ephemeral profile/model files, 38 generated
cache files, and 266 additional evidence files remain external. Manifest
SHA-256:
`94e52a6c9fb47770d7acf43b8dedab105a8e45e723166eb3e47178102d29f06f`.

The Old Faithful inventory state and checksum are recorded below after each
approved promotion so later scratch additions do not silently alter historical
proof.

Current Old Faithful inventory: 417 files, 192,667,212 bytes. Fifty-nine
source artifacts have a canonical Gallery destination; 15 raw captures, 14
generated cache files, and 329 additional evidence files remain external.
Manifest SHA-256:
`303843552d02a8af4efe3e84160ffd3d9e993ec287f81eaaf9912ccb8940d1e7`.

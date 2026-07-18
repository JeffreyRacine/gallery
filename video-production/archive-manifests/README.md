# External campaign archive manifest

`campaign-scratch-artifacts.tsv` inventories the complete dated scratch tree
used to develop Candidate A and the Italy conditional-density review cut. Paths
are relative to the scratch root; no private absolute path or file content is
stored in the manifest.

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

The manifest is historical proof for the 2026-07-18 campaign. Rebuilding it
after the external scratch tree changes creates a new checksum state and should
be reviewed as such.

Current inventory: 781 files, 534,761,203 bytes. Forty-five source artifacts
have a canonical Gallery destination; 21 raw captures, two rejected takes, 100
installed-environment files, 309 ephemeral profile/model files, 38 generated
cache files, and 266 additional evidence files remain external. Manifest
SHA-256:
`94e52a6c9fb47770d7acf43b8dedab105a8e45e723166eb3e47178102d29f06f`.

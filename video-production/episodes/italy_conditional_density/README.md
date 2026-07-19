# Italy conditional density

Status: example, 90/45 camera, silent animatic, `npcdens()` pronunciation, and
the corrected continuous Cove narration approved by Jeffrey on 2026-07-18.
Jeffrey authorized public Gallery promotion, commit, and push on 2026-07-18.

## Rebuild the review cut

```sh
./render/render_frames.sh
./render/render_silent_animatic.sh
./render/render_narrated_review.sh
```

The tracked review videos let a future update be compared directly:

- `review/silent-animatic.mp4`: approved silent visual,
  SHA-256 `60ab43d53f5d1468ac49ebd167a0e73424b64d034d7339824b5669fabb23ecee`;
- `review/narrated-prototype.mp4`: approved narrated prototype,
  SHA-256 `827b90ba90175250f9af46cf2e4760118a9e8f27fcc3801e50653b0cf32fe0ca`.

The public master removes the review-only `DRAFT` badge from the opening
frame; timing, narration, camera, code, and all other visual content are
unchanged from Jeffrey's approved cut.

The narrated cut copies the approved H.264 visual stream without re-encoding,
adds the normalized Cove master, and pads the natural 24.02-second narration
with silence through the 25-second outro.

The current retake corrects only the spoken pronunciation of `unimodal`, using
the private cue `you knee modal`. It is a fresh continuous narration, not a
word splice.

## Recreate narration from an external raw capture

Raw `.caf` files remain outside Git. After measuring the intended trim bounds:

```sh
python3 ../../framework/normalize_system_audio.py RAW.caf \
  narration/narration_master.wav --trim-start 11.68 --trim-end 35.70
```

Those exact bounds apply only to the retained corrected 2026-07-18 take. The microphone
was muted during capture. The private cue is `N P see dense`; public text always
uses `npcdens()`.

Run `render/sync_public_bundle.sh --check` to confirm the promoted public
script, media, poster, captions, and transcript remain byte-identical to this
source bundle.

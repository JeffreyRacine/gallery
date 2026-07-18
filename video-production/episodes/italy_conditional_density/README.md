# Italy conditional density

Status: example, 90/45 camera, silent animatic, `npcdens()` pronunciation, and
the corrected continuous Cove narration approved by Jeffrey on 2026-07-18.
This remains a prototype source bundle, not an authorized public Gallery
promotion.

## Rebuild the review cut

```sh
./render/render_frames.sh
./render/render_silent_animatic.sh
./render/render_narrated_review.sh
```

The tracked review videos let a future update be compared directly:

- `review/silent-animatic.mp4`: approved silent visual,
  SHA-256 `e536a951e5766bb55462a7963ba71fc62ae23c198875d146edfe62522c757b98`;
- `review/narrated-prototype.mp4`: approved narrated prototype,
  SHA-256 `0cf2add02570e7ff31f8511fd167b34f627468c9cd58e6dfbd2a564679c66cb9`.

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

# Italy conditional density

Status: example, 90/45 camera, silent animatic, and `npcdens()` pronunciation
approved. The continuous Cove narration has been captured and synchronized into
a 25-second review cut. It awaits Jeffrey's listening review and is not a public
Gallery bundle.

## Rebuild the review cut

```sh
./render/render_frames.sh
./render/render_silent_animatic.sh
./render/render_narrated_review.sh
```

The tracked review videos let a future update be compared directly:

- `review/silent-animatic.mp4`: approved silent visual,
  SHA-256 `e536a951e5766bb55462a7963ba71fc62ae23c198875d146edfe62522c757b98`;
- `review/narrated-prototype.mp4`: current listening review,
  SHA-256 `57ffe6cc3c0dfe9817b8479ba00d6693b108d11c6baba8bc404022e9694d785c`.

The narrated cut copies the approved H.264 visual stream without re-encoding,
adds the normalized Cove master, and pads the natural 23.4-second narration
with silence through the 25-second outro.

## Recreate narration from an external raw capture

Raw `.caf` files remain outside Git. After measuring the intended trim bounds:

```sh
python3 ../../framework/normalize_system_audio.py RAW.caf \
  narration/narration_master.wav --trim-start 10.30 --trim-end 33.70
```

Those exact bounds apply only to the retained 2026-07-18 take. The microphone
was muted during capture. The private cue is `N P see dense`; public text always
uses `npcdens()`.

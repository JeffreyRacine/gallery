# Italy `npcdist()` Narrated Review Ledger

Date: 2026-07-18
Claim tier: approved scratch narrated master; not promoted

## Authorization and scope

Jeffrey approved the silent animatic and private `N P see dist` pronunciation
probe, authorizing complete Cove narration capture and a narrated review
master. This did not authorize Gallery promotion, push, or publication.

Jeffrey then clarified that the population identity connecting conditional
density and distribution must not imply that the fitted distribution is
obtained by integrating a separately estimated density. The narration remains
the approved short population statement. The proposed Gallery description and
linked mathematical block now state the target-specific estimation distinction
explicitly.

## Narration source and capture

- Public narration source: `narration/italy_cdist_draft.txt`
- Private Voice prompt: `narration/italy_cdist_chatgpt_voice_prompt.txt`
- Public function spelling: `npcdist()`
- Private Cove cue: `N P see dist`
- Raw system-audio capture:
  `captures/raw/italy_cdist_chatgpt_voice_full_narration.caf`
- Raw format: 52.960 seconds, 48 kHz stereo PCM float
- Voice session: Cove; microphone off during the spoken response; session
  explicitly ended after capture

The raw capture contains a separate 145 ms interface/pre-roll sound at
21.566-21.711 seconds. Cove's single continuous narration begins at 23.3526
seconds and ends at 48.2242 seconds. The normalized master retains only
23.30-48.30 seconds, excluding the entire pre-roll region without a word-level
or sentence-level splice.

## Normalized narration master

- File:
  `captures/edited/italy_cdist_chatgpt_voice_full_narration_master.wav`
- Duration: 25.000 seconds
- Format: 48 kHz mono 16-bit PCM
- Integrated loudness: -16.2 LUFS
- True peak: -1.5 dBFS
- Speech alignment: 0.00-24.90 seconds
- SHA-256:
  `732efa6d78efb7b4aea53780c72352d0598f2c40f8557183bf79664c4d41cde0`

The retained tiny-English Whisper alignment recovers the complete intended
narration, including `N P see dist`, with punctuation-only differences such as
`per capita` versus public `per-capita`. This is a reproducibility check; human
listening review remains authoritative.

## Narrated review master

- File: `renders/italy_cdist_narrated_review_prototype.mp4`
- SHA-256:
  `0b9c865e1f649a9061bbd5ccca6b04176ccee63edf4bb601d74ee813ecb2af04`
- Size: 2,146,449 bytes
- Duration: 25.000 seconds
- Video: H.264 High, 1920 x 1080, 30 fps, `yuv420p`
- Audio: AAC, 48 kHz mono, 160 kb/s target
- Video source: stream-copied from the approved silent animatic
- Decode: full FFmpeg decode completed without error

The publication master removes the review-only `DRAFT` badge from the opening
frame. Its narration, timing, camera, code, and remaining visual sequence are
unchanged from the approved review cut.

Accessibility drafts:

- Captions: `captions/italy_cdist_draft.vtt`
- Caption SHA-256:
  `c8954ef30b9c69cde5c3e87900f70a14f96b8596e0e0cfb699626e4a8f200688`
- Transcript: `narration/italy_cdist_transcript.txt`
- Transcript SHA-256:
  `d47b1ab5391b70de348465b19067ee684ed34b7c6ed3ffcebb144b7f2dfb62dd`

## Target-specific estimation distinction

The proposed Video Demos description and linked mathematical block state:

> The density-distribution equation connects population targets; it is not an
> instruction to derive one fitted object mechanically from another.
> `npcdens()` and `npcdist()` select smoothing for conditional-density and
> conditional-distribution estimation respectively. Integrating a fitted
> conditional density therefore need not reproduce the separately optimized
> conditional-distribution estimate. Likewise, `npreg()` selects smoothing for
> the conditional-mean target, while `npqreg()` uses the underlying
> conditional-distribution bandwidth selection it inverts.

## Jeffrey approval

Jeffrey approved the combined narration/visual pacing, complete pronunciation,
captions, and target-specific estimation note on 2026-07-18. This authorizes
preparation of the complete reproducibility and accessibility bundle plus the
exact proposed Gallery tranche and rendered diff. It does not authorize
promotion, commit of episode media, push, or publication.

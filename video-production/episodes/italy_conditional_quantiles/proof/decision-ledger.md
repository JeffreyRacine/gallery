# Italy `npqreg()` Narrated Review Ledger

Date: 2026-07-18
Claim tier: scratch narrated review master; not promoted or publication-ready

## Authorization and scope

Jeffrey approved the silent animatic, focused 58-word narration, supporting
description, and pronunciation comparison. The approved spoken rule says N,
P, and Q as three letters, then `reg` as one syllable that rhymes exactly with
`egg` and ends in a hard `g`. This authorized one continuous Cove narration
and a narrated scratch review master; it did not authorize Gallery promotion,
episode-media commit, push, or publication.

## Narration source and takes

- Public source: `narration/italy_qreg_draft.txt`
- Private Cove prompt: `narration/italy_qreg_chatgpt_voice_prompt.txt`
- Public function spelling: `npqreg()`
- Voice: Cove
- Microphone: muted during every system-audio capture

Take disposition:

1. Take 1 is rejected because Cove added “one moment” before the approved
   text.
2. Take 2 is an exact-word fallback but its complete speech envelope is only
   about 17.2 seconds, too fast for the approved visual grammar.
3. Take 3 contains a paced full response, but Jeffrey's first listening review
   found an aborted “Choose aro…” start before the clean “Choose a…” onset.
   The resulting 28-second master is rejected.

Take 3 raw capture:

- File: `captures/raw/italy_qreg_chatgpt_voice_full_narration_take3_paced.caf`
- Duration: 68.760 seconds
- Format: 48 kHz stereo PCM float
- SHA-256:
  `f76ce196c894dabbe173f8d869f63719edcf45fb7be8156b55384dce12d255bd`

Cove's aborted start occupies 13.1629-13.7467 seconds and is followed by 796
ms of silence. The clean uninterrupted 58-word response begins at 14.5435
seconds and ends at 40.5637 seconds. The corrected retained interval is
14.43-40.70 seconds, with clean source silence at both boundaries and no
internal word- or sentence-level splice.

Rejected first-review artifacts are retained explicitly:

- Audio:
  `captures/edited/REJECTED_italy_qreg_chatgpt_voice_full_narration_false_start.wav`
- Audio SHA-256:
  `881d000f2939e2d4ced0969719ba73f314c567e60415873020f93923989dfa5f`
- Video:
  `renders/REJECTED_italy_qreg_narrated_review_false_start.mp4`
- Video SHA-256:
  `14e0453e7143498522b66fe72c1fb8bc3f17009f524af5c162fe568505a0f766`

## Narration master

- Continuous normalized response:
  `captures/edited/italy_qreg_chatgpt_voice_take3_paced_continuous.wav`
- Continuous duration: 26.270 seconds
- Continuous SHA-256:
  `115ecbfba955ee501f965ccec27ff5fb59597509d520ff46ea1a1be38a516631`
- Review master:
  `captures/edited/italy_qreg_chatgpt_voice_full_narration_master.wav`
- Review-master duration: 26.500 seconds
- Format: 48 kHz mono 16-bit PCM
- Integrated loudness: -16.6 LUFS
- True peak: -1.5 dBFS
- Review-master SHA-256:
  `ac340a5bef3e4d3428d697fa53aab2c3caeddc4f07a4de8f16a058fd44ef2edb`

The review master adds 250 ms of leading silence and enough trailing silence
to reach 26.5 seconds. It excludes the entire aborted pre-roll before the
second clean onset and does not time-stretch or splice the retained continuous
speech. The tiny-English alignment now begins with “Choose a probability” and
recovers the complete public word sequence, including “N P Q reg”; it cannot
establish phonetic quality. Jeffrey's listening review remains authoritative.

## Narrated review video

- File: `renders/italy_qreg_narrated_review_prototype.mp4`
- Duration: 26.500 seconds
- Size: 1,990,543 bytes
- Video: H.264 High, 1920 x 1080, 30 fps, `yuv420p`
- Audio: AAC LC, 48 kHz mono, 160 kb/s target
- Fast start: yes (`moov` at byte 36 before `mdat` at byte 30,600)
- Full FFmpeg decode: pass
- Framework validation: all checks pass
- SHA-256:
  `a941bc9c8eb2085abd6567b767d908fd1e4860e9c6aef6828223aeecd557fc09`

The publication master removes the review-only `DRAFT` badge from the opening
frame. Its narration, timing, code, and remaining visual sequence are
unchanged from the approved review cut.

The approved 25-second silent animatic is uniformly extended to 26.5 seconds.
Because its content is static frames joined by dissolves, this preserves every
approved visual and aligns the final Gallery sentence with the outro without
altering Cove's speech.

## Accessibility drafts

- Captions: `captions/italy_qreg_draft.vtt`
- Caption SHA-256:
  `c27637e1d94a48e946b770d33b5cdd4228ac25249f13ef48cd94119be9347fc5`
- Transcript: `narration/italy_qreg_transcript.txt`
- Transcript SHA-256:
  `4b170b24524c194f70776013598edcbeccdc9a3cf141991b0e4c8bad7e970458`

Public captions and transcript use `npqreg()` and contain no private phonetic
cue. Captions are manually drafted from the retained word timings but remain
subject to Jeffrey's embedded-size review.

## Current review gate

Review the continuous narrated master for:

1. `npqreg()` pronounced “enn pee cue-reg,” with `reg` rhyming with `egg`;
2. the corrected 26.5-second narration/visual pacing and clean opening;
3. caption timing and line density; and
4. overall information load at the embedded size.

Approval would freeze the `npqreg()` episode and authorize preparation of its
complete reproducibility/accessibility bundle and proposed Gallery tranche.
It would not authorize promotion, commit of episode media, push, or
publication.

# Italy narration alignment proof

The retained narration master is one continuous Cove response captured with
the microphone muted. It has no word-level splice.

- duration: 24.020 seconds;
- initial silence: 0.117 seconds at the -50 dB threshold;
- integrated loudness: -16.5 LUFS;
- loudness range: 2.7 LU;
- true peak: -1.5 dBTP;
- SHA-256:
  `bab7f79ec2d0ec03ee2074efddcacbe1d4e5d5dc6c4b0cf3be6d370e0af5a95b`.

This is the complete retake requested after the first full review. The private
spoken cue `you knee modal` produces the approved public word `unimodal`; no
audio from the superseded take is spliced into this master.

Faster Whisper `tiny.en` supplied alignment hints, not caption wording:

| Start | End | Public caption source |
|---:|---:|---|
| 0.100 | 6.170 | Per-capita GDP across 21 Italian regions begins mainly unimodal after the war. |
| 6.870 | 11.830 | Here, year is an ordered factor, so `npcdens()` smooths across observed year levels. |
| 12.450 | 17.550 | Across later years, two clear peaks emerge, corresponding to the wealthier North and less wealthy South. |
| 17.950 | 21.470 | One call reveals the whole conditional density, not merely an average. |
| 21.810 | 23.690 | The full script is on Gallery Video Demos. |

The automated model misrecognized parts of the ordered-factor sentence and the
function name. The WebVTT file was therefore corrected manually against the
approved public text and the visible ChatGPT Voice response. Public captions do
not reproduce the private `N P see dense` phonetic spelling.

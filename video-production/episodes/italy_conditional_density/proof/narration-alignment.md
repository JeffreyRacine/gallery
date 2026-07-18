# Italy narration alignment proof

The retained narration master is one continuous Cove response captured with
the microphone muted. It has no word-level splice.

- duration: 23.400 seconds;
- initial silence: 0.114 seconds;
- trailing silence: 0.124 seconds;
- integrated loudness: -16.5 LUFS;
- loudness range: 2.4 LU;
- true peak: -1.5 dBTP;
- SHA-256:
  `defc7f330c18aebc7a07c2112d2f58c4a6e4598ff8608c6732bd22f03761cb05`.

Faster Whisper `tiny.en` supplied alignment hints, not caption wording:

| Start | End | Public caption source |
|---:|---:|---|
| 0.000 | 5.800 | Per-capita GDP across 21 Italian regions begins mainly unimodal after the war. |
| 6.200 | 11.000 | Here, year is an ordered factor, so `npcdens()` smooths across observed year levels. |
| 11.740 | 16.760 | Across later years, two clear peaks emerge, corresponding to the wealthier North and less wealthy South. |
| 17.260 | 20.880 | One call reveals the whole conditional density, not merely an average. |
| 20.880 | 23.100 | The full script is on Gallery Video Demos. |

The automated model misrecognized parts of the ordered-factor sentence and the
function name. The WebVTT file was therefore corrected manually against the
approved public text and the visible ChatGPT Voice response. Public captions do
not reproduce the private `N P see dense` phonetic spelling.

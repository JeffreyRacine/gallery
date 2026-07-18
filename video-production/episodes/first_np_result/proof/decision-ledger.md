# Candidate A Video Demos Redesign Ledger

Date: 2026-07-18
Status: seedless full-RStudio correction validated and committed locally; no push authorized

## Authorization and decisions

Jeffrey selected a dedicated **Examples -> Video Demos** section with each
episode collapsed by default. Candidate A moves there as the first canonical
entry. **Start Here -> Overview** retains only a compact direct link.

During final review Jeffrey also corrected two durable details:

1. episode outros direct viewers to the Gallery **Video Demos** page, not the
   Start Here page; and
2. deterministic examples such as Candidate A omit `set.seed(42)`. Seed 42 is
   the standing choice only when a demonstration invokes randomness.

No push or publication is authorized.

## Gallery information architecture

Source changes:

- `_quarto.yml`: adds **Video Demos** after **Interactive Demos** under
  **Examples**;
- `video_demos.qmd`: adds the canonical series page and a collapsed Candidate A
  entry containing its player, fallbacks, exact script, provenance, and
  transcript;
- `index.qmd`: replaces the full player with a compact 24-second newcomer link;
- Candidate A's public script, captions, transcript, and MP4 are revised;
- Quarto regenerates the 30-page sidebar, search index, sitemap, new
  `docs/video_demos.html`, and byte-identical rendered asset copies.

The generated search and sitemap files are reordered by the full Quarto site
render while adding the thirtieth page. Their content was retained exactly as
rendered rather than hand-normalized.

## Candidate A media correction

The corrected Cove sentence is:

> Your first reproducible N P analysis is complete, and the full script is on
> the Gallery Video Demos page.

The visible Voice transcript contains exactly that sentence. The raw local
system-audio capture is retained outside Git. The production master replaces
the complete previous final sentence at 17.350 seconds, inside the measured
silence between sentences. This is a sentence-boundary edit, not a word-level
splice. The earlier approved `npreg()` sentence and pronunciation remain
untouched.

The final frame now reads **Gallery -> Examples -> Video Demos**. The visible
load/data frame contains only `library(np)` and the bundled-data command. A
post-review audit found that the later actual-RStudio return still used the
older capture containing `set.seed(42)`. That residual frame has now been
replaced with a fresh installed-build RStudio capture of the deterministic
seedless script. The script, console output, fitted result, and plot agree
throughout the revised master.

Final public asset inventory:

| File | Bytes | SHA-256 |
|---|---:|---|
| `first_np_result.R` | 241 | `de1af5234900e9722c8253bb36f7dd69cf485758e4405b7b881833f864733976` |
| `first_np_result.en.vtt` | 528 | `2a58cd1e6214bf7c60005ed0913d8ce3e09c24cddba35645737d27d0679cd825` |
| `first_np_result.mp4` | 1,930,219 | `e9b8abe6b9616c310230efbcfb314bd40babe3f0162a5f4e26ac7a4c32139a40` |
| `first_np_result_poster.png` | 97,699 | `5e7115743f6a01b3fa39ca31741ebf79dd8a1c3625859af6a6d549fc73ae2d53` |
| `first_np_result_transcript.txt` | 381 | `1b55ba030151177c1813ea9053376261dc47db59ad15b872c7e953f2020871dd` |

The `www/` and `docs/www/` copies are byte-identical.

## Validation

- exact public CRAN builds: `np` 0.70-5 and `crs` 0.15-45 from the
  campaign-local library;
- deterministic installed script: pass, `PROOF_OK`, no unexpected conditions;
- data: bundled `cps71`, 205 observations;
- selected bandwidth: 1.892158;
- measured installed runtime for the revised script: 0.78977585 seconds;
- final MP4: 23.966667 seconds, H.264 High, 1920 x 1080, 30 fps, 719 frames,
  `yuv420p`;
- audio: AAC-LC, mono, 48 kHz, 1,123 frames;
- file size: 1,930,219 bytes;
- integrated narration-master loudness: -16.2 LUFS, 2.2 LU LRA, -1.5 dBFS
  true peak;
- `faststart`: `ftyp` byte 4, `moov` byte 36, `mdat` byte 27,773;
- full error-level MP4 decode: pass;
- WebVTT parse: six cues through 23.900 seconds;
- full 30-page Quarto render: pass without warning;
- Gallery hygiene lint: pass;
- `git diff --check`: pass after removing trailing whitespace only from each
  newly generated Video Demos sidebar item;
- disclosure default state: closed, player dimensions 0 x 0;
- disclosure interaction: opens normally;
- opened player: 23.966667 seconds, 1920 x 1080, native controls,
  `preload="metadata"`, 755 x 424 embedded size;
- default English caption track: showing;
- playback: advances normally;
- page transcript contains **Gallery Video Demos** and no stale **Gallery Start
  Here** outro;
- exact displayed/downloadable script contains no seed and the page explains
  why none is needed.
- extracted late actual-RStudio frame at 19.0 seconds: seed absent; source,
  console, fitted bandwidth, and plot consistent with the public script.

## Claim boundary

This proof supports a narrow local follow-up commit for the Video Demos
architecture and corrected Candidate A bundle. It does not authorize a push,
publication, or a claim that the broader analytical series is validated.

Local commit created after all checks: `640705f` (`Move first video into
collapsible Video Demos`). The branch was not pushed.

Follow-up correction commit: `27586e1` (`Remove residual seed from first
video`). It replaces only the source and rendered MP4 copies after a fresh
seedless installed-build RStudio capture and media validation. The branch was
not pushed.

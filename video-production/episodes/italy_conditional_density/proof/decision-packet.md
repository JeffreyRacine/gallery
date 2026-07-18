# Italy Conditional-Density Decision Packet

Date: 2026-07-18
Status: silent animatic, pronunciation, and corrected narrated prototype
approved; no Gallery promotion proposed

## Jeffrey decisions — 2026-07-18

1. Camera approved at `theta = 90`, `phi = 45`, with one fixed perspective.
2. Regional wording revised to “wealthier North and less wealthy South.”
3. The ordered-factor sentence is retained and surfaced explicitly below.
4. Cove production pronunciation is `N P see dense`; run a short in-context
   probe before recording the eventual complete narration.

The silent hybrid animatic implements Candidate A's approved
RStudio/close-up/RStudio grammar. Jeffrey approved the 90/45 camera, silent
animatic, and `N P see dense` pronunciation on 2026-07-18. The complete Cove
narration was then captured with the microphone muted and synchronized without
changing the approved visual stream.

## Revised narration text

> Per-capita GDP across 21 Italian regions begins mainly unimodal after the
> war. Here, year is an ordered factor, so `npcdens()` smooths across observed
> year levels. Across later years, two clear peaks emerge, corresponding to the
> wealthier North and less wealthy South. One call reveals the whole
> conditional density, not merely an average. The full script is on Gallery
> Video Demos.

The private Cove prompt substitutes only `N P see dense` for the public
function spelling. Code, captions, transcript, overlays, and Gallery prose
retain `npcdens()`.

## Review artifacts

### Silent fixed-angle animatic

- `renders/italy_cdens_silent_draft_animatic.mp4`
- `proof/italy_cdens_silent_animatic_contact_sheet.png`
- 25.000 seconds; 1920 x 1080; 30 fps; H.264; `yuv420p`; no audio.
- 750 frames; 1,290,138 bytes.
- Fast-start layout: `ftyp` at byte 4, `moov` at byte 36, and `mdat` at byte
  9,867.
- Full decode: pass.
- SHA-256:
  `e536a951e5766bb55462a7963ba71fc62ae23c198875d146edfe62522c757b98`.
- The 90/45 plot remains fixed. The only motion is a restrained 0.35-second
  dissolve between storyboard frames.
- A fresh installed-build Italy RStudio capture appears before and after the
  controlled close-ups; unrelated assistant controls and the campaign-local
  path are masked, while code, summary values, object names, and plot remain
  unaltered.

### Cove pronunciation listening probe

- Public spelling: `npcdens()`.
- Private production cue: `N P see dense`.
- Exact probe sentence: “One N P see dense call reveals the whole conditional
  density, not merely an average.”
- Listening file:
  `captures/edited/italy_cdens_chatgpt_voice_pronunciation_listening_probe.wav`.
- One continuous response; no word splice; 5.050 seconds; mono 48 kHz PCM.
- Measured listening level: -16.2 LUFS; true peak -1.5 dBTP; LRA 0.6 LU.
- SHA-256:
  `c145c55633e7b181f0c8b2110c46d391eac271c29b4e537c31188b5cd7f97c48`.
- The retained capture was made with the microphone muted. Unrelated ambient
  audio from an aborted opening attempt is absent from the raw and edited
  probe artifacts.

## Completed prototype review gate

Jeffrey has approved items 1-4 below for the silent/probe gate:

1. the pronunciation of `N P see dense` in the five-second listening probe;
2. the revised narration text and ordered-factor sentence;
3. the 25-second silent pacing and visual density; and
4. the RStudio/close-up/RStudio structure and final Video Demos route.

Jeffrey's first full-take review identified only the pronunciation of
`unimodal`: Cove used an “unny-modal” opening. The replacement is a fresh
24.02-second continuous take using the private cue `you knee modal`; it is not
a word splice. It has no five-second vocal pre-roll and is padded with silence
through the unchanged 25-second outro. Jeffrey approved that corrected cut on
2026-07-18. Nothing in this packet is a Gallery promotion candidate.

## Evidence summary

- Public CRAN `np` 0.70-5 installed proof: pass.
- Dataset: 1,008 rows, 21 regions, 48 ordered year levels, 1951-1998.
- `Italy$year`: `ordered/factor`, verified from the installed object and help.
- Five-run total fit/summary/plot time: 2.733-2.765 seconds, median 2.745.
- Result parity: exact across the five fresh runs.
- Provisional public script: six essential statements, no unnecessary seed.
- Initial and refined contact sheets: rendered from one installed fit per
  sheet; no package-source or development-build code used.

## Scratch artifacts

- `scripts/italy_conditional_density_short.R`
- `scripts/run_italy_cdens_proof.R`
- `scripts/render_italy_cdens_angle_study.R`
- `scripts/render_italy_cdens_angle_contact_sheet.sh`
- `scripts/render_italy_cdens_angle_refinement.sh`
- `proof/italy_cdens_fixed_angle_contact_sheet.png`
- `proof/italy_cdens_fixed_angle_refinement.png`
- `renders/italy_cdens_approved_theta90_phi45.png`
- `captures/edited/italy_cdens_rstudio_full_window_sanitized_1920x1080.png`
- `review/silent-animatic.mp4`
- `review/narrated-prototype.mp4`
- `review/contact-sheet.png`
- `narration/italy_cdens_chatgpt_voice_probe.txt`
- `narration/italy_cdens_chatgpt_voice_prompt.txt`
- `narration/pronunciation_probe.wav`
- `narration/narration_master.wav`
- `storyboards/ITALY_CONDITIONAL_DENSITY_STORYBOARD.md`
- `narration/italy_cdens_draft.txt`
- `captions/italy_cdens_draft.vtt`
- `manifests/italy_conditional_density.yml`

The compact reproducible source and review bundle is now retained under
`video-production/episodes/italy_conditional_density/`. Raw captures, rejected
takes, and generated caches remain outside Git and are listed in the campaign
archive manifest.

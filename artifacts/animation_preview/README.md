# Animation Preview Hub

Syfte: samla alla lokala HTML-previews for karaktarer och animationstester pa ett stalle med tydliga roller.

## Rekommenderad pipeline

1. `reference_preview`
   - Kallmaterial eller rorelsereferens.
   - Exempel: `pivot_reference_preview/`
2. `still_preview`
   - Baspose, proportioner, siluett och lagerkontroll.
   - Exempel: `skogshjalte_still_preview/`
3. `motion_lab`
   - Timing, amplitud, kedjerorelse och ledmappning.
   - Exempel: `skogshjalte_motion_lab/`
4. `clean_preview`
   - Ren oversattning av godkand rorelse till karaktarens faktiska preview-rigg.
   - Exempel: `skogshjalte_pivot_clean_preview/`
5. `walk`
  - Dedikerad gang-preview for att lasa tyngdskifte, fotrullning och secondary motion.
  - Exempel: `skogshjalte_walk_preview/`
6. `scene_preview`
   - Flera karaktarer eller mer produktlika situationer.
   - Exempel: `skog_loke_forest_log_celebrate_preview/`

## Nuvarande previews

- `pivot_reference_preview/`
  - Roll: rorelsereferens fran Pivot Animator.
  - Status: kallmaterial, inte target-preview.
- `skogshjalte_still_preview/`
  - Roll: baspose och assetkontroll for Skogshjalte.
  - Status: startpunkt for design och proportioner.
- `skogshjalte_motion_lab/`
  - Roll: flerleds-labb for overkropp, pelvis och wave-test.
  - Status: experimentyta for timing och articulation.
- `skogshjalte_pivot_clean_preview/`
  - Roll: ren mappning av Pivot-vinkning till faktisk humanoid-preview.
  - Status: nuvarande canonical target-preview for Skogshjaltes vinkning.
- `skogshjalte_walk_preview/`
  - Roll: canonical walk-preview for Skogshjalte.
  - Status: aktiv target-preview for gangcykeln.
- `loke_walk_preview/`
  - Roll: walk-reference for segmenterad humanoid-standard.
  - Status: referens for framtida walk-cycles och amplitudjamforelse.
- `skog_loke_forest_log_celebrate_preview/`
  - Roll: scenpreview med flera karaktarer.
  - Status: staging och celebration, inte rigg-source-of-truth.
- `ville2_walk_preview/`
  - Roll: historisk Ville-preview.
  - Status: referensmaterial, inte humanoid-standard.

## Namnregler

- Anvand formatet `<slug>_<purpose>_preview/`.
- Godkanda purpose-namn:
  - `reference`
  - `still`
  - `motion_lab`
  - `pivot_clean`
  - `walk`
  - `scene`
  - `celebrate`

## Arbetsregler

- Lagg inte ny rorelse direkt i scene-preview om motion-lab eller clean-preview saknas.
- Om en preview blir canonical for en rorelse, skriv det tydligt i HUD-text eller i denna fil.
- Nar en preview bara ar historisk referens, markera den som historisk i hubben i stallet for att lata den se aktuell ut.

## Snabbstart

- Oppna `index.html` i denna mapp for en samlad oversikt over alla previews.
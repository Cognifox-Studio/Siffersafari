# Karaktärsanimationer (Ville / mascot)

Mål: hålla ett enda tydligt animationsspår för Ville och andra karaktärer i UI:t.

## Riktning

Från och med 2026-03-10 är riktningen hybrid:

- Rive för karaktärer (Ville och andra interaktiva figurer)
- Lottie för UI-effekter (konfetti, stjärnor, korta sekvenser)

Från och med 2026-03-10 stöder vi flera animationsstater per tema (idle, happy, celebrate, error) via `CharacterAnimationState` enum och flexibel asset-konfigurering i `AppThemeConfig`.

Det innebär:

- ✅ en JSON-fil per animation-state per tema (inte en stor kombinerad fil)
- ✅ enkel fallback-logik (t.ex. happy → idle om happy-json inte finns)
- ✅ backward-kompatibilitet (gamla `ThemeMascot` constructor fungerar fortfarande)
- ❌ inga frame-sekvenser för Ville i produktkoden
- ❌ inga procedural mascot-animationer i Flutter som alternativt huvudspår

## Nuläge

- `ThemeMascot` och `CharacterAnimationPlayer` använder Rive om `characterRiveAsset` finns och är aktiverad
- annars fallback till Lottie per state (`characterIdleAsset`, `characterHappyAsset`, etc.)
- om varken Rive eller Lottie kan laddas visas en tydlig placeholder i UI:t

## Rekommenderat arbetsflöde

### 1. Ta fram animationen
1. Ta fram eller exportera en färdig Rive-animation (`.riv`) för karaktären
2. Lägg state machine i filen (idle, happy, celebrate, error)
3. Namnge enligt mönster: `ville_{tema}.riv` (t.ex. `ville_jungle.riv`)
4. Om ni saknar Rive för ett tema: använd tillfällig Lottie fallback per state
5. Namnge Lottie-fallback enligt mönster: `ville_{tema}_{state}.json` (t.ex. `ville_jungle_happy.json`)
3. Lägg utkast i `artifacts/` tills animationen är godkänd
4. Testa i lokal preview (se HTML-preview i `artifacts/animation_preview/`)

## Preview-labb for humanoider

For Loke, Skogshjalte och framtida humanoider ska animationer inte tas fram direkt i produktkod eller scenpreview. Anvand i stallet denna preview-kedja:

1. `reference_preview`
   - rorelsereferens eller kallmaterial
2. `still_preview`
   - baspose, siluett, lager och proportioner
3. `motion_lab`
   - timing, amplitud, ledkedjor och articulation
4. `clean_preview`
   - ren oversattning av godkand rorelse till final preview-rigg
5. `scene_preview`
   - fler karaktarer eller mer produktlika situationer

Aktuella canonical previews:

- `artifacts/animation_preview/skogshjalte_walk_preview/`
  - canonical walk-preview for Skogshjaltes gangcykel
- `artifacts/animation_preview/loke_walk_preview/`
  - walk-reference for segmenterad humanoidstandard
- `artifacts/animation_preview/skogshjalte_pivot_clean_preview/`
  - canonical clean preview for Skogshjaltes Pivot-vinkning

Aktiva stodpreviews:

- `artifacts/animation_preview/pivot_reference_preview/`
  - kallmaterial och timingreferens
- `artifacts/animation_preview/skogshjalte_still_preview/`
  - pose och assetkontroll
- `artifacts/animation_preview/skogshjalte_motion_lab/`
  - experimentyta for flerledsrorelse
- `artifacts/animation_preview/skog_loke_forest_log_celebrate_preview/`
  - scenpreview, inte rigg-source-of-truth

Historisk preview:

- `artifacts/animation_preview/ville2_walk_preview/`
  - bevarad som referens, men inte canonical humanoidstandard

### 2. Integrera i appen
1. Flytta godkänd `.riv` och eventuella `.json` till `assets/animations/`
2. Registrera i `pubspec.yaml` (i assets-sektionen)
3. Uppdatera `lib/core/theme/app_theme_config.dart`:
   ```dart
   case AppTheme.jungle:
     return const AppThemeConfig(
       // ...
       characterRiveAsset: 'assets/animations/ville_jungle.riv',
       characterRiveStateMachine: 'State Machine 1',
       characterIdleAsset: 'assets/animations/ville_jungle_idle.json',
       characterHappyAsset: 'assets/animations/ville_jungle_happy.json',
       characterCelebrateAsset: 'assets/animations/ville_jungle_celebrate.json',
       characterErrorAsset: 'assets/animations/ville_jungle_error.json',
       // ...
     );
   ```

### 3. Använda i widgets
```dart
// Alternativ 1: Enkel (idle-state)
ThemeMascot(
  lottieAsset: characterLottieAsset,
  height: 120,
)

// Alternativ 2: Med state-kontroll
ThemeMascot.withState(
  appThemeConfig: themeCfg,
  state: CharacterAnimationState.celebrate,
  height: 120,
)

// Alternativ 3: Ny dedicated widget
CharacterAnimationPlayer(
  appThemeConfig: themeCfg,
  state: CharacterAnimationState.happy,
  height: 120,
)
```

## Rekommenderade Ville-animationer per tema

De första animationerna bör vara små och tydliga:

| State | Användning | Längd | Loopers |
|-------|-----------|-------|---------|
| **idle** | Viloläge, start-skärm, mellan quiz | 1.0–2.0s | ✓ Loop |
| **happy** | Rätt svar, bra resultat | 0.8–1.5s | eller enklare idle |
| **celebrate** | Upplåsning, stor seger | 1.5–2.5s | eller loop |
| **error** | Fel svar, misslyckande | 0.8–1.2s | eller idle |

## Asset-struktur

Lägg bara in godkända karaktärsassets i `assets/animations/`.

Exempel:

```
assets/animations/
  celebration.json              (feedback, generisk)
  ville_jungle.riv              (primär karaktärsanimation via Rive)
  ville_jungle_idle.json        (Ville i djungel, idle)
  ville_jungle_happy.json       (Ville i djungel, happy)
  ville_jungle_celebrate.json   (Ville i djungel, celebrate)
  ville_jungle_error.json       (Ville i djungel, error)
  ville_space_idle.json
  ville_space_happy.json
  ...
```

## Implementationsdetaljer

### CharacterAnimationState enum
```dart
enum CharacterAnimationState {
  idle,      // Default resting state
  happy,     // Happy/pleased state
  celebrate, // Celebration/victory state
  error,     // Error/confused state
}
```

### AppThemeConfig.getCharacterAnimation(state)
Helpermetod som returnerar rätt asset för en state:
- Om specifik state-asset saknas fallback till `idle`
- Om idle-asset saknas fallback till legacy `characterLottieAsset`

### AppThemeConfig.shouldUseRiveCharacter
Helper som styr rendering:
- `true` när `preferRiveCharacter` är aktivt och `characterRiveAsset` är satt
- annars används Lottie-fallback per state

## Nästa steg

1. **Fas 1 (denna vecka):** Exportera `ville_jungle_idle.json`, `ville_jungle_happy.json`, `ville_jungle_celebrate.json` från valfri editor
2. **Fas 2 (nästa vecka):** Test i `CharacterAnimationPlayer` med quiz-integration
3. **Fas 3:** Exportera övriga teman (space, underwater, fantasy)
4. **Framtid:** Flytta fler karaktärer till Rive, behåll Lottie för UI-juicing

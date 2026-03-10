# Karaktärsanimationer (Ville / mascot)

Mål: hålla ett enda tydligt animationsspår för Ville och andra karaktärer i UI:t.

## Riktning

Från och med 2026-03-09 är Lottie enda godkända animationsspår för Ville i repo:t.

Från och med 2026-03-10 stöder vi flera animationsstater per tema (idle, happy, celebrate, error) via `CharacterAnimationState` enum och flexibel asset-konfigurering i `AppThemeConfig`.

Det innebär:

- ✅ en JSON-fil per animation-state per tema (inte en stor kombinerad fil)
- ✅ enkel fallback-logik (t.ex. happy → idle om happy-json inte finns)
- ✅ backward-kompatibilitet (gamla `ThemeMascot` constructor fungerar fortfarande)
- ❌ inga frame-sekvenser för Ville i produktkoden
- ❌ inga procedural mascot-animationer i Flutter som alternativt huvudspår

## Nuläge

- `lottie` är appens animationspaket för förhandsgranskade och godkända animationer
- `ThemeMascot` och nya `CharacterAnimationPlayer` rendererar mascot-animationer från Lottie-filer
- `AppThemeConfig` definierar animationsstater per tema via `characterIdleAsset`, `characterHappyAsset`, etc.
- om en kuraterad mascot-Lottie ännu inte finns visas en tydlig placeholder i UI:t tills animationen är klar

## Rekommenderat arbetsflöde

### 1. Ta fram animationen
1. Ta fram eller exportera en färdig Lottie-animation utanför appen
2. Namnge enligt mönster: `ville_{tema}_{state}.json` (t.ex. `ville_jungle_happy.json`)
3. Lägg utkast i `artifacts/` tills animationen är godkänd
4. Testa i lokal preview (se HTML-preview i `artifacts/animation_preview/`)

### 2. Integrera i appen
1. Flytta godkänd `.json` till `assets/animations/`
2. Registrera i `pubspec.yaml` (i assets-sektionen)
3. Uppdatera `lib/core/theme/app_theme_config.dart`:
   ```dart
   case AppTheme.jungle:
     return const AppThemeConfig(
       // ...
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

Lägg bara in godkända Lottie-filer i `assets/animations/`.

Exempel:

```
assets/animations/
  celebration.json              (feedback, generisk)
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

## Nästa steg

1. **Fas 1 (denna vecka):** Exportera `ville_jungle_idle.json`, `ville_jungle_happy.json`, `ville_jungle_celebrate.json` från valfri editor
2. **Fas 2 (nästa vecka):** Test i `CharacterAnimationPlayer` med quiz-integration
3. **Fas 3:** Exportera övriga teman (space, underwater, fantasy)
4. **Framtid:** Om komplex riggning behövs → evaluera Rive (men Lottie räcker för nu)

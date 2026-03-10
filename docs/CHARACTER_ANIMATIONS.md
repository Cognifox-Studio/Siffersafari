# Karaktärsanimationer (Ville / mascot)

Mål: hålla ett enda tydligt animationsspår för Ville och andra karaktärer i UI:t.

## Riktning

Från och med 2026-03-09 är Lottie enda godkända animationsspår för Ville i repo:t.

Det innebär:

- inga frame-sekvenser för Ville i produktkoden
- inga procedural mascot-animationer i Flutter som alternativt huvudspår
- inga lokala generatorflöden för spritepacks i repo:t

## Nuläge

- `lottie` är appens animationspaket för förhandsgranskade och godkända animationer
- `ThemeMascot` renderar mascot-animation endast från en Lottie-fil som är definierad för temat
- om en kuraterad mascot-Lottie ännu inte finns visas en tydlig placeholder i UI:t tills animationen är klar

## Rekommenderat arbetsflöde

1. Ta fram eller exportera en färdig Lottie-animation utanför appen.
2. Lägg utkast i `artifacts/` tills animationen är godkänd.
3. Flytta godkänd `.json` till `assets/animations/`.
4. Koppla in animationen via temat och visa den genom `ThemeMascot`.

## Rekommenderade Ville-animationer

De första animationerna bör vara små och tydliga:

- idle loop
- walk loop
- wave / greeting
- celebrate / reward
- thinking / hint

## Asset-struktur

Lägg bara in godkända Lottie-filer i `assets/animations/`.

Exempel:

```
assets/animations/
  ville_idle.json
  ville_walk.json
  ville_wave.json
```

## Praktisk användning i appen

Karaktärsanimationer ska kopplas via `AppThemeConfig.characterLottieAsset`.

Om Lottie-filen saknas eller inte kan laddas ska `ThemeMascot` visa en placeholder, inte byta till något annat animationsspår.

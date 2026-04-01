---
description: "Konventioner för lib/features/ – feature-ägda skärmar, dialoger och widgets i hybrid feature-first-struktur"
applyTo: "lib/features/**"
---

# Feature-konventioner (Siffersafari)

## Syfte

`lib/features/` används för feature-ägd UI i den pågående övergången till feature-first struktur.

Lägg ny feature-specifik UI här i stället för i `lib/presentation/` när koden tydligt hör till en enskild feature.

## Struktur

Följ befintligt mönster:

```text
lib/features/<feature>/
  presentation/
    screens/
    dialogs/
    widgets/
```

Nuvarande exempel finns i:

- `lib/features/profiles/presentation/`
- `lib/features/home/presentation/`
- `lib/features/quiz/presentation/`
- `lib/features/onboarding/presentation/`

## Ägarskap

- Feature-ägd skärm, dialog eller widget ska ligga kvar i sin featuremapp.
- Flytta bara kod till `lib/core/` när den är tydligt tvärgående och återanvänds av flera features.
- Lägg inte ny feature-specifik UI i `lib/presentation/` om den naturligt hör till en befintlig feature.

## Beroenden

- Featurekod får använda `core/`, `domain/`, `data/` och etablerade delade widgets/utilities.
- Featurekod får tillfälligt importera legacy-UI från `lib/presentation/` där hybridstrukturen redan gör det.
- Undvik direkta beroenden mellan features om det går. Flytta gemensamma abstraktioner till `core/` eller `domain/` i stället för att skapa korskopplingar.

## UI-mönster

- Följ samma presentationsregler som i `.github/instructions/presentation.instructions.md` för widgets, navigering, Riverpod, `ThemedBackgroundScaffold` och responsiv layout.
- Screens i features följer samma mönster som övriga screens: använd `ConsumerWidget` eller `ConsumerStatefulWidget` när `ref` behövs.
- Dialoger följer samma wrapper-mönster som i `create_user_dialog.dart`: en top-level `showXxxDialog(...)` som öppnar en privat dialogklass.
- Feature-widgets ska hålla sina beroenden explicita via konstruktorparametrar när de inte själva behöver `ref`.

## Namngivning

- Filnamn: `snake_case.dart`
- Screens: `*_screen.dart`
- Dialoger: `*_dialog.dart`
- Feature-widgets: beskrivande namn utifrån användning, till exempel `home_story_progress_card.dart`

## Praktiska regler

- Bevara feature-lokal copy och UI-logik nära skärmen eller dialogen om den inte används brett.
- Återanvänd befintliga `AppConstants`, tema-tokens och providers i stället för lokala ad hoc-konstanter.
- När en feature växer: skapa fler små widgets i featuremappen innan du flyttar upp kod till delade lager.

## Undvik

- Nya featuremappar utan tydligt ägarskap eller utan att följa `presentation/`-strukturen.
- Att lägga feature-specifika helpers i `core/` för tidigt.
- Att skapa nya korsimportsberoenden mellan features när samma resultat kan uppnås via `core/` eller `domain/`.
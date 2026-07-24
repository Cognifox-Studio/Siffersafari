# Start Har i lib

Detta ar den snabbaste kartan over appkoden.

## Borja har beroende pa vad du vill forsta

- Andra en skarm: `features/<feature>/presentation/`
- Forsta varfor en knapp, hero eller CTA visas: featurets provider eller read model
- Forsta quizregler, progression eller resultatmerge: `core/services/`
- Forsta var data sparas: `data/repositories/local_storage_repository.dart`
- Forsta startflodet: `main.dart` -> `app/bootstrap/presentation/`

## Lager i praktiken

- `app/`: startup, splash och gates in i appen
- `features/`: featureagda skarmar, dialoger, widgets och vissa providers
- `core/`: appstate, DI, services, tema och utilities
- `domain/`: ren Dart-logik utan Flutter
- `data/`: Hive-lagring och repository-lager
- `presentation/widgets/`: bara delad UI

## Namnsignaler

- `*_screen.dart`: entrypoint for en skarm
- `*_dialog.dart`: modal eller kort sidoflod
- `*_provider.dart`: state, wiring eller read model-provider
- `__*_part.dart`: intern del till filen bredvid, inte en fristaende modul
- `*_service.dart`: regelmotor eller teknisk integration

## Nasta kartor

- `features/START_HERE.md`
- `core/services/SERVICES_INDEX.md`
- `../docs/TRACE_MAP.md`
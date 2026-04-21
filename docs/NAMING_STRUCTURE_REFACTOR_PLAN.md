<!--
typ: how-to
syfte: Genomför namn- och strukturstädning stegvis utan att bryta imports, tester eller onboarding.
uppdaterad: 2026-04-18
-->

# Naming & Structure Refactor Plan

Status: Våg 1-5 är implementerade. Våg 6 är delvis implementerad genom docssync och audit-guard. Historiska pathar i vågbeskrivningarna nedan finns kvar som migrationshistorik.

## Syfte

Den här planen beskriver hur repo:t ska städas upp så att en ny utvecklare snabbare kan förstå:

- vilken kod som är feature-ägd
- vad som är delad UI eller global app-infrastruktur
- vilka filer som är aktiva, legacy eller bara historiska spår
- vilka entrypoints som är de riktiga vägarna in i appen

Planen är avsiktligt stegvis. Målet är inte en stor engångsrefaktor utan en serie tydliga vågor där varje våg lämnar kodbasen i ett bättre och verifierat läge.

## Målbild

- Tekniska fil- och symbolnamn är engelska och ASCII-baserade.
- Feature-ägd UI ligger under `lib/features/<feature>/presentation/widgets/`.
- `lib/presentation/widgets/` innehåller bara verkligt delad UI och app-shell-komponenter.
- Feature-specifik state ligger nära respektive feature när det inte skapar onödiga korsberoenden.
- Legacy-filer och stale docsreferenser tas bort i samma våg som deras ersättare landar.
- Dokumentationen pekar alltid på de kanoniska entrypointsen.

## Gör Samtidigt

Följande arbete ska göras samtidigt som själva rename- och flyttvågorna:

1. Lägg in en kort naming-standard i `docs/README.md`, `docs/ARCHITECTURE.md` och `docs/PROJECT_STRUCTURE.md`.
2. Rensa stale referenser i samma patch som varje rename eller flytt.
3. Lägg till en kort sektion med canonical entrypoints i dokumentationen.
4. Standardisera testhelpers där namnkollisioner redan finns, särskilt `integration_test/integration_test_utils.dart` mot `test/test_utils.dart`.
5. Skapa målmappar innan första större widgetflytt.
6. Håll en separat retire-lista så att legacy-filer inte bara får nya namn av misstag.
7. Fånga en analyze-baseline före första vågen så att nya problem kan särskiljas från redan existerande analyzerfel.
8. Inför en tillfällig migrationsregel: lägg inte ny kod i `lib/presentation/widgets/`, `lib/shared/` eller andra legacy-zoner medan flyttvågorna pågår, utom när kod tas bort eller flyttas ut därifrån.
9. Lägg till en enkel audit-guard som hittar pensionerade namn och förbjudna legacy-pathar efter varje våg, antingen som audit-test eller som ett litet verifieringsskript.
10. Lås importstilen under migreringen: använd `package:siffersafari/...` för cross-feature- och core-importer, och undvik nya relativa imports mellan features.

## Naming-Standard

### Kod

- Dart-filer: `snake_case.dart`
- Screens: `*_screen.dart`
- Dialoger: `*_dialog.dart`
- Feature-widgets: beskrivande namn efter ansvar, inte historiska alias
- Publika metoder ska signalera ansvar och sidoeffekt tydligt
- Undvik generiska namn som `build`, `finish`, `process`, `handle` eller `update` i services och state-notifiers om mer precis terminologi är möjlig

### Arkitektur

- Feature-ägd UI hör hemma i featuremappen
- Delad UI ska vara dokumenterat motiverad för att få ligga kvar i `lib/presentation/widgets/`
- `core/providers/` ska reserveras för globala appproviders, DI-bryggor och tydligt tvärgående state
- Legacy-mappar som `shared/` ska inte få nya långsiktiga ansvar
- Cross-feature-importer ska vara tydliga och stabila; under migreringen ska nya relativa imports mellan features undvikas

### Dokumentation och tooling

- Nya tekniska dokument ska ha engelska filnamn
- Forskningsmaterial och historiska spår ska särskiljas från aktiv referensdokumentation
- Prompt-, script- och artifactnamn ska vara lowercase ASCII när det är praktiskt möjligt

## Canonical Entrypoints

- Startup: `lib/main.dart`, `lib/app/bootstrap/presentation/startup_splash_gate.dart`, `lib/app/bootstrap/presentation/startup_flow_gate.dart`
- Home: `lib/features/home/presentation/screens/home_screen.dart`
- Quiz: `lib/features/quiz/presentation/screens/quiz_screen.dart`, `lib/features/quiz/presentation/screens/results_screen.dart`
- Story: `lib/features/story/presentation/screens/story_map_screen.dart`
- Parent mode: `lib/features/parent/presentation/screens/parent_pin_screen.dart`, `lib/features/parent/presentation/screens/parent_dashboard_screen.dart`
- Onboarding: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`, `lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart`
- Test entrypoints: `test/test_utils.dart`, `integration_test/integration_test_utils.dart`
- Docs facit: `docs/ARCHITECTURE.md`, `docs/PROJECT_STRUCTURE.md`, `docs/SERVICES_API.md`

## Retire vs Rename

Skilj alltid mellan dessa två listor innan implementation:

- `rename/move`: aktiv kod som ska leva vidare under tydligare namn eller path
- `retire`: döda, duplicerade eller legacy-filer som ska bort efter att ersättare och referenser är verifierade

En fil får inte flyttas till `rename/move` bara för att undvika att ta bort gammal ballast.

## Vågordning

### Våg 0 – Förberedelser

1. Dokumentera analyze-baseline och kända externa fel.
2. Skapa rename/move-ledger med `old`, `new`, `reason`, `type`, `phase`, `risk`, `verification`.
3. Skapa separat retire-lista.
4. Skapa målmappar för kommande widget- och featureflyttar.
5. Säkerställ att docsindexet kan ta emot den nya naming-guiden.
6. Etablera en tillfällig legacy-freeze för `lib/presentation/widgets/` och `lib/shared/` tills motsvarande vågor är klara.
7. Bestäm om audit-guarden ska vara ett test under `test/unit/audits/` eller ett separat script, och använd samma mekanism i alla följande vågor.

### Våg 1 – Legacy retirement och integrationshelper

Implementera i denna ordning:

1. Döp om `integration_test/test_utils.dart` till `integration_test/integration_test_utils.dart`
2. Uppdatera imports i:
   - `integration_test/app_smoke_test.dart`
   - `integration_test/parent_features_test.dart`
   - `integration_test/parent_pin_security_question_flow_test.dart`
   - `integration_test/screenshots_test.dart`
3. Pensionera `lib/presentation/widgets/mascot_character.dart`
4. Pensionera `lib/presentation/widgets/theme_mascot.dart`
5. Uppdatera stale referenser i `docs/PROJECT_STRUCTURE.md` och `artifacts/RIVE_RIGS_GUIDE.md`

Verifiering:

- workspace-sökning efter `mascot_character`, `theme_mascot` och gamla integrationshelpern
- `flutter analyze`
- relevanta widget- och integrationstester

### Våg 2 – Quiz-widgets till featuremapp

Implementera i denna ordning:

1. Skapa `lib/features/quiz/presentation/widgets/`
2. Flytta `lib/presentation/widgets/answer_button.dart` till quiz-featuret
3. Flytta `lib/presentation/widgets/question_card.dart` till quiz-featuret
4. Uppdatera imports i:
   - `lib/features/quiz/presentation/screens/quiz_screen.dart`
   - `test/widget/accessibility_widgets_test.dart`
   - `integration_test/screenshots_test.dart`

Verifiering:

- workspace-sökning efter gamla widgetpathar
- `flutter analyze`
- quizrelaterade widgettester
- screenshot-test om vågen påverkar imports eller rendering

### Våg 3 – Daily Challenge till egen feature-yta

Implementera i denna ordning:

1. Skapa `lib/features/daily_challenge/presentation/widgets/`
2. Flytta `lib/presentation/widgets/daily_challenge_card.dart` till den nya featureytan
3. Uppdatera imports i:
   - `lib/features/home/presentation/screens/home_screen.dart`
   - `test/widget/daily_challenge_card_test.dart`
4. Flytta `lib/core/providers/daily_challenge_provider.dart` till `lib/features/daily_challenge/providers/daily_challenge_provider.dart`
5. Uppdatera imports i:
   - `lib/features/home/presentation/screens/home_screen.dart`
   - `lib/features/quiz/presentation/screens/results_screen.dart`
   - `test/widget/daily_challenge_card_test.dart`
   - `test/unit/services/daily_challenge_streak_test.dart`
   - `docs/SERVICES_API.md`
   - `docs/Plan.md`

Verifiering:

- workspace-sökning efter gamla daily challenge-pathar
- `flutter analyze`
- home-, results- och daily challenge-relaterade tester

### Våg 4 – Config/provider cleanup

Implementera i denna ordning:

1. Flytta `lib/shared/settings/quiz_feature_settings.dart` till `lib/core/config/quiz_feature_settings.dart`
2. Uppdatera imports i:
   - `lib/core/providers/quiz_provider.dart`
   - `lib/core/providers/missing_number_settings_provider.dart`
   - `lib/core/providers/spaced_repetition_settings_provider.dart`
   - `lib/core/providers/word_problems_settings_provider.dart`
   - `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
3. Pensionera `lib/presentation/providers.dart` om inga aktiva importer tillkommer
4. Låt `lib/core/providers/story_progress_provider.dart` ligga kvar tills en senare, bredare providerarkitektur är definierad

Verifiering:

- workspace-sökning efter gamla config- och barrelpathar
- `flutter analyze`
- onboarding-, quiz- och storyrelaterade tester

### Våg 5 – Högsignal-symboler

Rekommenderade omdöpningar:

- `StoryProgressionService.build(...)` -> `createStoryProgress(...)`
- `OnboardingScreen._finish()` -> `_completeOnboardingAndSaveProfile()`
- `QuizNotifier.goToNextQuestion()` -> `advanceToNextQuestion()`
- `AppUpdateService.installUpdate(...)` -> `startUpdateInstallation(...)`

Verifiering:

- sök bort gamla symbolnamn i kod och tester
- `flutter analyze`
- fokuserade tester för de features där symbolerna används

### Våg 6 – Docs, prompts, scripts och artifacts

1. Synka `docs/README.md`, `docs/ARCHITECTURE.md`, `docs/PROJECT_STRUCTURE.md` och `docs/SERVICES_API.md`
2. Lägg in naming-standard och canonical entrypoints där de saknas
3. Normalisera promptnamn under `.github/prompts/`
4. Planera eventuell omgruppering av `scripts/` i mindre ansvarskluster
5. Normalisera artifactnamn med mellanrum eller blandad casing

Verifiering:

- klickbarhet och riktighet i docsreferenser
- workspace-sökning efter stale namn i docs och tooling

## Checklista För Varje Våg

1. Verifiera att målpathen finns eller skapas i samma patch.
2. Uppdatera alla imports, tester och docsreferenser i samma ändring.
3. Sök bort gamla namn innan vågen räknas som klar.
4. Kör `flutter analyze` efter varje våg som ändrar imports eller publika symboler.
5. Kör fokuserade tester direkt efter varje våg.
6. Kör `flutter test` efter sista rename/move-vågen.
7. Uppdatera docs samma våg när strukturen eller entrypoints ändras.
8. Kör audit-guarden efter varje våg så att pensionerade namn eller förbjudna legacy-pathar inte smyger tillbaka.

## Gör Inte Samtidigt

- ändra inte featurelogik bara för att en fil flyttas
- gör inte bred domänmodellredesign i samma våg
- blanda inte in assetproduktion eller releasearbete
- gör inte copy- eller UX-omskrivningar i samma PR-serie

## Klart När

Planen är genomförd när följande är sant:

- gamla pathar och symbolnamn inte längre förekommer i aktiv kod eller docs
- feature-ägd UI ligger i featuremappar
- delad UI är tydligt avgränsad
- docs pekar på rätt entrypoints och naming-standard
- analyzer- och testresultat är verifierade för varje våg

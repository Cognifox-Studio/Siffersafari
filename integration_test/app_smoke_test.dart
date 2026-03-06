import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:siffersafari/core/di/injection.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/main.dart' as app;

import 'test_utils.dart' as it;

String? _activeOnboardingStep(WidgetTester tester) {
  final stepPattern = RegExp(r'^\d+/\d+$');

  for (final widget in tester.widgetList<Text>(find.byType(Text))) {
    final text = widget.data?.trim();
    if (text != null && stepPattern.hasMatch(text)) {
      return text;
    }
  }

  return null;
}

Future<void> _launchCleanApp(WidgetTester tester) async {
  await app.main();
  await it.settle(tester, const Duration(milliseconds: 1200));

  if (getIt.isRegistered<LocalStorageRepository>()) {
    await getIt<LocalStorageRepository>().clearAllData();
    await tester.pump(const Duration(milliseconds: 120));
  }

  await app.main();
  await it.settle(tester, const Duration(milliseconds: 1200));
}

Future<bool> _completeOnboardingStepIfVisible(WidgetTester tester) async {
  final activeStep = _activeOnboardingStep(tester);

  if ((activeStep?.startsWith('1/') ?? true) &&
      find.text('Vilken årskurs kör du?').evaluate().isNotEmpty) {
    final nextButton = find.widgetWithText(ElevatedButton, 'Nästa');
    if (nextButton.evaluate().isNotEmpty) {
      await it.tap(tester, nextButton);
      await it.settle(tester, const Duration(milliseconds: 500));
      return true;
    }
  }

  if ((activeStep?.startsWith('2/') ?? false) &&
      find.text('Kan barnet läsa?').evaluate().isNotEmpty) {
    final noButton = find.widgetWithText(ElevatedButton, 'Nej');
    if (noButton.evaluate().isNotEmpty) {
      await it.tap(tester, noButton);
      await it.settle(tester, const Duration(milliseconds: 500));
      return true;
    }
  }

  if ((activeStep?.startsWith('3/') ?? false) ||
      ((activeStep?.startsWith('2/') ?? false) &&
          find.text('Kan barnet läsa?').evaluate().isEmpty)) {
    final doneButton = find.widgetWithText(ElevatedButton, 'Klar');
    if (doneButton.evaluate().isNotEmpty) {
      await it.tap(tester, doneButton);
      await it.settle(tester, const Duration(milliseconds: 600));
      return true;
    }

    final nextButton = find.widgetWithText(ElevatedButton, 'Nästa');
    if (nextButton.evaluate().isNotEmpty) {
      await it.tap(tester, nextButton);
      await it.settle(tester, const Duration(milliseconds: 500));
      return true;
    }
  }

  final skipButton = find.widgetWithText(TextButton, 'Hoppa över');
  if (skipButton.evaluate().isNotEmpty) {
    await it.tap(tester, skipButton);
    await it.settle(tester, const Duration(milliseconds: 700));
    return true;
  }

  return false;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Integration (smoke): skapa användare vid behov och starta quiz',
    (tester) async {
      await _launchCleanApp(tester);

      Future<void> ensureHomeVisible() async {
        final operationCardKeys = <Key>[
          const Key('operation_card_addition'),
          const Key('operation_card_subtraction'),
          const Key('operation_card_multiplication'),
          const Key('operation_card_division'),
        ];

        bool hasCreateProfileButton() {
          return find
              .widgetWithText(ElevatedButton, 'Skapa profil')
              .evaluate()
              .isNotEmpty;
        }

        bool hasOperationCards() {
          for (final key in operationCardKeys) {
            if (find.byKey(key).evaluate().isNotEmpty) return true;
          }
          return false;
        }

        final deadline = DateTime.now().add(const Duration(seconds: 35));
        while (DateTime.now().isBefore(deadline)) {
          await _completeOnboardingStepIfVisible(tester);
          if (hasOperationCards() || hasCreateProfileButton()) return;

          // If we're in Settings, go back.
          if (find.text('Inställningar').evaluate().isNotEmpty) {
            final backButton = find.byType(BackButton);
            if (backButton.evaluate().isNotEmpty) {
              await it.tap(tester, backButton);
              await it.settle(tester, const Duration(milliseconds: 700));
              if (hasOperationCards()) return;
            }
          }

          // If we're in Quiz, close it.
          if (find.textContaining('Fråga ').evaluate().isNotEmpty) {
            final close = find.byIcon(Icons.close);
            if (close.evaluate().isNotEmpty) {
              await it.tap(tester, close);
              await it.settle(tester, const Duration(milliseconds: 700));
              if (hasOperationCards()) return;
            }
          }

          // If we're in Results, go back to start.
          final backToStart = find.text('Tillbaka till Start');
          if (backToStart.evaluate().isNotEmpty) {
            await it.tap(tester, backToStart);
            await it.settle(tester, const Duration(milliseconds: 700));
            if (hasOperationCards()) return;
          }

          await tester.pump(const Duration(milliseconds: 120));
          if (hasOperationCards() || hasCreateProfileButton()) return;
        }

        fail(
          'Could not reach Home or Create Profile. Visible texts: '
          '${it.visibleTexts(tester).take(120).toList()}',
        );
      }

      await ensureHomeVisible();

      // Fresh install path: create a user if none exists.
      final createUserHomeButton =
          find.widgetWithText(ElevatedButton, 'Skapa profil');
      if (createUserHomeButton.evaluate().isNotEmpty) {
        await it.tap(tester, createUserHomeButton);
        await it.settle(tester, const Duration(milliseconds: 400));
        // Create user dialog.
        await it.waitFor(
          tester,
          'create-user dialog',
          () => find.text('Skapa användare').evaluate().isNotEmpty,
        );

        await tester.enterText(find.byType(TextField).first, 'Test');
        await it.settle(tester, const Duration(milliseconds: 250));

        await it.tap(tester, find.text('Skapa'));
        await ensureHomeVisible();
      }

      // Onboarding can be pushed via post-frame callback after returning to Home.
      await ensureHomeVisible();

      // Start a quiz by tapping the first available operation card.
      final operationCardKeys = <Key>[
        const Key('operation_card_addition'),
        const Key('operation_card_subtraction'),
        const Key('operation_card_multiplication'),
        const Key('operation_card_division'),
      ];

      Finder? chosenOperation;
      for (final key in operationCardKeys) {
        final candidate = find.byKey(key);
        if (candidate.evaluate().isNotEmpty) {
          chosenOperation = candidate;
          break;
        }
      }

      if (chosenOperation == null) {
        final visibleTexts = tester
            .widgetList<Text>(find.byType(Text))
            .map((w) => w.data)
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        fail(
          'No operation cards found on Home. Visible Text widgets: '
          '${visibleTexts.take(80).toList()}',
        );
      }

      await it.tap(tester, chosenOperation);
      await it.waitFor(
        tester,
        'quiz question visible',
        () => find.textContaining('Fråga ').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 12),
      );

      // Quiz screen should show a question title.
      expect(find.textContaining('Fråga '), findsOneWidget);

      // Close the quiz and return.
      await it.tap(tester, find.byIcon(Icons.close));
      await it.waitFor(
        tester,
        'home operation cards visible',
        () {
          for (final key in operationCardKeys) {
            if (find.byKey(key).evaluate().isNotEmpty) return true;
          }
          return false;
        },
        timeout: const Duration(seconds: 12),
      );

      // Ensure we're back on home (operation cards visible).
      Finder? anyOperation;
      for (final key in operationCardKeys) {
        final candidate = find.byKey(key);
        if (candidate.evaluate().isNotEmpty) {
          anyOperation = candidate;
          break;
        }
      }
      expect(anyOperation, isNotNull);
    },
  );

  testWidgets(
    'Smoke: app startar och hittar huvudskärm',
    (tester) async {
      await _launchCleanApp(tester);
      await it.waitFor(
        tester,
        'app started (onboarding or home)',
        () =>
            find.text('Hoppa över').evaluate().isNotEmpty ||
            find.text('Nu kör vi!').evaluate().isNotEmpty ||
            find.text('Vilken årskurs kör du?').evaluate().isNotEmpty ||
            find.text('Kan barnet läsa?').evaluate().isNotEmpty ||
            find.text('Vad vill du räkna?').evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_addition')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_subtraction')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_multiplication')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_division')).evaluate().isNotEmpty ||
            find.text('Skapa profil').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 35),
      );

      // Verify app is running and we can find key UI elements.
      // Either we're in onboarding or we can see operation cards.
        final onboardingVisible =
          find.text('Hoppa över').evaluate().isNotEmpty ||
            find.text('Nu kör vi!').evaluate().isNotEmpty ||
            find.text('Vilken årskurs kör du?').evaluate().isNotEmpty ||
            find.text('Kan barnet läsa?').evaluate().isNotEmpty ||
            find.text('Vad vill du räkna?').evaluate().isNotEmpty;

      final homeVisible = find
              .byKey(const Key('operation_card_addition'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('operation_card_subtraction'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('operation_card_multiplication'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('operation_card_division'))
              .evaluate()
              .isNotEmpty ||
          find.text('Skapa profil').evaluate().isNotEmpty;

      expect(
        onboardingVisible || homeVisible,
        isTrue,
        reason: 'App should show either onboarding or home screen',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'Smoke: öppna inställningar och gå tillbaka',
    (tester) async {
      await _launchCleanApp(tester);
      await it.waitFor(
        tester,
        'home/onboarding visible',
        () =>
            find.text('Hoppa över').evaluate().isNotEmpty ||
            find.text('Nu kör vi!').evaluate().isNotEmpty ||
            find.text('Skapa profil').evaluate().isNotEmpty ||
            find.byIcon(Icons.settings).evaluate().isNotEmpty ||
            find.byTooltip('Föräldraläge').evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_addition')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_subtraction')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_multiplication')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_division')).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 35),
      );

      while (await _completeOnboardingStepIfVisible(tester)) {
        // complete current onboarding flow
      }

      // Find settings icon (gear icon).
      Future<void> maybeCreateProfile() async {
        final createProfileButton =
            find.widgetWithText(ElevatedButton, 'Skapa profil');
        if (createProfileButton.evaluate().isEmpty) return;

        await it.tap(tester, createProfileButton);
        await it.settle(tester, const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField).first, 'SmokeUser');
        await it.settle(tester, const Duration(milliseconds: 250));
        await it.tap(tester, find.text('Skapa'));
        await it.settle(tester, const Duration(milliseconds: 700));
      }

      Future<void> maybeSkipOnboarding() async {
        if (find.text('Hoppa över').evaluate().isEmpty) return;
        await it.tap(tester, find.text('Hoppa över'));
        await it.settle(tester, const Duration(milliseconds: 700));
      }

      Future<void> ensureParentDashboard() async {
        await maybeCreateProfile();
        await maybeSkipOnboarding();

        await it.waitFor(
          tester,
          'parent mode entry point',
          () => find.byTooltip('Föräldraläge').evaluate().isNotEmpty,
          timeout: const Duration(seconds: 35),
        );

        await it.tap(tester, find.byTooltip('Föräldraläge'));
        await it.settle(tester, const Duration(milliseconds: 500));

        if (find.text('Skapa PIN').evaluate().isNotEmpty) {
          final pinFields = find.byType(TextField);
          expect(pinFields, findsAtLeastNWidgets(2));
          await tester.enterText(pinFields.at(0), '1234');
          await tester.enterText(pinFields.at(1), '1234');
          await it.settle(tester, const Duration(milliseconds: 250));
          await it.tap(tester, find.text('Spara PIN'));
          await it.settle(tester, const Duration(milliseconds: 500));

          if (find.text('Sätt säkerhetsfråga').evaluate().isNotEmpty) {
            final recoveryDialog = find.byType(AlertDialog);
            expect(recoveryDialog, findsOneWidget);
            final answerField = find.descendant(
              of: recoveryDialog,
              matching: find.byType(TextField),
            );
            expect(answerField, findsOneWidget);
            await tester.enterText(answerField, 'hemligt');
            await it.settle(tester, const Duration(milliseconds: 200));
            await it.tap(
              tester,
              find.descendant(
                of: recoveryDialog,
                matching:
                    find.widgetWithText(ElevatedButton, 'Spara säkerhetsfråga'),
              ),
            );
          }
        } else if (find.text('Ange PIN').evaluate().isNotEmpty) {
          final pinField = find.byType(TextField).first;
          await tester.enterText(pinField, '1234');
          await it.settle(tester, const Duration(milliseconds: 200));
          await it.tap(tester, find.text('Öppna'));
        }

        await it.waitForText(tester, 'Översikt');
      }

      await ensureParentDashboard();

      await it.tap(tester, find.byTooltip('Inställningar'));
      await it.waitForText(tester, 'Inställningar');

      // Verify we're in settings.
      expect(
        find.text('Inställningar'),
        findsOneWidget,
      );

      // Go back.
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await it.tap(tester, backButton);
      await it.waitForText(tester, 'Översikt');

      expect(find.text('Översikt'), findsWidgets);
    },
    timeout: const Timeout(
      Duration(
        minutes: 2,
      ),
    ),
  );

  testWidgets(
    'Smoke: hemvyn visar spelkort efter profilskapande',
    (tester) async {
      await _launchCleanApp(tester);

      final createProfileButton =
          find.widgetWithText(ElevatedButton, 'Skapa profil');
      if (createProfileButton.evaluate().isNotEmpty) {
        await it.tap(tester, createProfileButton);
        await it.settle(tester, const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField).first, 'AchievementUser');
        await it.settle(tester, const Duration(milliseconds: 250));
        await it.tap(tester, find.text('Skapa'));
        await it.settle(tester, const Duration(milliseconds: 700));
      }

      while (await _completeOnboardingStepIfVisible(tester)) {
        // complete current onboarding flow
      }

      expect(find.byKey(const Key('operation_card_addition')), findsOneWidget);
      expect(find.text('Poäng'), findsWidgets);
      expect(find.textContaining('Hej'), findsWidgets);
    },
    timeout: const Timeout(
      Duration(
        minutes: 2,
      ),
    ),
  );

  testWidgets(
    'Smoke: profile switcher kan öppnas',
    (tester) async {
      await _launchCleanApp(tester);
      await it.waitFor(
        tester,
        'home/onboarding visible',
        () =>
            find.text('Hoppa över').evaluate().isNotEmpty ||
            find.text('Nu kör vi!').evaluate().isNotEmpty ||
            find.text('Skapa profil').evaluate().isNotEmpty ||
            find.byIcon(Icons.arrow_drop_down).evaluate().isNotEmpty ||
            find.byKey(const Key('profile_selector')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_addition')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_subtraction')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_multiplication')).evaluate().isNotEmpty ||
            find.byKey(const Key('operation_card_division')).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 35),
      );

      Future<void> maybeSkipOnboarding() async {
        while (await _completeOnboardingStepIfVisible(tester)) {
          // complete current onboarding flow
        }
      }

      Future<void> maybeCreateProfile(String name) async {
        final createProfileButton =
            find.widgetWithText(ElevatedButton, 'Skapa profil');
        if (createProfileButton.evaluate().isEmpty) return;
        await it.tap(tester, createProfileButton);
        await it.settle(tester, const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField).first, name);
        await it.settle(tester, const Duration(milliseconds: 250));
        await it.tap(tester, find.text('Skapa'));
        await it.settle(tester, const Duration(milliseconds: 700));
      }

      Future<void> ensureParentDashboard() async {
        await maybeCreateProfile('ProfileSwitchUser');
        await maybeSkipOnboarding();
        await it.waitFor(
          tester,
          'parent mode entry point',
          () => find.byTooltip('Föräldraläge').evaluate().isNotEmpty,
          timeout: const Duration(seconds: 35),
        );
        await it.tap(tester, find.byTooltip('Föräldraläge'));
        await it.settle(tester, const Duration(milliseconds: 500));

        if (find.text('Skapa PIN').evaluate().isNotEmpty) {
          final pinFields = find.byType(TextField);
          expect(pinFields, findsAtLeastNWidgets(2));
          await tester.enterText(pinFields.at(0), '1234');
          await tester.enterText(pinFields.at(1), '1234');
          await it.settle(tester, const Duration(milliseconds: 250));
          await it.tap(tester, find.text('Spara PIN'));
          await it.settle(tester, const Duration(milliseconds: 500));

          if (find.text('Sätt säkerhetsfråga').evaluate().isNotEmpty) {
            final recoveryDialog = find.byType(AlertDialog);
            expect(recoveryDialog, findsOneWidget);
            final answerField = find.descendant(
              of: recoveryDialog,
              matching: find.byType(TextField),
            );
            expect(answerField, findsOneWidget);
            await tester.enterText(answerField, 'hemligt');
            await it.settle(tester, const Duration(milliseconds: 200));
            await it.tap(
              tester,
              find.descendant(
                of: recoveryDialog,
                matching:
                    find.widgetWithText(ElevatedButton, 'Spara säkerhetsfråga'),
              ),
            );
          }
        } else if (find.text('Ange PIN').evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField).first, '1234');
          await it.settle(tester, const Duration(milliseconds: 200));
          await it.tap(tester, find.text('Öppna'));
        }

        await it.waitForText(tester, 'Översikt');
      }

      await ensureParentDashboard();
      await it.tap(tester, find.byTooltip('Inställningar'));
      await it.waitForText(tester, 'Inställningar');

      await it.tap(tester, find.text('Skapa användare'));
      await it.settle(tester, const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField).first, 'AndraUser');
      await it.settle(tester, const Duration(milliseconds: 250));
      await it.tap(tester, find.text('Skapa'));
      await it.settle(tester, const Duration(milliseconds: 700));

      final userDropdown = find.byType(DropdownButton<String>);
      final dropdownFallback = find.byType(DropdownButton);
      if (userDropdown.evaluate().isNotEmpty) {
        await it.tap(tester, userDropdown.first);
      } else {
        await it.tap(tester, dropdownFallback.first);
      }

      await it.waitForText(tester, 'AndraUser');
      expect(find.text('AndraUser'), findsWidgets);

      await tester.tapAt(const Offset(10, 10));
      await it.settle(tester, const Duration(milliseconds: 250));
    },
    timeout: const Timeout(
      Duration(
        minutes: 2,
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:siffersafari/core/di/injection.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/main.dart' as app;

import 'integration_test_utils.dart' as it;

const _kSettleShort = Duration(milliseconds: 250);
const _kSettleMedium = Duration(milliseconds: 400);
const _kSettleLong = Duration(milliseconds: 600);

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

bool _isVisible(Finder finder) => finder.hitTestable().evaluate().isNotEmpty;

Future<void> _drainUiAnimations(WidgetTester tester) async {
  await tester.idle();
  await it.settle(tester, _kSettleMedium);
}

Future<void> _cleanupAfterTest(WidgetTester tester) async {
  // Dispose active controllers/tickers before invariant checks.
  await tester.idle();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await _drainUiAnimations(tester);
}

Future<void> _launchCleanApp(WidgetTester tester) async {
  await app.main();
  await it.settle(tester, _kSettleLong);

  if (getIt.isRegistered<LocalStorageRepository>()) {
    await getIt<LocalStorageRepository>().clearAllData();
    await tester.pump(const Duration(milliseconds: 120));
  }

  await app.main();
  await it.settle(tester, _kSettleLong);
}

Future<bool> _completeOnboardingStepIfVisible(WidgetTester tester) async {
  final activeStep = _activeOnboardingStep(tester);
  final gradeTitle = find.text('Vilken årskurs kör du?');
  final readingTitle = find.text('Kan barnet läsa?');

  if (_isVisible(readingTitle)) {
    final noButton = find.text('Nej').hitTestable();
    if (noButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(noButton.first);
      await tester.tap(noButton.first);
      await it.settle(tester, _kSettleMedium);
      return true;
    }
  }

  if ((activeStep?.startsWith('1/') ?? true) && _isVisible(gradeTitle)) {
    final nextButton = find.widgetWithText(ElevatedButton, 'Nästa');
    if (nextButton.evaluate().isNotEmpty) {
      await it.tap(tester, nextButton);
      await it.settle(tester, _kSettleMedium);
      return true;
    }
    // Single-step onboarding (1/1): the only button is "Starta".
    final startButton = find.widgetWithText(ElevatedButton, 'Starta');
    if (startButton.evaluate().isNotEmpty) {
      await it.tap(tester, startButton);
      await it.settle(tester, _kSettleMedium);
      return true;
    }
  }

  final skipButton = find.widgetWithText(TextButton, 'Hoppa över');
  if (skipButton.evaluate().isNotEmpty) {
    await it.tap(tester, skipButton);
    await it.settle(tester, _kSettleMedium);
    return true;
  }

  return false;
}

Future<void> _ensureHomeVisible(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 35));
  while (DateTime.now().isBefore(deadline)) {
    await _completeOnboardingStepIfVisible(tester);

    if (find.byTooltip('Föräldraläge').evaluate().isNotEmpty ||
        find
            .widgetWithText(ElevatedButton, 'Skapa profil')
            .evaluate()
            .isNotEmpty ||
        find
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
            .isNotEmpty) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 120));
  }

  fail(
    'Could not reach Home. Visible texts: '
    '${it.visibleTexts(tester).take(120).toList()}',
  );
}

/// Integration tests for parent-facing critical features:
/// - PIN creation happy path
/// - Profile management
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Integration (Parent): skapa PIN och öppna föräldradashboard',
    (tester) async {
      addTearDown(() async {
        await _cleanupAfterTest(tester);
      });
      await app.main();
      await it.settle(tester, const Duration(milliseconds: 600));

      // Navigate to settings (gear icon in top-right).
      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isEmpty) {
        // Skip if onboarding/other UI blocks it.
        return;
      }

      await it.tap(tester, settingsIcon, after: const Duration(seconds: 1));
      await it.settle(tester, const Duration(milliseconds: 300));

      // Find "Föräldraläge" button.
      final parentModeButton = find.text('Föräldraläge');
      expect(parentModeButton, findsOneWidget);

      await it.tap(tester, parentModeButton, after: const Duration(seconds: 1));
      await it.waitForText(
        tester,
        'Skapa PIN',
        timeout: const Duration(seconds: 12),
      );

      // Should show PIN creation screen.
      expect(find.text('Skapa PIN'), findsWidgets);

      // Enter a 4-digit PIN (e.g. 1234).
      final pinFields = find.byType(TextField);
      expect(pinFields, findsNWidgets(2));

      await tester.enterText(pinFields.at(0), '1234');
      await tester.pump(const Duration(milliseconds: 120));
      await tester.enterText(pinFields.at(1), '1234');
      await tester.pump(const Duration(milliseconds: 120));

      final savePinButton = find.text('Spara PIN');
      expect(savePinButton, findsOneWidget);
      await it.tap(
        tester,
        savePinButton,
        after: const Duration(milliseconds: 450),
      );

      // If recovery setup dialog appears, close it.
      if (find.text('Sätt säkerhetsfråga').evaluate().isNotEmpty) {
        final closeRecoveryDialog = find.text('Hoppa över');
        if (closeRecoveryDialog.evaluate().isNotEmpty) {
          await it.tap(
            tester,
            closeRecoveryDialog,
            after: const Duration(milliseconds: 500),
          );
          await it.settle(tester, const Duration(milliseconds: 300));
        }
      }

      // Should now be in Parent Dashboard.
      await it.waitForText(
        tester,
        'Översikt',
        timeout: const Duration(seconds: 20),
      );
      expect(find.text('Översikt'), findsWidgets);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'Integration (Profil): skapa ny profil och byt profil',
    (tester) async {
      addTearDown(() async {
        await _cleanupAfterTest(tester);
      });
      await app.main();
      await it.settle(tester, const Duration(milliseconds: 600));

      // Go to settings.
      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isEmpty) return;

      await it.tap(tester, settingsIcon, after: const Duration(seconds: 1));
      await it.settle(tester, const Duration(milliseconds: 300));

      // Look for "Byt profil" or "Skapa profil".
      final switchProfileButton = find.textContaining('profil');
      if (switchProfileButton.evaluate().isEmpty) return;

      await it.tap(
        tester,
        switchProfileButton.first,
        after: const Duration(milliseconds: 450),
      );
      await it.settle(tester, const Duration(milliseconds: 300));

      // Should show profile selection or creation screen.
      final createProfileButton = find.text('Skapa profil');
      if (createProfileButton.evaluate().isNotEmpty) {
        await it.tap(
          tester,
          createProfileButton,
          after: const Duration(milliseconds: 450),
        );
        await it.settle(tester, const Duration(milliseconds: 300));

        // Enter profile name (e.g. "Test User").
        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'Integration Test User');
        await tester.pump(const Duration(milliseconds: 150));

        // Select grade (Åk 3).
        final gradeDropdown = find.byType(DropdownButton<int?>);
        if (gradeDropdown.evaluate().isNotEmpty) {
          await it.tryTap(
            tester,
            gradeDropdown,
            after: const Duration(milliseconds: 300),
          );
          await tester.pump(const Duration(milliseconds: 120));

          final ak3 = find.text('Åk 3').last;
          if (ak3.evaluate().isNotEmpty) {
            await it.tryTap(
              tester,
              ak3,
              after: const Duration(milliseconds: 300),
            );
            await tester.pump(const Duration(milliseconds: 120));
          }
        }

        // Confirm creation.
        final confirmButton = find.text('Skapa');
        if (confirmButton.evaluate().isNotEmpty) {
          await it.tap(
            tester,
            confirmButton,
            after: const Duration(milliseconds: 450),
          );
          await it.settle(tester, const Duration(milliseconds: 600));
        }

        // Should be back at home with new profile active.
        expect(tester.takeException(), isNull);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'Integration (OTA): kontrollera release från föräldradashboard',
    (tester) async {
      addTearDown(() async {
        await _cleanupAfterTest(tester);
      });
      await _launchCleanApp(tester);
      await _ensureHomeVisible(tester);

      final createUserHomeButton =
          find.widgetWithText(ElevatedButton, 'Skapa profil');
      if (createUserHomeButton.evaluate().isNotEmpty) {
        await it.tap(tester, createUserHomeButton, after: _kSettleShort);
        await it.waitFor(
          tester,
          'create-user dialog',
          () => find.text('Skapa användare').evaluate().isNotEmpty,
        );

        await tester.enterText(find.byType(TextField).first, 'OTA Test');
        await it.settle(tester, _kSettleShort);
        await it.tap(tester, find.text('Skapa'), after: _kSettleMedium);
        await _ensureHomeVisible(tester);
      }

      final parentModeEntry = find.byTooltip('Föräldraläge');
      expect(parentModeEntry, findsOneWidget);
      await it.tap(tester, parentModeEntry, after: const Duration(seconds: 1));

      await it.waitFor(
        tester,
        'parent pin screen visible',
        () =>
            find.text('Skapa PIN').evaluate().isNotEmpty ||
            find.text('Ange PIN').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 15),
      );

      expect(find.text('Skapa PIN'), findsWidgets);
      final pinFields = find.byType(TextField);
      expect(pinFields, findsNWidgets(2));
      await tester.enterText(pinFields.at(0), '1234');
      await tester.pump(const Duration(milliseconds: 120));
      await tester.enterText(pinFields.at(1), '1234');
      await tester.pump(const Duration(milliseconds: 120));
      await it.tap(tester, find.text('Spara PIN'), after: _kSettleMedium);

      if (find.text('Sätt säkerhetsfråga').evaluate().isNotEmpty) {
        await it.tap(tester, find.text('Hoppa över'), after: _kSettleMedium);
      }

      await it.waitFor(
        tester,
        'parent dashboard visible',
        () =>
            find.text('Översikt').evaluate().isNotEmpty ||
            find.text('Appuppdatering').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 20),
      );

      final otaHeading = find.text('Appuppdatering');
      await tester.ensureVisible(otaHeading);
      expect(otaHeading, findsOneWidget);

      await it.tap(
        tester,
        find.widgetWithText(ElevatedButton, 'Sök uppdatering'),
        after: _kSettleMedium,
      );

      await it.waitFor(
        tester,
        'ota release check result',
        () =>
            find.text('Ny uppdatering hittad').evaluate().isNotEmpty ||
            find.textContaining('Ny version finns:').evaluate().isNotEmpty ||
            find
                .textContaining('Du har redan senaste versionen')
                .evaluate()
                .isNotEmpty ||
            find
                .textContaining('Kunde inte kontrollera uppdatering')
                .evaluate()
                .isNotEmpty,
        timeout: const Duration(seconds: 30),
      );

      if (find.text('Ny uppdatering hittad').evaluate().isNotEmpty) {
        expect(
          find.textContaining(
            'Profiler, statistik, PIN och lokala data ligger kvar',
          ),
          findsOneWidget,
        );
        await it.tap(tester, find.text('Inte nu'), after: _kSettleShort);
      }

      expect(find.text('Appuppdatering'), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

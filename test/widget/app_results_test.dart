import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/question_card.dart';
import 'package:siffersafari/main.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  Future<void> tapContinueButton(WidgetTester tester) async {
    const timeout = Duration(seconds: 15);
    final steps = (timeout.inMilliseconds / 50).ceil().clamp(1, 400);

    for (var i = 0; i < steps; i++) {
      await skipOnboardingIfPresent(tester);

      final next = find.byType(ElevatedButton).hitTestable();
      if (next.evaluate().isNotEmpty) {
        await tester.tap(next.last, warnIfMissed: false);
        await tester.pump();
        return;
      }

      


      await tester.pump(const Duration(milliseconds: 50));
    }

    throw TestFailure('Kunde inte hitta fortsatt-knappen i feedbackflödet.');
  }

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] Results – quick practice session from results screen',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      final multiplication =
          find.byKey(const Key('operation_card_multiplication'));
      await pumpUntilFound(tester, multiplication);
      expect(multiplication, findsOneWidget);

      await tester.ensureVisible(multiplication);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, multiplication);
      await pumpUntilFound(tester, find.byType(QuestionCard));
      expect(find.byType(QuestionCard), findsOneWidget);

      for (var i = 0; i < 10; i++) {
        await tester.ensureVisible(find.text('42'));
        await tester.pump();
        await tester.tap(find.text('42'));
        await tapContinueButton(tester);
        if (i < 9) {
          await pumpUntilFound(tester, find.byType(QuestionCard));
        }
      }

      await pumpUntilFound(tester, find.textContaining('Spela igen'));

      await tester.ensureVisible(find.text('Snabbträna ⚡'));
      await tester.tap(find.text('Snabbträna ⚡'));
      await pumpUntilFound(tester, find.byType(QuestionCard));

      expect(find.byType(QuestionCard), findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] Results – empty focus mode when no weaknesses found',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      final multiplication =
          find.byKey(const Key('operation_card_multiplication'));
      await pumpUntilFound(tester, multiplication);
      expect(multiplication, findsOneWidget);

      await tester.ensureVisible(multiplication);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, multiplication);
      await pumpUntilFound(tester, find.byType(QuestionCard));
      expect(find.byType(QuestionCard), findsOneWidget);

      for (var i = 0; i < 10; i++) {
        await tester.ensureVisible(find.text('42'));
        await tester.pump();
        await tester.tap(find.text('42'));
        await tapContinueButton(tester);
        if (i < 9) {
          await pumpUntilFound(tester, find.byType(QuestionCard));
        }
      }

      await pumpUntilFound(tester, find.textContaining('Spela igen'));

      await tester.ensureVisible(find.text('Snabbträna ⚡'));
      await tester.tap(find.text('Snabbträna ⚡'));
      await pumpUntilFound(tester, find.byType(QuestionCard));
      expect(find.byType(QuestionCard), findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] Results – shows story checkpoint reveal after completed quest',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      final addition = find.byKey(const Key('operation_card_addition'));
      await pumpUntilFound(tester, addition);
      expect(addition, findsOneWidget);

      await tester.ensureVisible(addition);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, addition);
      await pumpUntilFound(tester, find.byType(QuestionCard));

      for (var i = 0; i < 10; i++) {
        await tester.ensureVisible(find.text('42'));
        await tester.pump();
        await tester.tap(find.text('42'));
        await tapContinueButton(tester);
        if (i < 9) {
          await pumpUntilFound(tester, find.byType(QuestionCard));
        }
      }

      await pumpUntilFound(tester, find.text('Nytt stopp!'));

      expect(find.text('Nytt stopp!'), findsOneWidget);
      expect(
        find.textContaining('Nästa mål: Hitta borttappade siffror'),
        findsWidgets,
      );
    },
  );
}








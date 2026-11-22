import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/di/injection.dart';
import 'package:siffersafari/core/services/text_to_speech_service.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/question_card.dart';
import 'package:siffersafari/main.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] QuizScreen – visar uppläsning och läser upp feedback när funktionen är på',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'tts-user';
      const user = UserProgress(
        userId: userId,
        name: 'TTS',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);
      await repository.saveSetting(
        SettingsKeys.textToSpeechEnabled(userId),
        true,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      final multiplication =
          find.byKey(const Key('operation_card_multiplication'));
      await pumpUntilFound(tester, multiplication);

      await tester.ensureVisible(multiplication);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, multiplication);
      await pumpUntilFound(tester, find.byType(QuestionCard));

      final speakButton = find.byKey(const Key('quiz_tts_button'));
      await tester.ensureVisible(speakButton);
      expect(speakButton, findsOneWidget);

      await tester.tap(speakButton);
      await tester.pump();

      final tts = getIt<TextToSpeechService>() as MockTextToSpeechService;
      verify(() => tts.speakQuestion(any())).called(1);
      expect(find.text('Stoppa'), findsOneWidget);

      await tester.tap(speakButton);
      await tester.pump();
      verify(() => tts.stop()).called(greaterThanOrEqualTo(1));
      expect(find.text('Läs upp'), findsOneWidget);

      await tester.ensureVisible(find.text('42'));
      await tester.tap(find.text('42'), warnIfMissed: true);
      await pumpUntilFound(tester, find.byType(AlertDialog));

      verify(() => tts.speakFeedback(any())).called(1);
    },
  );

  /// Åk 1–2: read-aloud used to be off by default *and* the button was hidden
  /// unless an adult had found the switch in the parent dashboard, so a child
  /// who cannot read the prompt had no way to hear it at all.
  testWidgets(
    '[Widget] QuizScreen – Åk 2 hör frågan utan att någon slagit på uppläsning',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'young-user';
      const user = UserProgress(
        userId: userId,
        name: 'Loke',
        ageGroup: AgeGroup.young,
        gradeLevel: 2,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);
      // Note: no textToSpeechEnabled setting is written anywhere.

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      final addition = find.byKey(const Key('operation_card_addition'));
      await pumpUntilFound(tester, addition);
      await tester.ensureVisible(addition);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, addition);
      await pumpUntilFound(tester, find.byType(QuestionCard));

      // The affordance is visible without anybody configuring anything...
      final speakButton = find.byKey(const Key('quiz_tts_button'));
      await tester.ensureVisible(speakButton);
      expect(speakButton, findsOneWidget);

      // ...and the question was read out as soon as it appeared.
      final tts = getIt<TextToSpeechService>() as MockTextToSpeechService;
      verify(() => tts.speakQuestion(any())).called(greaterThanOrEqualTo(1));
    },
  );

  testWidgets(
    '[Widget] QuizScreen – Åk 5 får ingen uppläsning förvald',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'older-user';
      const user = UserProgress(
        userId: userId,
        name: 'Noa',
        ageGroup: AgeGroup.middle,
        gradeLevel: 5,
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
      await tester.ensureVisible(multiplication);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, multiplication);
      await pumpUntilFound(tester, find.byType(QuestionCard));

      expect(find.byKey(const Key('quiz_tts_button')), findsNothing);
      final tts = getIt<TextToSpeechService>() as MockTextToSpeechService;
      verifyNever(() => tts.speakQuestion(any()));
    },
  );

  /// Mute has to win: the read-aloud default for Åk 1–2 must not start talking
  /// on a profile whose sound is switched off.
  testWidgets(
    '[Widget] QuizScreen – tyst profil hör varken fråga eller feedback',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'muted-user';
      const user = UserProgress(
        userId: userId,
        name: 'Tyst',
        ageGroup: AgeGroup.young,
        gradeLevel: 2,
        soundEnabled: false,
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
      await tester.ensureVisible(addition);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tapInteractiveDescendant(tester, addition);
      await pumpUntilFound(tester, find.byType(QuestionCard));

      expect(find.byKey(const Key('quiz_tts_button')), findsNothing);

      final tts = getIt<TextToSpeechService>() as MockTextToSpeechService;
      verifyNever(() => tts.speakQuestion(any()));
      verifyNever(() => tts.speakFeedback(any()));
    },
  );
}

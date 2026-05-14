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
      await tester.tap(multiplication);
      await pumpUntilFound(tester, find.byType(QuestionCard));

      final speakButton = find.byKey(const Key('quiz_tts_button'));
      await tester.ensureVisible(speakButton);
      expect(speakButton, findsOneWidget);

      await tester.tap(speakButton);
      await tester.pump();

      final tts = getIt<TextToSpeechService>() as MockTextToSpeechService;
      verify(() => tts.speakQuestion(any())).called(1);

      await tester.ensureVisible(find.text('42'));
      await tester.tap(find.text('42'), warnIfMissed: true);
      await pumpUntilFound(tester, find.byType(AlertDialog));

      verify(() => tts.speakFeedback(any())).called(1);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] QuizNotifier SRS injection', () {
    late InMemoryLocalStorageRepository repository;
    late QuizNotifier notifier;
    const userId = 'test_user';

    setUp(() async {
      repository = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});
      when(() => audio.playCelebrationSound()).thenAnswer((_) async {});

      notifier = QuizNotifier(
        QuestionGeneratorService(),
        FeedbackService(),
        audio,
        repository,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    Future<void> seedSchedules(
      List<({String key, int daysAgo})> schedules,
    ) async {
      final now = DateTime.now();
      final raw = schedules
          .map(
            (s) => {
              'key': s.key,
              'questionId': s.key,
              'nextReviewDate':
                  now.subtract(Duration(days: s.daysAgo)).toIso8601String(),
              'intervalDays': AppConstants.firstReviewInterval,
              'consecutiveCorrect': 0,
            },
          )
          .toList(growable: false);
      await repository.saveSetting(
        SettingsKeys.spacedRepetitionSchedules(userId),
        raw,
      );
    }

    test('injicerar due-nyckel som första fråga i sessionen', () async {
      await seedSchedules([
        (key: 'multiplication|4 × 7 = ?', daysAgo: 1),
      ]);

      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
      );

      final session = notifier.state.session;
      expect(session, isNotNull);
      expect(session!.questions, isNotEmpty);

      final firstQuestion = session.questions.first;
      expect(firstQuestion.operationType, OperationType.multiplication);
      expect(firstQuestion.operand1, 4);
      expect(firstQuestion.operand2, 7);
      expect(firstQuestion.correctAnswer, 28);
    });

    test('cap:ar pendingDueKeys till totalQuestions ~/ 3', () async {
      // young = 8 frågor, cap = 8 ~/ 3 = 2 → så pendingDueKeys ska bli
      // (2 - 1) = 1 efter att första due-nyckeln konsumerats.
      await seedSchedules([
        (key: 'multiplication|2 × 3 = ?', daysAgo: 1),
        (key: 'multiplication|4 × 5 = ?', daysAgo: 1),
        (key: 'multiplication|6 × 7 = ?', daysAgo: 1),
        (key: 'multiplication|8 × 9 = ?', daysAgo: 1),
      ]);

      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
      );

      // Cap = 2 totalt, en användes som första fråga, en kvar i pending.
      expect(notifier.state.pendingDueKeys, hasLength(1));
    });

    test('filtrerar bort due-nycklar från andra operationer', () async {
      await seedSchedules([
        (key: 'multiplication|4 × 7 = ?', daysAgo: 1),
        (key: 'addition|5 + 3 = ?', daysAgo: 1),
      ]);

      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
      );

      final session = notifier.state.session;
      expect(session, isNotNull);
      // Första frågan ska vara additions-nyckeln (multiplikation filtreras bort).
      expect(session!.questions.first.operationType, OperationType.addition);
      expect(session.questions.first.correctAnswer, 8);
    });

    test('OperationType.mixed accepterar alla due-nycklar', () async {
      await seedSchedules([
        (key: 'multiplication|4 × 7 = ?', daysAgo: 1),
        (key: 'addition|5 + 3 = ?', daysAgo: 1),
      ]);

      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.mixed,
        difficulty: DifficultyLevel.easy,
      );

      // Cap = 2, en blir första fråga, en kvar i pending.
      // Båda nycklarna ska räknas som due (ingen filtrering).
      expect(notifier.state.pendingDueKeys, hasLength(1));
    });

    test('framtida schedules räknas inte som due', () async {
      await seedSchedules([
        (key: 'multiplication|4 × 7 = ?', daysAgo: -7), // 7 dagar i framtiden
      ]);

      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
      );

      // Inga due-nycklar → första fråga är slumpmässigt genererad,
      // pendingDueKeys är tomt.
      expect(notifier.state.pendingDueKeys, isEmpty);
    });

    test('konsumerar pendingDueKeys i goToNextQuestion', () async {
      await seedSchedules([
        (key: 'multiplication|2 × 3 = ?', daysAgo: 1),
        (key: 'multiplication|4 × 5 = ?', daysAgo: 1),
      ]);

      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
      );

      expect(notifier.state.pendingDueKeys, hasLength(1));

      notifier.advanceToNextQuestion();

      // Efter goToNextQuestion ska pendingDueKeys ha minskat med 1.
      expect(notifier.state.pendingDueKeys, isEmpty);

      // Andra frågan i sessionen ska komma från due-nyckeln.
      final session = notifier.state.session;
      expect(session, isNotNull);
      expect(session!.questions.length, greaterThanOrEqualTo(2));
      final secondQuestion = session.questions[1];
      expect(secondQuestion.operationType, OperationType.multiplication);
      expect(secondQuestion.correctAnswer, 20); // 4 × 5
    });
  });
}

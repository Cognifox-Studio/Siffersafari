import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] AchievementService', () {
    late AchievementService service;

    setUp(() {
      service = AchievementService();
    });

    test('låser upp första quiz-utmärkelsen', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );

      const session = QuizSession(
        sessionId: 's1',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        questions: [],
        targetQuestionCount: 0,
        correctAnswers: 0,
        wrongAnswers: 0,
        totalPoints: 0,
      );

      final reward = service.evaluate(user: user, session: session);
      expect(reward.unlockedIds, contains(AppConstants.firstQuizAchievement));
      expect(
        reward.unlockedIds,
        contains(AppConstants.firstAdditionAchievement),
      );
    });

    test('låser inte upp redan upplåst achievement igen', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
        achievements: [AppConstants.firstQuizAchievement],
      );

      const session = QuizSession(
        sessionId: 's1',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        questions: [],
        targetQuestionCount: 0,
        correctAnswers: 0,
        wrongAnswers: 0,
        totalPoints: 0,
      );

      final reward = service.evaluate(user: user, session: session);
      expect(
        reward.unlockedIds,
        isNot(contains(AppConstants.firstQuizAchievement)),
      );
    });

    test('streak-7 triggar men inte streak-30 vid 7', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
        currentStreak: 7,
      );

      const session = QuizSession(
        sessionId: 's1',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        questions: [],
        targetQuestionCount: 10,
        correctAnswers: 7,
        wrongAnswers: 3,
        totalPoints: 70,
      );

      final reward = service.evaluate(user: user, session: session);
      expect(reward.unlockedIds, contains(AppConstants.streak7Achievement));
      expect(
        reward.unlockedIds,
        isNot(contains(AppConstants.streak30Achievement)),
      );
    });

    test('exponerar badgealbum i stabil ordning', () {
      final entries = service.albumEntries;

      expect(
        entries.map((entry) => entry.id),
        orderedEquals(const [
          AppConstants.firstQuizAchievement,
          AppConstants.firstAdditionAchievement,
          AppConstants.firstSubtractionAchievement,
          AppConstants.firstMultiplicationAchievement,
          AppConstants.firstDivisionAchievement,
          AppConstants.perfectScoreAchievement,
          AppConstants.hardQuizAchievement,
          AppConstants.quiz10Achievement,
          AppConstants.points500Achievement,
          AppConstants.master100Achievement,
          AppConstants.streak7Achievement,
          AppConstants.streak30Achievement,
        ]),
      );
      expect(
        service.getAlbumLabel(AppConstants.master100Achievement),
        '100 rätt',
      );
      expect(
        service.getBadgeEmoji(AppConstants.firstQuizAchievement),
        '🧭',
      );
    });

    test('låser upp sen quiz-, poäng- och svårnivåbadge när gränser passeras',
        () {
      const user = UserProgress(
        userId: 'u10',
        name: 'Rut',
        ageGroup: AgeGroup.older,
        totalQuizzesTaken: 9,
        totalPoints: 470,
      );

      const session = QuizSession(
        sessionId: 's10',
        ageGroup: AgeGroup.older,
        operationType: OperationType.division,
        difficulty: DifficultyLevel.hard,
        questions: [],
        targetQuestionCount: 10,
        correctAnswers: 8,
        wrongAnswers: 2,
        totalPoints: 40,
      );

      final reward = service.evaluate(user: user, session: session);

      expect(
        reward.unlockedIds,
        contains(AppConstants.firstDivisionAchievement),
      );
      expect(reward.unlockedIds, contains(AppConstants.hardQuizAchievement));
      expect(reward.unlockedIds, contains(AppConstants.quiz10Achievement));
      expect(reward.unlockedIds, contains(AppConstants.points500Achievement));
    });
  });
}

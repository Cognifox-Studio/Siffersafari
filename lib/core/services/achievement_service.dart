import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import '../constants/app_constants.dart';

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.displayName,
    required this.albumLabel,
    required this.emoji,
  });

  final String id;
  final String displayName;
  final String albumLabel;
  final String emoji;

  static const unknown = AchievementDefinition(
    id: 'unknown_achievement',
    displayName: 'Okänd prestation',
    albumLabel: 'Märke',
    emoji: '❔',
  );
}

class AchievementReward {
  const AchievementReward({
    required this.unlockedIds,
    required this.bonusPoints,
  });

  final List<String> unlockedIds;
  final int bonusPoints;

  bool get hasRewards => unlockedIds.isNotEmpty || bonusPoints > 0;
}

/// Evaluates and awards achievements based on user progress and quiz performance.
///
/// Checks unlocking conditions (streaks, total points, operations mastered, etc.)
/// against defined achievement criteria. Tracks bonus points when new
/// achievements are unlocked.
class AchievementService {
  static const List<AchievementDefinition> _definitions = [
    AchievementDefinition(
      id: AppConstants.firstQuizAchievement,
      displayName: 'Första quizet',
      albumLabel: 'Första',
      emoji: '🧭',
    ),
    AchievementDefinition(
      id: AppConstants.firstAdditionAchievement,
      displayName: 'Första plusrundan',
      albumLabel: 'Plus',
      emoji: '➕',
    ),
    AchievementDefinition(
      id: AppConstants.firstSubtractionAchievement,
      displayName: 'Första minusrundan',
      albumLabel: 'Minus',
      emoji: '➖',
    ),
    AchievementDefinition(
      id: AppConstants.firstMultiplicationAchievement,
      displayName: 'Första gångerrundan',
      albumLabel: 'Gånger',
      emoji: '✖️',
    ),
    AchievementDefinition(
      id: AppConstants.firstDivisionAchievement,
      displayName: 'Första delatrundan',
      albumLabel: 'Delat',
      emoji: '➗',
    ),
    AchievementDefinition(
      id: AppConstants.perfectScoreAchievement,
      displayName: 'Perfekt resultat',
      albumLabel: 'Perfekt',
      emoji: '⭐',
    ),
    AchievementDefinition(
      id: AppConstants.hardQuizAchievement,
      displayName: 'Klarade svår nivå',
      albumLabel: 'Svår',
      emoji: '🧗',
    ),
    AchievementDefinition(
      id: AppConstants.quiz10Achievement,
      displayName: '10 quiz spelade',
      albumLabel: '10 quiz',
      emoji: '🎒',
    ),
    AchievementDefinition(
      id: AppConstants.points500Achievement,
      displayName: '500 poäng',
      albumLabel: '500 p',
      emoji: '🪙',
    ),
    AchievementDefinition(
      id: AppConstants.master100Achievement,
      displayName: 'Mästare 100',
      albumLabel: '100 rätt',
      emoji: '💯',
    ),
    AchievementDefinition(
      id: AppConstants.streak7Achievement,
      displayName: '7-dagars streak',
      albumLabel: '7 dagar',
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: AppConstants.streak30Achievement,
      displayName: '30-dagars streak',
      albumLabel: '30 dagar',
      emoji: '👑',
    ),
  ];

  List<AchievementDefinition> get albumEntries => _definitions;

  AchievementReward evaluate({
    required UserProgress user,
    required QuizSession session,
  }) {
    final unlocked = <String>[];
    var bonusPoints = 0;

    if (_shouldUnlockFirstQuiz(user)) {
      unlocked.add(AppConstants.firstQuizAchievement);
      bonusPoints += 50;
    }

    final firstOperationAchievement = _firstOperationAchievementFor(session);
    if (firstOperationAchievement != null &&
        _shouldUnlockOperationAchievement(user, firstOperationAchievement)) {
      unlocked.add(firstOperationAchievement);
      bonusPoints += 15;
    }

    if (_shouldUnlockPerfectScore(session, user)) {
      unlocked.add(AppConstants.perfectScoreAchievement);
      bonusPoints += 75;
    }

    if (_shouldUnlockHardQuiz(session, user)) {
      unlocked.add(AppConstants.hardQuizAchievement);
      bonusPoints += 25;
    }

    if (_shouldUnlockQuizCount(user, 10, AppConstants.quiz10Achievement)) {
      unlocked.add(AppConstants.quiz10Achievement);
      bonusPoints += 30;
    }

    if (_shouldUnlockTotalPoints(
      user,
      session,
      500,
      AppConstants.points500Achievement,
    )) {
      unlocked.add(AppConstants.points500Achievement);
      bonusPoints += 40;
    }

    if (_shouldUnlockMaster100(user, session)) {
      unlocked.add(AppConstants.master100Achievement);
      bonusPoints += 100;
    }

    if (_shouldUnlockStreak(user, 7)) {
      unlocked.add(AppConstants.streak7Achievement);
      bonusPoints += 75;
    }

    if (_shouldUnlockStreak(user, 30)) {
      unlocked.add(AppConstants.streak30Achievement);
      bonusPoints += 150;
    }

    return AchievementReward(
      unlockedIds: unlocked,
      bonusPoints: bonusPoints,
    );
  }

  AchievementDefinition getDefinition(String achievementId) {
    for (final definition in _definitions) {
      if (definition.id == achievementId) {
        return definition;
      }
    }

    return AchievementDefinition.unknown;
  }

  String getAlbumLabel(String achievementId) {
    return getDefinition(achievementId).albumLabel;
  }

  String getBadgeEmoji(String achievementId) {
    return getDefinition(achievementId).emoji;
  }

  bool _shouldUnlockFirstQuiz(UserProgress user) {
    return user.totalQuizzesTaken == 0 &&
        !user.achievements.contains(AppConstants.firstQuizAchievement);
  }

  bool _shouldUnlockOperationAchievement(
    UserProgress user,
    String achievementId,
  ) {
    return !user.achievements.contains(achievementId);
  }

  bool _shouldUnlockPerfectScore(QuizSession session, UserProgress user) {
    return session.successRate == 1.0 &&
        !user.achievements.contains(AppConstants.perfectScoreAchievement);
  }

  bool _shouldUnlockHardQuiz(QuizSession session, UserProgress user) {
    return session.difficulty == DifficultyLevel.hard &&
        !user.achievements.contains(AppConstants.hardQuizAchievement);
  }

  bool _shouldUnlockQuizCount(
    UserProgress user,
    int target,
    String achievementId,
  ) {
    return user.totalQuizzesTaken + 1 >= target &&
        !user.achievements.contains(achievementId);
  }

  bool _shouldUnlockTotalPoints(
    UserProgress user,
    QuizSession session,
    int target,
    String achievementId,
  ) {
    return user.totalPoints + session.totalPoints >= target &&
        !user.achievements.contains(achievementId);
  }

  bool _shouldUnlockMaster100(UserProgress user, QuizSession session) {
    final totalCorrect = user.totalCorrectAnswers + session.correctAnswers;
    return totalCorrect >= 100 &&
        !user.achievements.contains(AppConstants.master100Achievement);
  }

  bool _shouldUnlockStreak(UserProgress user, int streak) {
    return user.currentStreak >= streak &&
        !user.achievements.contains(
          streak == 7
              ? AppConstants.streak7Achievement
              : AppConstants.streak30Achievement,
        );
  }

  String? _firstOperationAchievementFor(QuizSession session) {
    switch (session.operationType) {
      case OperationType.addition:
        return AppConstants.firstAdditionAchievement;
      case OperationType.subtraction:
        return AppConstants.firstSubtractionAchievement;
      case OperationType.multiplication:
        return AppConstants.firstMultiplicationAchievement;
      case OperationType.division:
        return AppConstants.firstDivisionAchievement;
      case OperationType.mixed:
        return null;
    }
  }
}

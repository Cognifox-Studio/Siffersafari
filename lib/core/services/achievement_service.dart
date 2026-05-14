import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';

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
      id: AppConstants.perfectScoreAchievement,
      displayName: 'Perfekt resultat',
      albumLabel: 'Perfekt',
      emoji: '⭐',
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

    if (_shouldUnlockPerfectScore(session, user)) {
      unlocked.add(AppConstants.perfectScoreAchievement);
      bonusPoints += 75;
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

  String getDisplayName(String achievementId) {
    return getDefinition(achievementId).displayName;
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

  bool _shouldUnlockPerfectScore(QuizSession session, UserProgress user) {
    return session.successRate == 1.0 &&
        !user.achievements.contains(AppConstants.perfectScoreAchievement);
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
}

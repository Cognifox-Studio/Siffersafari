import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/services/streak_celebration.dart';

class ResultsReadModel {
  const ResultsReadModel({
    required this.session,
    required this.activeUser,
    required this.reward,
    required this.storyProgress,
    required this.questCompletion,
    required this.stars,
    required this.shouldCelebrate,
    required this.totalPoints,
    required this.hasStoryCheckpoint,
    required this.streak,
  });

  final QuizSession? session;
  final UserProgress? activeUser;
  final AchievementReward? reward;
  final StoryProgress? storyProgress;
  final QuestCompletionEvent? questCompletion;
  final int stars;
  final bool shouldCelebrate;
  final int totalPoints;
  final bool hasStoryCheckpoint;

  /// Streak line for the results screen, or null when there is nothing to say.
  final StreakCelebration? streak;

  static int calculateStars(double successRate) {
    if (successRate >= 0.9) return 3;
    if (successRate >= 0.7) return 2;
    if (successRate >= 0.5) return 1;
    return 0;
  }

  factory ResultsReadModel.fromState({
    required QuizState quizState,
    required UserState userState,
    required StoryProgress? storyProgress,
  }) {
    final session = quizState.session;
    if (session == null) {
      return const ResultsReadModel(
        session: null,
        activeUser: null,
        reward: null,
        storyProgress: null,
        questCompletion: null,
        stars: 0,
        shouldCelebrate: false,
        totalPoints: 0,
        hasStoryCheckpoint: false,
        streak: null,
      );
    }

    final reward = userState.lastReward;
    final stars = calculateStars(session.successRate);
    final shouldCelebrate = session.successRate >= 0.5 &&
        (session.successRate >= 0.8 ||
            (reward?.unlockedIds.isNotEmpty ?? false));
    final bonusPoints = reward?.bonusPoints ?? 0;
    final questCompletion = userState.lastQuestCompletion;
    final hasStoryCheckpoint = questCompletion != null && storyProgress != null;
    final activeUser = userState.activeUser;
    final streak = activeUser == null
        ? null
        : streakCelebration(
            currentStreak: activeUser.currentStreak,
            longestStreak: activeUser.longestStreak,
          );

    return ResultsReadModel(
      session: session,
      activeUser: userState.activeUser,
      reward: reward,
      storyProgress: storyProgress,
      questCompletion: questCompletion,
      stars: stars,
      shouldCelebrate: shouldCelebrate,
      totalPoints: session.totalPoints + bonusPoints,
      hasStoryCheckpoint: hasStoryCheckpoint,
      streak: streak,
    );
  }
}

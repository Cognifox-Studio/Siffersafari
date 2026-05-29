import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

enum HomePrimaryAction {
  resumeQuiz,
  openStoryMap,
  startStoryQuest,
  startFreePlay,
}

class HomeReadModel {
  const HomeReadModel({
    required this.activeUser,
    required this.questStatus,
    required this.storyProgress,
    required this.allowedOps,
    required this.hasResumableSession,
    required this.hasStoryQuest,
    required this.isDailyChallengeCompleted,
    required this.heroEyebrow,
    required this.heroTitle,
    required this.primaryAction,
    this.heroSubtitle,
  });

  final UserProgress? activeUser;
  final QuestStatus? questStatus;
  final StoryProgress? storyProgress;
  final Set<OperationType> allowedOps;
  final bool hasResumableSession;
  final bool hasStoryQuest;
  final bool isDailyChallengeCompleted;
  final String heroEyebrow;
  final String heroTitle;
  final String? heroSubtitle;
  final HomePrimaryAction primaryAction;

  String get primaryButtonLabel {
    return switch (primaryAction) {
      HomePrimaryAction.resumeQuiz => 'Fortsätt',
      HomePrimaryAction.openStoryMap => 'Se episoden',
      HomePrimaryAction.startStoryQuest => 'Spela nästa stopp',
      HomePrimaryAction.startFreePlay => 'Spela nu',
    };
  }

  factory HomeReadModel.fromState({
    required UserState userState,
    required QuizState quizState,
    required StoryProgress? storyProgress,
    required Set<OperationType> parentAllowedOps,
    required bool hasPersistedInProgressSession,
    required bool isDailyChallengeCompleted,
  }) {
    return HomeReadModel.fromValues(
      activeUser: userState.activeUser,
      questStatus: userState.questStatus,
      quizUserId: quizState.userId,
      hasActiveQuizSession: quizState.session != null,
      storyProgress: storyProgress,
      parentAllowedOps: parentAllowedOps,
      hasPersistedInProgressSession: hasPersistedInProgressSession,
      isDailyChallengeCompleted: isDailyChallengeCompleted,
    );
  }

  factory HomeReadModel.fromValues({
    required UserProgress? activeUser,
    required QuestStatus? questStatus,
    required String? quizUserId,
    required bool hasActiveQuizSession,
    required StoryProgress? storyProgress,
    required Set<OperationType> parentAllowedOps,
    required bool hasPersistedInProgressSession,
    required bool isDailyChallengeCompleted,
  }) {
    final user = activeUser;
    final allowedOps = DifficultyConfig.effectiveAllowedOperations(
      parentAllowedOperations: parentAllowedOps,
      gradeLevel: user?.gradeLevel,
    );
    final hasActiveInMemorySession =
        user != null && quizUserId == user.userId && hasActiveQuizSession;
    final hasResumableSession =
        hasActiveInMemorySession || hasPersistedInProgressSession;
    final hasStoryQuest = user != null &&
        storyProgress != null &&
        questStatus != null &&
        allowedOps.contains(questStatus.quest.operation);

    final primaryAction = hasResumableSession
        ? HomePrimaryAction.resumeQuiz
        : hasStoryQuest && storyProgress.isEpisodeComplete
            ? HomePrimaryAction.openStoryMap
            : hasStoryQuest
                ? HomePrimaryAction.startStoryQuest
                : HomePrimaryAction.startFreePlay;

    return HomeReadModel(
      activeUser: user,
      questStatus: questStatus,
      storyProgress: storyProgress,
      allowedOps: allowedOps,
      hasResumableSession: hasResumableSession,
      hasStoryQuest: hasStoryQuest,
      isDailyChallengeCompleted: isDailyChallengeCompleted,
      heroEyebrow: user == null
          ? 'Redo för safari?'
          : hasStoryQuest
              ? 'Hej, ${user.name}!'
              : 'Välkommen, ${user.name}! 👋',
      heroTitle: user == null
          ? 'Börja spela'
          : hasStoryQuest
              ? storyProgress.isEpisodeComplete
                  ? storyProgress.endingTitle
                  : storyProgress.currentObjectiveTitle
              : 'Dags för äventyr!',
      heroSubtitle: user == null
          ? 'Skapa en profil först.'
          : hasStoryQuest
              ? storyProgress.isEpisodeComplete
                  ? storyProgress.endingBody
                  : storyProgress.currentObjectiveDescription
              : null,
      primaryAction: primaryAction,
    );
  }
}

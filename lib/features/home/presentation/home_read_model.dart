import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
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
    required this.heroEyebrow,
    required this.heroTitle,
    required this.primaryAction,
    this.heroSubtitle,
    this.resumeSession,
  });

  final UserProgress? activeUser;
  final QuestStatus? questStatus;
  final StoryProgress? storyProgress;
  final Set<OperationType> allowedOps;
  final bool hasResumableSession;
  final bool hasStoryQuest;
  final String heroEyebrow;
  final String heroTitle;
  final String? heroSubtitle;
  final HomePrimaryAction primaryAction;
  final QuizSession? resumeSession;

  String get primaryButtonLabel {
    return switch (primaryAction) {
      HomePrimaryAction.resumeQuiz => _resumeButtonLabel,
      HomePrimaryAction.openStoryMap => 'Se episoden',
      HomePrimaryAction.startStoryQuest => 'Spela nästa stopp',
      HomePrimaryAction.startFreePlay => 'Spela nu',
    };
  }

  String get _resumeButtonLabel {
    final session = resumeSession;
    if (session == null) return 'Fortsätt';

    final op = session.operationType.displayName;
    final answered = session.answers.length;
    final total = session.totalQuestions;
    if (total <= 0) return 'Fortsätt $op';
    return 'Fortsätt $op ($answered/$total)';
  }

  factory HomeReadModel.fromState({
    required UserState userState,
    required QuizState quizState,
    required StoryProgress? storyProgress,
    required Set<OperationType> parentAllowedOps,
    required bool hasPersistedInProgressSession,
    QuizSession? resumeSession,
  }) {
    return HomeReadModel.fromValues(
      activeUser: userState.activeUser,
      questStatus: userState.questStatus,
      quizUserId: quizState.userId,
      hasActiveQuizSession: quizState.session != null,
      storyProgress: storyProgress,
      parentAllowedOps: parentAllowedOps,
      hasPersistedInProgressSession: hasPersistedInProgressSession,
      resumeSession: resumeSession ?? quizState.session,
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
    QuizSession? resumeSession,
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
      resumeSession: hasResumableSession ? resumeSession : null,
    );
  }
}

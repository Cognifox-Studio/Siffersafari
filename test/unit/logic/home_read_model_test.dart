import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/home/presentation/home_read_model.dart';

void main() {
  group('[Unit] HomeReadModel', () {
    test('visar profilstart när ingen användare är vald', () {
      final model = HomeReadModel.fromState(
        userState: const UserState(),
        quizState: const QuizState(),
        storyProgress: null,
        parentAllowedOps: _baseOperations,
        hasPersistedInProgressSession: false,
        isDailyChallengeCompleted: false,
      );

      expect(model.heroTitle, 'Börja spela');
      expect(model.heroSubtitle, 'Skapa en profil först.');
      expect(model.primaryAction, HomePrimaryAction.startFreePlay);
      expect(model.primaryButtonLabel, 'Spela nu');
    });

    test('prioriterar fortsätt när en session kan återupptas', () {
      final user = _user();
      final model = HomeReadModel.fromState(
        userState: UserState(activeUser: user, questStatus: _questStatus()),
        quizState: QuizState(userId: user.userId, session: _session()),
        storyProgress: _storyProgress(isEpisodeComplete: true),
        parentAllowedOps: _baseOperations,
        hasPersistedInProgressSession: false,
        isDailyChallengeCompleted: true,
      );

      expect(model.hasResumableSession, isTrue);
      expect(model.primaryAction, HomePrimaryAction.resumeQuiz);
      expect(model.primaryButtonLabel, 'Fortsätt');
      expect(model.isDailyChallengeCompleted, isTrue);
    });

    test('visar story-CTA när aktivt uppdrag matchar tillåtna räknesätt', () {
      final user = _user();
      final model = HomeReadModel.fromState(
        userState: UserState(activeUser: user, questStatus: _questStatus()),
        quizState: const QuizState(),
        storyProgress: _storyProgress(),
        parentAllowedOps: _baseOperations,
        hasPersistedInProgressSession: false,
        isDailyChallengeCompleted: false,
      );

      expect(model.hasStoryQuest, isTrue);
      expect(model.heroEyebrow, 'Hej, Test!');
      expect(model.heroTitle, 'Hitta gläntan');
      expect(model.primaryAction, HomePrimaryAction.startStoryQuest);
      expect(model.primaryButtonLabel, 'Spela nästa stopp');
    });
  });
}

const _baseOperations = {
  OperationType.addition,
  OperationType.subtraction,
  OperationType.multiplication,
  OperationType.division,
};

UserProgress _user() {
  return const UserProgress(
    userId: 'u1',
    name: 'Test',
    ageGroup: AgeGroup.middle,
  );
}

QuestStatus _questStatus() {
  return const QuestStatus(
    quest: QuestDefinition(
      id: 'q_plus_easy',
      title: 'Samla sifferfrukter',
      description: 'Bli skicklig på plus.',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.easy,
    ),
    masteryRate: 0.5,
    progress: 0.5,
    isCompleted: false,
  );
}

QuizSession _session() {
  return const QuizSession(
    sessionId: 's1',
    ageGroup: AgeGroup.middle,
    operationType: OperationType.addition,
    difficulty: DifficultyLevel.easy,
    questions: [],
    targetQuestionCount: 10,
  );
}

StoryProgress _storyProgress({bool isEpisodeComplete = false}) {
  return StoryProgress(
    worldTitle: 'Djungeln',
    worldSubtitle: 'Följ stigen.',
    chapterTitle: 'Kapitel 1',
    actIndex: 1,
    totalActs: 3,
    actTitle: 'Starten',
    actBody: 'Börja här.',
    currentObjectiveTitle: 'Hitta gläntan',
    currentObjectiveDescription: 'Spela nästa stopp.',
    progress: 0.3,
    completedNodes: 1,
    totalNodes: 3,
    currentNodeIndex: 1,
    nodes: const [],
    isEpisodeComplete: isEpisodeComplete,
    endingTitle: 'Episoden är klar',
    endingBody: 'Bra jobbat.',
  );
}

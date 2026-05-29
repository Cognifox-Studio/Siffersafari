import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/core/services/quiz_review_schedule_service.dart';
import 'package:siffersafari/core/services/quiz_session_planner.dart';
import 'package:siffersafari/core/services/quiz_session_storage_service.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/difficulty_config.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/local_storage_repository.dart';
import '../../domain/constants/learning_constants.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_session.dart';
import '../../domain/entities/quiz_session_json.dart';
import '../../domain/enums/age_group.dart';
import '../../domain/enums/difficulty_level.dart';
import '../../domain/enums/operation_type.dart';
import '../../domain/services/adaptive_difficulty_service.dart';
import '../../domain/services/feedback_service.dart';
import '../../domain/services/spaced_repetition_service.dart';
import 'adaptive_difficulty_service_provider.dart';
import 'audio_service_provider.dart';
import 'feedback_service_provider.dart';
import 'local_storage_repository_provider.dart';
import 'question_generator_service_provider.dart';
import 'spaced_repetition_service_provider.dart';

// region QuizState Class

class QuizState {
  const QuizState({
    this.userId,
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.feedback,
    this.difficultyStepsByOperation = const {},
    this.recentResultsByOperation = const {},
    this.questionsSinceLastStepChangeByOperation = const {},
    this.correctStreak = 0,
    this.bestCorrectStreak = 0,
    this.speedBonusCount = 0,
    this.reviewSchedulesByKey = const {},
    this.dueReviewCount = 0,
    this.pendingDueKeys = const [],
    this.isDailyChallenge = false,
  });

  final String? userId;
  final QuizSession? session;
  final bool isLoading;
  final String? errorMessage;
  final FeedbackResult? feedback;
  final Map<OperationType, int> difficultyStepsByOperation;
  final Map<OperationType, List<bool>> recentResultsByOperation;
  final Map<OperationType, int> questionsSinceLastStepChangeByOperation;
  final int correctStreak;
  final int bestCorrectStreak;
  final int speedBonusCount;
  final Map<String, ReviewSchedule> reviewSchedulesByKey;
  final int dueReviewCount;
  final List<String> pendingDueKeys;
  final bool isDailyChallenge;

  QuizState copyWith({
    String? userId,
    QuizSession? session,
    bool? isLoading,
    String? errorMessage,
    FeedbackResult? feedback,
    Map<OperationType, int>? difficultyStepsByOperation,
    Map<OperationType, List<bool>>? recentResultsByOperation,
    Map<OperationType, int>? questionsSinceLastStepChangeByOperation,
    int? correctStreak,
    int? bestCorrectStreak,
    int? speedBonusCount,
    Map<String, ReviewSchedule>? reviewSchedulesByKey,
    int? dueReviewCount,
    List<String>? pendingDueKeys,
    bool? isDailyChallenge,
  }) {
    return QuizState(
      userId: userId ?? this.userId,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      feedback: feedback,
      difficultyStepsByOperation:
          difficultyStepsByOperation ?? this.difficultyStepsByOperation,
      recentResultsByOperation:
          recentResultsByOperation ?? this.recentResultsByOperation,
      questionsSinceLastStepChangeByOperation:
          questionsSinceLastStepChangeByOperation ??
              this.questionsSinceLastStepChangeByOperation,
      correctStreak: correctStreak ?? this.correctStreak,
      bestCorrectStreak: bestCorrectStreak ?? this.bestCorrectStreak,
      speedBonusCount: speedBonusCount ?? this.speedBonusCount,
      reviewSchedulesByKey: reviewSchedulesByKey ?? this.reviewSchedulesByKey,
      dueReviewCount: dueReviewCount ?? this.dueReviewCount,
      pendingDueKeys: pendingDueKeys ?? this.pendingDueKeys,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
    );
  }
}

// endregion

// region QuizNotifier Class

/// Manages quiz session state: questions, answers, feedback, and streaks.
///
/// Key responsibilities:
/// - Generate questions for a session based on operation type and difficulty.
/// - Track user answers and calculate success rate.
/// - Evaluate feedback (correct/incorrect) and bonus points.
/// - Update streak counters and persist session progress.
/// - Support custom question lists for focus mode.
///
/// Use [startSession] to begin a quiz; [submitAnswer] to record responses.
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(
    QuestionGeneratorService questionGenerator,
    FeedbackService feedbackService,
    AudioService audioService,
    LocalStorageRepository repository, {
    required AdaptiveDifficultyService adaptiveDifficultyService,
    required SpacedRepetitionService spacedRepetitionService,
    QuizReviewScheduleService? reviewScheduleService,
    QuizSessionPlanner? sessionPlanner,
    QuizSessionStorageService? sessionStorageService,
  })  : _feedbackService = feedbackService,
        _audioService = audioService,
        _repository = repository,
        _adaptiveDifficultyService = adaptiveDifficultyService,
        _spacedRepetitionService = spacedRepetitionService,
        _reviewScheduleService = reviewScheduleService ??
            QuizReviewScheduleService(
              questionGenerator: questionGenerator,
              repository: repository,
              spacedRepetitionService: spacedRepetitionService,
            ),
        _sessionPlanner = sessionPlanner ??
            QuizSessionPlanner(
              questionGenerator: questionGenerator,
              reviewScheduleService: reviewScheduleService ??
                  QuizReviewScheduleService(
                    questionGenerator: questionGenerator,
                    repository: repository,
                    spacedRepetitionService: spacedRepetitionService,
                  ),
            ),
        _sessionStorageService =
            sessionStorageService ?? QuizSessionStorageService(repository),
        super(const QuizState());

  final FeedbackService _feedbackService;
  final AudioService _audioService;
  final LocalStorageRepository _repository;
  final AdaptiveDifficultyService _adaptiveDifficultyService;
  final SpacedRepetitionService _spacedRepetitionService;
  final QuizReviewScheduleService _reviewScheduleService;
  final QuizSessionPlanner _sessionPlanner;
  final QuizSessionStorageService _sessionStorageService;
  final _uuid = const Uuid();

  void hydrateReviewSummaryForUser(String userId) {
    if (userId.isEmpty) return;

    final reviewState = _reviewScheduleService.loadInitialReviewState(userId);

    state = state.copyWith(
      userId: userId,
      reviewSchedulesByKey: Map<String, ReviewSchedule>.unmodifiable(
        reviewState.schedules,
      ),
      dueReviewCount: reviewState.dueCount,
    );
  }

  ({bool wordProblemsEnabled, bool missingNumberEnabled})
      _resolveSessionFeatureFlags({
    required String userId,
    bool? wordProblemsEnabledOverride,
    bool? missingNumberEnabledOverride,
  }) {
    final wordProblemsEnabled = wordProblemsEnabledOverride ??
        QuizFeatureSettings.readWordProblemsEnabled(
          repository: _repository,
          userId: userId,
        );
    final missingNumberEnabled = missingNumberEnabledOverride ??
        QuizFeatureSettings.readMissingNumberEnabled(
          repository: _repository,
          userId: userId,
        );

    return (
      wordProblemsEnabled: wordProblemsEnabled,
      missingNumberEnabled: missingNumberEnabled,
    );
  }

  void _activateSessionState({
    required String userId,
    required QuizSession session,
    required Map<OperationType, int> steps,
    required QuizReviewStateSnapshot reviewState,
    required bool isDailyChallenge,
    List<String> pendingDueKeys = const [],
  }) {
    state = state.copyWith(
      userId: userId,
      session: session,
      feedback: null,
      difficultyStepsByOperation: steps,
      recentResultsByOperation: const {},
      questionsSinceLastStepChangeByOperation: const {},
      correctStreak: 0,
      bestCorrectStreak: 0,
      speedBonusCount: 0,
      reviewSchedulesByKey: Map<String, ReviewSchedule>.unmodifiable(
        reviewState.schedules,
      ),
      dueReviewCount: reviewState.dueCount,
      pendingDueKeys: List<String>.unmodifiable(pendingDueKeys),
      isDailyChallenge: isDailyChallenge,
    );

    _persistInProgressSession(
      userId: userId,
      session: session,
      pendingDueKeys: pendingDueKeys,
      persistEvenWithoutAnswers: true,
    );
  }

  void startSession({
    required String userId,
    required AgeGroup ageGroup,
    int? gradeLevel,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    Map<OperationType, int>? initialDifficultyStepsByOperation,
    bool? wordProblemsEnabled,
    bool? missingNumberEnabled,
    bool isDailyChallenge = false,
  }) {
    debugPrint(
      '[QuizNotifier] startSession: userId=$userId, '
      'operation=${operationType.name}, difficulty=${difficulty.name}',
    );

    _sessionStorageService.prepareInProgressStorage(
      userId: userId,
      operationType: operationType,
      difficulty: difficulty,
    );

    final count = DifficultyConfig.getQuestionsPerSession(ageGroup);

    final steps = Map<OperationType, int>.unmodifiable(
      initialDifficultyStepsByOperation ??
          DifficultyConfig.buildDifficultySteps(
            storedSteps: const {},
            defaultDifficulty: difficulty,
            gradeLevel: gradeLevel,
          ),
    );

    final featureFlags = _resolveSessionFeatureFlags(
      userId: userId,
      wordProblemsEnabledOverride: wordProblemsEnabled,
      missingNumberEnabledOverride: missingNumberEnabled,
    );

    final reviewState = _reviewScheduleService.loadInitialReviewState(userId);
    final questionPlan = _sessionPlanner.buildGeneratedSessionPlan(
      ageGroup: ageGroup,
      operationType: operationType,
      difficulty: difficulty,
      targetQuestionCount: count,
      difficultyStepsByOperation: steps,
      schedules: reviewState.schedules,
      now: DateTime.now(),
      wordProblemsEnabled: featureFlags.wordProblemsEnabled,
      missingNumberEnabled: featureFlags.missingNumberEnabled,
      gradeLevel: gradeLevel,
    );

    final session = QuizSession(
      sessionId: _uuid.v4(),
      ageGroup: ageGroup,
      gradeLevel: gradeLevel,
      operationType: operationType,
      difficulty: difficulty,
      questions: questionPlan.initialQuestions,
      targetQuestionCount: count,
      wordProblemsEnabled: featureFlags.wordProblemsEnabled,
      missingNumberEnabled: featureFlags.missingNumberEnabled,
      difficultyStepsByOperation: steps,
      startTime: DateTime.now(),
    );

    _activateSessionState(
      userId: userId,
      session: session,
      steps: steps,
      reviewState: reviewState,
      isDailyChallenge: isDailyChallenge,
      pendingDueKeys: questionPlan.pendingDueKeys,
    );
  }

  void resumeSession({
    required String userId,
    required Map<String, dynamic> sessionMap,
  }) {
    debugPrint('[QuizNotifier] resumeSession: userId=$userId');

    final session = QuizSessionJson.fromJson(sessionMap);

    _sessionStorageService.prepareInProgressStorage(
      userId: userId,
      operationType: session.operationType,
      difficulty: session.difficulty,
    );

    final reviewState = _reviewScheduleService.loadInitialReviewState(userId);

    _activateSessionState(
      userId: userId,
      session: session,
      steps: session.difficultyStepsByOperation,
      reviewState: reviewState,
      isDailyChallenge: false,
      pendingDueKeys: _reviewScheduleService.readPendingDueKeys(sessionMap),
    );
  }

  bool resumeLatestSessionForUser({
    required String userId,
    String? operationTypeName,
  }) {
    final sessionMap = _repository.getQuizSession(
      userId,
      operationTypeName: operationTypeName,
    );
    if (sessionMap == null) {
      return false;
    }

    resumeSession(userId: userId, sessionMap: sessionMap);
    return true;
  }

  void startCustomSession({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required List<Question> questions,
    required AgeGroup ageGroup,
    int? gradeLevel,
    Map<OperationType, int>? initialDifficultyStepsByOperation,
    bool? wordProblemsEnabled,
    bool? missingNumberEnabled,
  }) {
    debugPrint(
      '[QuizNotifier] startCustomSession: userId=$userId, '
      'operation=${operationType.name}, questions=${questions.length}',
    );
    if (questions.isEmpty) {
      debugPrint(
        '[QuizNotifier] startCustomSession: empty questions list, skipping',
      );
      return;
    }

    _sessionStorageService.prepareInProgressStorage(
      userId: userId,
      operationType: operationType,
      difficulty: difficulty,
    );

    final featureFlags = _resolveSessionFeatureFlags(
      userId: userId,
      wordProblemsEnabledOverride: wordProblemsEnabled,
      missingNumberEnabledOverride: missingNumberEnabled,
    );

    final steps = Map<OperationType, int>.unmodifiable(
      initialDifficultyStepsByOperation ??
          DifficultyConfig.buildDifficultySteps(
            storedSteps: const {},
            defaultDifficulty: difficulty,
            gradeLevel: gradeLevel,
          ),
    );

    final reviewState = _reviewScheduleService.loadInitialReviewState(userId);

    final questionPlan = _sessionPlanner.buildCustomSessionPlan(
      questions: questions,
      difficulty: difficulty,
      operationType: operationType,
      schedules: reviewState.schedules,
      now: DateTime.now(),
    );

    final session = QuizSession(
      sessionId: _uuid.v4(),
      ageGroup: ageGroup,
      gradeLevel: gradeLevel,
      operationType: operationType,
      difficulty: difficulty,
      questions: questionPlan.initialQuestions,
      targetQuestionCount: questions.length,
      wordProblemsEnabled: featureFlags.wordProblemsEnabled,
      missingNumberEnabled: featureFlags.missingNumberEnabled,
      difficultyStepsByOperation: steps,
      startTime: DateTime.now(),
    );

    _activateSessionState(
      userId: userId,
      session: session,
      steps: steps,
      reviewState: reviewState,
      isDailyChallenge: false,
      pendingDueKeys: questionPlan.pendingDueKeys,
    );
  }

  void submitAnswer({
    required int answer,
    required Duration responseTime,
    required AgeGroup ageGroup,
  }) {
    final session = state.session;
    if (session == null || session.currentQuestion == null) {
      debugPrint('[QuizNotifier] submitAnswer: no active session');
      return;
    }

    final question = session.currentQuestion!;
    final isCorrect = question.isCorrect(answer);
    debugPrint(
      '[QuizNotifier] submitAnswer: question=${question.id}, '
      'answer=$answer, correct=$isCorrect, time=${responseTime.inSeconds}s',
    );

    if (isCorrect) {
      _audioService.playCorrectSound();
    } else {
      _audioService.playWrongSound();
    }

    final updatedAnswers = Map<String, int>.from(session.answers)
      ..[question.id] = answer;

    final updatedTimes = Map<String, Duration>.from(session.responseTimes)
      ..[question.id] = responseTime;

    final gotSpeedBonus = isCorrect && responseTime.inSeconds <= 5;
    final previousStreak = state.correctStreak;
    final newStreak = isCorrect ? (state.correctStreak + 1) : 0;
    final comboMultiplier =
        _comboMultiplierForStreak(isCorrect ? newStreak : 0);
    final pointsEarned = _calculatePoints(
      isCorrect: isCorrect,
      responseTime: responseTime,
      difficulty: session.difficulty,
      correctStreak: isCorrect ? newStreak : 0,
    );
    final newBestStreak = newStreak > state.bestCorrectStreak
        ? newStreak
        : state.bestCorrectStreak;
    final newSpeedBonusCount = state.speedBonusCount + (gotSpeedBonus ? 1 : 0);

    final isLastQuestion =
        session.currentQuestionIndex >= session.questions.length - 1;

    final updatedSession = session.copyWith(
      correctAnswers: session.correctAnswers + (isCorrect ? 1 : 0),
      wrongAnswers: session.wrongAnswers + (isCorrect ? 0 : 1),
      totalPoints: session.totalPoints + pointsEarned,
      answers: updatedAnswers,
      responseTimes: updatedTimes,
      endTime: isLastQuestion ? DateTime.now() : session.endTime,
    );

    final op = question.operationType;

    final updatedResultsByOperation =
        Map<OperationType, List<bool>>.from(state.recentResultsByOperation);
    final updatedOpResults =
        List<bool>.from(updatedResultsByOperation[op] ?? const [])
          ..add(isCorrect);
    const maxRecent = AppConstants.questionsBeforeAdjustment;
    if (updatedOpResults.length > maxRecent) {
      updatedOpResults.removeAt(0);
    }
    updatedResultsByOperation[op] = updatedOpResults;

    final currentStep = DifficultyConfig.clampDifficultyStep(
      state.difficultyStepsByOperation[op] ??
          DifficultyConfig.minDifficultyStep,
    );
    final questionsSinceLastStepChange =
        state.questionsSinceLastStepChangeByOperation[op] ??
            LearningConstants.cooldownQuestionsAfterStepChange;

    final suggestedStep = _adaptiveDifficultyService.suggestDifficultyStep(
      currentStep: currentStep,
      recentResults: updatedOpResults,
      minStep: DifficultyConfig.minDifficultyStep,
      maxStep: DifficultyConfig.maxDifficultyStep,
      questionsSinceLastStepChange: questionsSinceLastStepChange,
    );

    final updatedDifficultySteps =
        Map<OperationType, int>.from(state.difficultyStepsByOperation)
          ..[op] = suggestedStep;

    final updatedQuestionsSinceLastStepChangeByOperation =
        Map<OperationType, int>.from(
      state.questionsSinceLastStepChangeByOperation,
    )..[op] =
            suggestedStep != currentStep ? 0 : questionsSinceLastStepChange + 1;

    final feedback = _feedbackService.buildFeedback(
      question: question,
      userAnswer: answer,
      ageGroup: ageGroup,
      pointsEarned: pointsEarned,
      gotSpeedBonus: gotSpeedBonus,
      correctStreak: isCorrect ? newStreak : previousStreak,
      responseTime: responseTime,
      comboMultiplier: comboMultiplier,
    );

    final userId = state.userId;
    final isSpacedRepetitionEnabled = userId != null &&
        userId.isNotEmpty &&
        _reviewScheduleService.isSpacedRepetitionEnabled(userId);

    final updatedReviewSchedules = isSpacedRepetitionEnabled
        ? (() {
            final reviewKey = _reviewScheduleService.keyForQuestion(question);
            final previousReview = state.reviewSchedulesByKey[reviewKey];
            final updatedReview = _spacedRepetitionService.scheduleNextReview(
              questionId: reviewKey,
              wasCorrect: isCorrect,
              previous: previousReview,
              now: DateTime.now(),
            );
            return Map<String, ReviewSchedule>.from(state.reviewSchedulesByKey)
              ..[reviewKey] = updatedReview;
          })()
        : const <String, ReviewSchedule>{};
    final dueCount = isSpacedRepetitionEnabled
        ? _reviewScheduleService.countDueReviews(
            updatedReviewSchedules,
            DateTime.now(),
          )
        : 0;

    state = state.copyWith(
      session: updatedSession.copyWith(
        difficultyStepsByOperation: Map<OperationType, int>.unmodifiable(
          updatedDifficultySteps,
        ),
      ),
      feedback: feedback,
      difficultyStepsByOperation: Map<OperationType, int>.unmodifiable(
        updatedDifficultySteps,
      ),
      recentResultsByOperation: Map<OperationType, List<bool>>.unmodifiable(
        updatedResultsByOperation.map(
          (k, v) => MapEntry(k, List<bool>.unmodifiable(v)),
        ),
      ),
      questionsSinceLastStepChangeByOperation:
          Map<OperationType, int>.unmodifiable(
        updatedQuestionsSinceLastStepChangeByOperation,
      ),
      correctStreak: newStreak,
      bestCorrectStreak: newBestStreak,
      speedBonusCount: newSpeedBonusCount,
      reviewSchedulesByKey: Map<String, ReviewSchedule>.unmodifiable(
        updatedReviewSchedules,
      ),
      dueReviewCount: dueCount,
    );

    if (userId != null && userId.isNotEmpty) {
      debugPrint(
        '[QuizNotifier] submitAnswer: persisting session for userId=$userId',
      );
      _persistInProgressSession(
        userId: userId,
        session: updatedSession,
        pendingDueKeys: state.pendingDueKeys,
      );
      if (isSpacedRepetitionEnabled) {
        unawaited(
          _reviewScheduleService.saveReviewSchedules(
            userId,
            updatedReviewSchedules,
          ),
        );
      }
    }
  }

  void cancelSession(String userId) {
    final session = state.session;
    if (session == null) return;
    _persistInProgressSession(
      userId: userId,
      session: session,
      pendingDueKeys: state.pendingDueKeys,
      persistEvenWithoutAnswers: true,
    );
  }

  void advanceToNextQuestion() {
    final session = state.session;
    if (session == null) return;

    final nextIndex = session.currentQuestionIndex + 1;
    final isComplete = nextIndex >= session.totalQuestions;

    var updatedQuestions = session.questions;
    var newPendingDueKeys = state.pendingDueKeys;

    if (!isComplete && nextIndex >= updatedQuestions.length) {
      final nextPlan = _sessionPlanner.buildNextQuestionPlan(
        session: session,
        difficultyStepsByOperation: state.difficultyStepsByOperation,
        pendingDueKeys: newPendingDueKeys,
      );
      final nextQuestion = nextPlan.question;
      newPendingDueKeys = nextPlan.pendingDueKeys;
      updatedQuestions = [...updatedQuestions, nextQuestion];
    }

    final updatedSession = session.copyWith(
      currentQuestionIndex: nextIndex,
      endTime: isComplete ? DateTime.now() : session.endTime,
      questions: updatedQuestions,
    );

    state = state.copyWith(
      session: updatedSession,
      feedback: null,
      pendingDueKeys: newPendingDueKeys,
    );

    final userId = state.userId;
    if (userId != null && userId.isNotEmpty) {
      _persistInProgressSession(
        userId: userId,
        session: updatedSession,
        pendingDueKeys: newPendingDueKeys,
        persistEvenWithoutAnswers: true,
      );
    }
  }

  void clearFeedback() {
    if (state.feedback == null) return;
    state = state.copyWith(feedback: null);
  }

  void _persistInProgressSession({
    required String userId,
    required QuizSession session,
    required List<String> pendingDueKeys,
    bool persistEvenWithoutAnswers = false,
  }) {
    if (userId.isEmpty) return;
    _sessionStorageService.persistInProgressSession(
      userId: userId,
      session: session,
      pendingDueKeys: pendingDueKeys,
      persistEvenWithoutAnswers: persistEvenWithoutAnswers,
    );
  }

  static double _comboMultiplierForStreak(int streak) {
    if (streak >= 5) return 2.0;
    if (streak >= 3) return 1.5;
    return 1.0;
  }

  int _calculatePoints({
    required bool isCorrect,
    required Duration responseTime,
    required DifficultyLevel difficulty,
    int correctStreak = 0,
  }) {
    if (!isCorrect) return 0;

    var points = AppConstants.basePointsPerQuestion;
    points = (points * difficulty.pointMultiplier).round();

    if (responseTime.inSeconds <= 5) {
      points += AppConstants.bonusPointsForSpeed;
    }

    final multiplier = _comboMultiplierForStreak(correctStreak);
    if (multiplier > 1.0) {
      points = (points * multiplier).round();
    }

    return points;
  }
}

// endregion

// region Provider Definition

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final generator = ref.watch(questionGeneratorServiceProvider);
  final feedback = ref.watch(feedbackServiceProvider);
  final audio = ref.watch(audioServiceProvider);
  final repo = ref.watch(localStorageRepositoryProvider);
  final adaptiveDifficulty = ref.watch(adaptiveDifficultyServiceProvider);
  final spacedRepetition = ref.watch(spacedRepetitionServiceProvider);
  final reviewScheduleService = QuizReviewScheduleService(
    questionGenerator: generator,
    repository: repo,
    spacedRepetitionService: spacedRepetition,
  );
  final sessionPlanner = QuizSessionPlanner(
    questionGenerator: generator,
    reviewScheduleService: reviewScheduleService,
  );
  final sessionStorageService = QuizSessionStorageService(repo);

  return QuizNotifier(
    generator,
    feedback,
    audio,
    repo,
    adaptiveDifficultyService: adaptiveDifficulty,
    spacedRepetitionService: spacedRepetition,
    reviewScheduleService: reviewScheduleService,
    sessionPlanner: sessionPlanner,
    sessionStorageService: sessionStorageService,
  );
});

// endregion

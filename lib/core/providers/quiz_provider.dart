import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_features.dart';
import '../../core/config/difficulty_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/settings_keys.dart';
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
import '../services/audio_service.dart';
import '../services/question_generator_service.dart';
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
    this._questionGenerator,
    this._feedbackService,
    this._audioService,
    this._repository, {
    required AdaptiveDifficultyService adaptiveDifficultyService,
    required SpacedRepetitionService spacedRepetitionService,
  })  : _adaptiveDifficultyService = adaptiveDifficultyService,
        _spacedRepetitionService = spacedRepetitionService,
        super(const QuizState());

  final QuestionGeneratorService _questionGenerator;
  final FeedbackService _feedbackService;
  final AudioService _audioService;
  final LocalStorageRepository _repository;
  final AdaptiveDifficultyService _adaptiveDifficultyService;
  final SpacedRepetitionService _spacedRepetitionService;
  final _uuid = const Uuid();

  String _packedReviewKey({
    required OperationType operationType,
    required int operand1,
    required int operand2,
    required int correctAnswer,
    required String displayQuestionText,
  }) {
    return 'v2|${operationType.name}|$operand1|$operand2|$correctAnswer|$displayQuestionText';
  }

  String _reviewKeyForQuestion(Question question) {
    // Question IDs are per-session UUIDs, so use a stable packed content key
    // on disk instead of display-text parsing.
    return _packedReviewKey(
      operationType: question.operationType,
      operand1: question.operand1,
      operand2: question.operand2,
      correctAnswer: question.correctAnswer,
      displayQuestionText: question.displayQuestionText,
    );
  }

  String _normalizeStoredReviewKey(String key) {
    if (key.isEmpty || key.startsWith('v2|')) return key;

    final parsed = _questionGenerator.tryGenerateFromSrsKey(
      key,
      DifficultyLevel.easy,
    );
    if (parsed == null) return key;

    return _reviewKeyForQuestion(parsed);
  }

  String _canonicalStoredReviewKey({
    required String key,
    required String questionId,
  }) {
    final normalizedKey = _normalizeStoredReviewKey(key);
    final normalizedQuestionId = _normalizeStoredReviewKey(questionId);

    if (normalizedQuestionId.startsWith('v2|')) return normalizedQuestionId;
    if (normalizedKey.startsWith('v2|')) return normalizedKey;
    return normalizedQuestionId;
  }

  Map<String, ReviewSchedule> _loadReviewSchedules(String userId) {
    dynamic raw;
    try {
      raw = _repository.getSetting(
        SettingsKeys.spacedRepetitionSchedules(userId),
      );
    } catch (e) {
      debugPrint(
        '[QuizNotifier] _loadReviewSchedules skipped (storage unavailable): $e',
      );
      return const <String, ReviewSchedule>{};
    }
    if (raw is! List) return const <String, ReviewSchedule>{};

    final map = <String, ReviewSchedule>{};
    var migratedAny = false;
    for (final item in raw) {
      if (item is! Map) continue;
      final entry = Map<String, dynamic>.from(item);
      final key = entry['key']?.toString();
      final questionId = entry['questionId']?.toString();
      final nextReviewRaw = entry['nextReviewDate']?.toString();
      final intervalDays = entry['intervalDays'];
      final consecutiveCorrect = entry['consecutiveCorrect'];

      if (key == null || key.isEmpty) continue;
      if (questionId == null || questionId.isEmpty) continue;
      final nextReviewDate = DateTime.tryParse(nextReviewRaw ?? '');
      if (nextReviewDate == null) continue;
      if (intervalDays is! int || consecutiveCorrect is! int) continue;

      final canonicalKey = _canonicalStoredReviewKey(
        key: key,
        questionId: questionId,
      );
      if (canonicalKey != key || canonicalKey != questionId) {
        migratedAny = true;
      }

      final schedule = ReviewSchedule(
        questionId: canonicalKey,
        nextReviewDate: nextReviewDate,
        intervalDays: intervalDays,
        consecutiveCorrect: consecutiveCorrect,
      );

      final existing = map[canonicalKey];
      if (existing == null ||
          nextReviewDate.isAfter(existing.nextReviewDate) ||
          (nextReviewDate.isAtSameMomentAs(existing.nextReviewDate) &&
              consecutiveCorrect >= existing.consecutiveCorrect)) {
        map[canonicalKey] = schedule;
      }
    }

    if (migratedAny) {
      unawaited(_saveReviewSchedules(userId, map));
    }

    return map;
  }

  Future<void> _saveReviewSchedules(
    String userId,
    Map<String, ReviewSchedule> schedules,
  ) async {
    final raw = schedules.entries
        .map(
          (entry) => {
            'key': entry.key,
            'questionId': entry.key,
            'nextReviewDate': entry.value.nextReviewDate.toIso8601String(),
            'intervalDays': entry.value.intervalDays,
            'consecutiveCorrect': entry.value.consecutiveCorrect,
          },
        )
        .toList(growable: false);

    try {
      await _repository.saveSetting(
        SettingsKeys.spacedRepetitionSchedules(userId),
        raw,
      );
    } catch (e) {
      debugPrint(
        '[QuizNotifier] _saveReviewSchedules skipped (storage unavailable): $e',
      );
    }
  }

  int _countDueReviews(Map<String, ReviewSchedule> schedules, DateTime now) {
    return _spacedRepetitionService
        .getDueQuestionIds(schedules.values.toList(growable: false), now)
        .length;
  }

  bool _isSpacedRepetitionEnabled(String userId) {
    try {
      return QuizFeatureSettings.readSpacedRepetitionEnabled(
        repository: _repository,
        userId: userId,
      );
    } catch (_) {
      return AppFeatures.spacedRepetitionEnabled;
    }
  }

  void hydrateReviewSummaryForUser(String userId) {
    if (userId.isEmpty) return;

    final isEnabled = _isSpacedRepetitionEnabled(userId);
    final reviewSchedules = isEnabled
        ? _loadReviewSchedules(userId)
        : const <String, ReviewSchedule>{};
    final dueCount =
        isEnabled ? _countDueReviews(reviewSchedules, DateTime.now()) : 0;

    state = state.copyWith(
      userId: userId,
      reviewSchedulesByKey: Map<String, ReviewSchedule>.unmodifiable(
        reviewSchedules,
      ),
      dueReviewCount: dueCount,
    );
  }

  void _persistInProgressSession({
    required String userId,
    required QuizSession session,
    bool persistEvenWithoutAnswers = false,
  }) {
    debugPrint(
      '[QuizNotifier] _persistInProgressSession: '
      'userId=$userId, operationType=${session.operationType.name}',
    );
    final answered = session.correctAnswers + session.wrongAnswers;
    if (answered <= 0 && !persistEvenWithoutAnswers) {
      debugPrint(
        '[QuizNotifier] _persistInProgressSession: no answers yet, skipping',
      );
      return;
    }

    final inProgressId = _repository.inProgressQuizSessionId(
      userId: userId,
      operationTypeName: session.operationType.name,
    );

    // Clean up any legacy in-progress entries
    unawaited(
      _repository.purgeInProgressQuizSessions(
        userId: userId,
        operationTypeName: session.operationType.name,
        exceptSessionId: inProgressId,
      ),
    );

    final sessionMap = session.toJson();
    sessionMap['sessionId'] = inProgressId;
    sessionMap['userId'] = userId;
    sessionMap['isComplete'] = false;
    sessionMap['pendingDueKeys'] = List<String>.from(state.pendingDueKeys);
    if (answered <= 0) {
      sessionMap['totalQuestions'] = 0;
      sessionMap['correctAnswers'] = 0;
      sessionMap['wrongAnswers'] = 0;
      sessionMap['successRate'] = 0.0;
      sessionMap['totalPoints'] = 0;
    }

    unawaited(_repository.saveQuizSession(sessionMap));
  }

  void _resetInProgressUnderlag({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
  }) {
    final now = DateTime.now();
    _writeSessionInfo(
      userId: userId,
      operationType: operationType,
      difficulty: difficulty,
      correctAnswers: 0,
      totalQuestions: 0,
      successRate: 0.0,
      points: 0,
      start: now,
      end: now,
    );
  }

  void _writeSessionInfo({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required int correctAnswers,
    required int totalQuestions,
    required double successRate,
    required int points,
    required DateTime start,
    required DateTime end,
  }) {
    final inProgressId = _repository.inProgressQuizSessionId(
      userId: userId,
      operationTypeName: operationType.name,
    );

    // Clean up any legacy in-progress entries so benchmark underlag doesn't
    // overcount abandoned sessions.
    unawaited(
      _repository.purgeInProgressQuizSessions(
        userId: userId,
        operationTypeName: operationType.name,
        exceptSessionId: inProgressId,
      ),
    );

    // Fire-and-forget so answering stays snappy.
    unawaited(
      _repository.saveQuizSession({
        'sessionId': inProgressId,
        'userId': userId,
        'operationType': operationType.name,
        'difficulty': difficulty.name,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'successRate': successRate,
        'points': points,
        'bonusPoints': 0,
        'pointsWithBonus': points,
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'isComplete': false,
      }),
    );
  }

  void _prepareInProgressStorage({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
  }) {
    _resetInProgressUnderlag(
      userId: userId,
      operationType: operationType,
      difficulty: difficulty,
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

  ({Map<String, ReviewSchedule> schedules, int dueCount})
      _loadInitialReviewState(
    String userId,
  ) {
    final isSpacedRepetitionEnabled = _isSpacedRepetitionEnabled(userId);
    final reviewSchedules = isSpacedRepetitionEnabled
        ? _loadReviewSchedules(userId)
        : const <String, ReviewSchedule>{};
    final dueCount = isSpacedRepetitionEnabled
        ? _countDueReviews(reviewSchedules, DateTime.now())
        : 0;

    return (schedules: reviewSchedules, dueCount: dueCount);
  }

  void _activateSessionState({
    required String userId,
    required QuizSession session,
    required Map<OperationType, int> steps,
    required ({
      Map<String, ReviewSchedule> schedules,
      int dueCount
    }) reviewState,
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
      persistEvenWithoutAnswers: true,
    );
  }

  /// Returns due SRS keys filtered to the sessionâ€™s operation type.
  /// For [OperationType.mixed] sessions, all due keys are included.
  /// Capped at [max(1, totalQuestions ~/ 3)] to avoid flooding the session.
  List<String> _getDueKeysForSession(
    Map<String, ReviewSchedule> schedules,
    OperationType sessionOpType,
    int totalQuestions,
    DateTime now,
  ) {
    final allDue = _spacedRepetitionService.getDueQuestionIds(
      schedules.values.toList(growable: false),
      now,
    );
    final filtered = allDue.where((key) {
      if (sessionOpType == OperationType.mixed) return true;
      // v2-format: "v2|{opName}|..." â€” extract opName from segment [1]
      // legacy format remains supported while old storage migrates forward.
      final isV2 = key.startsWith('v2|');
      final opName = isV2
          ? key.split('|').elementAtOrNull(1) ?? ''
          : key.substring(0, key.indexOf('|').clamp(0, key.length));
      if (opName.isEmpty) return false;
      return opName == sessionOpType.name;
    }).toList();

    if (filtered.isEmpty) return const [];
    final cap = (totalQuestions ~/ 3).clamp(1, filtered.length);
    return filtered.take(cap).toList();
  }

  List<String> _readPendingDueKeys(Map<String, dynamic> sessionMap) {
    final raw = sessionMap['pendingDueKeys'];
    if (raw is! List) return const <String>[];

    return raw
        .whereType<String>()
        .where((key) => key.isNotEmpty)
        .toList(growable: false);
  }

  ({List<Question> initialQuestions, List<String> pendingDueKeys})
      _buildCustomSessionQuestionPlan({
    required List<Question> questions,
    required DifficultyLevel difficulty,
    required OperationType operationType,
    required Map<String, ReviewSchedule> schedules,
    required DateTime now,
  }) {
    final dueKeys = _getDueKeysForSession(
      schedules,
      operationType,
      questions.length,
      now,
    );
    if (dueKeys.isEmpty) {
      return (
        initialQuestions: List<Question>.unmodifiable(questions),
        pendingDueKeys: const <String>[],
      );
    }

    Question? firstDueQuestion;
    final remainingDueKeys = <String>[];

    for (final key in dueKeys) {
      final parsed = _questionGenerator.tryGenerateFromSrsKey(key, difficulty);
      if (parsed == null) continue;

      if (firstDueQuestion == null) {
        firstDueQuestion = parsed;
      } else {
        remainingDueKeys.add(key);
      }
    }

    if (firstDueQuestion == null) {
      return (
        initialQuestions: List<Question>.unmodifiable(questions),
        pendingDueKeys: const <String>[],
      );
    }

    final totalDueCount = 1 + remainingDueKeys.length;
    final retainedCustomCount =
        questions.length > totalDueCount ? questions.length - totalDueCount : 0;

    return (
      initialQuestions: List<Question>.unmodifiable([
        firstDueQuestion,
        ...questions.take(retainedCustomCount),
      ]),
      pendingDueKeys: List<String>.unmodifiable(remainingDueKeys),
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

    _prepareInProgressStorage(
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

    final reviewState = _loadInitialReviewState(userId);

    // Compute due SRS keys for this session and try to use the first one.
    final dueKeys = _getDueKeysForSession(
      reviewState.schedules,
      operationType,
      count,
      DateTime.now(),
    );
    final firstDueQuestion = dueKeys.isNotEmpty
        ? _questionGenerator.tryGenerateFromSrsKey(dueKeys.first, difficulty)
        : null;
    final firstQuestion = firstDueQuestion ??
        _questionGenerator.generateQuestion(
          ageGroup: ageGroup,
          operationType: operationType,
          difficulty: difficulty,
          difficultyStepsByOperation: steps,
          gradeLevel: gradeLevel,
          wordProblemsEnabledOverride: featureFlags.wordProblemsEnabled,
          missingNumberEnabledOverride: featureFlags.missingNumberEnabled,
        );
    final remainingDueKeys =
        dueKeys.isNotEmpty ? dueKeys.sublist(1) : const <String>[];

    final session = QuizSession(
      sessionId: _uuid.v4(),
      ageGroup: ageGroup,
      gradeLevel: gradeLevel,
      operationType: operationType,
      difficulty: difficulty,
      questions: [firstQuestion],
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
      pendingDueKeys: remainingDueKeys,
    );
  }

  void resumeSession({
    required String userId,
    required Map<String, dynamic> sessionMap,
  }) {
    debugPrint('[QuizNotifier] resumeSession: userId=$userId');

    final session = QuizSessionJson.fromJson(sessionMap);

    _prepareInProgressStorage(
      userId: userId,
      operationType: session.operationType,
      difficulty: session.difficulty,
    );

    final reviewState = _loadInitialReviewState(userId);

    _activateSessionState(
      userId: userId,
      session: session,
      steps: session.difficultyStepsByOperation,
      reviewState: reviewState,
      isDailyChallenge: false,
      pendingDueKeys: _readPendingDueKeys(sessionMap),
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

    _prepareInProgressStorage(
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

    final reviewState = _loadInitialReviewState(userId);

    final questionPlan = _buildCustomSessionQuestionPlan(
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
        _isSpacedRepetitionEnabled(userId);

    final updatedReviewSchedules = isSpacedRepetitionEnabled
        ? (() {
            final reviewKey = _reviewKeyForQuestion(question);
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
        ? _countDueReviews(updatedReviewSchedules, DateTime.now())
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
      _persistInProgressSession(userId: userId, session: updatedSession);
      if (isSpacedRepetitionEnabled) {
        unawaited(_saveReviewSchedules(userId, updatedReviewSchedules));
      }
    }
  }

  void cancelSession(String userId) {
    final session = state.session;
    if (session == null) return;
    _persistInProgressSession(
      userId: userId,
      session: session,
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
      Question nextQuestion;
      if (newPendingDueKeys.isNotEmpty) {
        final candidate = _questionGenerator.tryGenerateFromSrsKey(
          newPendingDueKeys.first,
          session.difficulty,
        );
        nextQuestion = candidate ??
            _questionGenerator.generateQuestion(
              ageGroup: session.ageGroup,
              operationType: session.operationType,
              difficulty: session.difficulty,
              difficultyStepsByOperation: state.difficultyStepsByOperation,
              gradeLevel: session.gradeLevel,
              wordProblemsEnabledOverride: session.wordProblemsEnabled,
              missingNumberEnabledOverride: session.missingNumberEnabled,
            );
        newPendingDueKeys = newPendingDueKeys.sublist(1);
      } else {
        nextQuestion = _questionGenerator.generateQuestion(
          ageGroup: session.ageGroup,
          operationType: session.operationType,
          difficulty: session.difficulty,
          difficultyStepsByOperation: state.difficultyStepsByOperation,
          gradeLevel: session.gradeLevel,
          wordProblemsEnabledOverride: session.wordProblemsEnabled,
          missingNumberEnabledOverride: session.missingNumberEnabled,
        );
      }
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
        persistEvenWithoutAnswers: true,
      );
    }
  }

  void clearFeedback() {
    if (state.feedback == null) return;
    state = state.copyWith(feedback: null);
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

  return QuizNotifier(
    generator,
    feedback,
    audio,
    repo,
    adaptiveDifficultyService: adaptiveDifficulty,
    spacedRepetitionService: spacedRepetition,
  );
});

// endregion

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:siffersafari/core/config/app_features.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import 'question_generator_service.dart';

class QuizReviewStateSnapshot {
  const QuizReviewStateSnapshot({
    required this.schedules,
    required this.dueCount,
  });

  final Map<String, ReviewSchedule> schedules;
  final int dueCount;
}

class QuizReviewScheduleService {
  const QuizReviewScheduleService({
    required QuestionGeneratorService questionGenerator,
    required LocalStorageRepository repository,
    required SpacedRepetitionService spacedRepetitionService,
  })  : _questionGenerator = questionGenerator,
        _repository = repository,
        _spacedRepetitionService = spacedRepetitionService;

  final QuestionGeneratorService _questionGenerator;
  final LocalStorageRepository _repository;
  final SpacedRepetitionService _spacedRepetitionService;

  String keyForQuestion(Question question) {
    return _packedReviewKey(
      operationType: question.operationType,
      operand1: question.operand1,
      operand2: question.operand2,
      correctAnswer: question.correctAnswer,
      displayQuestionText: question.displayQuestionText,
    );
  }

  bool isSpacedRepetitionEnabled(String userId) {
    try {
      return QuizFeatureSettings.readSpacedRepetitionEnabled(
        repository: _repository,
        userId: userId,
      );
    } catch (_) {
      return AppFeatures.spacedRepetitionEnabled;
    }
  }

  QuizReviewStateSnapshot loadInitialReviewState(String userId) {
    final isEnabled = isSpacedRepetitionEnabled(userId);
    final reviewSchedules = isEnabled
        ? loadReviewSchedules(userId)
        : const <String, ReviewSchedule>{};
    final dueCount =
        isEnabled ? countDueReviews(reviewSchedules, DateTime.now()) : 0;

    return QuizReviewStateSnapshot(
      schedules: reviewSchedules,
      dueCount: dueCount,
    );
  }

  Map<String, ReviewSchedule> loadReviewSchedules(String userId) {
    dynamic raw;
    try {
      raw = _repository.getSetting(
        SettingsKeys.spacedRepetitionSchedules(userId),
      );
    } catch (e) {
      debugPrint(
        '[QuizReviewScheduleService] loadReviewSchedules skipped (storage unavailable): $e',
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
      unawaited(saveReviewSchedules(userId, map));
    }

    return map;
  }

  Future<void> saveReviewSchedules(
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
        '[QuizReviewScheduleService] saveReviewSchedules skipped (storage unavailable): $e',
      );
    }
  }

  int countDueReviews(Map<String, ReviewSchedule> schedules, DateTime now) {
    return _spacedRepetitionService
        .getDueQuestionIds(schedules.values.toList(growable: false), now)
        .length;
  }

  List<String> getDueKeysForSession(
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

  List<String> readPendingDueKeys(Map<String, dynamic> sessionMap) {
    final raw = sessionMap['pendingDueKeys'];
    if (raw is! List) return const <String>[];

    return raw
        .whereType<String>()
        .where((key) => key.isNotEmpty)
        .toList(growable: false);
  }

  String _packedReviewKey({
    required OperationType operationType,
    required int operand1,
    required int operand2,
    required int correctAnswer,
    required String displayQuestionText,
  }) {
    return 'v2|${operationType.name}|$operand1|$operand2|$correctAnswer|$displayQuestionText';
  }

  String _normalizeStoredReviewKey(String key) {
    if (key.isEmpty || key.startsWith('v2|')) return key;

    final parsed = _questionGenerator.tryGenerateFromSrsKey(
      key,
      DifficultyLevel.easy,
    );
    if (parsed == null) return key;

    return keyForQuestion(parsed);
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
}

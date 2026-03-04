import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/settings_keys.dart';
import '../../domain/entities/user_progress.dart';

/// Repository for local storage operations using Hive
class LocalStorageRepository {
  Box<dynamic> get _userProgressBox => Hive.box(AppConstants.userProgressBox);
  Box<dynamic> get _quizHistoryBox => Hive.box(AppConstants.quizHistoryBox);
  Box<dynamic> get _settingsBox => Hive.box(AppConstants.settingsBox);

  String inProgressQuizSessionId({
    required String userId,
    required String operationTypeName,
  }) {
    // Deterministic key so “in progress” is overwritten when the child starts
    // the same operation again.
    return 'inprogress_${userId}_$operationTypeName';
  }

  Map<String, dynamic>? _tryAsStringKeyedMap(dynamic value) {
    if (value is! Map) return null;
    try {
      return Map<String, dynamic>.from(value);
    } catch (_) {
      return null;
    }
  }

  DateTime _sessionStartTime(Map<String, dynamic> session) {
    return DateTime.tryParse(session['startTime']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Validate critical quiz session fields and skip if invalid
  /// Returns null if data is corrupted/invalid, otherwise the validated session
  Map<String, dynamic>? _validateQuizSession(dynamic value) {
    final session = _tryAsStringKeyedMap(value);
    if (session == null) return null;

    // Validate critical fields
    final sessionId = session['sessionId'];
    final userId = session['userId'];
    final isComplete = session['isComplete'];
    final operationType = session['operationType'];

    if (sessionId is! String || sessionId.isEmpty) return null;
    if (userId is! String || userId.isEmpty) return null;
    if (isComplete is! bool) return null;
    if (operationType is! String || operationType.isEmpty) return null;

    return session;
  }

  /// Save user progress
  Future<void> saveUserProgress(UserProgress progress) async {
    await _userProgressBox.put(progress.userId, progress);
  }

  /// Get user progress by ID
  UserProgress? getUserProgress(String userId) {
    return _userProgressBox.get(userId) as UserProgress?;
  }

  /// Get all user profiles
  List<UserProgress> getAllUserProfiles() {
    return _userProgressBox.values.cast<UserProgress>().toList();
  }

  /// Delete user progress
  Future<void> deleteUserProgress(String userId) async {
    await _userProgressBox.delete(userId);
  }

  /// Save a quiz session to history
  Future<void> saveQuizSession(Map<String, dynamic> session) async {
    final sessionId = session['sessionId'] as String;
    debugPrint('[LocalStorage] saveQuizSession: sessionId=$sessionId');
    try {
      await _quizHistoryBox.put(sessionId, session);
      debugPrint('[LocalStorage] saveQuizSession: success for $sessionId');
    } catch (e, st) {
      debugPrint('[LocalStorage] saveQuizSession failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteQuizSession(String sessionId) async {
    debugPrint('[LocalStorage] deleteQuizSession: sessionId=$sessionId');
    try {
      await _quizHistoryBox.delete(sessionId);
      debugPrint('[LocalStorage] deleteQuizSession: success for $sessionId');
    } catch (e, st) {
      debugPrint('[LocalStorage] deleteQuizSession failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> purgeInProgressQuizSessions({
    required String userId,
    required String operationTypeName,
    String? exceptSessionId,
  }) async {
    debugPrint(
      '[LocalStorage] purgeInProgressQuizSessions: userId=$userId, '
      'operationTypeName=$operationTypeName, exceptSessionId=$exceptSessionId',
    );
    try {
      final keys = _quizHistoryBox.keys.toList(growable: false);
      debugPrint('[LocalStorage] Quiz history has ${keys.length} sessions');
      for (final key in keys) {
      final value = _quizHistoryBox.get(key);
      
      // Validate before accessing fields
      final session = _validateQuizSession(value);
      if (session == null) {
        // Silently skip/delete corrupted entries
        await _quizHistoryBox.delete(key);
        continue;
      }

      if (session['userId'] != userId) continue;
      if (session['operationType'] != operationTypeName) continue;
      if (session['isComplete'] != false) continue;

      if (exceptSessionId != null && session['sessionId'] == exceptSessionId) {
        continue;
      }

      await _quizHistoryBox.delete(key);
      }
    debugPrint('[LocalStorage] purgeInProgressQuizSessions completed');
    } catch (e, st) {
      debugPrint('[LocalStorage] purgeInProgressQuizSessions failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// Get quiz history for a user
  List<Map<String, dynamic>> getQuizHistory(String userId, {int? limit}) {
    if (limit != null && limit <= 0) return const [];

    // Fast path: when limit is small (typical UI use), avoid sorting the full
    // history. Keep only the newest [limit] items while iterating.
    if (limit != null) {
      final top = <Map<String, dynamic>>[]; // newest -> oldest

      for (final value in _quizHistoryBox.values) {
        // Validate before accessing
        final session = _validateQuizSession(value);
        if (session == null) continue;
        if (session['userId'] != userId) continue;

        final date = _sessionStartTime(session);

        var insertAt = top.length;
        for (var i = 0; i < top.length; i++) {
          final existingDate = _sessionStartTime(top[i]);
          if (date.isAfter(existingDate)) {
            insertAt = i;
            break;
          }
        }

        if (insertAt == top.length) {
          if (top.length < limit) {
            top.add(session);
          }
        } else {
          top.insert(insertAt, session);
          if (top.length > limit) {
            top.removeLast();
          }
        }
      }

      return top;
    }

    // Full list requested.
    final allSessions = <Map<String, dynamic>>[];
    for (final value in _quizHistoryBox.values) {
      // Validate before accessing
      final session = _validateQuizSession(value);
      if (session == null) continue;
      if (session['userId'] != userId) continue;
      allSessions.add(session);
    }

    // Sort by date (newest first)
    allSessions.sort((a, b) {
      return _sessionStartTime(b).compareTo(_sessionStartTime(a));
    });

    return allSessions;
  }

  /// Delete quiz history for a user
  Future<void> deleteQuizHistoryForUser(String userId) async {
    final keys = _quizHistoryBox.keys.toList(growable: false);
    for (final key in keys) {
      final value = _quizHistoryBox.get(key);
      // Validate before accessing
      final session = _validateQuizSession(value);
      if (session != null && session['userId'] == userId) {
        await _quizHistoryBox.delete(key);
      }
    }
  }

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Delete a setting
  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  /// Get a setting
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  // --- Typed settings helpers (prefer these over raw getSetting/saveSetting) ---

  String? getActiveUserId() {
    final raw = getSetting(SettingsKeys.activeUserId);
    return raw is String && raw.isNotEmpty ? raw : null;
  }

  Future<void> setActiveUserId(String userId) async {
    await saveSetting(SettingsKeys.activeUserId, userId);
  }

  Future<void> clearActiveUserId() async {
    await deleteSetting(SettingsKeys.activeUserId);
  }

  bool isOnboardingDone(String userId) {
    final raw = getSetting(SettingsKeys.onboardingDone(userId));
    return raw is bool ? raw : false;
  }

  Future<void> setOnboardingDone(String userId, bool done) async {
    await saveSetting(SettingsKeys.onboardingDone(userId), done);
  }

  List<String> getAllowedOperationNames(String userId) {
    final raw = getSetting(SettingsKeys.allowedOperations(userId));
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const <String>[];
  }

  Future<void> setAllowedOperationNames(
    String userId,
    List<String> operationNames,
  ) async {
    await saveSetting(SettingsKeys.allowedOperations(userId), operationNames);
  }

  String? getCurrentQuestId(String userId) {
    final raw = getSetting(SettingsKeys.questCurrent(userId));
    return raw is String && raw.isNotEmpty ? raw : null;
  }

  Future<void> setCurrentQuestId(String userId, String questId) async {
    await saveSetting(SettingsKeys.questCurrent(userId), questId);
  }

  Set<String> getCompletedQuestIds(String userId) {
    final raw = getSetting(SettingsKeys.questCompleted(userId));
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  Future<void> setCompletedQuestIds(String userId, Set<String> questIds) async {
    await saveSetting(
      SettingsKeys.questCompleted(userId),
      questIds.toList(growable: false),
    );
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await _userProgressBox.clear();
    await _quizHistoryBox.clear();
    await _settingsBox.clear();
  }
}

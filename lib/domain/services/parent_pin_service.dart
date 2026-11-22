import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import '../entities/pin_recovery_config.dart';

// BCrypt is deliberately CPU-expensive (that is the point), so the two helpers
// below are the units of work that [ParentPinService] may push onto a
// background isolate (see `_hashPin` / `_checkPin`).
String _hashPinSync(String pin) =>
    BCrypt.hashpw(pin, BCrypt.gensalt(logRounds: 10));

bool _checkPinSync(List<String> arguments) =>
    BCrypt.checkpw(arguments[0], arguments[1]);

/// Service for secure parent PIN management with hashing and rate limiting.
class ParentPinService {
  ParentPinService(this._storage);

  final LocalStorageRepository _storage;

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 5);

  /// Hash a PIN using BCrypt (adaptive hashing with built-in salt).
  ///
  /// Release/profile builds run this off the UI isolate so the parent gate
  /// cannot freeze a frame. Debug builds hash inline: an isolate hop inside a
  /// widget test's fake-async zone is a well-known source of hangs, and debug
  /// jank never reaches users.
  Future<String> _hashPin(String pin) => kDebugMode
      ? Future<String>.value(_hashPinSync(pin))
      : compute(_hashPinSync, pin);

  /// Constant-time BCrypt comparison. See [_hashPin] for the isolate policy.
  Future<bool> _checkPin(String plainText, String hash) => kDebugMode
      ? Future<bool>.value(_checkPinSync(<String>[plainText, hash]))
      : compute(_checkPinSync, <String>[plainText, hash]);

  // region Rate limiting (shared by PIN and security answer)

  /// Throws [PinLockoutException] while locked out, and clears an expired
  /// lockout (resetting the attempt counter) on the way through.
  Future<void> _assertNotLockedOut({
    required String attemptsKey,
    required String lockoutKey,
  }) async {
    final lockoutUntil = _storage.getSetting(lockoutKey) as int?;
    if (lockoutUntil == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now < lockoutUntil) {
      final remainingMinutes = ((lockoutUntil - now) / 1000 / 60).ceil();
      throw PinLockoutException(remainingMinutes);
    }

    // Lockout expired, clear it.
    await _storage.deleteSetting(lockoutKey);
    await _storage.saveSetting(attemptsKey, 0);
  }

  int _remainingAttempts(String attemptsKey) {
    final failedAttempts = _storage.getSetting(attemptsKey) as int? ?? 0;
    final remaining = _maxFailedAttempts - failedAttempts;
    return remaining > 0 ? remaining : 0;
  }

  /// Records a failed attempt and throws [PinLockoutException] on the attempt
  /// that trips the lockout.
  Future<void> _registerFailure({
    required String attemptsKey,
    required String lockoutKey,
  }) async {
    final failedAttempts = (_storage.getSetting(attemptsKey) as int? ?? 0) + 1;
    await _storage.saveSetting(attemptsKey, failedAttempts);

    if (failedAttempts >= _maxFailedAttempts) {
      final lockoutUntil =
          DateTime.now().add(_lockoutDuration).millisecondsSinceEpoch;
      await _storage.saveSetting(lockoutKey, lockoutUntil);
      throw PinLockoutException(_lockoutDuration.inMinutes);
    }
  }

  Future<void> _resetFailures({
    required String attemptsKey,
    required String lockoutKey,
  }) async {
    await _storage.saveSetting(attemptsKey, 0);
    await _storage.deleteSetting(lockoutKey);
  }

  int? _lockoutRemainingMinutes(String lockoutKey) {
    final lockoutUntil = _storage.getSetting(lockoutKey) as int?;
    if (lockoutUntil == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutUntil) return null;

    return ((lockoutUntil - now) / 1000 / 60).ceil();
  }

  // endregion

  /// Check if PIN exists (has been set).
  bool hasPinSet() {
    final hash = _storage.getSetting(SettingsKeys.parentPinHash) as String?;
    return hash != null && hash.isNotEmpty;
  }

  /// Save a new PIN (hashed).
  Future<void> setPin(String pin) async {
    final hash = await _hashPin(pin);
    await _storage.saveSetting(SettingsKeys.parentPinHash, hash);

    // Reset failed attempts when setting new PIN — for both the PIN itself and
    // the security question, since this is an authenticated action.
    await _resetFailures(
      attemptsKey: SettingsKeys.parentPinFailedAttempts,
      lockoutKey: SettingsKeys.parentPinLockoutUntil,
    );
    await _resetFailures(
      attemptsKey: SettingsKeys.parentSecurityAnswerFailedAttempts,
      lockoutKey: SettingsKeys.parentSecurityAnswerLockoutUntil,
    );
  }

  /// Verify if provided PIN matches stored hash.
  /// Returns true if correct, false if wrong or locked out.
  /// Throws [PinLockoutException] if currently locked out.
  Future<bool> verifyPin(String pin) async {
    await _assertNotLockedOut(
      attemptsKey: SettingsKeys.parentPinFailedAttempts,
      lockoutKey: SettingsKeys.parentPinLockoutUntil,
    );

    final storedHash =
        _storage.getSetting(SettingsKeys.parentPinHash) as String?;
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }

    final isCorrect = await _checkPin(pin, storedHash);

    if (isCorrect) {
      await _resetFailures(
        attemptsKey: SettingsKeys.parentPinFailedAttempts,
        lockoutKey: SettingsKeys.parentPinLockoutUntil,
      );
      return true;
    }

    await _registerFailure(
      attemptsKey: SettingsKeys.parentPinFailedAttempts,
      lockoutKey: SettingsKeys.parentPinLockoutUntil,
    );
    return false;
  }

  /// Get remaining failed attempts before lockout.
  int getRemainingAttempts() =>
      _remainingAttempts(SettingsKeys.parentPinFailedAttempts);

  /// Check if currently locked out and return remaining minutes.
  int? getLockoutRemainingMinutes() =>
      _lockoutRemainingMinutes(SettingsKeys.parentPinLockoutUntil);

  // ============================================================================
  // PIN RECOVERY METHODS (Security Question)
  // ============================================================================

  /// Check if recovery config is set up
  bool hasRecoveryConfigured() {
    final config = _getRecoveryConfig();
    return config != null;
  }

  /// Get the stored recovery config (or null if not set)
  PinRecoveryConfig? _getRecoveryConfig() {
    final raw = _storage.getSetting(SettingsKeys.parentPinRecoveryConfig);
    if (raw is! Map) return null;

    try {
      return PinRecoveryConfig(
        securityQuestion: raw['securityQuestion'] as String? ?? '',
        securityAnswerHash: raw['securityAnswerHash'] as String? ?? '',
        createdAt: raw['createdAt'] is String
            ? DateTime.tryParse(raw['createdAt'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  /// Save recovery config to storage
  Future<void> _saveRecoveryConfig(PinRecoveryConfig config) async {
    await _storage.saveSetting(SettingsKeys.parentPinRecoveryConfig, {
      'securityQuestion': config.securityQuestion,
      'securityAnswerHash': config.securityAnswerHash,
      'createdAt': config.createdAt?.toIso8601String(),
    });
  }

  /// Setup PIN recovery on first PIN creation using a security question.
  Future<void> setupPinRecovery({
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    // Hash the security answer
    final answerHash = await _hashPin(securityAnswer.trim().toLowerCase());

    // Store recovery config for security question based recovery.
    final config = PinRecoveryConfig(
      securityQuestion: securityQuestion,
      securityAnswerHash: answerHash,
      createdAt: DateTime.now(),
    );

    await _saveRecoveryConfig(config);

    // A freshly configured answer starts with a clean slate.
    await _resetFailures(
      attemptsKey: SettingsKeys.parentSecurityAnswerFailedAttempts,
      lockoutKey: SettingsKeys.parentSecurityAnswerLockoutUntil,
    );
  }

  /// Verify security question answer.
  ///
  /// Rate limited with the same policy as [verifyPin]. Without this the free-text
  /// recovery answer is an unlimited-guess way around the PIN lockout.
  ///
  /// Throws [PinLockoutException] if currently locked out.
  Future<bool> verifySecurityAnswer(String answer) async {
    await _assertNotLockedOut(
      attemptsKey: SettingsKeys.parentSecurityAnswerFailedAttempts,
      lockoutKey: SettingsKeys.parentSecurityAnswerLockoutUntil,
    );

    final config = _getRecoveryConfig();
    if (config == null) return false;

    // Compare lowercase, trimmed answers
    final isCorrect = await _checkPin(
      answer.trim().toLowerCase(),
      config.securityAnswerHash,
    );

    if (isCorrect) {
      await _resetFailures(
        attemptsKey: SettingsKeys.parentSecurityAnswerFailedAttempts,
        lockoutKey: SettingsKeys.parentSecurityAnswerLockoutUntil,
      );
      return true;
    }

    await _registerFailure(
      attemptsKey: SettingsKeys.parentSecurityAnswerFailedAttempts,
      lockoutKey: SettingsKeys.parentSecurityAnswerLockoutUntil,
    );
    return false;
  }

  /// Get remaining attempts at the security question before lockout.
  int getRemainingSecurityAnswerAttempts() =>
      _remainingAttempts(SettingsKeys.parentSecurityAnswerFailedAttempts);

  /// Check if the security question is currently locked out.
  int? getSecurityAnswerLockoutRemainingMinutes() =>
      _lockoutRemainingMinutes(SettingsKeys.parentSecurityAnswerLockoutUntil);

  /// Get security question (for display in recovery flow)
  String? getSecurityQuestion() {
    return _getRecoveryConfig()?.securityQuestion;
  }

  /// Clear recovery config (e.g., when user deletes profile)
  Future<void> clearRecoveryConfig() async {
    await _storage.deleteSetting(SettingsKeys.parentPinRecoveryConfig);
    await _resetFailures(
      attemptsKey: SettingsKeys.parentSecurityAnswerFailedAttempts,
      lockoutKey: SettingsKeys.parentSecurityAnswerLockoutUntil,
    );
  }
}

/// Exception thrown when PIN verification is attempted during lockout.
class PinLockoutException implements Exception {
  PinLockoutException(this.remainingMinutes);

  final int remainingMinutes;

  @override
  String toString() =>
      'För många felaktiga försök. Försök igen om $remainingMinutes minut${remainingMinutes != 1 ? 'er' : ''}.';
}

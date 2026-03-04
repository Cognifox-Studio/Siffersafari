import 'package:bcrypt/bcrypt.dart';

import '../../data/repositories/local_storage_repository.dart';
import '../entities/pin_recovery_config.dart';

/// Service for secure parent PIN management with hashing and rate limiting.
class ParentPinService {
  ParentPinService(this._storage);

  final LocalStorageRepository _storage;

  static const String _pinHashKey = 'parent_pin_hash';
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lockoutUntilKey = 'pin_lockout_until';
  static const String _recoveryConfigKey = 'pin_recovery_config';

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 5);
  static const int _backupCodesPerConfig = 6;

  /// Hash a PIN using BCrypt (adaptive hashing with built-in salt).
  String _hashPin(String pin) {
    // Generate salt and hash in one operation (cost factor 10 is standard)
    return BCrypt.hashpw(pin, BCrypt.gensalt(logRounds: 10));
  }

  /// Check if PIN exists (has been set).
  bool hasPinSet() {
    final hash = _storage.getSetting(_pinHashKey) as String?;
    return hash != null && hash.isNotEmpty;
  }

  /// Save a new PIN (hashed).
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.saveSetting(_pinHashKey, hash);
    // Reset failed attempts when setting new PIN
    await _storage.saveSetting(_failedAttemptsKey, 0);
    await _storage.deleteSetting(_lockoutUntilKey);
  }

  /// Verify if provided PIN matches stored hash.
  /// Returns true if correct, false if wrong or locked out.
  /// Throws [PinLockoutException] if currently locked out.
  Future<bool> verifyPin(String pin) async {
    // Check lockout
    final lockoutUntil = _storage.getSetting(_lockoutUntilKey) as int?;
    if (lockoutUntil != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now < lockoutUntil) {
        final remainingMinutes = ((lockoutUntil - now) / 1000 / 60).ceil();
        throw PinLockoutException(remainingMinutes);
      } else {
        // Lockout expired, clear it
        await _storage.deleteSetting(_lockoutUntilKey);
        await _storage.saveSetting(_failedAttemptsKey, 0);
      }
    }

    final storedHash = _storage.getSetting(_pinHashKey) as String?;
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }

    // Use BCrypt.checkpw for secure constant-time comparison
    final isCorrect = BCrypt.checkpw(pin, storedHash);

    if (isCorrect) {
      // Reset failed attempts on successful login
      await _storage.saveSetting(_failedAttemptsKey, 0);
      await _storage.deleteSetting(_lockoutUntilKey);
      return true;
    } else {
      // Increment failed attempts
      final failedAttempts =
          (_storage.getSetting(_failedAttemptsKey) as int? ?? 0) + 1;
      await _storage.saveSetting(_failedAttemptsKey, failedAttempts);

      if (failedAttempts >= _maxFailedAttempts) {
        // Lock out
        final lockoutUntil =
            DateTime.now().add(_lockoutDuration).millisecondsSinceEpoch;
        await _storage.saveSetting(_lockoutUntilKey, lockoutUntil);
        throw PinLockoutException(_lockoutDuration.inMinutes);
      }

      return false;
    }
  }

  /// Get remaining failed attempts before lockout.
  int getRemainingAttempts() {
    final failedAttempts = _storage.getSetting(_failedAttemptsKey) as int? ?? 0;
    final remaining = _maxFailedAttempts - failedAttempts;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if currently locked out and return remaining minutes.
  int? getLockoutRemainingMinutes() {
    final lockoutUntil = _storage.getSetting(_lockoutUntilKey) as int?;
    if (lockoutUntil == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutUntil) return null;

    return ((lockoutUntil - now) / 1000 / 60).ceil();
  }

  // ============================================================================
  // PIN RECOVERY METHODS (Security Question + Backup Codes)
  // ============================================================================

  /// Check if recovery config is set up
  bool hasRecoveryConfigured() {
    final config = _getRecoveryConfig();
    return config != null;
  }

  /// Get the stored recovery config (or null if not set)
  PinRecoveryConfig? _getRecoveryConfig() {
    final raw = _storage.getSetting(_recoveryConfigKey);
    if (raw is! Map) return null;

    try {
      return PinRecoveryConfig(
        securityQuestion: raw['securityQuestion'] as String? ?? '',
        securityAnswerHash: raw['securityAnswerHash'] as String? ?? '',
        backupCodes: List<String>.from(raw['backupCodes'] as List? ?? []),
        backupCodesUsed: List<bool>.from(raw['backupCodesUsed'] as List? ?? []),
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
    await _storage.saveSetting(_recoveryConfigKey, {
      'securityQuestion': config.securityQuestion,
      'securityAnswerHash': config.securityAnswerHash,
      'backupCodes': config.backupCodes,
      'backupCodesUsed': config.backupCodesUsed,
      'createdAt': config.createdAt?.toIso8601String(),
    });
  }

  /// Generate a random backup code (8 alphanumeric characters)
  static String _generateBackupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecond;
    final buffer = StringBuffer();
    var seed = random;
    for (var i = 0; i < 8; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff; // LCG algorithm
      buffer.write(chars[seed % chars.length]);
    }
    return buffer.toString();
  }

  /// Setup PIN recovery on first PIN creation
  /// Returns the generated backup codes (plaintext, for display only)
  Future<List<String>> setupPinRecovery({
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    // Hash the security answer
    final answerHash = _hashPin(securityAnswer.trim().toLowerCase());

    // Generate backup codes
    final plainCodes = List<String>.generate(
      _backupCodesPerConfig,
      (_) => _generateBackupCode(),
    );

    // Hash the backup codes for storage
    final hashedCodes = plainCodes.map((code) => _hashPin(code)).toList();

    // Create config with all codes marked as unused
    final config = PinRecoveryConfig(
      securityQuestion: securityQuestion,
      securityAnswerHash: answerHash,
      backupCodes: hashedCodes,
      backupCodesUsed: List<bool>.filled(_backupCodesPerConfig, false),
      createdAt: DateTime.now(),
    );

    await _saveRecoveryConfig(config);
    return plainCodes; // Return plaintext for user to save/write down
  }

  /// Verify security question answer and optionally get remaining backup codes
  /// Returns (isCorrect, remainingCodesCount)
  Future<(bool, int?)> verifySecurityAnswer(String answer) async {
    final config = _getRecoveryConfig();
    if (config == null) return (false, null);

    // Compare lowercase, trimmed answers
    final isCorrect = BCrypt.checkpw(
      answer.trim().toLowerCase(),
      config.securityAnswerHash,
    );

    if (isCorrect) {
      return (true, config.remainingCodes);
    } else {
      return (false, null);
    }
  }

  /// Verify and use a backup code to reset PIN
  /// Code must not have been used before
  /// Returns true if code was valid and marked as used, false otherwise
  Future<bool> verifyAndUseBackupCode(String code) async {
    final config = _getRecoveryConfig();
    if (config == null) return false;

    // Find matching code (case-insensitive)
    int? matchIndex;
    for (var i = 0; i < config.backupCodes.length; i++) {
      if (config.backupCodesUsed[i]) continue; // Skip used codes
      if (BCrypt.checkpw(code.trim().toUpperCase(), config.backupCodes[i])) {
        matchIndex = i;
        break;
      }
    }

    if (matchIndex == null) return false; // Code not found or already used

    // Mark code as used
    final updatedCodesUsed = [...config.backupCodesUsed];
    updatedCodesUsed[matchIndex] = true;
    final updatedConfig = config.copyWith(backupCodesUsed: updatedCodesUsed);
    await _saveRecoveryConfig(updatedConfig);

    return true;
  }

  /// Regenerate backup codes (e.g., from settings after recovery)
  /// Returns the new plaintext codes for user display
  Future<List<String>> regenerateBackupCodes() async {
    final config = _getRecoveryConfig();
    if (config == null) return [];

    final plainCodes = List<String>.generate(
      _backupCodesPerConfig,
      (_) => _generateBackupCode(),
    );
    final hashedCodes = plainCodes.map((code) => _hashPin(code)).toList();

    final updatedConfig = config.copyWith(
      backupCodes: hashedCodes,
      backupCodesUsed: List<bool>.filled(_backupCodesPerConfig, false),
    );
    await _saveRecoveryConfig(updatedConfig);

    return plainCodes;
  }

  /// Get security question (for display in recovery flow)
  String? getSecurityQuestion() {
    return _getRecoveryConfig()?.securityQuestion;
  }

  /// Clear recovery config (e.g., when user deletes profile)
  Future<void> clearRecoveryConfig() async {
    await _storage.deleteSetting(_recoveryConfigKey);
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

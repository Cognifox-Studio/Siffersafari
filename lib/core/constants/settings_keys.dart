/// Centralized keys for persisted settings stored in Hive.
///
/// Keeping these in one place makes it safer to refactor/rename settings and
/// reduces the risk of typos or diverging key formats across the codebase.
class SettingsKeys {
  SettingsKeys._();

  static const String activeUserId = 'active_user_id';
  static const String parentPinHash = 'parent_pin_hash';
  static const String parentPinFailedAttempts = 'pin_failed_attempts';
  static const String parentPinLockoutUntil = 'pin_lockout_until';
  static const String parentPinRecoveryConfig = 'pin_recovery_config';

  static String onboardingDone(String userId) => 'onboarding_done_$userId';

  static String allowedOperations(String userId) => 'allowed_ops_$userId';

  static String questCurrent(String userId) => 'quest_current_$userId';

  static String questCompleted(String userId) => 'quest_completed_$userId';

  static String wordProblemsEnabled(String userId) =>
      'word_problems_enabled_$userId';

  static String missingNumberEnabled(String userId) =>
      'missing_number_enabled_$userId';

  static String spacedRepetitionSchedules(String userId) =>
      'spaced_repetition_schedules_$userId';

  static String spacedRepetitionEnabled(String userId) =>
      'spaced_repetition_enabled_$userId';

  static String textToSpeechEnabled(String userId) =>
      'text_to_speech_enabled_$userId';

  static String soundVolume(String userId) => 'sound_volume_$userId';

  static String musicVolume(String userId) => 'music_volume_$userId';

  static const String analyticsEvents = 'analytics_events';

  /// Legacy Daily Challenge keys — kept so profile delete still wipes orphans.
  static String legacyDailyChallengeCompletion(String userId, String date) =>
      'daily_challenge_${userId}_$date';

  static String legacyDailyChallengeStreak(String userId) =>
      'daily_challenge_streak_$userId';

  static List<String> userScopedExactKeys(String userId) => [
        onboardingDone(userId),
        allowedOperations(userId),
        questCurrent(userId),
        questCompleted(userId),
        wordProblemsEnabled(userId),
        missingNumberEnabled(userId),
        spacedRepetitionSchedules(userId),
        spacedRepetitionEnabled(userId),
        textToSpeechEnabled(userId),
        soundVolume(userId),
        musicVolume(userId),
        legacyDailyChallengeStreak(userId),
      ];

  static List<String> userScopedKeyPrefixes(String userId) => [
        'daily_challenge_${userId}_',
      ];

  static List<String> userScopedSampleKeys(String userId) => [
        ...userScopedExactKeys(userId),
        legacyDailyChallengeCompletion(userId, '2026-01-02'),
      ];

  static bool isUserScopedKey(String userId, Object rawKey) {
    final key = rawKey.toString();
    if (userScopedExactKeys(userId).contains(key)) return true;
    return userScopedKeyPrefixes(userId)
        .any((prefix) => key.startsWith(prefix));
  }

  static List<String> globalKeys() => const [
        activeUserId,
        parentPinHash,
        parentPinFailedAttempts,
        parentPinLockoutUntil,
        parentPinRecoveryConfig,
        analyticsEvents,
      ];
}

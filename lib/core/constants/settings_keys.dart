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

  /// Failed attempts / lockout for the PIN-recovery security question.
  ///
  /// Tracked separately from the PIN counters: the recovery answer is free text
  /// and would otherwise be an unrate-limited way around the PIN lockout.
  static const String parentSecurityAnswerFailedAttempts =
      'pin_security_answer_failed_attempts';
  static const String parentSecurityAnswerLockoutUntil =
      'pin_security_answer_lockout_until';

  static String onboardingDone(String userId) => 'onboarding_done_$userId';

  /// The variant one child was put in for one experiment (step 23).
  ///
  /// Stored, not recomputed on every launch: a child must not switch variant
  /// mid-week, and an analysis must not see the same child on both sides.
  /// Opt-in för den dagliga påminnelsen (steg 15). Av som default.
  static String reminderOptIn(String userId) => 'reminder_opt_in_$userId';

  /// Dagen då en påminnelse senast skickades, så det blir högst en per dag.
  static String reminderLastSentDay(String userId) =>
      'reminder_last_day_$userId';

  static String experiment(String userId, String experiment) =>
      'experiment_${userId}_$experiment';

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

  /// Per-day activity counters (`YYYY-MM-DD` -> {o: opens, s: sessions}).
  static String dailyActivity(String userId) => 'daily_activity_$userId';

  /// ISO date of the last spent grace day (one forgiven day per week).
  static String streakGraceUsed(String userId) => 'streak_grace_used_$userId';

  /// The streak that was lost, kept until the child plays again.
  static String streakBrokenFrom(String userId) => 'streak_broken_from_$userId';

  /// ISO-8601 timestamp when parent opted in to Firebase cloud backup; absent = off.
  static const String cloudBackupOptInAt = 'cloud_backup_opt_in_at';

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
        dailyActivity(userId),
        streakGraceUsed(userId),
        reminderOptIn(userId),
        reminderLastSentDay(userId),
        streakBrokenFrom(userId),
      ];

  static List<String> userScopedKeyPrefixes(String userId) => [
        'daily_challenge_${userId}_',
        // Experimentvarianten hör till barnet: byter profilen bort ska den
        // bort med den, annars kan nästa profil ärva en variant.
        'experiment_${userId}_',
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
        parentSecurityAnswerFailedAttempts,
        parentSecurityAnswerLockoutUntil,
        cloudBackupOptInAt,
        analyticsEvents,
      ];
}

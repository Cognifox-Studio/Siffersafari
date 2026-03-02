/// Centralized keys for persisted settings stored in Hive.
///
/// Keeping these in one place makes it safer to refactor/rename settings and
/// reduces the risk of typos or diverging key formats across the codebase.
class SettingsKeys {
  SettingsKeys._();

  static const String activeUserId = 'active_user_id';

  static String onboardingDone(String userId) => 'onboarding_done_$userId';

  static String allowedOperations(String userId) => 'allowed_ops_$userId';

  static String questCurrent(String userId) => 'quest_current_$userId';

  static String questCompleted(String userId) => 'quest_completed_$userId';
}

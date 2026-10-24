/// Storage-related constants (Flutter-free).
class StorageConstants {
  StorageConstants._();

  // Hive Box Names
  static const String userProgressBox = 'user_progress';
  static const String quizHistoryBox = 'quiz_history';
  static const String settingsBox = 'settings';

  /// Soft cap for completed quiz_history rows per child (newest kept).
  /// In-progress sessions are never pruned by this limit.
  static const int maxCompletedQuizHistoryPerUser = 40;
}

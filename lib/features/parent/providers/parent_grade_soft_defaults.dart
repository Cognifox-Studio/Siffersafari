import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/missing_number_settings_provider.dart';
import 'package:siffersafari/core/providers/word_problems_settings_provider.dart';

/// Applies quiz feature soft defaults when parent changes Åk (#68).
Future<void> applyParentGradeSoftDefaults(
  WidgetRef ref, {
  required String userId,
  required int? gradeLevel,
}) async {
  final repository = ref.read(localStorageRepositoryProvider);
  final wordProblemsNotifier =
      ref.read(wordProblemsEnabledProvider(userId).notifier);
  final missingNumberNotifier =
      ref.read(missingNumberEnabledProvider(userId).notifier);

  if (gradeLevel == 1 &&
      !QuizFeatureSettings.hasStoredWordProblemsEnabled(
        repository: repository,
        userId: userId,
      )) {
    await wordProblemsNotifier.setEnabled(false);
  }
  if (gradeLevel != null &&
      gradeLevel <= 2 &&
      !QuizFeatureSettings.hasStoredMissingNumberEnabled(
        repository: repository,
        userId: userId,
      )) {
    await missingNumberNotifier.setEnabled(false);
  }
}

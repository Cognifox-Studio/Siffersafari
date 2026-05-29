import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

final onboardingCompletionProvider =
    Provider.autoDispose.family<bool, String>((ref, userId) {
  return ref.watch(localStorageRepositoryProvider).isOnboardingDone(userId) ==
      true;
});

final onboardingControllerProvider =
    Provider.autoDispose.family<OnboardingController, String>((ref, userId) {
  return OnboardingController(ref, userId);
});

class OnboardingController {
  const OnboardingController(this._ref, this._userId);

  final Ref _ref;
  final String _userId;

  int? loadInitialGrade() {
    final repository = _ref.read(localStorageRepositoryProvider);
    final activeUser = _ref.read(userProvider).activeUser;
    final user = activeUser?.userId == _userId
        ? activeUser
        : repository.getUserProgress(_userId);

    return user?.gradeLevel;
  }

  Future<void> complete({required int? gradeLevel}) async {
    final repository = _ref.read(localStorageRepositoryProvider);
    final effectiveGrade = gradeLevel ?? 1;
    final effectiveAgeGroup = DifficultyConfig.effectiveAgeGroup(
      fallback: AgeGroup.young,
      gradeLevel: effectiveGrade,
    );

    final activeUser = _ref.read(userProvider).activeUser;
    if (activeUser != null && activeUser.userId == _userId) {
      await _ref.read(userProvider.notifier).saveUser(
            activeUser.copyWith(
              gradeLevel: effectiveGrade,
              ageGroup: effectiveAgeGroup,
            ),
          );
    } else {
      final user = repository.getUserProgress(_userId);
      if (user != null) {
        await repository.saveUserProgress(
          user.copyWith(
            gradeLevel: effectiveGrade,
            ageGroup: effectiveAgeGroup,
          ),
        );
        await _ref.read(userProvider.notifier).loadUsers();
      }
    }

    await _ref
        .read(parentSettingsProvider(_userId).notifier)
        .setAllowedOperations(_defaultAllowedOperationsFor(effectiveGrade));

    final hasStoredReadingSetting =
        QuizFeatureSettings.hasStoredWordProblemsEnabled(
      repository: repository,
      userId: _userId,
    );
    if (!hasStoredReadingSetting) {
      await QuizFeatureSettings.saveWordProblemsEnabled(
        repository: repository,
        userId: _userId,
        enabled: QuizFeatureSettings.defaultWordProblemsEnabled(
          repository: repository,
          userId: _userId,
        ),
      );
    }

    await repository.setOnboardingDone(_userId, true);
    _ref.invalidate(onboardingCompletionProvider(_userId));
  }

  Set<OperationType> _defaultAllowedOperationsFor(int? gradeLevel) {
    if (gradeLevel == null) {
      return const {
        OperationType.addition,
        OperationType.subtraction,
      };
    }

    return DifficultyConfig.visibleOperationsForGrade(gradeLevel);
  }
}

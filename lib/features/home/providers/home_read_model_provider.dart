import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/home/presentation/home_read_model.dart';
import 'package:siffersafari/features/home/providers/home_session_status_provider.dart';

final homeReadModelProvider = Provider.autoDispose<HomeReadModel>((ref) {
  final homeUserState = ref.watch(
    userProvider.select(
      (state) => (
        activeUser: state.activeUser,
        questStatus: state.questStatus,
      ),
    ),
  );
  final user = homeUserState.activeUser;
  final quizSummary = ref.watch(
    quizProvider.select(
      (state) => (
        userId: state.userId,
        hasSession: state.session != null,
      ),
    ),
  );
  final storyProgress = ref.watch(storyProgressProvider);
  final parentAllowedOps = user == null
      ? _defaultAllowedOperations
      : ref.watch(parentSettingsProvider(user.userId));
  final hasPersistedInProgressSession = user == null
      ? false
      : ref.watch(homePersistedQuizSessionProvider(user.userId));

  return HomeReadModel.fromValues(
    activeUser: user,
    questStatus: homeUserState.questStatus,
    quizUserId: quizSummary.userId,
    hasActiveQuizSession: quizSummary.hasSession,
    storyProgress: storyProgress,
    parentAllowedOps: parentAllowedOps,
    hasPersistedInProgressSession: hasPersistedInProgressSession,
  );
});

const _defaultAllowedOperations = {
  OperationType.addition,
  OperationType.subtraction,
  OperationType.multiplication,
  OperationType.division,
};

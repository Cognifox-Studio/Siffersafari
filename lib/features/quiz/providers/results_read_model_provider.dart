import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/features/quiz/presentation/results_read_model.dart';

final resultsReadModelProvider = Provider.autoDispose<ResultsReadModel>((ref) {
  final quizState = ref.watch(quizProvider);
  final userState = ref.watch(userProvider);
  final storyProgress = ref.watch(storyProgressProvider);

  return ResultsReadModel.fromState(
    quizState: quizState,
    userState: userState,
    storyProgress: storyProgress,
  );
});

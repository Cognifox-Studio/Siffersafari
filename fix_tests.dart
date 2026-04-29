import 'dart:io';

void main() {
  final f1 = File('test/unit/logic/quiz_progression_edge_cases_test.dart');
  var p1 = f1.readAsStringSync();
  p1 = p1.replaceAll(
    'import ''package:siffersafari/domain/services/feedback_service.dart'';',
    'import ''package:siffersafari/domain/services/feedback_service.dart'';\nimport ''package:siffersafari/domain/services/spaced_repetition_service.dart'';'
  );
  p1 = p1.replaceAll(
    'final notifier = QuizNotifier(\n        FakeQuestionGeneratorService(),\n        FeedbackService(),\n        audio,\n        repo,\n      );',
    'final notifier = QuizNotifier(\n        FakeQuestionGeneratorService(),\n        FeedbackService(),\n        audio,\n        repo,\n        adaptiveDifficultyService: AdaptiveDifficultyService(),\n        spacedRepetitionService: SpacedRepetitionService(),\n      );'
  );
  p1 = p1.replaceAll(
    'final notifier = QuizNotifier(\n        generator,\n        FeedbackService(),\n        audio,\n        repo,\n        adaptiveDifficultyService: MockAdaptiveDifficultyService(),\n      );',
    'final notifier = QuizNotifier(\n        generator,\n        FeedbackService(),\n        audio,\n        repo,\n        adaptiveDifficultyService: MockAdaptiveDifficultyService(),\n        spacedRepetitionService: SpacedRepetitionService(),\n      );'
  );
  p1 = p1.replaceAll(
    'final notifier = QuizNotifier(\n        generator,\n        FeedbackService(),\n        audio,\n        repo,\n        adaptiveDifficultyService: AdaptiveDifficultyService(),\n      );',
    'final notifier = QuizNotifier(\n        generator,\n        FeedbackService(),\n        audio,\n        repo,\n        adaptiveDifficultyService: AdaptiveDifficultyService(),\n        spacedRepetitionService: SpacedRepetitionService(),\n      );'
  );
  f1.writeAsStringSync(p1);

  final f2 = File('test/unit/logic/quiz_provider_srs_test.dart');
  var p2 = f2.readAsStringSync();
  p2 = p2.replaceAll(
    'final notifier = QuizNotifier(\n    generator,\n    feedback,\n    audio,\n    repo,\n  );',
    'final notifier = QuizNotifier(\n    generator,\n    feedback,\n    audio,\n    repo,\n    adaptiveDifficultyService: AdaptiveDifficultyService(),\n    spacedRepetitionService: SpacedRepetitionService(),\n  );'
  );
  p2 = p2.replaceAll(
    'import ''package:siffersafari/domain/services/audio_service.dart'';',
    'import ''package:siffersafari/domain/services/audio_service.dart'';\nimport ''package:siffersafari/domain/services/spaced_repetition_service.dart'';\nimport ''package:siffersafari/domain/services/adaptive_difficulty_service.dart'';'
  );
  f2.writeAsStringSync(p2);
}

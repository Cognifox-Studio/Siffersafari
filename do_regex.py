import re

with open('test/unit/logic/quiz_progression_edge_cases_test.dart', 'r', encoding='utf-8') as f:
    c = f.read()
c = re.sub(r'(?s)final notifier = QuizNotifier\(\s*FakeQuestionGeneratorService\(\),\s*FeedbackService\(\),\s*audio,\s*repo,\s*adaptiveDifficultyService:\s*AdaptiveDifficultyService\(\),\s*\);',
           'final notifier = QuizNotifier(\n        FakeQuestionGeneratorService(),\n        FeedbackService(),\n        audio,\n        repo,\n        adaptiveDifficultyService: AdaptiveDifficultyService(),\n        spacedRepetitionService: SpacedRepetitionService(),\n      );', c)

with open('test/unit/logic/quiz_progression_edge_cases_test.dart', 'w', encoding='utf-8') as f:
    f.write(c)

with open('test/unit/logic/quiz_provider_srs_test.dart', 'r', encoding='utf-8') as f:
    c2 = f.read()

c2 = re.sub(r'import \'package:siffersafari/domain/services/audio_service.dart\';',
            'import \'package:siffersafari/domain/services/audio_service.dart\';\nimport \'package:siffersafari/domain/services/spaced_repetition_service.dart\';\nimport \'package:siffersafari/domain/services/adaptive_difficulty_service.dart\';', c2)
c2 = re.sub(r'(?s)final notifier = QuizNotifier\(\s*generator,\s*feedback,\s*audio,\s*repo,\s*\);',
            'final notifier = QuizNotifier(\n    generator,\n    feedback,\n    audio,\n    repo,\n    adaptiveDifficultyService: AdaptiveDifficultyService(),\n    spacedRepetitionService: SpacedRepetitionService(),\n  );', c2)

with open('test/unit/logic/quiz_provider_srs_test.dart', 'w', encoding='utf-8') as f:
    f.write(c2)

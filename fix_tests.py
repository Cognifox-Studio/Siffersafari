import os, re

def fix(path):
    print("Fixing", path)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Imports
    riverpod = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
    deps = (
        "import 'package:siffersafari/core/providers/audio_service_provider.dart';\n"
        "import 'package:siffersafari/core/providers/feedback_service_provider.dart';\n"
        "import 'package:siffersafari/core/providers/question_generator_service_provider.dart';\n"
        "import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';\n"
        "import 'package:siffersafari/core/providers/adaptive_difficulty_service_provider.dart';\n"
        "import 'package:siffersafari/core/providers/achievement_service_provider.dart';\n"
        "import 'package:siffersafari/core/providers/quest_progression_service_provider.dart';\n"
        "import 'package:siffersafari/core/providers/spaced_repetition_service_provider.dart';\n"
    )
    if riverpod not in content:
        content = content.replace("import 'package:flutter_test/flutter_test.dart';", riverpod + deps + "import 'package:flutter_test/flutter_test.dart';")
        
    def repl1(m):
        return '''final container = ProviderContainer(
        overrides: [
          questionGeneratorServiceProvider.overrideWithValue(_FakeQuestionGeneratorService()),
          feedbackServiceProvider.overrideWithValue(FeedbackService()),
          audioServiceProvider.overrideWithValue(audio),
          localStorageRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(quizProvider.notifier);'''
      
    content = re.sub(
        r'final notifier = QuizNotifier\(\s*_FakeQuestionGeneratorService\(\),\s*FeedbackService\(\),\s*audio,\s*repo,\s*\);',
        repl1, content)
        
    def repl2(m):
        return '''final container = ProviderContainer(
        overrides: [
          questionGeneratorServiceProvider.overrideWithValue(_FakeQuestionGeneratorService()),
          feedbackServiceProvider.overrideWithValue(FeedbackService()),
          audioServiceProvider.overrideWithValue(audio),
          localStorageRepositoryProvider.overrideWithValue(repo),
          adaptiveDifficultyServiceProvider.overrideWithValue(AdaptiveDifficultyService()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(quizProvider.notifier);'''

    content = re.sub(
        r'final notifier = QuizNotifier\(\s*_FakeQuestionGeneratorService\(\),\s*FeedbackService\(\),\s*audio,\s*repo,\s*adaptiveDifficultyService:\s*AdaptiveDifficultyService\(\),\s*\);',
        repl2, content)

    # For QuizProvider Analytics test
    def repl3(m):
        return '''container = ProviderContainer(
        overrides: [
          questionGeneratorServiceProvider.overrideWithValue(MockQuestionGeneratorService()),
          feedbackServiceProvider.overrideWithValue(MockFeedbackService()),
          audioServiceProvider.overrideWithValue(MockAudioService()),
          localStorageRepositoryProvider.overrideWithValue(repo),
          spacedRepetitionServiceProvider.overrideWithValue(MockSpacedRepetitionService()),
        ],
      );
      notifier = container.read(quizProvider.notifier);'''

    content = re.sub(
        r'notifier = QuizNotifier\(\s*MockQuestionGeneratorService\(\),\s*MockFeedbackService\(\),\s*MockAudioService\(\),\s*repo,\s*spacedRepetitionService:\s*MockSpacedRepetitionService\(\),\s*\);',
        repl3, content)
        
    # Same as above but the SRS is missing from the params sometimes:
    def repl4(m):
        return '''container = ProviderContainer(
        overrides: [
          questionGeneratorServiceProvider.overrideWithValue(MockQuestionGeneratorService()),
          feedbackServiceProvider.overrideWithValue(MockFeedbackService()),
          audioServiceProvider.overrideWithValue(MockAudioService()),
          localStorageRepositoryProvider.overrideWithValue(repo),
        ],
      );
      notifier = container.read(quizProvider.notifier);'''

    content = re.sub(
        r'notifier = QuizNotifier\(\s*MockQuestionGeneratorService\(\),\s*MockFeedbackService\(\),\s*MockAudioService\(\),\s*repo,\s*\);',
        repl4, content)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

fix('test/unit/logic/quiz_progression_edge_cases_test.dart')
fix('test/unit/logic/quiz_provider_analytics_test.dart')
fix('test/unit/logic/quiz_provider_srs_test.dart')


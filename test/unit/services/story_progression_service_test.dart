import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/core/services/story_progression_service.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] StoryProgressionService', () {
    const questService = QuestProgressionService();
    const storyService = StoryProgressionService();

    const easyQuest = QuestDefinition(
      id: 'quest_bridge',
      title: 'Laga bron',
      description: 'Räkna rätt och gå vidare.',
      difficulty: DifficultyLevel.easy,
      operation: OperationType.addition,
    );

    const secondQuest = QuestDefinition(
      id: 'quest_finish',
      title: 'Sista bron',
      description: 'Nu är du framme.',
      difficulty: DifficultyLevel.medium,
      operation: OperationType.multiplication,
    );

    test('bygger jungle-progress från första questen', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );

      final questStatus = questService.getCurrentStatus(
        user: user,
        currentQuestId: null,
        completedQuestIds: <String>{},
      );

      final story = storyService.createStoryProgress(
        path: questService.questsForUser(user),
        currentStatus: questStatus,
        completedQuestIds: const <String>{},
      );

      expect(story.worldTitle, 'Maskoten i djungeln');
      expect(story.totalNodes, 30);
      expect(story.currentNodeIndex, 0);
      expect(story.completedNodes, 0);
      expect(story.nodes.first.state.name, 'current');
      expect(story.nodes.first.landmark, 'Startlägret');
      expect(
        story.nodes.first.landmarkHint,
        'Maskoten packar verktygen inför uppdraget.',
      );
      expect(story.nodes.first.sceneTag, 'baslager');
      expect(story.chapterTitle, 'Kapitel 1: Den trasiga bron');
    });

    test('markerar tidigare noder som completed', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );

      final questStatus = questService.getCurrentStatus(
        user: user,
        currentQuestId: 'q_times_easy',
        completedQuestIds: <String>{'q_plus_easy', 'q_minus_easy'},
      );

      final story = storyService.createStoryProgress(
        path: questService.questsForUser(user),
        currentStatus: questStatus,
        completedQuestIds: const <String>{'q_plus_easy', 'q_minus_easy'},
      );

      expect(story.completedNodes, 2);
      expect(story.currentNode?.id, 'q_times_easy');
      expect(story.nodes[0].state.name, 'completed');
      expect(story.nodes[1].state.name, 'completed');
      expect(story.nodes[2].state.name, 'current');
    });

    test('ger nästa biome för pågående easy-kapitel', () {
      final progress = storyService.createStoryProgress(
        path: const [easyQuest, easyQuest],
        currentStatus: const QuestStatus(
          quest: easyQuest,
          masteryRate: 0.25,
          progress: 0.25,
          isCompleted: false,
        ),
        completedQuestIds: const <String>{},
      );

      expect(progress.nextBiome?.name, 'Nattskogen');
      expect(progress.nextBiome?.previewPrefix, 'Efter djungeln');
    });

    test('ger ingen nästa biome när sista noden redan är aktiv', () {
      final progress = storyService.createStoryProgress(
        path: const [easyQuest, secondQuest],
        currentStatus: const QuestStatus(
          quest: secondQuest,
          masteryRate: 1.0,
          progress: 1.0,
          isCompleted: false,
        ),
        completedQuestIds: const {'quest_bridge'},
      );

      expect(progress.nextBiome, isNull);
    });
  });
}

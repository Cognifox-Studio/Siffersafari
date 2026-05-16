import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestProgressionService', () {
    const service = QuestProgressionService();

    test('startar på första quest utan state', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );

      final status = service.getCurrentStatus(
        user: user,
        currentQuestId: null,
        completedQuestIds: <String>{},
      );

      expect(status.quest.id, 'q_plus_easy');
      expect(status.progress, 0.0);
      expect(status.isCompleted, isFalse);
    });

    test('middle-path innehåller 30 quests för hela kartan', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );

      final path = service.questsForUser(user);

      expect(path, hasLength(30));
      expect(path.first.id, 'q_plus_easy');
      expect(path.last.id, 'q_div_medium_4__del_2');
    });

    test('Åk 1–2 får exakt 10 stopp även med bara plus och minus', () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
        gradeLevel: 1,
      );

      final firstId = service.firstQuestId(user);
      expect(firstId, 'q_plus_easy');

      final path = service.questsForUser(
        user,
        allowedOperations: {
          OperationType.addition,
          OperationType.subtraction,
        },
      );

      expect(path, hasLength(10));
      expect(path.every((quest) => quest.difficulty.name == 'easy'), isTrue);
      expect(path.last.id, 'q_minus_easy_3__del_2');

      final nextAfterLastEasy = service.nextQuestId(
        user: user,
        currentQuestId: path.last.id,
        allowedOperations: {
          OperationType.addition,
          OperationType.subtraction,
        },
      );
      expect(nextAfterLastEasy, isNull);
    });

    test(
      'Unit (QuestProgressionService): kan filtrera quests till endast division (föräldern har sista ordet)',
      () {
        const user = UserProgress(
          userId: 'u1',
          name: 'Test',
          ageGroup: AgeGroup.middle,
          gradeLevel: 1,
        );

        final status = service.getCurrentStatus(
          user: user,
          currentQuestId: null,
          completedQuestIds: <String>{},
          allowedOperations: {OperationType.division},
        );

        final path = service.questsForUser(
          user,
          allowedOperations: {OperationType.division},
        );

        expect(status.quest.operation, OperationType.division);
        expect(status.quest.id, 'q_div_easy');
        expect(path, hasLength(10));
        expect(path.last.id, 'q_div_easy_3__del_4');
      },
    );

    test(
      'Unit (QuestProgressionService): väljer första quest om currentQuestId ligger utanför path',
      () {
        const user = UserProgress(
          userId: 'u1',
          name: 'Test',
          ageGroup: AgeGroup.middle,
          gradeLevel: 1,
        );

        final status = service.getCurrentStatus(
          user: user,
          currentQuestId: 'q_plus_medium',
          completedQuestIds: <String>{},
        );

        expect(status.quest.id, 'q_plus_easy');
      },
    );

    test(
        'Unit (QuestProgressionService): markerar quest klar när mastery passerar tröskel',
        () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
        masteryLevels: {
          'addition_easy': 0.81,
        },
      );

      final status = service.getCurrentStatus(
        user: user,
        currentQuestId: 'q_plus_easy',
        completedQuestIds: <String>{},
      );

      expect(status.quest.id, 'q_plus_easy');
      expect(status.isCompleted, isTrue);
      expect(status.progress, 1.0);
    });

    test(
        'Unit (QuestProgressionService): hoppar över avklarade quests och väljer nästa',
        () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );

      final status = service.getCurrentStatus(
        user: user,
        currentQuestId: 'q_plus_easy',
        completedQuestIds: <String>{'q_plus_easy'},
      );

      expect(status.quest.id, 'q_minus_easy');
    });

    test(
        'Unit (QuestProgressionService): nextQuestId returnerar null på sista quest i path',
        () {
      const user = UserProgress(
        userId: 'u1',
        name: 'Test',
        ageGroup: AgeGroup.middle,
        gradeLevel: 1,
      );

      final path = service.questsForUser(user);

      final next = service.nextQuestId(
        user: user,
        currentQuestId: path.last.id,
      );

      expect(next, isNull);
    });
  });
}

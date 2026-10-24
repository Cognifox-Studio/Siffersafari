import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';

void main() {
  group('[Unit] Quest path length vs Åk (#66)', () {
    const service = QuestProgressionService();

    test('Åk 1–2 use 10 stops; Åk 3–4 use 30; Åk 5+ use 34', () {
      expect(
        service.targetStopCountForGrade(
          gradeLevel: 1,
          ageGroup: AgeGroup.young,
        ),
        10,
      );
      expect(
        service.targetStopCountForGrade(
          gradeLevel: 2,
          ageGroup: AgeGroup.young,
        ),
        10,
      );
      expect(
        service.targetStopCountForGrade(
          gradeLevel: 3,
          ageGroup: AgeGroup.middle,
        ),
        30,
      );
      expect(
        service.targetStopCountForGrade(
          gradeLevel: 5,
          ageGroup: AgeGroup.older,
        ),
        34,
      );
    });
  });
}

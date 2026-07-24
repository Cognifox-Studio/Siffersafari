import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';

void main() {
  group('[Unit] AdaptiveDifficultyService', () {
    late AdaptiveDifficultyService service;

    setUp(() {
      service = AdaptiveDifficultyService();
    });

    test('beräknar träffsäkerhet korrekt', () {
      final results = [true, true, false, true, false];
      final successRate = service.calculateSuccessRate(results);

      expect(successRate, 0.6); // 3/5
    });

    test('steg – höjer vid hög träffsäkerhet', () {
      final results = [true, true, true, true, true];
      final step = service.suggestDifficultyStep(
        currentStep: 5,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 6);
    });

    test('steg – sänker vid låg träffsäkerhet', () {
      final results = [false, false, true, false, false];
      final step = service.suggestDifficultyStep(
        currentStep: 5,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 4);
    });

    test('steg – klampar vid max', () {
      final results = [true, true, true, true, true];
      final step = service.suggestDifficultyStep(
        currentStep: 10,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 10);
    });

    test('steg – klampar vid min', () {
      final results = [false, false, false, false, false];
      final step = service.suggestDifficultyStep(
        currentStep: 1,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 1);
    });

    test('steg – höjer inte när micro och macro är i konflikt', () {
      final results = [false, false, false, false, true, true, true];
      final step = service.suggestDifficultyStep(
        currentStep: 5,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 5);
    });

    test('steg – ändrar inte på micro-signal utan macro-bekräftelse', () {
      final results = [true, true, true];
      final step = service.suggestDifficultyStep(
        currentStep: 5,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 5);
    });

    test('steg – tillåter macro-only när ingen micro-signal finns', () {
      final results = [true, false, true, false, true];
      final step = service.suggestDifficultyStep(
        currentStep: 5,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
      );

      expect(step, 4);
    });

    test('steg – cooldown blockerar nivåändring', () {
      final results = [true, true, true, true, true];
      final step = service.suggestDifficultyStep(
        currentStep: 5,
        recentResults: results,
        minStep: 1,
        maxStep: 10,
        questionsSinceLastStepChange: 1,
      );

      expect(step, 5);
    });
  });
}

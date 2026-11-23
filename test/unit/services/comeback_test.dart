import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/comeback.dart';

void main() {
  group('[Unit] Comeback efter uppehåll', () {
    test('tre dagar borta räknas som uppehåll', () {
      expect(
        isComebackGap(
          lastSessionDate: DateTime(2026, 11, 16, 19),
          now: DateTime(2026, 11, 19, 7),
        ),
        isTrue,
      );
    });

    test('andra dagen i rad är inget uppehåll', () {
      expect(
        isComebackGap(
          lastSessionDate: DateTime(2026, 11, 18, 19),
          now: DateTime(2026, 11, 19, 7),
        ),
        isFalse,
      );
    });

    test('samma dag räknas aldrig som uppehåll', () {
      expect(
        isComebackGap(
          lastSessionDate: DateTime(2026, 11, 19, 7),
          now: DateTime(2026, 11, 19, 20),
        ),
        isFalse,
      );
    });

    test('första gången någonsin är inget uppehåll', () {
      expect(
        isComebackGap(lastSessionDate: null, now: DateTime(2026, 11, 19)),
        isFalse,
      );
    });

    test('en trasig framtid nollställer inget', () {
      expect(
        isComebackGap(
          lastSessionDate: DateTime(2026, 11, 25),
          now: DateTime(2026, 11, 19),
        ),
        isFalse,
      );
    });

    test('steget sänks med ett, aldrig under botten', () {
      expect(softenedStepForComeback(5), 4);
      expect(softenedStepForComeback(2), 1);
      expect(softenedStepForComeback(1), 1);
      expect(softenedStepForComeback(1, minStep: 3), 3);
    });

    test('bara räknesättet hon möter blir lättare', () {
      final steps = softenedStepsForComeback(
        const {
          OperationType.addition: 5,
          OperationType.multiplication: 6,
        },
        operation: OperationType.addition,
      );

      expect(steps[OperationType.addition], 4);
      expect(steps[OperationType.multiplication], 6);
    });
  });
}

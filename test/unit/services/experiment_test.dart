import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/experiment.dart';

void main() {
  group('[Unit] Experimenthake', () {
    test('samma barn får samma variant varje gång', () {
      final first = experimentVariant(
        userId: 'signe',
        experiment: Experiments.weeklyQuest,
        variants: Experiments.all[Experiments.weeklyQuest]!,
      );
      final again = experimentVariant(
        userId: 'signe',
        experiment: Experiments.weeklyQuest,
        variants: Experiments.all[Experiments.weeklyQuest]!,
      );

      expect(first, again);
    });

    test('två experiment är inte samma lottning', () {
      // Om experimentnamnet inte blandas in hamnar varje barn i samma variant
      // av allt, och då kan två resultat aldrig läsas isär.
      var differ = 0;
      for (var i = 0; i < 100; i++) {
        final weekly = experimentVariant(
          userId: 'barn$i',
          experiment: Experiments.weeklyQuest,
          variants: const ['on', 'off'],
        );
        final streak = experimentVariant(
          userId: 'barn$i',
          experiment: Experiments.streakBadge,
          variants: const ['on', 'off'],
        );
        if (weekly != streak) differ++;
      }

      expect(differ, greaterThanOrEqualTo(25));
    });

    test('fördelningen är inte sned över hundra barn', () {
      var on = 0;
      for (var i = 0; i < 100; i++) {
        if (variantIsOn(
          userId: 'barn$i',
          experiment: Experiments.weeklyQuest,
        )) {
          on++;
        }
      }

      expect(on, greaterThan(25));
      expect(on, lessThan(75));
    });

    test('tom variantslista kraschar inte', () {
      expect(
        experimentVariant(
          userId: 'x',
          experiment: 'okänd',
          variants: const [],
        ),
        'a',
      );
    });

    test('okänt experiment faller tillbaka på av/på', () {
      expect(
        experimentVariant(
          userId: 'x',
          experiment: 'finns_inte',
          variants: Experiments.all['finns_inte'] ?? const ['off', 'on'],
        ),
        anyOf('off', 'on'),
      );
    });
  });
}

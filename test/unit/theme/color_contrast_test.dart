import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/theme/color_contrast.dart';

/// Åk 1–2 / contrast: the quiz answer buttons are the only thing a child has
/// to read, so the number on them has to be legible on the fill it lands on.
///
/// Before `legibleInkOn` the ink came from `colorScheme.onPrimary`, which is
/// white in every theme, while the fills are mid-tone theme colours. Measured
/// on the shipped palette: white is 3.11:1 on space orange, 2.86:1 on jungle
/// green, and 1.78-2.15:1 on the accent fill used for the selected answer.
/// WCAG AA asks for 4.5:1 (3:1 for large text), so the digit a child had just
/// tapped was the least readable thing on the screen.
void main() {
  group('[Unit] color contrast', () {
    test('contrastRatio matches the WCAG reference values', () {
      expect(contrastRatio(Colors.white, Colors.black), closeTo(21.0, 0.01));
      expect(contrastRatio(Colors.white, Colors.white), closeTo(1.0, 0.01));
      // Order must not matter.
      expect(
        contrastRatio(Colors.black, Colors.white),
        closeTo(contrastRatio(Colors.white, Colors.black), 0.001),
      );
    });

    test('readableInkOn picks the dark ink on light fills and white on dark', () {
      expect(readableInkOn(const Color(0xFFF7B733)), AppColors.textPrimary);
      expect(readableInkOn(AppColors.spacePrimary), AppColors.textPrimary);
      expect(readableInkOn(const Color(0xFF122B4A)), Colors.white);
    });

    test('legibleInkOn keeps a preferred ink that is already readable', () {
      const fill = Color(0xFF122B4A);
      expect(legibleInkOn(fill, Colors.white), Colors.white);
    });

    test('legibleInkOn replaces a preferred ink that is not', () {
      // White on the selected-answer accent is ~2:1 in every theme.
      expect(legibleInkOn(AppColors.spaceSecondary, Colors.white),
          AppColors.textPrimary);
    });

    test('every theme fill reaches AA with the ink the widget will choose', () {
      final fills = <String, Color>{
        'space idle': AppColors.spacePrimary,
        'space selected': AppColors.spaceSecondary,
        'jungle idle': AppColors.junglePrimary,
        'jungle selected': AppColors.jungleSecondary,
        'desert idle': AppColors.desertPrimary,
        'desert selected': AppColors.desertSecondary,
        'correct': AppColors.correctAnswer,
        'wrong': AppColors.wrongAnswer,
      };

      final failures = <String>[];
      fills.forEach((name, fill) {
        final ratio = contrastRatio(fill, readableInkOn(fill));
        if (ratio < AppConstants.minTextContrastRatio) {
          failures.add('$name: ${ratio.toStringAsFixed(2)}:1');
        }
      });

      expect(
        failures,
        isEmpty,
        reason: 'Dessa fyllningar klarar inte '
            '${AppConstants.minTextContrastRatio}:1 mot sin läsbaraste '
            'textfärg: ${failures.join(', ')}',
      );
    });
  });
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/core/theme/color_contrast.dart';

/// The themed background is a photograph-like image with a coloured scrim on
/// top, and light UI text is drawn on the result. Whether that text is legible
/// is decided by the artwork's brightness, which used to be a single global
/// scrim of 0.72 for every theme -- too heavy for the dark space art (which it
/// buried) and too light at the bottom edge for the bright jungle and desert
/// art. The scrim is now derived per theme from the art itself.
///
/// Deriving it from a number in the source is only trustworthy if that number
/// is still true, so this test decodes the shipped WebP and checks:
///   1. the declared p99 luminance still matches the actual artwork,
///   2. the declared scrim keeps light text at the WCAG large-text ratio, and
///   3. the scrim is not heavier than the artwork needs (otherwise the art is
///      paid for and never seen).
///
/// Swap the art and this fails with the numbers needed to fix it.
void main() {
  /// Relative luminance of the brightest 1% of the artwork, which is what the
  /// scrim has to bring down. Sampling keeps this fast enough for CI.
  double measureArtP99(String assetPath) {
    final bytes = File(assetPath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    expect(
      decoded,
      isNotNull,
      reason: 'Kunde inte avkoda $assetPath - kontrollera att filen finns och '
          'att formatet fortfarande är WebP',
    );

    final image = decoded!;
    final stride = 3;
    final values = <double>[];
    for (var y = 0; y < image.height; y += stride) {
      for (var x = 0; x < image.width; x += stride) {
        final p = image.getPixel(x, y);
        values.add(
          Color.fromARGB(
            255,
            p.r.toInt(),
            p.g.toInt(),
            p.b.toInt(),
          ).computeLuminance(),
        );
      }
    }
    values.sort();
    return values[((values.length - 1) * 0.99).floor()];
  }

  double contrastOfWhiteOn(double backdropLuminance) =>
      1.05 / (backdropLuminance + 0.05);

  group('[Unit] Bakgrundsscrim mot temaillustrationer', () {
    for (final theme in AppThemeConfig.implementedThemes) {
      test('${theme.name}: scrimmen matchar konsten och håller kontrasten',
          () {
        final cfg = AppThemeConfig.forTheme(theme);
        final measured = measureArtP99(cfg.backgroundAsset);

        // 1. The declared measurement still describes the shipped artwork.
        expect(
          measured,
          closeTo(cfg.backgroundArtP99Luminance, 0.03),
          reason: 'Konsten i ${cfg.backgroundAsset} har luminans p99 '
              '${measured.toStringAsFixed(3)} men konfigurationen säger '
              '${cfg.backgroundArtP99Luminance}. Mät om och uppdatera '
              'backgroundArtP99Luminance + backgroundScrim.',
        );

        final base = cfg.baseBackgroundColor.computeLuminance();
        final composite =
            cfg.backgroundScrim * base + (1 - cfg.backgroundScrim) * measured;

        // 2. Light text on the composite stays legible...
        expect(
          contrastOfWhiteOn(composite),
          greaterThanOrEqualTo(AppConstants.minBackdropContrastRatio),
          reason: '${theme.name}: vit text på bakgrunden får '
              '${contrastOfWhiteOn(composite).toStringAsFixed(2)}:1, under '
              '${AppConstants.minBackdropContrastRatio}:1',
        );

        // 3. ...without darkening the artwork more than it needs.
        final needed = scrimAlphaFor(
          art: measured,
          base: base,
          limit: maxBackdropLuminance(),
        );
        expect(
          cfg.backgroundScrim,
          lessThanOrEqualTo(needed + 0.10),
          reason: '${theme.name}: scrimmen är ${cfg.backgroundScrim} men '
              '${needed.toStringAsFixed(2)} räcker - resten döljer bara konsten',
        );
      });
    }
  });
}

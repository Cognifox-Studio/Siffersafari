import 'package:flutter/material.dart';
import 'package:siffersafari/core/constants/app_constants.dart';

/// WCAG 2.1 contrast helpers.
///
/// The quiz draws large numbers on saturated theme fills. Picking the ink from
/// a theme *role* (`colorScheme.onPrimary` is always white here) says nothing
/// about the fill it ends up on: white is 2.86:1 on the jungle green and
/// 1.78:1 on the space accent, i.e. the answer a child just tapped was the
/// least readable thing on screen. These helpers let the widget ask the
/// question that actually matters — how much does this ink contrast with this
/// fill — instead of trusting a role name.

/// Relative contrast ratio between two colours, from 1.0 to 21.0.
///
/// WCAG asks for 3:1 on large text and graphical objects, 4.5:1 on body text.
double contrastRatio(Color a, Color b) {
  final lumA = a.computeLuminance();
  final lumB = b.computeLuminance();
  final lighter = lumA > lumB ? lumA : lumB;
  final darker = lumA > lumB ? lumB : lumA;
  return (lighter + 0.05) / (darker + 0.05);
}

/// The more legible of the app's two inks on [background]: its dark text
/// colour or white.
Color readableInkOn(
  Color background, {
  Color light = Colors.white,
  Color dark = AppColors.textPrimary,
}) {
  return contrastRatio(background, light) >= contrastRatio(background, dark)
      ? light
      : dark;
}

/// Keeps [preferred] when it is legible on [background], otherwise switches to
/// [readableInkOn]. Lets a caller express intent without being able to make
/// text unreadable.
Color legibleInkOn(
  Color background,
  Color preferred, {
  double minimum = AppConstants.minTextContrastRatio,
}) {
  return contrastRatio(background, preferred) >= minimum
      ? preferred
      : readableInkOn(background);
}

/// Highest backdrop luminance that can still carry light text at [ratio].
///
/// A backdrop at luminance L leaves light text (#FFFFFF) at
/// `1.05 / (L + 0.05)`, so inverting that gives the ceiling.
double maxBackdropLuminance([double ratio = AppConstants.minBackdropContrastRatio]) =>
    1.05 / ratio - 0.05;

/// Smallest scrim alpha that keeps [art] -- composited over [base] -- at or
/// below [limit] luminance.
///
/// The scrim replaces part of the artwork with the theme's dark base colour, so
/// the composite is `alpha * base + (1 - alpha) * art`. Solving that for the
/// limit gives the alpha below. A theme with dark art needs very little scrim;
/// a theme with bright art needs a lot, and that is a property of the art, not
/// a global design constant.
double scrimAlphaFor({
  required double art,
  required double base,
  required double limit,
}) {
  if (art <= limit) return 0.0;
  if (art <= base) return 1.0;
  return ((art - limit) / (art - base)).clamp(0.0, 1.0);
}

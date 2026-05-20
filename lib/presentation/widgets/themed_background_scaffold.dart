import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/theme/app_theme_colors.dart';

class ThemedBackgroundScaffold extends ConsumerWidget {
  const ThemedBackgroundScaffold({
    required this.body,
    this.appBar,
    this.padding,
    this.overlayOpacity = AppConstants.backgroundOverlayOpacity,
    this.extendBodyBehindAppBar = false,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final EdgeInsetsGeometry? padding;
  final double overlayOpacity;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(appThemeConfigProvider);
    final theme = Theme.of(context);
    final themeColors = context.appThemeColors;
    final onPrimary = theme.colorScheme.onPrimary;

    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (size.width * dpr).round();
    final cacheHeight = (size.height * dpr).round();

    final effectiveExtendBodyBehindAppBar =
        extendBodyBehindAppBar || appBar != null;
    final appBarHeight = appBar?.preferredSize.height ?? 0.0;
    final overlayTopOpacity =
        (overlayOpacity + 0.12).clamp(0.0, 1.0).toDouble();
    final overlayBottomOpacity =
        (overlayOpacity - 0.08).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: themeColors.baseBackgroundColor,
      appBar: appBar,
      extendBodyBehindAppBar: effectiveExtendBodyBehindAppBar,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                cfg.backgroundAsset,
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(color: themeColors.baseBackgroundColor);
                },
              ),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeColors.baseBackgroundColor
                          .withValues(alpha: overlayTopOpacity),
                      themeColors.baseBackgroundColor
                          .withValues(alpha: overlayBottomOpacity),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeColors.primaryActionColor.withValues(alpha: 0.12),
                      Colors.transparent,
                      themeColors.accentColor.withValues(alpha: 0.10),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -size.height * 0.06,
            left: -size.width * 0.10,
            right: -size.width * 0.10,
            child: IgnorePointer(
              child: _AtmosphericGlow(
                size: Size(size.width * 1.2, size.height * 0.34),
                colors: [
                  onPrimary.withValues(alpha: 0.14),
                  themeColors.accentColor.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SizedBox(height: appBar == null ? 96 : 140),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -60,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: themeColors.accentColor,
                size: 180,
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -90,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: themeColors.secondaryActionColor,
                size: 220,
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -30,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: themeColors.primaryActionColor,
                size: 96,
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.18,
            right: -30,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: onPrimary,
                size: 88,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.only(
                  top: effectiveExtendBodyBehindAppBar && appBar != null
                      ? appBarHeight
                      : 0,
                ),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmosphericGlow extends StatelessWidget {
  const _AtmosphericGlow({
    required this.size,
    required this.colors,
  });

  final Size size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 0.95,
            colors: colors,
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  const _FloatingOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: size * 0.18,
              spreadRadius: size * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}

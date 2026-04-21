import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';

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
      backgroundColor: cfg.baseBackgroundColor,
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
                  return ColoredBox(color: cfg.baseBackgroundColor);
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
                      cfg.baseBackgroundColor
                          .withValues(alpha: overlayTopOpacity),
                      cfg.baseBackgroundColor
                          .withValues(alpha: overlayBottomOpacity),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -60,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: cfg.accentColor,
                size: 180,
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -90,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: cfg.secondaryActionColor,
                size: 220,
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -30,
            child: IgnorePointer(
              child: _FloatingOrb(
                color: cfg.primaryActionColor,
                size: 96,
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

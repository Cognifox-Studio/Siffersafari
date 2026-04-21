import 'package:flutter/material.dart';
import 'package:siffersafari/core/constants/app_constants.dart';

class PlayfulPanel extends StatelessWidget {
  const PlayfulPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.largePadding),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.radius,
    this.hero = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? highlightColor;
  final double? radius;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;
    final resolvedRadius =
        radius ?? AppConstants.borderRadius * (hero ? 2 : 1.5);
    final resolvedHighlight = highlightColor ?? scheme.secondary;
    final resolvedBackground = backgroundColor ??
        theme.cardTheme.color ??
        onPrimary.withValues(alpha: hero ? 0.16 : AppOpacities.panelFill);
    final resolvedBorder =
        borderColor ?? onPrimary.withValues(alpha: AppOpacities.hudBorder);
    final gradientTop = Color.alphaBlend(
      resolvedHighlight.withValues(alpha: hero ? 0.05 : 0.03),
      resolvedBackground,
    );

    final content = Padding(
      padding: padding,
      child: child,
    );

    final decoratedChild = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientTop,
            resolvedBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(color: resolvedBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: hero ? 0.18 : 0.12),
            blurRadius: hero ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: Material(
          color: Colors.transparent,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  child: content,
                ),
        ),
      ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: decoratedChild,
    );
  }
}

class PlayfulSectionHeading extends StatelessWidget {
  const PlayfulSectionHeading({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.trailing,
    this.center = false,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? trailing;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final crossAxisAlignment =
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (eyebrow != null && eyebrow!.isNotEmpty) ...[
          Text(
            eyebrow!,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  Text(
                    title,
                    textAlign: center ? TextAlign.center : TextAlign.start,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      subtitle!,
                      textAlign: center ? TextAlign.center : TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: mutedOnPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppConstants.defaultPadding),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

class PlayfulStatPill extends StatelessWidget {
  const PlayfulStatPill({
    required this.label,
    required this.value,
    this.icon,
    this.highlightColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final accent = highlightColor ?? scheme.secondary;

    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.3),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: accent, size: 18),
            const SizedBox(height: AppConstants.microSpacing4),
          ],
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PlayfulInfoChip extends StatelessWidget {
  const PlayfulInfoChip({
    required this.label,
    this.icon,
    this.color,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final chipColor = color ?? scheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.28),
        ),
      ),
      child: Wrap(
        spacing: AppConstants.microSpacing6,
        runSpacing: AppConstants.microSpacing4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 16, color: chipColor),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class PlayfulAccentCard extends StatelessWidget {
  const PlayfulAccentCard({
    required this.label,
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
    this.backgroundColor,
    super.key,
  });

  final String label;
  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final baseBackground =
        backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;

    return PlayfulPanel(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      backgroundColor: Color.alphaBlend(
        accentColor.withValues(alpha: 0.10),
        baseBackground,
      ),
      borderColor: accentColor.withValues(alpha: 0.34),
      highlightColor: accentColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.32),
              ),
            ),
            child: Icon(icon, color: onPrimary),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: onPrimary.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

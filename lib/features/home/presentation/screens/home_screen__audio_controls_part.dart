part of 'home_screen.dart';

class _HomeAudioLevelPicker extends StatelessWidget {
  const _HomeAudioLevelPicker({
    required this.title,
    required this.subtitle,
    required this.keyPrefix,
    required this.icon,
    required this.toneColor,
    required this.sliderValue,
    required this.isBusy,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String title;
  final String subtitle;
  final String keyPrefix;
  final IconData icon;
  final Color toneColor;
  final double sliderValue;
  final bool isBusy;
  final ValueChanged<double> onChanged;
  final Future<void> Function(double value) onChangeEnd;

  String _labelFor(AppAudioLevel level) {
    switch (level) {
      case AppAudioLevel.off:
        return 'Av';
      case AppAudioLevel.low:
        return 'Låg';
      case AppAudioLevel.high:
        return 'Hög';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColors = context.appThemeColors;
    final onPrimary = theme.colorScheme.onPrimary;
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final resolvedValue = sliderValue.clamp(0.0, 2.0);
    final activeLevel = AppAudioLevel.values[resolvedValue.round()];
    final background = Color.alphaBlend(
      toneColor.withValues(alpha: 0.12),
      themeColors.panelBackgroundColor,
    );

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            background,
            onPrimary.withValues(alpha: AppOpacities.panelFill),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.2),
        border: Border.all(
          color: toneColor.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: toneColor.withValues(alpha: 0.28),
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
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppConstants.microSpacing4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtleOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: AppConstants.microSpacing6,
                ),
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _labelFor(activeLevel),
                  key: Key('${keyPrefix}_value'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          SliderTheme(
            data: theme.sliderTheme.copyWith(
              activeTrackColor: toneColor,
              thumbColor: toneColor,
              overlayColor: toneColor.withValues(alpha: 0.18),
            ),
            child: Slider(
              key: Key('${keyPrefix}_slider'),
              min: 0,
              max: 2,
              divisions: 2,
              label: _labelFor(activeLevel),
              value: resolvedValue,
              onChanged:
                  isBusy ? null : (value) => onChanged(value.roundToDouble()),
              onChangeEnd:
                  isBusy ? null : (value) => onChangeEnd(value.roundToDouble()),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _AudioSliderStopLabel(
                  label: 'Av',
                  icon: Icons.volume_off_rounded,
                  active: activeLevel == AppAudioLevel.off,
                  align: TextAlign.start,
                  color: toneColor,
                ),
              ),
              Expanded(
                child: _AudioSliderStopLabel(
                  label: 'Låg',
                  icon: Icons.volume_down_rounded,
                  active: activeLevel == AppAudioLevel.low,
                  align: TextAlign.center,
                  color: toneColor,
                ),
              ),
              Expanded(
                child: _AudioSliderStopLabel(
                  label: 'Hög',
                  icon: Icons.volume_up_rounded,
                  active: activeLevel == AppAudioLevel.high,
                  align: TextAlign.end,
                  color: toneColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioSliderStopLabel extends StatelessWidget {
  const _AudioSliderStopLabel({
    required this.label,
    required this.icon,
    required this.active,
    required this.align,
    required this.color,
  });

  final String label;
  final IconData icon;
  final bool active;
  final TextAlign align;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

    return Column(
      crossAxisAlignment: align == TextAlign.start
          ? CrossAxisAlignment.start
          : align == TextAlign.end
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: active ? color : mutedOnPrimary,
        ),
        const SizedBox(height: AppConstants.microSpacing4),
        Text(
          label,
          textAlign: align,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? onPrimary : mutedOnPrimary,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

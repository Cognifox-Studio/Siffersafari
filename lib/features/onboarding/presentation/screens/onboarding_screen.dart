import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/image_cache_size.dart';
import 'package:siffersafari/features/onboarding/providers/onboarding_controller_provider.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

// region OnboardingScreen Widget

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    required this.userId,
    super.key,
  });

  final String userId;

  static int _activeCount = 0;
  static bool get isActive => _activeCount > 0;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

// endregion

// region _OnboardingScreenState Main Widget

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int? _gradeLevel;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

    OnboardingScreen._activeCount++;

    // Load persisted onboarding-related settings for this user.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gradeLevel = ref
          .read(onboardingControllerProvider(widget.userId))
          .loadInitialGrade();

      if (!mounted) return;
      setState(() {
        _gradeLevel = gradeLevel;
        _isInitializing = false;
      });
    });
  }

  @override
  void dispose() {
    OnboardingScreen._activeCount = OnboardingScreen._activeCount > 0
        ? OnboardingScreen._activeCount - 1
        : 0;
    super.dispose();
  }

  Future<void> _completeOnboardingAndSaveProfile() async {
    await ref
        .read(onboardingControllerProvider(widget.userId))
        .complete(gradeLevel: _gradeLevel);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ThemedBackgroundScaffold(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final layout = AdaptiveLayoutInfo.fromConstraints(constraints);
            final compactLayout = constraints.maxHeight < 620;
            final maxContentWidth = layout.contentMaxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PlayfulSectionHeading(
                      eyebrow: 'Nu kör vi!',
                      title: 'Välj årskurs',
                      subtitle: 'Tryck på en ruta.',
                    ),
                    SizedBox(
                      height: compactLayout
                          ? AppConstants.defaultPadding
                          : AppConstants.largePadding,
                    ),
                    Expanded(
                      child: _OnboardingGradePage(
                        gradeLevel: _gradeLevel,
                        onChanged: (value) => setState(() {
                          _gradeLevel = value;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    ElevatedButton(
                      onPressed: _isInitializing
                          ? null
                          : _completeOnboardingAndSaveProfile,
                      child: const Text('Starta'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.imageAsset,
    required this.title,
    required this.child,
  });

  final String imageAsset;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final imageHeight = AppConstants.minTouchTargetSize * 1.5;
    final imageCacheHeight = imageCacheExtent(context, imageHeight);
    return Center(
      child: PlayfulPanel(
        hero: true,
        highlightColor: accentColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                imageAsset,
                height: imageHeight,
                cacheHeight: imageCacheHeight,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingGradePage extends StatelessWidget {
  const _OnboardingGradePage({
    required this.gradeLevel,
    required this.onChanged,
  });

  final int? gradeLevel;
  final ValueChanged<int?> onChanged;

  static const _gradeItems = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      imageAsset: 'assets/images/ui/img_school_cap.png',
      title: 'Årskurs',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: [
              ..._gradeItems.map(
                (grade) => SizedBox(
                  width: 92,
                  child: _GradeChoiceButton(
                    label: 'Åk $grade',
                    isSelected: gradeLevel == grade,
                    onTap: () => onChanged(grade),
                  ),
                ),
              ),
              SizedBox(
                width: 156,
                child: _GradeChoiceButton(
                  label: 'Vet inte än',
                  isSelected: gradeLevel == null,
                  onTap: () => onChanged(null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeChoiceButton extends StatelessWidget {
  const _GradeChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final baseColor = isSelected
        ? scheme.secondary.withValues(alpha: 0.16)
        : onPrimary.withValues(alpha: AppOpacities.subtleFill);
    final borderColor = isSelected
        ? scheme.secondary.withValues(alpha: 0.82)
        : onPrimary.withValues(alpha: AppOpacities.hudBorder);

    return Semantics(
      button: true,
      selected: isSelected,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimationDuration,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.2),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadius * 1.2),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: AppConstants.defaultPadding,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// endregion

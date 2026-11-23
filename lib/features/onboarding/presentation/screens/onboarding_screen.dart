import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/image_cache_size.dart';
import 'package:siffersafari/domain/services/setup_plan.dart';
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
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _isInitializing) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final onPrimary = Theme.of(ctx).colorScheme.onPrimary;
            return AlertDialog(
              title: Text(
                'Avsluta utan att starta?',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              content: Text(
                'Profilen finns kvar. Vi sätter Åk ${_gradeLevel ?? 1} '
                'tills vidare — du kan ändra i Föräldraläge.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Fortsätt'),
                ),
                TextButton(
                  key: const Key('confirm_onboarding_abandon'),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Avsluta'),
                ),
              ],
            );
          },
        );
        if (leave != true || !mounted) return;
        await ref
            .read(onboardingControllerProvider(widget.userId))
            .complete(gradeLevel: _gradeLevel ?? 1);
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
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
    final plan = SetupPlan.forGrade(gradeLevel);
    return _OnboardingCard(
      imageAsset: 'assets/images/ui/img_school_cap.webp',
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
          const SizedBox(height: AppConstants.defaultPadding),
          _SetupPlanPreview(plan: plan),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            gradeLevel == null
                ? 'Osäker? Välj «Vet inte än» — du kan byta årskurs senare under Föräldrar.'
                : 'Du kan byta årskurs senare under Föräldrar om det inte stämmer.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.82),
                ),
          ),
        ],
      ),
    );
  }
}

/// The end of the checklist, shown before it is pressed.
///
/// Setup used to end in a black box: the grade went in, three settings came
/// out, and nothing said which. This is the sentence the parent can check --
/// and, if it is wrong, the reason to open Föräldraläge before the child meets
/// a level she cannot handle.
class _SetupPlanPreview extends StatelessWidget {
  const _SetupPlanPreview({required this.plan});

  final SetupPlan plan;

  static const Key _key = Key('onboarding_setup_plan');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    return Semantics(
      container: true,
      label: 'Så här börjar vi. ${plan.spokenSummary}',
      child: ExcludeSemantics(
        child: Container(
          key: _key,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.smallPadding,
            vertical: AppConstants.smallPadding,
          ),
          decoration: BoxDecoration(
            color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadius * 1.1),
            border: Border.all(
              color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Så här börjar vi',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: onPrimary.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
              const SizedBox(height: AppConstants.microSpacing6),
              Text(
                '${plan.gradeLabel} · ${plan.operationsLabel}',
                key: const Key('onboarding_setup_plan_summary'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '${plan.readingLabel}. Allt kan ändras i Föräldraläge.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onPrimary.withValues(alpha: 0.82),
                    ),
              ),
            ],
          ),
        ),
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

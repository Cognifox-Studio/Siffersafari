import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
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
      final repo = ref.read(localStorageRepositoryProvider);

      final activeUser = ref.read(userProvider).activeUser;
      final user = activeUser?.userId == widget.userId
          ? activeUser
          : repo.getUserProgress(widget.userId);

      if (!mounted) return;
      setState(() {
        _gradeLevel = user?.gradeLevel;
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

  Set<OperationType> _defaultAllowedOperationsFor(int? gradeLevel) {
    if (gradeLevel == null) {
      return const {
        OperationType.addition,
        OperationType.subtraction,
      };
    }

    return DifficultyConfig.visibleOperationsForGrade(gradeLevel);
  }

  Future<void> _completeOnboardingAndSaveProfile() async {
    final repo = ref.read(localStorageRepositoryProvider);

    // Fallback to grade 1 if the child skipped grade selection. This avoids
    // a null gradeLevel which would disable word problems, missing-number
    // questions and the parent benchmark section.
    final effectiveGrade = _gradeLevel ?? 1;

    final activeUser = ref.read(userProvider).activeUser;
    if (activeUser != null && activeUser.userId == widget.userId) {
      await ref
          .read(userProvider.notifier)
          .saveUser(activeUser.copyWith(gradeLevel: effectiveGrade));
    } else {
      final user = repo.getUserProgress(widget.userId);
      if (user != null) {
        await repo.saveUserProgress(user.copyWith(gradeLevel: effectiveGrade));
        await ref.read(userProvider.notifier).loadUsers();
      }
    }

    await ref.read(parentSettingsProvider.notifier).setAllowedOperations(
          widget.userId,
          _defaultAllowedOperationsFor(effectiveGrade),
        );

    final hasStoredReadingSetting =
        QuizFeatureSettings.hasStoredWordProblemsEnabled(
      repository: repo,
      userId: widget.userId,
    );
    if (!hasStoredReadingSetting) {
      await QuizFeatureSettings.saveWordProblemsEnabled(
        repository: repo,
        userId: widget.userId,
        enabled: QuizFeatureSettings.defaultWordProblemsEnabled(
          repository: repo,
          userId: widget.userId,
        ),
      );
    }

    await repo.setOnboardingDone(widget.userId, true);

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
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Center(
      child: PlayfulPanel(
        hero: true,
        highlightColor: accentColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                icon,
                size: AppConstants.minTouchTargetSize,
                color: accentColor,
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
      icon: Icons.school,
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

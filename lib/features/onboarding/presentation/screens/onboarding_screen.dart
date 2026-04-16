import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/shared/settings/quiz_feature_settings.dart';
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

  Future<void> _finish() async {
    final repo = ref.read(localStorageRepositoryProvider);

    final activeUser = ref.read(userProvider).activeUser;
    if (activeUser != null && activeUser.userId == widget.userId) {
      await ref
          .read(userProvider.notifier)
          .saveUser(activeUser.copyWith(gradeLevel: _gradeLevel));
    } else {
      final user = repo.getUserProgress(widget.userId);
      if (user != null) {
        await repo.saveUserProgress(user.copyWith(gradeLevel: _gradeLevel));
        await ref.read(userProvider.notifier).loadUsers();
      }
    }

    await ref.read(parentSettingsProvider.notifier).setAllowedOperations(
          widget.userId,
          _defaultAllowedOperationsFor(_gradeLevel),
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
    final accentColor = Theme.of(context).colorScheme.secondary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Nu kör vi!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Jag heter ${AppConstants.mascotName}.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: mutedOnPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Det här går snabbt, sen kör vi igång.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: mutedOnPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '1/1',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: mutedOnPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        minHeight: AppConstants.progressBarHeightSmall,
                        backgroundColor: onPrimary.withValues(
                          alpha: AppOpacities.progressTrackLight,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
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
                    const SizedBox(height: AppConstants.defaultPadding),
                    ElevatedButton(
                      onPressed: _isInitializing ? null : _finish,
                      child: Text(
                        'Starta',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
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
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: onPrimary.withValues(alpha: AppOpacities.cardBorder),
          ),
        ),
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
    final dropdownBg = Theme.of(context).scaffoldBackgroundColor;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    return _OnboardingCard(
      icon: Icons.school,
      title: 'Vilken årskurs kör du?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Vi väljer en lagom start direkt. Det går att ändra senare i Föräldraläge.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Årskurs',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              DropdownButton<int?>(
                value: gradeLevel,
                dropdownColor: dropdownBg,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: onPrimary),
                underline: const SizedBox.shrink(),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Vet inte'),
                  ),
                  ..._gradeItems.map(
                    (g) => DropdownMenuItem<int?>(
                      value: g,
                      child: Text('Åk $g'),
                    ),
                  ),
                ],
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// endregion

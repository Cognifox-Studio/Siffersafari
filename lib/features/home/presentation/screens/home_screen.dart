import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/missing_number_settings_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/providers/word_problems_settings_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:siffersafari/features/home/presentation/widgets/camp_scene_view.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_badge_album.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_story_progress_card.dart';
import 'package:siffersafari/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:siffersafari/features/parent/presentation/screens/parent_pin_screen.dart';
import 'package:siffersafari/features/profiles/presentation/dialogs/create_user_dialog.dart';
import 'package:siffersafari/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:siffersafari/features/settings/presentation/screens/settings_screen.dart';
import 'package:siffersafari/features/story/presentation/screens/story_map_screen.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

// region HomeScreen Setup

/// Home screen - main entry point of the app
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _checkedOnboardingForUserId;
  String? _loadedReviewSummaryForUserId;
  String _appVersionLabel = '...';
  bool _onboardingPushInFlight = false;
  CharacterReaction _mascotReaction = CharacterReaction.idle;
  int _mascotReactionNonce = 0;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    // Load existing users and start background music
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(userProvider.notifier);
      await notifier.loadUsers();

      if (!mounted) return;
      final activeUser = ref.read(userProvider).activeUser;
      if (activeUser != null) {
        _checkUserData(activeUser.userId);
      }

      // Start background music when home screen loads
      ref.read(audioServiceProvider).playMusic();

      if (mounted) {
        setState(() {
          _mascotReaction = CharacterReaction.enter;
          _mascotReactionNonce++;
        });
      }
    });
  }

  void _checkUserData(String userId) {
    if (_loadedReviewSummaryForUserId != userId) {
      _loadedReviewSummaryForUserId = userId;
      ref.read(quizProvider.notifier).hydrateReviewSummaryForUser(userId);
    }

    if (_checkedOnboardingForUserId != userId) {
      _checkedOnboardingForUserId = userId;
      _checkOnboarding(userId);
    }
  }

  void _checkOnboarding(String userId) {
    if (_onboardingPushInFlight || OnboardingScreen.isActive) return;

    final repo = ref.read(localStorageRepositoryProvider);
    final done = repo.isOnboardingDone(userId);

    if (done != true) {
      _onboardingPushInFlight = true;
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(userId: userId),
        ),
      )
          .whenComplete(() {
        if (mounted) {
          _onboardingPushInFlight = false;
        }
      });
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionLabel = packageInfo.buildNumber.isEmpty
          ? packageInfo.version
          : '${packageInfo.version}+${packageInfo.buildNumber}';

      if (!mounted) return;
      setState(() {
        _appVersionLabel = versionLabel;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _appVersionLabel = 'okänd';
      });
    }
  }

  // endregion

  // region _startQuiz Method

  void _startOrResumePrimaryQuiz({
    required UserProgress user,
    required Set<OperationType> allowedOps,
  }) {
    final didResume =
        ref.read(quizProvider.notifier).resumeLatestSessionForUser(
              userId: user.userId,
            );

    if (didResume) {
      ref.read(audioServiceProvider).playClickSound();
      setState(() {
        _mascotReaction = CharacterReaction.screenChange;
        _mascotReactionNonce++;
      });
      context.pushSmooth(const QuizScreen());
      return;
    }

    _startQuiz(
      operationType: allowedOps.isNotEmpty
          ? allowedOps.first
          : OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
    );
  }

  void _startQuiz({
    required OperationType operationType,
    required DifficultyLevel difficulty,
    bool isDailyChallenge = false,
  }) {
    ref.read(audioServiceProvider).playClickSound();

    final user = ref.read(userProvider).activeUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skapa en profil först!')),
      );
      context.pushSmooth(const SettingsScreen());
      return;
    }

    ref.read(userProvider.notifier).clearQuestNotice();

    final effectiveAgeGroup = DifficultyConfig.effectiveAgeGroup(
      fallback: user.ageGroup,
      gradeLevel: user.gradeLevel,
    );

    final effectiveDifficulty = DifficultyConfig.effectiveDifficulty(
      fallback: difficulty,
      gradeLevel: user.gradeLevel,
    );

    final steps = DifficultyConfig.buildDifficultySteps(
      storedSteps: user.operationDifficultySteps,
      defaultDifficulty: effectiveDifficulty,
      gradeLevel: user.gradeLevel,
    );

    final wordProblemsEnabled = ref.read(
      wordProblemsEnabledProvider(user.userId),
    );

    final missingNumberEnabled = ref.read(
      missingNumberEnabledProvider(user.userId),
    );

    ref.read(quizProvider.notifier).startSession(
          userId: user.userId,
          ageGroup: effectiveAgeGroup,
          gradeLevel: user.gradeLevel,
          operationType: operationType,
          difficulty: effectiveDifficulty,
          initialDifficultyStepsByOperation: steps,
          wordProblemsEnabled: wordProblemsEnabled,
          missingNumberEnabled: missingNumberEnabled,
          isDailyChallenge: isDailyChallenge,
        );

    unawaited(
      ref.read(appAnalyticsProvider).logEvent(
        name: 'quiz_started',
        userId: user.userId,
        properties: {
          'operation': operationType.name,
          'difficulty': effectiveDifficulty.name,
          'isDailyChallenge': isDailyChallenge,
          'gradeLevel': user.gradeLevel,
        },
      ),
    );

    setState(() {
      _mascotReaction = CharacterReaction.screenChange;
      _mascotReactionNonce++;
    });
    context.pushSmooth(const QuizScreen());
  }

  // endregion

  // region Main Build Method

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (previous, next) {
      final nextUser = next.activeUser;
      if (nextUser != null) {
        _checkUserData(nextUser.userId);
      }
    });

    final userState = ref.watch(userProvider);
    final user = userState.activeUser;
    final quizState = ref.watch(quizProvider);
    final storyProgress = ref.watch(storyProgressProvider);

    final themeCfg = ref.watch(appThemeConfigProvider);
    final backgroundAsset = themeCfg.backgroundAsset;
    final questHeroAsset = themeCfg.questHeroAsset;
    final characterAsset = themeCfg.characterAsset;
    final accentColor = themeCfg.accentColor;

    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final faintOnPrimary = onPrimary.withValues(alpha: AppOpacities.faintText);

    final parentAllowedOps = user == null
        ? _defaultAllowedOperations()
        : ref.watch(parentSettingsProvider(user.userId));

    final allowedOps = DifficultyConfig.effectiveAllowedOperations(
      parentAllowedOperations: parentAllowedOps,
      gradeLevel: user?.gradeLevel,
    );
    final hasPersistedInProgressSession = user == null
        ? false
        : ref
                .read(localStorageRepositoryProvider)
                .getQuizSession(user.userId) !=
            null;
    final hasActiveInMemorySession = user != null &&
        quizState.userId == user.userId &&
        quizState.session != null;
    final hasResumableSession =
        hasActiveInMemorySession || hasPersistedInProgressSession;
    final isDailyChallengeCompleted = user == null
        ? false
        : ref.watch(dailyChallengeProvider(user.userId)).isCompleted;
    final hasStoryQuest = user != null &&
        storyProgress != null &&
        userState.questStatus != null &&
        allowedOps.contains(userState.questStatus!.quest.operation);

    final operationCards = _buildOperationCards(context, allowedOps);

    return ThemedBackgroundScaffold(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = AdaptiveLayoutInfo.fromConstraints(constraints);
          final maxContentWidth = layout.contentMaxWidth;
          final isWideScreen = !layout.isCompactWidth;
          final gridCrossAxisCount = layout.gridColumns(
            compact: 2,
            medium: 3,
            expanded: 4,
          );
          final operationCardAspectRatio = layout.isShortHeight
              ? 1.45
              : layout.isExpandedWidth
                  ? 1.15
                  : layout.isMediumWidth
                      ? 1.0
                      : 0.95;

          final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
          final questHeroLogicalWidth = isWideScreen
              ? constraints.maxWidth.clamp(0.0, 800.0).toDouble()
              : constraints.maxWidth;
          final questHeroCacheWidth =
              (questHeroLogicalWidth * devicePixelRatio).round();
          final questHeroCacheHeight = (110 * devicePixelRatio).round();

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    PlayfulPanel(
                      hero: true,
                      highlightColor: accentColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/ui/img_logo_safari.png',
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                                if (user != null)
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      tooltip: 'Föräldraläge',
                                      onPressed: () {
                                        unawaited(
                                          ref
                                              .read(appAnalyticsProvider)
                                              .logEvent(
                                                name: 'parent_mode_opened',
                                                userId: user.userId,
                                              ),
                                        );
                                        context.pushSmooth(
                                          const ParentPinScreen(),
                                        );
                                      },
                                      iconSize: 56,
                                      icon: Image.asset(
                                        'assets/images/ui/ic_ui_padlock.png',
                                        width: 48,
                                        height: 48,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PlayfulSectionHeading(
                            center: true,
                            eyebrow: user != null
                                ? 'Välkommen, ${user.name}! 👋'
                                : 'Redo för safari?',
                            title: user != null
                                ? 'Dags för äventyr!'
                                : 'Börja spela',
                            subtitle:
                                user == null ? 'Skapa en profil först.' : null,
                          ),
                          if (user != null) ...[
                            const SizedBox(height: AppConstants.smallPadding),
                            CampSceneView(
                              mascotReaction: _mascotReaction,
                              mascotReactionNonce: _mascotReactionNonce,
                              isWideScreen: isWideScreen,
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: AppConstants.smallPadding,
                              runSpacing: AppConstants.smallPadding,
                              children: [
                                PlayfulInfoChip(
                                  label: 'Nivå ${user.level}',
                                  icon: Icons.auto_awesome_rounded,
                                  color: accentColor,
                                ),
                                if (hasStoryQuest)
                                  PlayfulInfoChip(
                                    label: 'Uppdrag',
                                    icon: Icons.explore_rounded,
                                    color: themeCfg.secondaryActionColor,
                                  ),
                                if (isDailyChallengeCompleted)
                                  PlayfulInfoChip(
                                    label: 'Dagens runda klar',
                                    icon: Icons.check_circle_rounded,
                                    color: themeCfg.progressCompletedColor,
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.largePadding),
                            ElevatedButton.icon(
                              key: const Key('primary_play_button'),
                              onPressed: () {
                                _startOrResumePrimaryQuiz(
                                  user: user,
                                  allowedOps: allowedOps,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: onPrimary,
                                foregroundColor: themeCfg.primaryActionColor,
                                minimumSize: const Size.fromHeight(60),
                              ),
                              icon: Icon(
                                hasResumableSession
                                    ? Icons.play_circle_fill_rounded
                                    : Icons.play_arrow_rounded,
                                size: 32,
                              ),
                              label: Text(
                                hasResumableSession ? 'Fortsätt' : 'Spela nu',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            HomeBadgeAlbum(achievementIds: user.achievements),
                          ] else ...[
                            const SizedBox(height: AppConstants.largePadding),
                            ElevatedButton(
                              onPressed: () {
                                showCreateUserDialog(
                                  context: context,
                                  ref: ref,
                                );
                              },
                              child: const Text('Skapa profil'),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (user != null) ...[
                      const SizedBox(height: AppConstants.largePadding),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '🎮 Mer spel',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.defaultPadding),

                    if (hasStoryQuest)
                      HomeStoryProgressCard(
                        story: storyProgress,
                        heroAsset: questHeroAsset,
                        backgroundAsset: backgroundAsset,
                        characterAsset: characterAsset,
                        primaryActionColor: themeCfg.primaryActionColor,
                        secondaryActionColor: themeCfg.secondaryActionColor,
                        accentColor: accentColor,
                        onPrimary: onPrimary,
                        mutedOnPrimary: mutedOnPrimary,
                        faintOnPrimary: onPrimary.withValues(
                          alpha: AppOpacities.faintText,
                        ),
                        cacheWidth: questHeroCacheWidth,
                        cacheHeight: questHeroCacheHeight,
                        onStartQuest: () => _startQuiz(
                          operationType: userState.questStatus!.quest.operation,
                          difficulty: userState.questStatus!.quest.difficulty,
                        ),
                        onOpenMap: () => context.pushSmooth(
                          const StoryMapScreen(),
                        ),
                      ),

                    const SizedBox(height: AppConstants.largePadding),

                    if (user != null)
                      const SizedBox(height: AppConstants.largePadding),

                    // Operation selection (responsive grid)
                    if (user != null)
                      ConstrainedBox(
                        constraints: isWideScreen
                            ? const BoxConstraints(maxWidth: 800)
                            : const BoxConstraints(),
                        child: GridView.count(
                          crossAxisCount: gridCrossAxisCount,
                          childAspectRatio: operationCardAspectRatio,
                          crossAxisSpacing: AppConstants.defaultPadding,
                          mainAxisSpacing: AppConstants.defaultPadding,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: operationCards,
                        ),
                      ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // Version Info
                    Text(
                      'Version $_appVersionLabel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: faintOnPrimary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // endregion

  // region UI Builder Methods

  Widget _buildOperationCard(
    BuildContext context,
    OperationType operation,
    IconData icon,
    String? assetPath,
  ) {
    final themeCfg = ref.read(appThemeConfigProvider);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final cardContent = PlayfulPanel(
      key: Key('operation_card_${operation.name}'),
      onTap: () => _startQuiz(
        operationType: operation,
        difficulty: DifficultyLevel.easy,
      ),
      highlightColor: themeCfg.primaryActionColor,
      padding: const EdgeInsets.all(AppConstants.microSpacing6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 170 || constraints.maxWidth < 160;
          final iconBubbleSize = compact ? 44.0 : 72.0;
          final iconSize = compact ? 24.0 : AppConstants.largeIconSize;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconBubbleSize,
                height: iconBubbleSize,
                decoration: BoxDecoration(
                  color: themeCfg.primaryActionColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeCfg.primaryActionColor.withValues(alpha: 0.32),
                  ),
                ),
                child: Hero(
                  tag: 'operation_${operation.name}',
                  child: assetPath != null
                      ? Center(
                          child: Image.asset(
                            assetPath,
                            width: iconBubbleSize * 0.7,
                            height: iconBubbleSize * 0.7,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          icon,
                          size: iconSize,
                          color: onPrimary,
                        ),
                ),
              ),
              SizedBox(
                height: compact
                    ? AppConstants.microSpacing6
                    : AppConstants.smallPadding,
              ),
              Text(
                operation.displayName,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 14 : null,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return Semantics(
      button: true,
      label: 'Starta ${operation.displayName}',
      child: ExcludeSemantics(
        // Only animate when not in widget test mode
        child: const bool.fromEnvironment('FLUTTER_TEST')
            ? cardContent
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: AppConstants.mediumAnimationDuration,
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: cardContent,
              ),
      ),
    );
  }

  Set<OperationType> _defaultAllowedOperations() {
    return {
      OperationType.addition,
      OperationType.subtraction,
      OperationType.multiplication,
      OperationType.division,
    };
  }

  List<Widget> _buildOperationCards(
    BuildContext context,
    Set<OperationType> allowedOps,
  ) {
    const configs =
        <({OperationType operation, IconData icon, String? assetPath})>[
      (
        operation: OperationType.addition,
        icon: Icons.add,
        assetPath: 'assets/images/ui/ic_math_addition.png'
      ),
      (
        operation: OperationType.subtraction,
        icon: Icons.remove,
        assetPath: 'assets/images/ui/ic_math_subtraction.png'
      ),
      (
        operation: OperationType.multiplication,
        icon: Icons.close,
        assetPath: 'assets/images/ui/ic_math_multiplication.png'
      ),
      (
        operation: OperationType.division,
        icon: Icons.percent,
        assetPath: 'assets/images/ui/ic_math_division.png'
      ),
    ];

    return configs
        .where((cfg) => allowedOps.contains(cfg.operation))
        .map(
          (cfg) => _buildOperationCard(
            context,
            cfg.operation,
            cfg.icon,
            cfg.assetPath,
          ),
        )
        .toList(growable: false);
  }

  // endregion
}

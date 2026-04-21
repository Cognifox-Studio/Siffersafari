import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/missing_number_settings_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/providers/word_problems_settings_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/domain/entities/level_up_event.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:siffersafari/features/home/presentation/screens/home_screen.dart';
import 'package:siffersafari/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
import 'package:siffersafari/presentation/widgets/star_rating.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

// region ResultsScreen Widget

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

// endregion

// region _ResultsScreenState Main Widget

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with TickerProviderStateMixin {
  bool _applied = false;
  bool _characterCelebrate = false;
  Timer? _celebrateTimer;

  late final AnimationController _lottieController;
  late final AnimationController _entranceController;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _actionsSlide;
  late final Animation<double> _actionsOpacity;

  static const int _slowAnswerThresholdSeconds = 8;

  List<_HardestQuestion> _getHardestQuestions(QuizSession session) {
    final items = <_HardestQuestion>[];

    for (final q in session.questions) {
      final answer = session.answers[q.id];
      final time = session.responseTimes[q.id];
      if (answer == null && time == null) continue;

      // Only show actual "hard" items:
      // - wrong answers always count
      // - correct answers only count if they were slow
      final wasCorrect = answer != null ? q.isCorrect(answer) : true;
      final isSlow = (time?.inSeconds ?? 0) >= _slowAnswerThresholdSeconds;
      final include = !wasCorrect || isSlow;
      if (!include) continue;

      items.add(
        _HardestQuestion(
          question: q,
          answer: answer,
          wasCorrect: wasCorrect,
          time: time,
        ),
      );
    }

    // Wrong answers first, then slowest response time.
    items.sort((a, b) {
      if (a.wasCorrect != b.wasCorrect) {
        return a.wasCorrect ? 1 : -1;
      }
      final at = a.time?.inMilliseconds ?? 0;
      final bt = b.time?.inMilliseconds ?? 0;
      return bt.compareTo(at);
    });

    if (items.length <= 3) return items;
    return items.take(3).toList(growable: false);
  }

  List<Question> _buildFocusedMiniPassQuestions(
    QuizSession session,
    List<_HardestQuestion> hardest,
    int count,
  ) {
    if (count <= 0) return const [];

    final weakQuestions =
        hardest.map((h) => h.question).toList(growable: false);

    final correctFast = <Question>[];
    final timed = <({Question q, int ms})>[];

    for (final q in session.questions) {
      final answer = session.answers[q.id];
      if (answer == null) continue;
      if (!q.isCorrect(answer)) continue;

      final ms = session.responseTimes[q.id]?.inMilliseconds;
      if (ms == null) {
        correctFast.add(q);
      } else {
        timed.add((q: q, ms: ms));
      }
    }

    timed.sort((a, b) => a.ms.compareTo(b.ms));
    correctFast
      ..addAll(timed.map((e) => e.q))
      ..removeWhere((q) => weakQuestions.contains(q));

    final weakCount = ((count * 0.8).round()).clamp(1, count);
    final easyCount = (count - weakCount).clamp(0, count);

    final result = <Question>[];

    if (weakQuestions.isEmpty) {
      // Fallback: no clear "hard" items, replay the quickest correct ones.
      final fallback = correctFast.isNotEmpty ? correctFast : session.questions;
      for (var i = 0; i < count; i++) {
        final q = fallback[i % fallback.length];
        result.add(q.copyWith(id: '${q.id}__focus_$i'));
      }
      return result;
    }

    // 70–80% focus on weak items.
    for (var i = 0; i < weakCount; i++) {
      final q = weakQuestions[i % weakQuestions.length];
      result.add(q.copyWith(id: '${q.id}__weak_$i'));
    }

    // 20–30% easier filler.
    final filler = correctFast.isNotEmpty
        ? correctFast
        : session.questions.where((q) => !weakQuestions.contains(q)).toList();
    for (var i = 0; i < easyCount; i++) {
      final q = filler.isNotEmpty
          ? filler[i % filler.length]
          : weakQuestions[i % weakQuestions.length];
      result.add(q.copyWith(id: '${q.id}__easy_$i'));
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _heroOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _actionsSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.18, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _actionsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.18, 0.7, curve: Curves.easeOut),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _celebrateTimer?.cancel();
    _lottieController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_applied) return;

    final quizState = ref.read(quizProvider);
    final session = quizState.session;
    if (session != null) {
      ref.read(userProvider.notifier).applyQuizResult(session);

      final reward = ref.read(userProvider).lastReward;
      final shouldCelebrate = session.successRate >= 0.8 ||
          (reward?.unlockedIds.isNotEmpty ?? false);
      if (shouldCelebrate) {
        ref.read(audioServiceProvider).playCelebrationSound();
        // Delay character jump until entrance + stars animation finishes.
        _celebrateTimer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _characterCelebrate = true);
        });
      }

      final userId = ref.read(userProvider).activeUser?.userId;
      if (userId != null && userId.isNotEmpty) {
        unawaited(
          ref.read(appAnalyticsProvider).logEvent(
            name: 'quiz_completed',
            userId: userId,
            properties: {
              'operation': session.operationType.name,
              'difficulty': session.difficulty.name,
              'successRate': session.successRate,
              'correctAnswers': session.correctAnswers,
              'wrongAnswers': session.wrongAnswers,
              'isDailyChallenge': quizState.isDailyChallenge,
            },
          ),
        );
      }

      // Mark the daily challenge as completed for this user.
      if (quizState.isDailyChallenge) {
        final completionUserId =
            ref.read(userProvider).activeUser?.userId ?? '';
        if (completionUserId.isNotEmpty) {
          ref
              .read(dailyChallengeProvider(completionUserId).notifier)
              .markCompleted();
          unawaited(
            ref.read(appAnalyticsProvider).logEvent(
              name: 'daily_challenge_completed',
              userId: completionUserId,
              properties: {
                'operation': session.operationType.name,
                'difficulty': session.difficulty.name,
                'successRate': session.successRate,
              },
            ),
          );
        }
      }

      // Surface level-up analytics if the child crossed a level threshold.
      final levelUp = ref.read(userProvider).lastLevelUp;
      if (levelUp != null && userId != null && userId.isNotEmpty) {
        unawaited(
          ref.read(appAnalyticsProvider).logEvent(
            name: 'level_up',
            userId: userId,
            properties: {
              'old_level': levelUp.oldLevel,
              'new_level': levelUp.newLevel,
              'title': levelUp.newTitle,
            },
          ),
        );
      }

      _applied = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final userState = ref.watch(userProvider);
    final session = quizState.session;
    final reward = userState.lastReward;
    final storyProgress = ref.watch(storyProgressProvider);
    final questCompletion = userState.lastQuestCompletion;

    final themeCfg = ref.watch(appThemeConfigProvider);

    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

    if (session == null) {
      return ThemedBackgroundScaffold(
        body: Center(
          child: Text(
            'Ingen data tillgänglig',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }

    final shouldCelebrate =
        session.successRate >= 0.8 || (reward?.unlockedIds.isNotEmpty ?? false);
    final stars = _calculateStars(session.successRate);
    final hardest = _getHardestQuestions(session);
    final bonusPoints = reward?.bonusPoints ?? 0;
    final totalPoints = session.totalPoints + bonusPoints;
    final panelColor = themeCfg.cardColor;
    final didUnlockSomething = reward?.unlockedIds.isNotEmpty ?? false;

    final badgeTeaser = _buildBadgeTeaser(
      session: session,
      quizState: quizState,
      stars: stars,
      bonusPoints: bonusPoints,
      didUnlockSomething: didUnlockSomething,
    );
    final activeUser = userState.activeUser;

    final summaryHero = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 112.h,
          child: GameCharacter(
            reaction: _characterCelebrate
                ? CharacterReaction.celebrate
                : CharacterReaction.idle,
            reactionNonce: _characterCelebrate ? 1 : 0,
            height: 112.h,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        PlayfulSectionHeading(
          eyebrow: 'Resultat',
          title: _getTitle(stars),
          center: true,
        ),
        const SizedBox(height: AppConstants.largePadding),
        if (shouldCelebrate) ...[
          TweenAnimationBuilder<double>(
            duration: AppConstants.celebrationPopDuration,
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, t, child) {
              final scale = 0.85 + (0.15 * t);
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              height: 150.h,
              child: Lottie.asset(
                'assets/animations/celebration.json',
                fit: BoxFit.contain,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;
                  _lottieController.forward().whenCompleteOrCancel(() {
                    if (mounted) _lottieController.forward(from: 0);
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
        ],
        StarRating(stars: stars),
      ],
    );

    final statsCard = PlayfulPanel(
      hero: true,
      backgroundColor: panelColor,
      highlightColor: scheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayfulSectionHeading(
            eyebrow: 'Så gick det',
            title: '${session.correctAnswers} rätt',
          ),
          SizedBox(height: AppConstants.largePadding.h),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: [
              PlayfulStatPill(
                label: 'Rätt',
                value: '${session.correctAnswers}',
                icon: Icons.check_circle_rounded,
                highlightColor: themeCfg.progressCompletedColor,
              ),
              PlayfulStatPill(
                label: 'Poäng',
                value: totalPoints.toString(),
                icon: Icons.star_rounded,
                highlightColor: themeCfg.primaryActionColor,
              ),
            ],
          ),
        ],
      ),
    );
    final showCoachCard = activeUser != null && stars == 0;
    final showCelebrationCard = didUnlockSomething || stars == 3;

    final actionColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (userState.lastLevelUp != null) ...[
          _LevelUpBanner(event: userState.lastLevelUp!),
          const SizedBox(height: AppConstants.largePadding),
        ],
        statsCard,
        if (questCompletion != null && storyProgress != null) ...[
          const SizedBox(height: AppConstants.largePadding),
          _buildStoryCheckpointPanel(
            context,
            panelColor: panelColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            storyProgress: storyProgress,
            questCompletion: questCompletion,
          ),
        ],
        if (showCoachCard) ...[
          const SizedBox(height: AppConstants.largePadding),
          _buildProgressSummaryPanel(
            context,
            panelColor: panelColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            user: activeUser,
            quizState: quizState,
          ),
        ],
        if (showCelebrationCard) ...[
          const SizedBox(height: AppConstants.largePadding),
          _buildBadgePanel(
            context,
            panelColor: panelColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            badgeTeaser: badgeTeaser,
          ),
        ],
        const SizedBox(height: AppConstants.largePadding),
        PlayfulPanel(
          hero: true,
          backgroundColor: panelColor,
          highlightColor: themeCfg.secondaryActionColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PlayfulSectionHeading(
                title: 'Kör mer?',
              ),
              SizedBox(height: AppConstants.defaultPadding.h),
              ElevatedButton.icon(
                onPressed: () => _startRoundFromResults(
                  session: session,
                  hardest: hardest,
                  useFocusedMiniPass: false,
                ),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Spela igen!'),
              ),
              SizedBox(height: AppConstants.defaultPadding.h),
              OutlinedButton.icon(
                onPressed: () => _startRoundFromResults(
                  session: session,
                  hardest: hardest,
                  useFocusedMiniPass: true,
                ),
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Snabbträna ⚡'),
              ),
              SizedBox(height: AppConstants.smallPadding.h),
              TextButton(
                onPressed: _goHomeFromResults,
                child: Text(
                  'Hem',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return ThemedBackgroundScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = AdaptiveLayoutInfo.fromConstraints(constraints);
          final maxContentWidth = layout.contentMaxWidth;
          final isWideScreen = !layout.isCompactWidth;
          final useTwoColumnResults = layout.isExpandedWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: isWideScreen
                      ? BoxConstraints(maxWidth: maxContentWidth)
                      : const BoxConstraints(),
                  child: useTwoColumnResults
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: AppConstants.defaultPadding,
                                ),
                                child: FadeTransition(
                                  opacity: _heroOpacity,
                                  child: SlideTransition(
                                    position: _heroSlide,
                                    child: summaryHero,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: FadeTransition(
                                opacity: _actionsOpacity,
                                child: SlideTransition(
                                  position: _actionsSlide,
                                  child: actionColumn,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _heroOpacity,
                              child: SlideTransition(
                                position: _heroSlide,
                                child: summaryHero,
                              ),
                            ),
                            const SizedBox(height: AppConstants.largePadding),
                            FadeTransition(
                              opacity: _actionsOpacity,
                              child: SlideTransition(
                                position: _actionsSlide,
                                child: actionColumn,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // endregion

  // region Helper Methods

  void _goHomeFromResults() {
    ref.read(userProvider.notifier).clearLastQuestCompletion();
    ref.read(userProvider.notifier).clearLastLevelUp();
    context.pushAndRemoveUntilSmooth(
      const HomeScreen(),
      (route) => false,
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

  void _startRoundFromResults({
    required QuizSession session,
    required List<_HardestQuestion> hardest,
    required bool useFocusedMiniPass,
  }) {
    ref.read(userProvider.notifier).clearLastQuestCompletion();
    ref.read(userProvider.notifier).clearLastLevelUp();

    final user = ref.read(userProvider).activeUser;
    if (user == null) {
      _goHomeFromResults();
      return;
    }

    final allowedOps = ref.read(parentSettingsProvider)[user.userId] ??
        _defaultAllowedOperations();
    if (!allowedOps.contains(session.operationType)) {
      _goHomeFromResults();
      return;
    }

    final effectiveAgeGroup = DifficultyConfig.effectiveAgeGroup(
      fallback: user.ageGroup,
      gradeLevel: user.gradeLevel,
    );

    final effectiveDifficulty = DifficultyConfig.effectiveDifficulty(
      fallback: session.difficulty,
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

    if (!useFocusedMiniPass) {
      ref.read(quizProvider.notifier).startSession(
            userId: user.userId,
            ageGroup: effectiveAgeGroup,
            gradeLevel: user.gradeLevel,
            operationType: session.operationType,
            difficulty: effectiveDifficulty,
            initialDifficultyStepsByOperation: steps,
            wordProblemsEnabled: wordProblemsEnabled,
            missingNumberEnabled: missingNumberEnabled,
          );
    } else {
      final count = DifficultyConfig.getQuestionsPerSession(
        effectiveAgeGroup,
      );

      final miniQuestions = _buildFocusedMiniPassQuestions(
        session,
        hardest,
        count,
      );

      if (miniQuestions.isEmpty) {
        ref.read(quizProvider.notifier).startSession(
              userId: user.userId,
              ageGroup: effectiveAgeGroup,
              gradeLevel: user.gradeLevel,
              operationType: session.operationType,
              difficulty: effectiveDifficulty,
              initialDifficultyStepsByOperation: steps,
              wordProblemsEnabled: wordProblemsEnabled,
              missingNumberEnabled: missingNumberEnabled,
            );
      } else {
        ref.read(quizProvider.notifier).startCustomSession(
              userId: user.userId,
              operationType: session.operationType,
              difficulty: effectiveDifficulty,
              questions: miniQuestions,
              ageGroup: effectiveAgeGroup,
              gradeLevel: user.gradeLevel,
              initialDifficultyStepsByOperation: steps,
              wordProblemsEnabled: wordProblemsEnabled,
              missingNumberEnabled: missingNumberEnabled,
            );
      }
    }

    context.pushAndRemoveUntilSmooth(
      const QuizScreen(),
      (route) => false,
    );
  }

  String _getTitle(int stars) {
    switch (stars) {
      case 3:
        return _mascotSays('Wow! Supersnyggt!');
      case 2:
        return _mascotSays('Snyggt jobbat!');
      case 1:
        return _mascotSays('Bra kämpat!');
      default:
        return _mascotSays('Heja! Prova igen!');
    }
  }

  String _mascotSays(String text) {
    return '${AppConstants.mascotName}: $text';
  }

  int _calculateStars(double successRate) {
    if (successRate >= 0.9) return 3;
    if (successRate >= 0.7) return 2;
    if (successRate >= 0.5) return 1;
    return 0;
  }

  Widget _buildBadgePanel(
    BuildContext context, {
    required Color panelColor,
    required Color onPrimary,
    required Color mutedOnPrimary,
    required _BadgeTeaser badgeTeaser,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return PlayfulPanel(
      backgroundColor: panelColor,
      highlightColor: scheme.secondary,
      padding: EdgeInsets.all(AppConstants.largePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                badgeTeaser.badgeEmoji,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(width: AppConstants.defaultPadding.w),
              Expanded(
                child: Text(
                  badgeTeaser.badgeTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.smallPadding.h),
          Text(
            badgeTeaser.badgeBody,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummaryPanel(
    BuildContext context, {
    required Color panelColor,
    required Color onPrimary,
    required Color mutedOnPrimary,
    required UserProgress user,
    required QuizState quizState,
  }) {
    final nextLevelText = user.pointsToNextLevel == UserProgress.pointsPerLevel
        ? 'Ny nivå!'
        : '${user.pointsToNextLevel} poäng till nivå ${user.level + 1}.';

    return PlayfulPanel(
      backgroundColor: panelColor,
      highlightColor: Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.all(AppConstants.largePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bra kämpat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: AppConstants.smallPadding.h),
          Text(
            'Spela en gång till så känns det lättare.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (quizState.bestCorrectStreak >= 2) ...[
            SizedBox(height: AppConstants.smallPadding.h),
            Text(
              '${quizState.bestCorrectStreak} rätt i rad.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          SizedBox(height: AppConstants.smallPadding.h),
          Text(
            nextLevelText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCheckpointPanel(
    BuildContext context, {
    required Color panelColor,
    required Color onPrimary,
    required Color mutedOnPrimary,
    required StoryProgress storyProgress,
    required QuestCompletionEvent questCompletion,
  }) {
    final themeCfg = ref.read(appThemeConfigProvider);
    final scheme = Theme.of(context).colorScheme;
    final currentNode = storyProgress.currentNode;
    final reachedLandmark = currentNode?.landmark ?? 'nästa plats';
    final nextTitle =
        questCompletion.nextQuestTitle ?? storyProgress.currentObjectiveTitle;
    final nextBody = questCompletion.nextQuestTitle == null
        ? 'Du är snart framme vid slutet av den här stigen.'
        : 'Nästa mål: $nextTitle';

    return PlayfulPanel(
      backgroundColor: panelColor,
      highlightColor: scheme.secondary,
      padding: EdgeInsets.all(AppConstants.largePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nytt stopp!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: AppConstants.smallPadding.h),
          Text(
            'Nu: $reachedLandmark',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: AppConstants.defaultPadding.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackCards = constraints.maxWidth < 620;
              final currentCard = _StoryFocusCard(
                label: 'Du är här',
                title: reachedLandmark,
                body: storyProgress.chapterTitle,
                icon: Icons.place_rounded,
                color: scheme.secondary,
                onPrimary: onPrimary,
              );
              final nextCard = _StoryFocusCard(
                label: 'Nästa stopp',
                title: nextTitle,
                body: nextBody,
                icon: Icons.flag_rounded,
                color: themeCfg.progressNextColor,
                onPrimary: onPrimary,
              );

              if (stackCards) {
                return Column(
                  children: [
                    currentCard,
                    SizedBox(height: AppConstants.defaultPadding.h),
                    nextCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: currentCard),
                  SizedBox(width: AppConstants.defaultPadding.w),
                  Expanded(child: nextCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  _BadgeTeaser _buildBadgeTeaser({
    required QuizSession session,
    required QuizState quizState,
    required int stars,
    required int bonusPoints,
    required bool didUnlockSomething,
  }) {
    final seed = session.sessionId;

    String badgeEmoji;
    String badgeTitle;
    String badgeBody;

    if (didUnlockSomething) {
      badgeEmoji = '🎁';
      badgeTitle = _mascotSays(
        _pick(
          seed,
          const ['Ny skatt!', 'Upplåsning!', 'Du hittade en grej!'],
        ),
      );
      badgeBody = 'Du låste upp något nytt. Fortsätt så!';
    } else if (stars >= 3) {
      badgeEmoji = '🏆';
      badgeTitle = _mascotSays(
        _pick(seed, const ['Stjärnkapten!', 'Mästarrunda!', 'Tre stjärnor!']),
      );
      badgeBody =
          '3 stjärnor i ${session.operationType.emoji} ${session.operationType.displayName}.';
    } else if (quizState.bestCorrectStreak >= 5) {
      badgeEmoji = '🔥';
      badgeTitle = _mascotSays(
        _pick(seed, const ['Svitproffs!', 'Du är i zonen!', 'Eldsvit!']),
      );
      badgeBody = 'Bästa svit: ${quizState.bestCorrectStreak} rätt i rad.';
    } else if (quizState.speedBonusCount >= 3) {
      badgeEmoji = '⚡';
      badgeTitle = _mascotSays(
        _pick(seed, const ['Blixtläge!', 'Snabbbonus-jägare!', 'Raketfart!']),
      );
      badgeBody =
          'Snabbbonusar: ${quizState.speedBonusCount} st (supersnabbt!).';
    } else if (session.successRate >= 0.7) {
      badgeEmoji = '🌟';
      badgeTitle = _mascotSays(
        _pick(seed, const ['Stabil runda!', 'Snyggt flow!', 'Bra tempo!']),
      );
      badgeBody =
          'Du är på gång i ${session.operationType.emoji} ${session.operationType.displayName}.';
    } else {
      badgeEmoji = '💪';
      badgeTitle = _mascotSays(
        _pick(seed, const ['Bra kämpat!', 'Du tränar!', 'Heja dig!']),
      );
      badgeBody = 'Varje runda gör dig lite starkare.';
    }

    final teaser = _buildTeaser(
      session: session,
      quizState: quizState,
      stars: stars,
      bonusPoints: bonusPoints,
    );

    return _BadgeTeaser(
      badgeEmoji: badgeEmoji,
      badgeTitle: badgeTitle,
      badgeBody: badgeBody,
      teaser: teaser,
    );
  }

  String _buildTeaser({
    required QuizSession session,
    required QuizState quizState,
    required int stars,
    required int bonusPoints,
  }) {
    if (stars < 3) {
      final needed = ((session.totalQuestions * 0.9).ceil())
          .clamp(1, session.totalQuestions);
      return 'Nästa mål: 3 stjärnor — sikta på $needed av ${session.totalQuestions} rätt!';
    }

    if (quizState.speedBonusCount == 0) {
      return 'Bonusjakt: svara supersnabbt för ⚡!';
    }

    if (quizState.bestCorrectStreak < 5) {
      return 'Svitjakt: prova att få 5 rätt i rad 🔥';
    }

    if (bonusPoints == 0) {
      return 'Tips: Snabbträna på det som känns svårast!';
    }

    return 'Redo för en ny runda?';
  }

  String _pick(String seed, List<String> options) {
    if (options.isEmpty) return '';
    final index = _stableHash(seed) % options.length;
    return options[index];
  }

  int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  // endregion
}

// region Helper Classes

class _BadgeTeaser {
  const _BadgeTeaser({
    required this.badgeEmoji,
    required this.badgeTitle,
    required this.badgeBody,
    required this.teaser,
  });

  final String badgeEmoji;
  final String badgeTitle;
  final String badgeBody;
  final String teaser;
}

class _StoryFocusCard extends StatelessWidget {
  const _StoryFocusCard({
    required this.label,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.onPrimary,
  });

  final String label;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return PlayfulAccentCard(
      label: label,
      title: title,
      body: body,
      icon: icon,
      accentColor: color,
    );
  }
}

class _HardestQuestion {
  const _HardestQuestion({
    required this.question,
    required this.answer,
    required this.wasCorrect,
    required this.time,
  });

  final Question question;
  final int? answer;
  final bool wasCorrect;
  final Duration? time;
}

// endregion

class _LevelUpBanner extends StatelessWidget {
  const _LevelUpBanner({required this.event});

  final LevelUpEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PlayfulPanel(
      hero: true,
      highlightColor: scheme.primary,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.32),
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivå ${event.newLevel}!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Du är nu ${event.newTitle}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.92),
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

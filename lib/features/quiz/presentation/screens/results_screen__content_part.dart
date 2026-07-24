part of 'results_screen.dart';

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with TickerProviderStateMixin {
  bool _applied = false;
  bool _characterCelebrate = false;
  bool _showConfetti = false;
  Timer? _celebrateTimer;
  late final AnimationController _entranceController;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _actionsSlide;
  late final Animation<double> _actionsOpacity;

  @override
  void initState() {
    super.initState();
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
      if (mounted) {
        _entranceController.forward();
        _applySessionResults();
      }
    });
  }

  @override
  void dispose() {
    _celebrateTimer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  void _applySessionResults() {
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
        _celebrateTimer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() {
              _characterCelebrate = true;
              _showConfetti = true;
            });
          }
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
            },
          ),
        );
      }

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

      setState(() {
        _applied = true;
      });
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

    final themeColors = context.appThemeColors;

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
    final hardest = _ResultsPracticePlanner.hardestQuestions(session);
    final bonusPoints = reward?.bonusPoints ?? 0;
    final totalPoints = session.totalPoints + bonusPoints;
    final panelColor = themeColors.cardColor;
    final didUnlockSomething = reward?.unlockedIds.isNotEmpty ?? false;

    final badgeTeaser = _buildBadgeTeaser(
      session: session,
      quizState: quizState,
      stars: stars,
      bonusPoints: bonusPoints,
      didUnlockSomething: didUnlockSomething,
    );
    final activeUser = userState.activeUser;
    final hasStoryCheckpoint = questCompletion != null && storyProgress != null;
    final starCacheSize = imageCacheExtent(context, 100.w);

    final summaryHero = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 112.h,
          child: GameCharacter(
            characterId: activeUser?.selectedCharacterId == 'signe'
                ? CharacterId.signe
                : activeUser?.selectedCharacterId == 'astrid'
                    ? CharacterId.astrid
                    : CharacterId.loke,
            reaction: _characterCelebrate
                ? CharacterReaction.celebrate
                : CharacterReaction.idle,
            reactionNonce: _characterCelebrate ? 1 : 0,
            height: 112.h,
            equippedItems: activeUser?.equippedItems,
            customItemOffsets: activeUser?.customItemOffsets,
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
              child: Image.asset(
                'assets/images/ui/ic_ui_star.png',
                width: 100.w,
                height: 100.w,
                cacheWidth: starCacheSize,
                cacheHeight: starCacheSize,
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
                highlightColor: themeColors.progressCompletedColor,
              ),
              PlayfulStatPill(
                label: 'Poäng',
                value: totalPoints.toString(),
                icon: Icons.star_rounded,
                highlightColor: themeColors.primaryActionColor,
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
        if (userState.newlyUnlockedItem != null) ...[
          _ItemUnlockedBanner(item: userState.newlyUnlockedItem!),
          const SizedBox(height: AppConstants.largePadding),
        ],
        if (userState.lastLevelUp != null) ...[
          _LevelUpBanner(event: userState.lastLevelUp!),
          const SizedBox(height: AppConstants.largePadding),
        ],
        statsCard,
        if (hasStoryCheckpoint) ...[
          const SizedBox(height: AppConstants.largePadding),
          _buildStoryCheckpointPanel(
            context,
            panelColor: panelColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            storyProgress: storyProgress,
            questCompletion: questCompletion,
            onContinueStory: _goToStoryMapFromResults,
          ),
        ],
        const SizedBox(height: AppConstants.largePadding),
        PlayfulPanel(
          hero: !hasStoryCheckpoint,
          backgroundColor: panelColor,
          highlightColor: themeColors.secondaryActionColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlayfulSectionHeading(
                title: hasStoryCheckpoint ? 'Mer att prova' : 'Kör mer?',
              ),
              SizedBox(height: AppConstants.defaultPadding.h),
              if (hasStoryCheckpoint)
                OutlinedButton.icon(
                  onPressed: () => _startRoundFromResults(
                    session: session,
                    hardest: hardest,
                    useFocusedMiniPass: false,
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Spela igen'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _startRoundFromResults(
                    session: session,
                    hardest: hardest,
                    useFocusedMiniPass: false,
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Spela igen'),
                ),
              SizedBox(height: AppConstants.defaultPadding.h),
              if (hasStoryCheckpoint)
                TextButton.icon(
                  onPressed: () => _startRoundFromResults(
                    session: session,
                    hardest: hardest,
                    useFocusedMiniPass: true,
                  ),
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('Snabbträna ⚡'),
                )
              else
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
      ],
    );

    return ConfettiOverlay(
      animate: _showConfetti,
      child: ThemedBackgroundScaffold(
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
      ),
    );
  }

  void _goHomeFromResults() {
    ref.read(userProvider.notifier).clearLastQuestCompletion();
    ref.read(userProvider.notifier).clearLastLevelUp();
    ref.read(audioServiceProvider).playHomeMusic();
    context.pushAndRemoveUntilSmooth(
      const HomeScreen(),
      (route) => false,
    );
  }

  void _goToStoryMapFromResults() {
    ref.read(userProvider.notifier).clearLastQuestCompletion();
    ref.read(userProvider.notifier).clearLastLevelUp();
    ref.read(audioServiceProvider).playMapOpenSound();
    ref.read(audioServiceProvider).playStoryMusic();
    context.pushAndRemoveUntilSmooth(
      const StoryMapScreen(),
      (route) => false,
    );
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

    final allowedOps = ref.read(parentSettingsProvider(user.userId));
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

      final miniQuestions = _ResultsPracticePlanner.focusedMiniPassQuestions(
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

    ref.read(audioServiceProvider).playQuizStartSound();
    ref.read(audioServiceProvider).playQuizMusic();
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
    final activeUser = ref.read(userProvider).activeUser;
    String charName = AppConstants.mascotName;
    if (activeUser != null && activeUser.selectedCharacterId.isNotEmpty) {
      final id = activeUser.selectedCharacterId;
      charName = id[0].toUpperCase() + id.substring(1);
    }
    return '$charName: $text';
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
    final themeColors = context.appThemeColors;
    final badgeCacheSize = imageCacheExtent(context, 48);

    return PlayfulPanel(
      hero: true,
      backgroundColor: panelColor,
      highlightColor: themeColors.primaryActionColor,
      padding: EdgeInsets.all(AppConstants.largePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (badgeTeaser.badgeImageAsset != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.asset(
                    badgeTeaser.badgeImageAsset!,
                    cacheWidth: badgeCacheSize,
                    cacheHeight: badgeCacheSize,
                  ),
                )
              else
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
    required VoidCallback onContinueStory,
  }) {
    final themeColors = context.appThemeColors;
    final scheme = Theme.of(context).colorScheme;
    final currentNode = storyProgress.currentNode;
    final reachedLandmark = currentNode?.landmark ?? 'nästa plats';
    final isEpisodeComplete = storyProgress.isEpisodeComplete;
    final panelTitle = isEpisodeComplete
        ? storyProgress.endingTitle
        : 'Nu nådde du $reachedLandmark!';
    final panelLead =
        isEpisodeComplete ? storyProgress.endingBody : 'Storyn gick vidare.';
    final nextTitle = isEpisodeComplete
        ? 'Episode 1 klar'
        : questCompletion.nextQuestTitle ?? storyProgress.currentObjectiveTitle;
    final nextBody =
        isEpisodeComplete ? storyProgress.endingBody : 'Nästa mål: $nextTitle';
    final storyButtonLabel =
        isEpisodeComplete ? 'Se episoden' : 'Fortsätt storyn';
    final storyButtonIcon =
        isEpisodeComplete ? Icons.map_rounded : Icons.explore_rounded;

    return PlayfulPanel(
      backgroundColor: panelColor,
      highlightColor: scheme.secondary,
      padding: EdgeInsets.all(AppConstants.largePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            panelTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: AppConstants.smallPadding.h),
          Text(
            panelLead,
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
                label: isEpisodeComplete ? 'Sista stopp' : 'Nu',
                title: reachedLandmark,
                body: isEpisodeComplete
                    ? questCompletion.completedQuestTitle
                    : questCompletion.completedQuestDescription,
                icon: Icons.place_rounded,
                color: scheme.secondary,
                onPrimary: onPrimary,
              );
              final nextCard = _StoryFocusCard(
                label: isEpisodeComplete ? 'Nu' : 'Sedan',
                title: nextTitle,
                body: nextBody,
                icon: Icons.flag_rounded,
                color: themeColors.progressNextColor,
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
          SizedBox(height: AppConstants.defaultPadding.h),
          ElevatedButton.icon(
            onPressed: onContinueStory,
            icon: Icon(storyButtonIcon),
            label: Text(storyButtonLabel),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
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
    String? badgeImageAsset;

    if (didUnlockSomething) {
      badgeEmoji = '🎁';
      badgeImageAsset = 'assets/images/ui/reward_chest.png';
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
      badgeImageAsset: badgeImageAsset,
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
}

class _BadgeTeaser {
  const _BadgeTeaser({
    required this.badgeEmoji,
    required this.badgeTitle,
    required this.badgeBody,
    required this.teaser,
    this.badgeImageAsset,
  });

  final String badgeEmoji;
  final String badgeTitle;
  final String badgeBody;
  final String teaser;
  final String? badgeImageAsset;
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

class _ItemUnlockedBanner extends StatelessWidget {
  const _ItemUnlockedBanner({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemCacheSize = imageCacheExtent(context, 56);
    return PlayfulPanel(
      hero: true,
      highlightColor: scheme.tertiary,
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.contain,
                cacheWidth: itemCacheSize,
                cacheHeight: itemCacheSize,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ny sak uppl\u00e5st!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kolla in din nya ${item.name} i garderoben.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
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

class _LevelUpBanner extends StatelessWidget {
  const _LevelUpBanner({required this.event});

  final LevelUpEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chestCacheSize = imageCacheExtent(context, 56);
    return PlayfulPanel(
      hero: true,
      highlightColor: scheme.primary,
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.asset(
                'assets/images/ui/reward_chest.png',
                fit: BoxFit.contain,
                cacheWidth: chestCacheSize,
                cacheHeight: chestCacheSize,
              ),
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

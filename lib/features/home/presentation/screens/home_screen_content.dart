part of 'home_screen.dart';

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _checkedOnboardingForUserId;
  String? _loadedReviewSummaryForUserId;
  bool _onboardingPushInFlight = false;
  CharacterReaction _mascotReaction = CharacterReaction.idle;
  int _mascotReactionNonce = 0;

  @override
  void initState() {
    super.initState();
    // Load existing users and start background music
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(userProvider.notifier);
      await notifier.loadUsers();

      if (!mounted) return;
      final activeUser = ref.read(userProvider).activeUser;
      if (activeUser != null) {
        _checkUserData(activeUser.userId);
      }

      // Start home music when the child lands on the main screen.
      ref.read(audioServiceProvider).playHomeMusic();

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

    final done = ref.read(onboardingCompletionProvider(userId));

    if (!done) {
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

  void _openStoryMap() {
    final audio = ref.read(audioServiceProvider);
    audio.playMapOpenSound();
    audio.playStoryMusic();

    context.pushSmooth(const StoryMapScreen()).then((_) {
      if (!mounted) return;
      ref.read(audioServiceProvider).playHomeMusic();
    });
  }

  void _openQuizScreen() {
    final audio = ref.read(audioServiceProvider);
    audio.playQuizStartSound();
    audio.playQuizMusic();

    context.pushSmooth(const QuizScreen()).then((_) {
      if (!mounted) return;
      ref.read(audioServiceProvider).playHomeMusic();
    });
  }

  Future<void> _openAudioControls(UserProgress user) async {
    final audio = ref.read(audioServiceProvider);
    var soundLevel = AppAudioLevel.fromVolume(
      audio.soundVolume,
      enabled: user.soundEnabled,
    );
    var soundSliderValue = _sliderValueForAudioLevel(soundLevel);
    var musicLevel = AppAudioLevel.fromVolume(
      audio.musicVolume,
      enabled: user.musicEnabled,
    );
    var musicSliderValue = _sliderValueForAudioLevel(musicLevel);
    var isApplying = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final themeColors = context.appThemeColors;
            final onPrimary = theme.colorScheme.onPrimary;
            final subtleOnPrimary =
                onPrimary.withValues(alpha: AppOpacities.subtleText);

            Future<void> updateSoundLevel(AppAudioLevel level) async {
              if (isApplying) return;

              setModalState(() {
                isApplying = true;
                soundLevel = level;
                soundSliderValue = _sliderValueForAudioLevel(level);
              });

              try {
                await ref.read(userProvider.notifier).setSoundLevel(level);
                if (level != AppAudioLevel.off) {
                  await ref.read(audioServiceProvider).playClickSound();
                }
              } finally {
                if (dialogContext.mounted) {
                  setModalState(() {
                    isApplying = false;
                  });
                }
              }
            }

            Future<void> updateMusicLevel(AppAudioLevel level) async {
              if (isApplying) return;

              setModalState(() {
                isApplying = true;
                musicLevel = level;
                musicSliderValue = _sliderValueForAudioLevel(level);
              });

              try {
                await ref.read(userProvider.notifier).setMusicLevel(level);
              } finally {
                if (dialogContext.mounted) {
                  setModalState(() {
                    isApplying = false;
                  });
                }
              }
            }

            void previewSoundSlider(double value) {
              if (isApplying) return;
              setModalState(() {
                soundSliderValue = value;
              });
            }

            void previewMusicSlider(double value) {
              if (isApplying) return;
              setModalState(() {
                musicSliderValue = value;
              });
            }

            Future<void> commitSoundSlider(double value) async {
              final level = _audioLevelForSliderValue(value);
              if (level == soundLevel) {
                setModalState(() {
                  soundSliderValue = _sliderValueForAudioLevel(soundLevel);
                });
                return;
              }
              await updateSoundLevel(level);
            }

            Future<void> commitMusicSlider(double value) async {
              final level = _audioLevelForSliderValue(value);
              if (level == musicLevel) {
                setModalState(() {
                  musicSliderValue = _sliderValueForAudioLevel(musicLevel);
                });
                return;
              }
              await updateMusicLevel(level);
            }

            return AlertDialog(
              key: const Key('home_audio_dialog'),
              title: Text(
                'Ljud',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dra för att välja nivå.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtleOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _HomeAudioLevelPicker(
                      title: 'Ljudeffekter',
                      subtitle: 'Klick och jubel',
                      keyPrefix: 'home_audio_sound',
                      icon: Icons.celebration_rounded,
                      toneColor: themeColors.secondaryActionColor,
                      sliderValue: soundSliderValue,
                      isBusy: isApplying,
                      onChanged: previewSoundSlider,
                      onChangeEnd: commitSoundSlider,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _HomeAudioLevelPicker(
                      title: 'Musik',
                      subtitle: 'Bakgrundsmusik',
                      keyPrefix: 'home_audio_music',
                      icon: Icons.music_note_rounded,
                      toneColor: themeColors.primaryActionColor,
                      sliderValue: musicSliderValue,
                      isBusy: isApplying,
                      onChanged: previewMusicSlider,
                      onChangeEnd: commitMusicSlider,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isApplying
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Klar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _sliderValueForAudioLevel(AppAudioLevel level) {
    return level.index.toDouble();
  }

  AppAudioLevel _audioLevelForSliderValue(double value) {
    final index = value.round().clamp(0, AppAudioLevel.values.length - 1);
    return AppAudioLevel.values[index];
  }

  IconData _primaryButtonIcon(HomePrimaryAction action) {
    return switch (action) {
      HomePrimaryAction.resumeQuiz => Icons.play_circle_fill_rounded,
      HomePrimaryAction.openStoryMap => Icons.map_rounded,
      HomePrimaryAction.startStoryQuest => Icons.explore_rounded,
      HomePrimaryAction.startFreePlay => Icons.play_arrow_rounded,
    };
  }

  void _startOrResumePrimaryQuiz({
    required UserProgress user,
    required Set<OperationType> allowedOps,
  }) {
    final didResume =
        ref.read(quizProvider.notifier).resumeLatestSessionForUser(
              userId: user.userId,
            );

    if (didResume) {
      setState(() {
        _mascotReaction = CharacterReaction.screenChange;
        _mascotReactionNonce++;
      });
      _openQuizScreen();
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
    _openQuizScreen();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      userProvider.select((state) => state.activeUser?.userId),
      (previousUserId, nextUserId) {
        if (nextUserId != null) {
          _checkUserData(nextUserId);
        }
      },
    );

    final homeModel = ref.watch(homeReadModelProvider);
    final user = homeModel.activeUser;
    final storyProgress = homeModel.storyProgress;

    final themeCfg = ref.watch(appThemeConfigProvider);
    final backgroundAsset = themeCfg.backgroundAsset;
    final questHeroAsset = themeCfg.questHeroAsset;
    final characterAsset = themeCfg.characterAsset;
    final themeColors = context.appThemeColors;
    final accentColor = themeColors.accentColor;

    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

    final allowedOps = homeModel.allowedOps;
    final hasStoryQuest = homeModel.hasStoryQuest;
    final heroEyebrow = homeModel.heroEyebrow;
    final heroTitle = homeModel.heroTitle;
    final heroSubtitle = homeModel.heroSubtitle;
    final primaryButtonLabel = homeModel.primaryButtonLabel;
    final primaryButtonIcon = _primaryButtonIcon(homeModel.primaryAction);

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

          final questHeroLogicalWidth = isWideScreen
              ? constraints.maxWidth.clamp(0.0, 800.0).toDouble()
              : constraints.maxWidth;
          final questHeroCacheWidth =
              imageCacheExtent(context, questHeroLogicalWidth);
          final questHeroCacheHeight = imageCacheExtent(context, 110);
          final homeLogoCacheHeight = imageCacheExtent(context, 120);
          final homeActionIconCacheSize = imageCacheExtent(context, 48);

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
                                  cacheHeight: homeLogoCacheHeight,
                                ),
                                if (user != null)
                                  Positioned(
                                    left: 0,
                                    child: IconButton(
                                      key: const Key('home_audio_button'),
                                      tooltip: 'Ljud',
                                      onPressed: () => _openAudioControls(user),
                                      iconSize: 42,
                                      icon: Icon(
                                        Icons.volume_up_rounded,
                                        color: onPrimary,
                                      ),
                                    ),
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
                                        cacheWidth: homeActionIconCacheSize,
                                        cacheHeight: homeActionIconCacheSize,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PlayfulSectionHeading(
                            center: true,
                            eyebrow: heroEyebrow,
                            title: heroTitle,
                            subtitle: heroSubtitle,
                          ),
                          if (user != null) ...[
                            const SizedBox(height: AppConstants.largePadding),
                            ElevatedButton.icon(
                              key: const Key('primary_play_button'),
                              onPressed: () {
                                if (homeModel.primaryAction ==
                                    HomePrimaryAction.openStoryMap) {
                                  _openStoryMap();
                                  return;
                                }

                                _startOrResumePrimaryQuiz(
                                  user: user,
                                  allowedOps: allowedOps,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(64),
                              ),
                              icon: Icon(primaryButtonIcon, size: 32),
                              label: Text(
                                primaryButtonLabel,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                if (hasStoryQuest && storyProgress != null)
                                  PlayfulInfoChip(
                                    label: storyProgress.isEpisodeComplete
                                        ? 'Episod klar'
                                        : storyProgress.actLabel,
                                    icon: Icons.explore_rounded,
                                    color: themeColors.secondaryActionColor,
                                  ),
                                if (homeModel.isDailyChallengeCompleted)
                                  PlayfulInfoChip(
                                    label: 'Dagens runda klar',
                                    icon: Icons.check_circle_rounded,
                                    color: themeColors.progressCompletedColor,
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            RepaintBoundary(
                              child: CampSceneView(
                                mascotReaction: _mascotReaction,
                                mascotReactionNonce: _mascotReactionNonce,
                                isWideScreen: isWideScreen,
                              ),
                            ),
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
                          'Välj räknesätt',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.defaultPadding),
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
                    if (user != null) ...[
                      const SizedBox(height: AppConstants.largePadding),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mer att göra',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: mutedOnPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      if (hasStoryQuest && storyProgress != null)
                        HomeStoryProgressCard(
                          story: storyProgress,
                          heroAsset: questHeroAsset,
                          backgroundAsset: backgroundAsset,
                          characterAsset: characterAsset,
                          primaryActionColor: themeColors.primaryActionColor,
                          secondaryActionColor:
                              themeColors.secondaryActionColor,
                          accentColor: accentColor,
                          onPrimary: onPrimary,
                          mutedOnPrimary: mutedOnPrimary,
                          faintOnPrimary: onPrimary.withValues(
                            alpha: AppOpacities.faintText,
                          ),
                          cacheWidth: questHeroCacheWidth,
                          cacheHeight: questHeroCacheHeight,
                          onStartQuest: () {
                            if (storyProgress.isEpisodeComplete) {
                              _openStoryMap();
                              return;
                            }

                            _startQuiz(
                              operationType:
                                  homeModel.questStatus!.quest.operation,
                              difficulty:
                                  homeModel.questStatus!.quest.difficulty,
                            );
                          },
                          onOpenMap: _openStoryMap,
                        ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      RepaintBoundary(
                        child: HomeBadgeAlbum(
                          achievementIds: user.achievements,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.defaultPadding),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperationCard(
    BuildContext context,
    OperationType operation,
    IconData icon,
    String? assetPath,
  ) {
    final themeColors = context.appThemeColors;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final cardContent = PlayfulPanel(
      key: Key('operation_card_${operation.name}'),
      onTap: () => _startQuiz(
        operationType: operation,
        difficulty: DifficultyLevel.easy,
      ),
      highlightColor: themeColors.primaryActionColor,
      padding: const EdgeInsets.all(AppConstants.microSpacing6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 170 || constraints.maxWidth < 160;
          final iconBubbleSize = compact ? 44.0 : 72.0;
          final iconSize = compact ? 24.0 : AppConstants.largeIconSize;
          final imageIconCacheSize = imageCacheExtent(
            context,
            iconBubbleSize * 0.7,
          );

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconBubbleSize,
                  height: iconBubbleSize,
                  decoration: BoxDecoration(
                    color:
                        themeColors.primaryActionColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeColors.primaryActionColor.withValues(
                        alpha: 0.32,
                      ),
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
                              cacheWidth: imageIconCacheSize,
                              cacheHeight: imageIconCacheSize,
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
            ),
          );
        },
      ),
    );

    return Semantics(
      button: true,
      label: 'Starta ${operation.displayName}',
      child: ExcludeSemantics(
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
}

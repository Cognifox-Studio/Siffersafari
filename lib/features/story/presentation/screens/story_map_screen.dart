import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/missing_number_settings_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/providers/word_problems_settings_provider.dart';
import 'package:siffersafari/core/theme/app_theme_colors.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/image_cache_size.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/features/home/presentation/screens/home_screen.dart';
import 'package:siffersafari/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

part 'story_map_screen__content_part.dart';
part 'story_map_screen__map_canvas_part.dart';
part 'story_map_screen__read_model_part.dart';

class StoryMapScreen extends ConsumerWidget {
  const StoryMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(storyProgressProvider);
    final userState = ref.watch(userProvider);
    final themeCfg = ref.watch(appThemeConfigProvider);
    final size = MediaQuery.sizeOf(context);
    final themeColors = context.appThemeColors;
    final accentColor = themeColors.accentColor;
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final layout = AdaptiveLayoutInfo.fromConstraints(
      BoxConstraints(maxWidth: size.width, maxHeight: size.height),
    );

    if (story == null) {
      return ThemedBackgroundScaffold(
        appBar: AppBar(
          title: const Text('Djungelkartan'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: PlayfulPanel(
                hero: true,
                highlightColor: accentColor,
                child: const PlayfulSectionHeading(
                  title: 'Ingen karta än',
                  subtitle: 'Spela först.',
                  center: true,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final mapModel = _StoryMapReadModel.from(story);
    final currentNode = mapModel.currentNode;
    final nextNode = mapModel.nextNode;
    final completedColor = themeColors.progressCompletedColor;
    final currentColor = themeColors.progressCurrentColor;
    final nextColor = themeColors.progressNextColor;

    void openQuizFromMap() {
      final audio = ref.read(audioServiceProvider);
      audio.playQuizStartSound();
      audio.playQuizMusic();

      context.pushSmooth(const QuizScreen()).then((_) {
        if (!context.mounted) return;
        ref.read(audioServiceProvider).playStoryMusic();
      });
    }

    void startCurrentQuest() {
      if (story.isEpisodeComplete) {
        ref.read(audioServiceProvider).playHomeMusic();
        context.pushAndRemoveUntilSmooth(
          const HomeScreen(),
          (route) => false,
        );
        return;
      }

      final user = userState.activeUser;
      final quest = userState.questStatus?.quest;
      final targetNode = currentNode ?? nextNode;

      if (user == null || (quest == null && targetNode == null)) {
        Navigator.of(context).maybePop();
        return;
      }

      ref.read(audioServiceProvider).playClickSound();
      ref.read(userProvider.notifier).clearQuestNotice();

      final effectiveAgeGroup = DifficultyConfig.effectiveAgeGroup(
        fallback: user.ageGroup,
        gradeLevel: user.gradeLevel,
      );

      final requestedDifficulty = quest?.difficulty ?? targetNode!.difficulty;
      final effectiveDifficulty = DifficultyConfig.effectiveDifficulty(
        fallback: requestedDifficulty,
        gradeLevel: user.gradeLevel,
      );

      final steps = DifficultyConfig.buildDifficultySteps(
        storedSteps: user.operationDifficultySteps,
        defaultDifficulty: effectiveDifficulty,
        gradeLevel: user.gradeLevel,
      );

      final operationType = quest?.operation ?? targetNode!.operation;
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
          );

      unawaited(
        ref.read(appAnalyticsProvider).logEvent(
          name: 'quiz_started',
          userId: user.userId,
          properties: {
            'operation': operationType.name,
            'difficulty': effectiveDifficulty.name,
            'isDailyChallenge': false,
            'gradeLevel': user.gradeLevel,
            'source': 'story_map',
          },
        ),
      );

      openQuizFromMap();
    }

    return ThemedBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Djungelkartan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout.isExpandedWidth ? 860 : 720,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PlayfulSectionHeading(
                  title: 'Djungelkartan',
                  subtitle: mapModel.headingSubtitle,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _MapHeroCard(
                  story: story,
                  heroAsset: themeCfg.questHeroAsset,
                  backgroundAsset: themeCfg.backgroundAsset,
                  completedColor: completedColor,
                  currentColor: currentColor,
                  accentColor: accentColor,
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                  subtleOnPrimary: subtleOnPrimary,
                ),
                const SizedBox(height: AppConstants.largePadding),
                _NowAndNextPanel(
                  story: story,
                  currentNode: currentNode,
                  nextNode: nextNode,
                  accentColor: accentColor,
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                  onContinue: startCurrentQuest,
                ),
                if (mapModel.hasNextBiomePreview) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  _LockedBiomeTeaser(
                    biome: story.nextBiome!,
                    accentColor: accentColor,
                    onPrimary: onPrimary,
                    mutedOnPrimary: mutedOnPrimary,
                  ),
                ],
                const SizedBox(height: AppConstants.defaultPadding),
                PlayfulPanel(
                  backgroundColor:
                      onPrimary.withValues(alpha: AppOpacities.panelFill),
                  highlightColor: accentColor,
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Resten av stigen',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      iconColor: accentColor,
                      collapsedIconColor: accentColor,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppConstants.microSpacing6,
                            right: AppConstants.microSpacing6,
                            bottom: AppConstants.microSpacing6,
                          ),
                          child: _NearbyStopsPanel(
                            story: story,
                            currentNode: currentNode,
                            nextNode: nextNode,
                            completedColor: completedColor,
                            currentColor: currentColor,
                            nextColor: nextColor,
                            accentColor: accentColor,
                            onPrimary: onPrimary,
                            mutedOnPrimary: mutedOnPrimary,
                            subtleOnPrimary: subtleOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

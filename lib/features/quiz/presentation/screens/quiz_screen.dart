import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/text_to_speech_service_provider.dart';
import 'package:siffersafari/core/providers/tts_enabled_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/core/services/text_to_speech_service.dart';
import 'package:siffersafari/core/theme/app_theme_colors.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/app/navigation/app_navigator.dart';
import 'package:siffersafari/features/quiz/presentation/dialogs/feedback_dialog.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/answer_button.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/question_card.dart';
import 'package:siffersafari/presentation/widgets/progress_indicator_bar.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  DateTime? _questionStartTime;
  int? _selectedAnswer;
  bool _feedbackDialogVisible = false;
  bool _ttsSpeaking = false;
  late final TextToSpeechService _textToSpeechService;
  ProviderSubscription<String?>? _autoReadSubscription;
  late final AudioService _audioService;
  // Memoized answer options keyed by question id to prevent reshuffle on rebuild.
  String? _cachedQuestionId;
  List<int>? _cachedOptions;

  List<int> _optionsForQuestion(Question question) {
    if (_cachedQuestionId != question.id) {
      _cachedQuestionId = question.id;
      _cachedOptions = question.allAnswerOptions;
    }
    return _cachedOptions!;
  }

  @override
  void initState() {
    super.initState();
    _textToSpeechService = ref.read(textToSpeechServiceProvider);
    _audioService = ref.read(audioServiceProvider);
    _textToSpeechService.onSpeakingChanged = (speaking) {
      if (!mounted) return;
      setState(() => _ttsSpeaking = speaking);
      // Duck quiz music while TTS speaks so narration stays audible (#74).
      _audioService.setMusicVolume(speaking ? 0.2 : 1.0);
    };
    _questionStartTime = DateTime.now();

    // Åk 1–2 cannot read a word problem yet, so the question is read out loud
    // as it arrives rather than waiting for the child to find a button.
    // `fireImmediately` covers the first question, which is normally already in
    // the session by the time this screen mounts.
    _autoReadSubscription = ref.listenManual<String?>(
      quizProvider.select((state) => state.session?.currentQuestion?.id),
      (_, next) => _autoReadQuestion(next),
      fireImmediately: true,
    );
  }

  /// Reads [questionId]'s prompt aloud when the child's profile should hear it.
  ///
  /// Deliberately silent unless every condition holds: the profile is Åk 1–2
  /// (older grades read the question themselves -- there the button is the
  /// affordance, not the default), read-aloud is enabled for the profile, and
  /// the profile's own sound is on, so a muted profile stays muted.
  void _autoReadQuestion(String? questionId) {
    if (questionId == null || !mounted) return;
    final user = ref.read(userProvider).activeUser;
    if (user == null || !user.soundEnabled) return;
    if ((user.gradeLevel ?? 99) > 2) return;
    if (!ref.read(ttsEnabledProvider(user.userId))) return;
    final question = ref.read(quizProvider).session?.currentQuestion;
    if (question == null || question.id != questionId) return;
    final text = question.displayQuestionText.trim();
    if (text.isEmpty) return;
    unawaited(_textToSpeechService.speakQuestion(text));
  }

  @override
  void dispose() {
    _autoReadSubscription?.close();
    _textToSpeechService.onSpeakingChanged = null;
    unawaited(_textToSpeechService.stop());
    _audioService.setMusicVolume(1.0);
    super.dispose();
  }

  Future<void> _handleClose() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final onPrimary = Theme.of(ctx).colorScheme.onPrimary;
        return AlertDialog(
          title: Text(
            'Avsluta quiz?',
            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          content: Text(
            'Rundan sparas inte. Du kan börja om när du vill.',
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Fortsätt spela'),
            ),
            TextButton(
              key: const Key('confirm_quiz_abandon'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Avsluta'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    unawaited(_textToSpeechService.stop());
    final quizState = ref.read(quizProvider);
    final session = quizState.session;
    final user = ref.read(userProvider).activeUser;
    if (session != null) {
      unawaited(
        ref.read(appAnalyticsProvider).logEvent(
          name: 'quiz_abandoned',
          userId: user?.userId,
          properties: {
            'question_index': session.currentQuestionIndex,
            'total_questions': session.totalQuestions,
            'operation': session.operationType.name,
          },
        ),
      );
      if (user != null) {
        ref.read(quizProvider.notifier).cancelSession(user.userId);
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _handleAnswerSelected(int answer) {
    if (_selectedAnswer != null) return;

    unawaited(_textToSpeechService.stop());
    ref.read(audioServiceProvider).playClickSound();

    setState(() {
      _ttsSpeaking = false;
      _selectedAnswer = answer;
    });

    final responseTime = DateTime.now().difference(_questionStartTime!);
    final user = ref.read(userProvider).activeUser;

    if (user == null) return;

    final effectiveAgeGroup = DifficultyConfig.effectiveAgeGroup(
      fallback: user.ageGroup,
      gradeLevel: user.gradeLevel,
    );

    final question = ref.read(quizProvider).session?.currentQuestion;
    final isCorrect = question?.isCorrect(answer) ?? false;
    if (user.soundEnabled) {
      if (isCorrect) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    }

    ref.read(quizProvider.notifier).submitAnswer(
          answer: answer,
          responseTime: responseTime,
          ageGroup: effectiveAgeGroup,
        );
  }

  void _handleNextQuestion() {
    unawaited(_textToSpeechService.stop());
    final quizState = ref.read(quizProvider);
    final session = quizState.session;

    if (session == null) return;

    final nextIndex = session.currentQuestionIndex + 1;
    if (nextIndex >= session.totalQuestions) {
      ref.read(quizProvider.notifier).clearFeedback();
      setState(() {
        _selectedAnswer = null;
      });
      AppNavigator.replaceWithResults(context);
      return;
    }

    ref.read(quizProvider.notifier).advanceToNextQuestion();
    setState(() {
      _selectedAnswer = null;
      _questionStartTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final session = quizState.session;
    final activeUser = ref.watch(userProvider).activeUser;
    final ttsEnabled = activeUser != null
        ? ref.watch(ttsEnabledProvider(activeUser.userId))
        : false;
    // A muted profile is muted: no read-aloud button, no automatic reading.
    // The profile's own sound setting is the contract, so it wins over the
    // parent dashboard's read-aloud preference.
    final readAloudAvailable = ttsEnabled &&
        switch (activeUser) {
          final user? => user.soundEnabled,
          _ => false,
        };
    // Åk 1–2 get the roomier read-aloud button; it is their main access path to
    // the question rather than a convenience.
    final youngLearner = (activeUser?.gradeLevel ?? 99) <= 2;

    final themeColors = context.appThemeColors;
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;

    final primaryActionColor = themeColors.primaryActionColor;
    final accentColor = themeColors.accentColor;
    final cardColor = themeColors.cardColor;
    final cardBorderColor = themeColors.panelBorderColor;
    final lightTextColor = onPrimary;
    final mutedTextColor = onPrimary.withValues(alpha: AppOpacities.mutedText);

    ref.listen(
      quizProvider.select((state) => state.session),
      (prev, session) {
        if (session == null || session.currentQuestion == null) {
          AppNavigator.resetStackToHome(context);
        }
      },
    );

    ref.listen(
      quizProvider.select((state) => state.feedback),
      (prev, feedback) {
        if (feedback != null &&
            _selectedAnswer != null &&
            !_feedbackDialogVisible) {
          _feedbackDialogVisible = true;

          final hapticUser = ref.read(userProvider).activeUser;
          if (hapticUser?.soundEnabled ?? false) {
            if (feedback.isCorrect) {
              HapticFeedback.mediumImpact();
            } else {
              HapticFeedback.heavyImpact();
            }
          }

          final currentSession = ref.read(quizProvider).session;
          final isLastQuestion = currentSession != null &&
              currentSession.currentQuestionIndex >=
                  currentSession.totalQuestions - 1;

          // Speak the feedback only when the profile itself is unmuted. This
          // used to check `ttsEnabled` alone, which was harmless while
          // read-aloud was off by default -- now that Åk 1-2 default to it, a
          // muted profile would have started talking.
          if (ttsEnabled && (hapticUser?.soundEnabled ?? false)) {
            unawaited(
              _textToSpeechService.speakFeedback(
                _feedbackAnnouncement(feedback),
              ),
            );
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.82),
            builder: (_) => FeedbackDialog(
              feedback: feedback,
              onContinue: _handleNextQuestion,
              continueLabel: isLastQuestion ? 'Se resultat' : 'Nästa',
              continueButtonColor: primaryActionColor,
              dialogBackgroundColor: cardColor,
              messageTextColor: mutedTextColor,
            ),
          ).whenComplete(() {
            _feedbackDialogVisible = false;
          });
        }
      },
    );

    if (session == null || session.currentQuestion == null) {
      return const ThemedBackgroundScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final question = session.currentQuestion!;
    final progress =
        (session.currentQuestionIndex + 1) / session.totalQuestions;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_handleClose());
      },
      child: ThemedBackgroundScaffold(
      appBar: AppBar(
        title: Semantics(
          liveRegion: true,
          label:
              'Fråga ${session.currentQuestionIndex + 1} av ${session.totalQuestions}',
          child: Text(
            'Fråga ${session.currentQuestionIndex + 1}/${session.totalQuestions}',
            style: TextStyle(color: onPrimary),
          ),
        ),
        leading: IconButton(
          tooltip: 'Stäng quiz',
          icon: Icon(Icons.close, color: onPrimary),
          onPressed: () => unawaited(_handleClose()),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = AdaptiveLayoutInfo.fromConstraints(constraints);
          final useSplitLayout = layout.isExpandedWidth ||
              (layout.isLandscape && !layout.isCompactWidth);
          final maxContentWidth = useSplitLayout
              ? layout.contentMaxWidth
              : (layout.isMediumWidth ? 760.0 : double.infinity);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: useSplitLayout
                  ? _buildLandscapeLayout(
                      context,
                      question: question,
                      currentQuestionNumber: session.currentQuestionIndex + 1,
                      totalQuestions: session.totalQuestions,
                      operationType: session.operationType,
                      progress: progress,
                      primaryActionColor: primaryActionColor,
                      accentColor: accentColor,
                      cardColor: cardColor,
                      cardBorderColor: cardBorderColor,
                      lightTextColor: lightTextColor,
                      mutedTextColor: mutedTextColor,
                      showReadAloud: readAloudAvailable,
                      youngLearner: youngLearner,
                      onPrimary: onPrimary,
                      layout: layout,
                    )
                  : _buildPortraitLayout(
                      context,
                      question: question,
                      currentQuestionNumber: session.currentQuestionIndex + 1,
                      totalQuestions: session.totalQuestions,
                      operationType: session.operationType,
                      progress: progress,
                      primaryActionColor: primaryActionColor,
                      accentColor: accentColor,
                      cardColor: cardColor,
                      cardBorderColor: cardBorderColor,
                      lightTextColor: lightTextColor,
                      mutedTextColor: mutedTextColor,
                      showReadAloud: readAloudAvailable,
                      youngLearner: youngLearner,
                      onPrimary: onPrimary,
                      layout: layout,
                    ),
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context, {
    required Question question,
    required int currentQuestionNumber,
    required int totalQuestions,
    required OperationType operationType,
    required double progress,
    required Color primaryActionColor,
    required Color accentColor,
    required Color cardColor,
    required Color cardBorderColor,
    required Color lightTextColor,
    required Color mutedTextColor,
    required bool showReadAloud,
    required bool youngLearner,
    required Color onPrimary,
    required AdaptiveLayoutInfo layout,
  }) {
    final questionFlex = layout.isShortHeight ? 5 : 6;
    final answersFlex = layout.isShortHeight ? 4 : 5;
    final answersTopPadding = layout.isShortHeight
        ? AppConstants.smallPadding.h
        : AppConstants.defaultPadding.h;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: ProgressIndicatorBar(
            progress: progress,
            currentQuestion: currentQuestionNumber,
            totalQuestions: totalQuestions,
            valueColor: accentColor,
            backgroundColor:
                onPrimary.withValues(alpha: AppOpacities.progressTrack),
          ),
        ),
        if (showReadAloud)
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding.w),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildSpeakButton(
                context,
                question,
                largeTarget: youngLearner,
              ),
            ),
          ),
        SizedBox(height: AppConstants.smallPadding.h),
        Expanded(
          flex: questionFlex,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: QuestionCard(
              key: ValueKey(question.id),
              question: question,
              cardColor: cardColor,
              shadowColor: primaryActionColor,
              questionTextColor: lightTextColor,
              subtitleTextColor: mutedTextColor,
              borderColor: cardBorderColor,
            ),
          ),
        ),
        Expanded(
          flex: answersFlex,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.defaultPadding.w,
              answersTopPadding,
              AppConstants.defaultPadding.w,
              AppConstants.defaultPadding.w,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildAnswerButtons(context, question),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context, {
    required Question question,
    required int currentQuestionNumber,
    required int totalQuestions,
    required OperationType operationType,
    required double progress,
    required Color primaryActionColor,
    required Color accentColor,
    required Color cardColor,
    required Color cardBorderColor,
    required Color lightTextColor,
    required Color mutedTextColor,
    required bool showReadAloud,
    required bool youngLearner,
    required Color onPrimary,
    required AdaptiveLayoutInfo layout,
  }) {
    final questionFlex = layout.isExpandedWidth ? 62 : 58;
    final sideFlex = 100 - questionFlex;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: ProgressIndicatorBar(
            progress: progress,
            currentQuestion: currentQuestionNumber,
            totalQuestions: totalQuestions,
            valueColor: accentColor,
            backgroundColor:
                onPrimary.withValues(alpha: AppOpacities.progressTrack),
          ),
        ),
        if (showReadAloud)
          Padding(
            padding: EdgeInsets.only(
              left: AppConstants.defaultPadding.w,
              right: AppConstants.defaultPadding.w,
              bottom: AppConstants.smallPadding.h,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildSpeakButton(
                context,
                question,
                largeTarget: youngLearner,
              ),
            ),
          ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: questionFlex,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultPadding.w,
                    right: AppConstants.smallPadding.w,
                    bottom: AppConstants.defaultPadding.h,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: QuestionCard(
                      key: ValueKey(question.id),
                      question: question,
                      cardColor: cardColor,
                      shadowColor: primaryActionColor,
                      questionTextColor: lightTextColor,
                      subtitleTextColor: mutedTextColor,
                      borderColor: cardBorderColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: sideFlex,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppConstants.smallPadding.w,
                    right: AppConstants.defaultPadding.w,
                    bottom: AppConstants.defaultPadding.h,
                  ),
                  child: _buildAnswerButtons(context, question),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButtons(BuildContext context, Question question) {
    final themeColors = context.appThemeColors;
    final idleButtonColor = themeColors.primaryActionColor;
    final selectedButtonColor = themeColors.secondaryActionColor;
    final buttonDisabledColor = themeColors.disabledBackgroundColor;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final options = _optionsForQuestion(question);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double spacingH = AppConstants.smallPadding.h;
        // Två rader
        final double calculatedHeight =
            ((availableHeight - spacingH) / 2).clamp(
          constraints.maxHeight < 360 ? 56.0 : AppConstants.answerButtonHeight,
          100.0,
        );

        final grade = ref.watch(userProvider).activeUser?.gradeLevel;
        final holdToConfirm = grade != null && grade <= 2;

        final children = options.map((answer) {
          final isSelected = _selectedAnswer == answer;
          final isCorrect = question.correctAnswer == answer;
          final showResult = _selectedAnswer != null;

          final button = AnswerButton(
            answer: answer,
            isSelected: isSelected,
            isCorrect: showResult ? isCorrect : null,
            selectedBackgroundColor: selectedButtonColor,
            idleBackgroundColor: idleButtonColor,
            idleTextColor: onPrimary,
            disabledBackgroundColor: buttonDisabledColor,
            minHeight: calculatedHeight,
            requireHoldToConfirm: holdToConfirm,
            onPressed: () => _handleAnswerSelected(answer),
          );

          final spacing = AppConstants.smallPadding.w;
          final itemWidth = (constraints.maxWidth - spacing) / 2;
          return SizedBox(
            width: itemWidth,
            height: calculatedHeight,
            child: button,
          );
        }).toList(growable: false);

        return Wrap(
          spacing: AppConstants.smallPadding.w,
          runSpacing: AppConstants.smallPadding.h,
          children: children,
        );
      },
    );
  }

  Widget _buildSpeakButton(
    BuildContext context,
    Question question, {
    required bool largeTarget,
  }) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return FilledButton.tonalIcon(
      key: const Key('quiz_tts_button'),
      onPressed: () {
        if (_ttsSpeaking) {
          unawaited(_textToSpeechService.stop());
          setState(() => _ttsSpeaking = false);
          return;
        }
        setState(() => _ttsSpeaking = true);
        unawaited(
          _textToSpeechService.speakQuestion(question.displayQuestionText),
        );
      },
      icon: Icon(
        _ttsSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
      ),
      label: Text(_ttsSpeaking ? 'Stoppa' : 'Läs upp'),
      style: FilledButton.styleFrom(
        foregroundColor: onPrimary,
        // Åk 1–2 get a full-size target; older grades keep the compact one so
        // the header does not grow for no reason.
        visualDensity:
            largeTarget ? VisualDensity.standard : VisualDensity.compact,
        minimumSize: largeTarget
            ? const Size(0, AppConstants.minTouchTargetSize)
            : null,
      ),
    );
  }

  String _feedbackAnnouncement(dynamic feedback) {
    final title = (feedback.title as String).trim();
    final parts = (feedback.message as String)
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(2)
        .toList(growable: false);

    return [title, ...parts].join('. ');
  }
}

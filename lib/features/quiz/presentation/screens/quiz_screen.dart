import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/home/presentation/screens/home_screen.dart';
import 'package:siffersafari/features/quiz/presentation/dialogs/feedback_dialog.dart';
import 'package:siffersafari/features/quiz/presentation/screens/results_screen.dart';
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
    _questionStartTime = DateTime.now();
  }

  void _handleClose() {
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
    }
    Navigator.of(context).pop();
  }

  void _handleAnswerSelected(int answer) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = answer;
    });

    final responseTime = DateTime.now().difference(_questionStartTime!);
    final user = ref.read(userProvider).activeUser;

    if (user == null) return;

    final effectiveAgeGroup = DifficultyConfig.effectiveAgeGroup(
      fallback: user.ageGroup,
      gradeLevel: user.gradeLevel,
    );

    ref.read(quizProvider.notifier).submitAnswer(
          answer: answer,
          responseTime: responseTime,
          ageGroup: effectiveAgeGroup,
        );
  }

  void _handleNextQuestion() {
    final quizState = ref.read(quizProvider);
    final session = quizState.session;

    if (session == null) return;

    final nextIndex = session.currentQuestionIndex + 1;
    if (nextIndex >= session.totalQuestions) {
      ref.read(quizProvider.notifier).clearFeedback();
      setState(() {
        _selectedAnswer = null;
      });
      context.pushReplacementSmooth(const ResultsScreen());
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
    final feedback = quizState.feedback;

    final themeCfg = ref.watch(appThemeConfigProvider);
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;

    final primaryActionColor = themeCfg.primaryActionColor;
    final accentColor = themeCfg.accentColor;
    final cardColor = themeCfg.cardColor;
    final cardBorderColor = onPrimary.withValues(alpha: AppOpacities.hudBorder);
    final lightTextColor = onPrimary;
    final mutedTextColor = onPrimary.withValues(alpha: AppOpacities.mutedText);

    if (session == null || session.currentQuestion == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.pushAndRemoveUntilSmooth(
          const HomeScreen(),
          (route) => false,
        );
      });

      return const ThemedBackgroundScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final question = session.currentQuestion!;
    final progress =
        (session.currentQuestionIndex + 1) / session.totalQuestions;
    final isLastQuestion =
        session.currentQuestionIndex >= session.totalQuestions - 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (feedback != null &&
          _selectedAnswer != null &&
          !_feedbackDialogVisible) {
        _feedbackDialogVisible = true;
        showDialog(
          context: context,
          barrierDismissible: false,
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
    });

    return ThemedBackgroundScaffold(
      appBar: AppBar(
        title: Text(
          'Fråga ${session.currentQuestionIndex + 1}/${session.totalQuestions}',
          style: TextStyle(color: onPrimary),
        ),
        leading: IconButton(
          tooltip: 'Stäng quiz',
          icon: Icon(Icons.close, color: onPrimary),
          onPressed: _handleClose,
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
                      onPrimary: onPrimary,
                      layout: layout,
                    ),
            ),
          );
        },
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
            valueColor: accentColor,
            backgroundColor:
                onPrimary.withValues(alpha: AppOpacities.progressTrack),
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
              child: SingleChildScrollView(
                child: _buildAnswerButtons(context, question),
              ),
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
            valueColor: accentColor,
            backgroundColor:
                onPrimary.withValues(alpha: AppOpacities.progressTrack),
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
                  child: SingleChildScrollView(
                    child: _buildAnswerButtons(context, question),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButtons(BuildContext context, Question question) {
    final themeCfg = ref.read(appThemeConfigProvider);
    final idleButtonColor = themeCfg.primaryActionColor;
    final selectedButtonColor = themeCfg.secondaryActionColor;
    final buttonDisabledColor = themeCfg.disabledBackgroundColor;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final options = _optionsForQuestion(question);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 520 ||
            (constraints.maxWidth >= 320 && constraints.maxHeight < 520);
        final buttonMinHeight = constraints.maxHeight < 360
            ? 56.0
            : AppConstants.answerButtonHeight;

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
            minHeight: buttonMinHeight,
            onPressed: () => _handleAnswerSelected(answer),
          );

          if (!useTwoColumns) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppConstants.smallPadding.h),
              child: button,
            );
          }

          final spacing = AppConstants.smallPadding.w;
          final itemWidth = (constraints.maxWidth - spacing) / 2;
          return SizedBox(width: itemWidth, child: button);
        }).toList(growable: false);

        if (!useTwoColumns) {
          return Column(children: children);
        }

        return Wrap(
          spacing: AppConstants.smallPadding.w,
          runSpacing: AppConstants.smallPadding.h,
          children: children,
        );
      },
    );
  }
}

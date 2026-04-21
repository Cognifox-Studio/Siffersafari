import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/constants/app_constants.dart';

class AnswerButton extends StatefulWidget {
  const AnswerButton({
    required this.answer,
    required this.onPressed,
    this.isSelected = false,
    this.isCorrect,
    this.selectedBackgroundColor,
    this.idleBackgroundColor,
    this.idleTextColor,
    this.disabledBackgroundColor,
    this.minHeight,
    super.key,
  });

  final int answer;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool? isCorrect;
  final Color? selectedBackgroundColor;
  final Color? idleBackgroundColor;
  final Color? idleTextColor;
  final Color? disabledBackgroundColor;
  final double? minHeight;

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _feedbackScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: AppConstants.microAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    // Correct: scale pop (0.92 → 1.12 → 1.0) via easeOutBack
    _feedbackScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.12), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.easeOutBack,
      ),
    );
    // Wrong: horizontal shake (damped sine) — computed inline in builder
  }

  @override
  void didUpdateWidget(covariant AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCorrect == null && widget.isCorrect != null) {
      _pressController.stop();
      _pressController.value = 0;
      _feedbackController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color textColor;
    String caption;

    if (widget.isCorrect != null) {
      // After answer is submitted
      if (widget.isCorrect!) {
        backgroundColor = AppColors.correctAnswer;
        textColor = scheme.onPrimary;
        caption = 'Rätt';
      } else if (widget.isSelected) {
        backgroundColor = AppColors.wrongAnswer;
        textColor = scheme.onPrimary;
        caption = 'Fel';
      } else {
        backgroundColor = widget.disabledBackgroundColor ?? scheme.surface;
        textColor = widget.idleTextColor ?? scheme.onSurface;
        caption = 'Svar';
      }
    } else {
      // Before answer is submitted
      backgroundColor = widget.isSelected
          ? (widget.selectedBackgroundColor ??
              Theme.of(context).colorScheme.primary)
          : (widget.idleBackgroundColor ?? scheme.surface);
      textColor = widget.isSelected
          ? scheme.onPrimary
          : (widget.idleTextColor ?? scheme.onSurface);
      caption = widget.isSelected ? 'Valt' : 'Tryck';
    }

    final isEnabled = widget.isCorrect == null;
    final String label;

    if (widget.isCorrect != null) {
      if (widget.isCorrect!) {
        label = 'Svar ${widget.answer}, rätt svar';
      } else if (widget.isSelected) {
        label = 'Svar ${widget.answer}, fel svar';
      } else {
        label = 'Svar ${widget.answer}';
      }
    } else {
      label = widget.isSelected
          ? 'Svar ${widget.answer}, valt'
          : 'Svar ${widget.answer}';
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pressController, _feedbackController]),
      builder: (context, child) {
        double combinedScale = _scaleAnimation.value;
        double dx = 0;
        if (widget.isCorrect != null && _feedbackController.value > 0) {
          if (widget.isCorrect!) {
            combinedScale = _feedbackScale.value;
          } else if (widget.isSelected) {
            // damped horizontal shake
            dx = 12 *
                math.sin(_feedbackController.value * math.pi * 5) *
                (1 - _feedbackController.value);
          }
        }
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(
            scale: combinedScale,
            child: child,
          ),
        );
      },
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: label,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTapDown: isEnabled ? _onTapDown : null,
            onTapUp: isEnabled ? _onTapUp : null,
            onTapCancel: isEnabled ? _onTapCancel : null,
            child: ElevatedButton(
              onPressed: isEnabled ? widget.onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                minimumSize: Size(
                  double.infinity,
                  (widget.minHeight ?? AppConstants.answerButtonHeight).h,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding.w,
                  vertical: AppConstants.defaultPadding.h,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: Colors.white.withValues(
                    alpha: widget.isSelected ? 0.28 : 0.14,
                  ),
                  width: widget.isSelected ? 2 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius * 1.6),
                ),
                elevation: widget.isSelected
                    ? AppConstants.answerButtonElevationSelected
                    : AppConstants.answerButtonElevationDefault,
                shadowColor: widget.isSelected
                    ? backgroundColor.withValues(
                        alpha: AppOpacities.buttonShadowSelected,
                      )
                    : Theme.of(context).shadowColor.withValues(
                          alpha: AppOpacities.buttonShadowIdle,
                        ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.answer.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  SizedBox(height: AppConstants.microSpacing4.h),
                  Text(
                    caption,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),       // ExcludeSemantics
      ),         // Semantics
    );           // AnimatedBuilder
  }
}

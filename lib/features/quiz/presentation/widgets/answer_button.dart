import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.requireHoldToConfirm = false,
    this.holdDuration = const Duration(milliseconds: 550),
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

  /// Åk 1–2: require a short hold so fat-finger taps don't lock in too early.
  final bool requireHoldToConfirm;
  final Duration holdDuration;

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _feedbackController;
  late AnimationController _holdController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _feedbackScale;
  Timer? _holdTimer;
  bool _holdCompleted = false;

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
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _feedbackScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.06), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 45),
    ]).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.easeOutCubic,
      ),
    );
    _holdController = AnimationController(
      duration: widget.holdDuration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdDuration != widget.holdDuration) {
      _holdController.duration = widget.holdDuration;
    }
    if (oldWidget.isCorrect == null && widget.isCorrect != null) {
      _cancelHold(resetFill: true);
      _pressController.stop();
      _pressController.value = 0;
      _feedbackController.forward(from: 0);
    }
    if (oldWidget.isCorrect != null && widget.isCorrect == null) {
      _holdCompleted = false;
      _holdController.value = 0;
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pressController.dispose();
    _feedbackController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _cancelHold({required bool resetFill}) {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (resetFill && !_holdCompleted) {
      _holdController.reverse();
    }
  }

  void _confirmHold() {
    if (_holdCompleted || !mounted) return;
    _holdCompleted = true;
    _holdTimer?.cancel();
    _holdTimer = null;
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.isCorrect != null) return;
    _pressController.forward();
    if (!widget.requireHoldToConfirm) return;
    _holdCompleted = false;
    _holdController.forward(from: 0);
    _holdTimer?.cancel();
    _holdTimer = Timer(widget.holdDuration, _confirmHold);
  }

  void _onPointerUp(PointerUpEvent event) {
    _pressController.reverse();
    if (!widget.requireHoldToConfirm || _holdCompleted) return;
    _cancelHold(resetFill: true);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pressController.reverse();
    if (!widget.requireHoldToConfirm || _holdCompleted) return;
    _cancelHold(resetFill: true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedMinHeight =
        widget.minHeight ?? AppConstants.answerButtonHeight;
    final compact = resolvedMinHeight < AppConstants.answerButtonHeight;
    Color backgroundColor;
    Color textColor;

    if (widget.isCorrect != null) {
      if (widget.isCorrect!) {
        backgroundColor = AppColors.correctAnswer;
        textColor = scheme.onPrimary;
      } else if (widget.isSelected) {
        backgroundColor = AppColors.wrongAnswer;
        textColor = scheme.onPrimary;
      } else {
        backgroundColor = widget.disabledBackgroundColor ?? scheme.surface;
        textColor = widget.idleTextColor ?? scheme.onSurface;
      }
    } else {
      backgroundColor = widget.isSelected
          ? (widget.selectedBackgroundColor ??
              Theme.of(context).colorScheme.primary)
          : (widget.idleBackgroundColor ?? scheme.surface);
      textColor = widget.isSelected
          ? scheme.onPrimary
          : (widget.idleTextColor ?? scheme.onSurface);
    }

    final isEnabled = widget.isCorrect == null;
    final String label;
    final String? hint;

    if (widget.isCorrect != null) {
      hint = null;
      if (widget.isCorrect!) {
        label = 'Svar ${widget.answer}, rätt svar';
      } else if (widget.isSelected) {
        label = 'Svar ${widget.answer}, fel svar';
      } else {
        label = 'Svar ${widget.answer}';
      }
    } else if (widget.requireHoldToConfirm) {
      label = 'Svar ${widget.answer}';
      hint = 'Håll inne för att välja';
    } else {
      hint = null;
      label = widget.isSelected
          ? 'Svar ${widget.answer}, valt'
          : 'Svar ${widget.answer}';
    }

    final borderRadius =
        BorderRadius.circular(AppConstants.borderRadius * 1.6);

    return AnimatedBuilder(
      animation: Listenable.merge(
        [_pressController, _feedbackController, _holdController],
      ),
      builder: (context, _) {
        double combinedScale = _scaleAnimation.value;
        double dx = 0;
        if (widget.isCorrect != null && _feedbackController.value > 0) {
          if (widget.isCorrect!) {
            combinedScale = _feedbackScale.value;
          } else if (widget.isSelected) {
            dx = 12 *
                math.sin(_feedbackController.value * math.pi * 5) *
                (1 - _feedbackController.value);
          }
        }
        final holdProgress = _holdController.value;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(
            scale: combinedScale,
            child: Semantics(
              button: true,
              enabled: isEnabled,
              label: label,
              hint: hint,
              onTap: isEnabled && !widget.requireHoldToConfirm
                  ? widget.onPressed
                  : null,
              onLongPress: isEnabled && widget.requireHoldToConfirm
                  ? _confirmHold
                  : null,
              child: ExcludeSemantics(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: isEnabled ? _onPointerDown : null,
                  onPointerUp: isEnabled ? _onPointerUp : null,
                  onPointerCancel: isEnabled ? _onPointerCancel : null,
                  child: Material(
                    color: backgroundColor,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: borderRadius,
                      side: BorderSide(
                        color: Colors.white.withValues(
                          alpha: widget.isSelected ? 0.28 : 0.14,
                        ),
                        width: widget.isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: borderRadius,
                      onTap: !isEnabled || widget.requireHoldToConfirm
                          ? null
                          : widget.onPressed,
                      child: SizedBox(
                        width: double.infinity,
                        height: resolvedMinHeight.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding.w,
                            vertical: compact
                                ? AppConstants.smallPadding.h
                                : AppConstants.defaultPadding.h,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (widget.requireHoldToConfirm &&
                                  isEnabled &&
                                  holdProgress > 0)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: borderRadius,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: holdProgress,
                                        widthFactor: 1,
                                        child: ColoredBox(
                                          color: scheme.onPrimary
                                              .withValues(alpha: 0.22),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Text(
                                widget.answer.toString(),
                                style: (compact
                                        ? Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                        : Theme.of(context)
                                            .textTheme
                                            .displaySmall)
                                    ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: compact ? 32 : 44,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({
    required this.feedback,
    required this.onContinue,
    this.continueLabel = 'Nästa',
    this.continueButtonColor,
    this.dialogBackgroundColor,
    this.messageTextColor,
    super.key,
  });

  final FeedbackResult feedback;
  final VoidCallback onContinue;
  final String continueLabel;
  final Color? continueButtonColor;
  final Color? dialogBackgroundColor;
  final Color? messageTextColor;

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  bool _announced = false;

  String _getCharacterName(String? characterId) {
    if (characterId == null || characterId.isEmpty) {
      return AppConstants.mascotName;
    }
    return characterId[0].toUpperCase() + characterId.substring(1);
  }

  String _mascotTitle(String title, String? characterId) {
    final prefix = '${_getCharacterName(characterId)}: ';
    if (title.startsWith(prefix)) return title;
    return '$prefix$title';
  }

  List<String> _messageLines(String message) {
    return message
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_announced) return;
    _announced = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeUser = ref.read(userProvider).activeUser;
      final direction = Directionality.of(context);
      final feedback = widget.feedback;
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${_mascotTitle(feedback.title, activeUser?.selectedCharacterId)}. ${feedback.message}',
        direction,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(userProvider).activeUser;
    final isCorrect = widget.feedback.isCorrect;
    const correctColor = AppColors.correctAnswer;
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final mutedOnSurface = onSurface.withValues(alpha: AppOpacities.mutedText);
    final lines = _messageLines(widget.feedback.message);

    final incorrectAccent = scheme.secondary;
    final mainColor = isCorrect ? correctColor : incorrectAccent;
    final comboStartColor = widget.continueButtonColor ?? scheme.primary;
    final comboEndColor = scheme.secondary;
    final buttonBackgroundColor = isCorrect
        ? correctColor
        : (widget.continueButtonColor ?? Theme.of(context).colorScheme.primary);

    final dialogBackgroundColor = widget.dialogBackgroundColor ??
        Theme.of(context).dialogTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    final dialogShape = Theme.of(context).dialogTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
        );

    final title =
        _mascotTitle(widget.feedback.title, activeUser?.selectedCharacterId);

    final comboMultiplier = widget.feedback.comboMultiplier;
    final showComboBadge = comboMultiplier >= 1.5;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding.w,
        vertical: AppConstants.largePadding.h,
      ),
      backgroundColor: dialogBackgroundColor,
      shape: dialogShape,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.largePadding.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showComboBadge) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding.w,
                    vertical: AppConstants.microSpacing6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      comboStartColor.withValues(alpha: 0.18),
                      dialogBackgroundColor,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: comboEndColor.withValues(alpha: 0.48),
                    ),
                  ),
                  child: Text(
                    '${comboMultiplier == comboMultiplier.roundToDouble() ? comboMultiplier.toStringAsFixed(0) : comboMultiplier.toStringAsFixed(1)}× COMBO! 🔥',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: AppConstants.smallPadding.h),
              ],
              ExcludeSemantics(
                child: Container(
                  height: 120.h,
                  alignment: Alignment.center,
                  child: activeUser != null
                      ? GameCharacter(
                          characterId: CharacterId.values.firstWhere(
                            (e) => e.name == activeUser.selectedCharacterId,
                            orElse: () => CharacterId.loke,
                          ),
                          equippedItems: activeUser.equippedItems,
                          customItemOffsets: activeUser.customItemOffsets,
                          reaction: isCorrect
                              ? CharacterReaction.celebrate
                              : CharacterReaction.answerWrong,
                          height: 120.h,
                        )
                      : Icon(
                          isCorrect
                              ? Icons.check_rounded
                              : Icons.psychology_alt_rounded,
                          color: mainColor,
                          size: AppConstants.feedbackDialogIconSize.sp,
                        ),
                ),
              ),
              SizedBox(height: AppConstants.defaultPadding.h),
              Semantics(
                header: true,
                label: title,
                child: ExcludeSemantics(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: AppConstants.defaultPadding.h),
              Semantics(
                label: widget.feedback.message,
                child: ExcludeSemantics(
                  child: Column(
                    children: [
                      if (lines.isNotEmpty)
                        Text(
                          lines.first,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color:
                                        widget.messageTextColor ?? mutedOnSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      if (lines.length >= 2) ...[
                        SizedBox(height: AppConstants.smallPadding.h),
                        Text(
                          lines[1],
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (lines.length >= 3) ...[
                        SizedBox(height: AppConstants.defaultPadding.h),
                        ..._buildExtraLines(
                          context,
                          lines.sublist(2),
                          defaultColor:
                              widget.messageTextColor ?? mutedOnSurface,
                          accentColor:
                              isCorrect ? correctColor : incorrectAccent,
                        ),
                      ],
                      if (widget.feedback.numberLine != null) ...[
                        SizedBox(height: AppConstants.defaultPadding.h),
                        _FeedbackNumberLineView(
                          numberLine: widget.feedback.numberLine!,
                          accentColor:
                              isCorrect ? correctColor : incorrectAccent,
                          textColor: onSurface,
                        ),
                      ],
                      if (widget.feedback.groupModel != null) ...[
                        SizedBox(height: AppConstants.defaultPadding.h),
                        _FeedbackGroupModelView(
                          groupModel: widget.feedback.groupModel!,
                          accentColor:
                              isCorrect ? correctColor : incorrectAccent,
                          textColor: onSurface,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppConstants.largePadding.h),
              ElevatedButton(
                autofocus: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onContinue();
                },
                style: (Theme.of(context).elevatedButtonTheme.style ??
                        const ButtonStyle())
                    .copyWith(
                  backgroundColor: WidgetStatePropertyAll(buttonBackgroundColor),
                  foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
                ),
                child: Text(
                  widget.continueLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExtraLines(
    BuildContext context,
    List<String> extraLines, {
    required Color defaultColor,
    required Color accentColor,
  }) {
    final widgets = <Widget>[];

    for (final line in extraLines) {
      final isHintOrMeta = line.startsWith('💡') ||
          line.startsWith('⚡') ||
          line.startsWith('🔥') ||
          line.startsWith('🪙');

      widgets.add(
        Text(
          line,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isHintOrMeta ? accentColor : defaultColor,
                fontWeight: isHintOrMeta ? FontWeight.w800 : FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return widgets;
  }
}

class _FeedbackNumberLineView extends StatelessWidget {
  const _FeedbackNumberLineView({
    required this.numberLine,
    required this.accentColor,
    required this.textColor,
  });

  final FeedbackNumberLine numberLine;
  final Color accentColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final startAlignment =
        numberLine.startOnLeft ? Alignment.centerLeft : Alignment.centerRight;
    final semanticsLabel = numberLine.isSubtraction
        ? 'Tallinje. Start ${numberLine.start}. Räkna tillbaka ${numberLine.jump} steg till ${numberLine.end}.'
        : 'Tallinje. Start ${numberLine.start}. Räkna fram ${numberLine.jump} steg till ${numberLine.end}.';

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          key: const Key('feedback_number_line'),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding.w,
                  vertical: AppConstants.microSpacing6.h,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.34),
                  ),
                ),
                child: Text(
                  numberLine.jumpLabel,
                  key: const Key('feedback_number_line_jump'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              SizedBox(height: AppConstants.smallPadding.h),
              SizedBox(
                height: 64.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: startAlignment,
                      child: Container(
                        key: const Key('feedback_number_line_start_chip'),
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.microSpacing6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Start',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18.w,
                      right: 18.w,
                      top: 22.h,
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10.w,
                      top: 16.h,
                      child: _NumberLineDot(
                        color: numberLine.startOnLeft
                            ? accentColor
                            : accentColor.withValues(alpha: 0.42),
                      ),
                    ),
                    Positioned(
                      right: 10.w,
                      top: 16.h,
                      child: _NumberLineDot(
                        color: numberLine.startOnLeft
                            ? accentColor.withValues(alpha: 0.42)
                            : accentColor,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 40.h,
                      child: SizedBox(
                        width: 46.w,
                        child: Text(
                          '${numberLine.leftValue}',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 40.h,
                      child: SizedBox(
                        width: 46.w,
                        child: Text(
                          '${numberLine.rightValue}',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberLineDot extends StatelessWidget {
  const _NumberLineDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
    );
  }
}

class _FeedbackGroupModelView extends StatelessWidget {
  const _FeedbackGroupModelView({
    required this.groupModel,
    required this.accentColor,
    required this.textColor,
  });

  final FeedbackGroupModel groupModel;
  final Color accentColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: groupModel.semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          key: const Key('feedback_group_model'),
          width: double.infinity,
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                groupModel.summaryLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: AppConstants.smallPadding.h),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppConstants.smallPadding.w,
                runSpacing: AppConstants.smallPadding.h,
                children: List<Widget>.generate(
                  groupModel.groupCount,
                  (index) => Container(
                    key: Key('feedback_group_chip_$index'),
                    width: 52.w,
                    height: 52.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Text(
                      '${groupModel.groupValue}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.smallPadding.h),
              Text(
                groupModel.isDivision
                    ? 'Tillsammans ${groupModel.totalValue}'
                    : 'Tillsammans ${groupModel.totalValue}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

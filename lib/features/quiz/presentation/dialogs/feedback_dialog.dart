import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

part 'feedback_dialog_content.dart';

class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({
    required this.feedback,
    required this.onContinue,
    this.continueLabel = 'N\u00e4sta',
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

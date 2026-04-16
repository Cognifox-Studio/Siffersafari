import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/daily_challenge_provider.dart';
import 'package:siffersafari/core/services/daily_challenge_service.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// Home screen card that shows today's daily challenge and lets the child
/// start it with a single tap or see that it's already done.
class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({
    required this.user,
    required this.userId,
    required this.allowedOps,
    required this.onStart,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.accentColor,
    super.key,
  });

  final UserProgress user;
  final String userId;
  final Set<OperationType> allowedOps;
  final void Function(DailyChallenge challenge) onStart;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(dailyChallengeServiceProvider);
    final challenge = service.getTodaysChallengeForUser(
      user: user,
      allowedOperations: allowedOps,
    );
    final challengeState = ref.watch(dailyChallengeProvider(userId));
    final isCompleted = challengeState.isCompleted;
    final streak = challengeState.streakCount;

    // Hide card if today's operation isn't allowed for this profile.
    if (!allowedOps.contains(challenge.operation)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '🌟',
                style: TextStyle(fontSize: 20.sp),
              ),
              const SizedBox(width: AppConstants.microSpacing8),
              Expanded(
                child: Text(
                  'Dagens utmaning',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.microSpacing8.w,
                    vertical: AppConstants.microSpacing4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.correctAnswer.withValues(alpha: 0.85),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Text(
                    '✅ Klar!',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              if (streak > 1) ...[
                const SizedBox(width: AppConstants.microSpacing6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.microSpacing8.w,
                    vertical: AppConstants.microSpacing4.h,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Text(
                    '🔥 $streak dagar',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            '${challenge.title} · ${challenge.difficulty.displayName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (!isCompleted) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            OutlinedButton.icon(
              onPressed: () => onStart(challenge),
              style: OutlinedButton.styleFrom(
                foregroundColor: onPrimary,
                side: BorderSide(color: accentColor),
              ),
              icon: const Icon(Icons.flash_on_rounded),
              label: const Text('Kör utmaningen'),
            ),
          ],
        ],
      ),
    );
  }
}

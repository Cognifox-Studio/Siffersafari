import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/missing_number_settings_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/spaced_repetition_settings_provider.dart';
import 'package:siffersafari/core/providers/tts_enabled_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/providers/word_problems_settings_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/image_cache_size.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/parent/presentation/screens/parent_pin_screen.dart';
import 'package:siffersafari/features/parent/providers/parent_quiz_history_provider.dart';
import 'package:siffersafari/features/settings/presentation/screens/settings_screen.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

part 'parent_dashboard_screen__benchmark_part.dart';
part 'parent_dashboard_screen__content_part.dart';
part 'parent_dashboard_screen__read_model_part.dart';
part 'parent_dashboard_screen__widgets_part.dart';

// region ParentDashboardScreen

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      userProvider.select((state) => state.activeUser),
    );
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final toolbarIconCacheSize = imageCacheExtent(context, 28);

    return ThemedBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Föräldraläge'),
        actions: [
          IconButton(
            tooltip: 'Inställningar',
            onPressed: () {
              context.pushSmooth(const SettingsScreen());
            },
            icon: Image.asset(
              'assets/images/ui/ic_ui_settings.png',
              width: 28,
              height: 28,
              cacheWidth: toolbarIconCacheSize,
              cacheHeight: toolbarIconCacheSize,
            ),
          ),
          IconButton(
            tooltip: 'Byt PIN',
            onPressed: () {
              context.pushSmooth(const ParentPinScreen(forceSetNewPin: true));
            },
            icon: const Icon(Icons.key),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = AdaptiveLayoutInfo.fromConstraints(constraints);
          final maxContentWidth = layout.contentMaxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: user == null
                  ? _NoActiveProfilePanel(
                      mutedOnPrimary: mutedOnPrimary,
                      onPrimary: onPrimary,
                    )
                  : _DashboardBody(userId: user.userId),
            ),
          );
        },
      ),
    );
  }

  // endregion
}

class _NoActiveProfilePanel extends StatelessWidget {
  const _NoActiveProfilePanel({
    required this.mutedOnPrimary,
    required this.onPrimary,
  });

  final Color mutedOnPrimary;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 44,
              color: onPrimary.withValues(alpha: AppOpacities.subtleText),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Ingen profil vald',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppConstants.microSpacing6),
            Text(
              'Välj eller skapa en profil på startsidan först.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// region _DashboardBody Main Widget

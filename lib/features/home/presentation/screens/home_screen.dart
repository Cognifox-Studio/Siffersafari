import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/missing_number_settings_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/providers/word_problems_settings_provider.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/core/theme/app_theme_colors.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/daily_challenge/providers/daily_challenge_provider.dart';
import 'package:siffersafari/features/home/presentation/widgets/camp_scene_view.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_badge_album.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_story_progress_card.dart';
import 'package:siffersafari/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:siffersafari/features/parent/presentation/screens/parent_pin_screen.dart';
import 'package:siffersafari/features/profiles/presentation/dialogs/create_user_dialog.dart';
import 'package:siffersafari/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:siffersafari/features/settings/presentation/screens/settings_screen.dart';
import 'package:siffersafari/features/story/presentation/screens/story_map_screen.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

part 'home_screen_content.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

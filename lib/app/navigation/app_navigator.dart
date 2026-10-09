import 'package:flutter/material.dart';
import 'package:siffersafari/app/navigation/app_routes.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/features/home/presentation/screens/home_screen.dart';
import 'package:siffersafari/features/inventory/presentation/screens/wardrobe_screen.dart';
import 'package:siffersafari/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:siffersafari/features/parent/presentation/screens/parent_pin_screen.dart';
import 'package:siffersafari/features/profiles/presentation/screens/profile_selection_screen.dart';
import 'package:siffersafari/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:siffersafari/features/quiz/presentation/screens/results_screen.dart';
import 'package:siffersafari/features/settings/presentation/screens/settings_screen.dart';
import 'package:siffersafari/features/story/presentation/screens/story_map_screen.dart';

/// App-level navigation so features avoid direct screen-to-screen imports.
abstract final class AppNavigator {
  static Route<void> _route(Widget page, String name) {
    return SmoothPageRoute(
      settings: RouteSettings(name: name),
      builder: (_) => page,
    );
  }

  static Future<void> openOnboarding(
    BuildContext context, {
    required String userId,
  }) {
    return Navigator.of(context).push(
      _route(OnboardingScreen(userId: userId), AppRoutes.onboarding),
    );
  }

  static Future<void> openStoryMap(BuildContext context) {
    return context.pushSmooth(const StoryMapScreen());
  }

  static Future<void> openQuiz(BuildContext context) {
    return context.pushSmooth(const QuizScreen());
  }

  static Future<void> replaceWithResults(BuildContext context) {
    return context.pushReplacementSmooth(const ResultsScreen());
  }

  static Future<void> replaceWithHome(BuildContext context) {
    return context.pushReplacementSmooth(const HomeScreen());
  }

  static Future<void> openHome(BuildContext context) {
    return context.pushSmooth(const HomeScreen());
  }

  static Future<void> openSettings(BuildContext context) {
    return context.pushSmooth(const SettingsScreen());
  }

  static Future<void> openWardrobe(BuildContext context) {
    return Navigator.of(context).push(
      _route(const WardrobeScreen(), AppRoutes.wardrobe),
    );
  }

  static Future<void> openParentPin(
    BuildContext context, {
    bool forceSetNewPin = false,
  }) {
    return context.pushSmooth(
      ParentPinScreen(forceSetNewPin: forceSetNewPin),
    );
  }

  static Future<void> resetStackToHome(BuildContext context) {
    return context.pushAndRemoveUntilSmooth(
      const HomeScreen(),
      (route) => false,
    );
  }

  static Future<void> resetStackToStoryMap(BuildContext context) {
    return context.pushAndRemoveUntilSmooth(
      const StoryMapScreen(),
      (route) => false,
    );
  }

  static Future<void> resetStackToQuiz(BuildContext context) {
    return context.pushAndRemoveUntilSmooth(
      const QuizScreen(),
      (route) => false,
    );
  }

  static Future<void> openProfileSelection(BuildContext context) {
    return context.pushReplacementSmooth(const ProfileSelectionScreen());
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.of(context).pop(result);
  }

  static void popToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

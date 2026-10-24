/// Theme options for the app
library;

import 'package:hive/hive.dart';

part 'app_theme.g.dart';

@HiveType(typeId: 4)
enum AppTheme {
  @HiveField(0)
  space('Rymd', '🚀'),

  @HiveField(1)
  jungle('Djungel', '🌴'),

  @HiveField(2)
  underwater('Undervatten', '🌊'),

  /// Desert / öken look (ROI #45). Hive id stays `fantasy` for save compat.
  @HiveField(3)
  fantasy('Öken', '🏜️');

  const AppTheme(this.displayName, this.emoji);

  final String displayName;
  final String emoji;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/services/achievement_service.dart';

import '../di/injection.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return getIt<AchievementService>();
});

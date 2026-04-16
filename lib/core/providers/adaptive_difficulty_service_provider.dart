import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';
import '../di/injection.dart';

final adaptiveDifficultyServiceProvider =
    Provider<AdaptiveDifficultyService>((ref) {
  return getIt<AdaptiveDifficultyService>();
});

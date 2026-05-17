import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';

import '../di/injection.dart';

final questProgressionServiceProvider =
    Provider<QuestProgressionService>((ref) {
  return getIt<QuestProgressionService>();
});

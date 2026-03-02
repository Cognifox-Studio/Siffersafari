import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection.dart';
import '../services/quest_progression_service.dart';

final questProgressionServiceProvider =
    Provider<QuestProgressionService>((ref) {
  return getIt<QuestProgressionService>();
});

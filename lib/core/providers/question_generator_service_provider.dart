import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection.dart';
import '../services/question_generator_service.dart';

final questionGeneratorServiceProvider =
    Provider<QuestionGeneratorService>((ref) {
  return getIt<QuestionGeneratorService>();
});

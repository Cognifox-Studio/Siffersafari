import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';

import '../di/injection.dart';

final questionGeneratorServiceProvider =
    Provider<QuestionGeneratorService>((ref) {
  return getIt<QuestionGeneratorService>();
});

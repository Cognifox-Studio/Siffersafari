import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/feedback_service.dart';
import '../di/injection.dart';

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return getIt<FeedbackService>();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection.dart';
import '../services/text_to_speech_service.dart';

final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  return getIt<TextToSpeechService>();
});

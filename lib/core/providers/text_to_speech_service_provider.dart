import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/services/text_to_speech_service.dart';

import '../di/injection.dart';

final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  return getIt<TextToSpeechService>();
});

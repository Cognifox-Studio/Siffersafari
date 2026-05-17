import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/services/audio_service.dart';

import '../di/injection.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return getIt<AudioService>();
});

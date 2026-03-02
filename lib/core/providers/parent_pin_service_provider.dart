import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/parent_pin_service.dart';
import '../di/injection.dart';

final parentPinServiceProvider = Provider<ParentPinService>((ref) {
  return getIt<ParentPinService>();
});

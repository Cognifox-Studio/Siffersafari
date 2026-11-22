import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/daily_activity_service.dart';
import 'local_storage_repository_provider.dart';

final dailyActivityProvider = Provider<DailyActivityService>((ref) {
  return DailyActivityService(ref.watch(localStorageRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_analytics_service.dart';
import 'local_storage_repository_provider.dart';

final appAnalyticsProvider = Provider<AppAnalyticsService>((ref) {
  return AppAnalyticsService(ref.watch(localStorageRepositoryProvider));
});

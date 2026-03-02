import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_storage_repository.dart';
import '../di/injection.dart';

/// Access to repositories via Riverpod so widgets can be tested/overridden
/// without reaching for GetIt directly.
final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  return getIt<LocalStorageRepository>();
});

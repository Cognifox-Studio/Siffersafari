import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/services/experiment_service.dart';

final experimentServiceProvider = Provider<ExperimentService>((ref) {
  return ExperimentService(ref.watch(localStorageRepositoryProvider));
});

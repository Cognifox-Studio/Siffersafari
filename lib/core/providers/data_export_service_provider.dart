import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:siffersafari/domain/services/data_export_service.dart';
import 'local_storage_repository_provider.dart';

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  final repository = ref.watch(localStorageRepositoryProvider);
  return DataExportService(repository: repository);
});

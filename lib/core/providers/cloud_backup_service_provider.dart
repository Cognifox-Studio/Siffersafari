import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:siffersafari/core/services/cloud_backup_service.dart';

final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  return GetIt.instance<CloudBackupService>();
});

import 'package:siffersafari/core/firebase/firebase_bootstrap.dart';
import 'package:siffersafari/firebase_options.dart';

/// Optional cloud backup (Firebase Auth + Firestore). Not used in core quiz flow.
abstract class CloudBackupService {
  bool get isProjectConfigured;

  bool get isRuntimeReady;

  /// True when parent has opted in (persisted in Hive). Default false.
  bool get isOptedIn;

  /// Phase 2: sign-in, upload, restore. Throws until implemented.
  Future<void> ensureSignedIn();
}

class DisabledCloudBackupService implements CloudBackupService {
  const DisabledCloudBackupService();

  @override
  bool get isProjectConfigured => DefaultFirebaseOptions.isConfigured;

  @override
  bool get isRuntimeReady => FirebaseBootstrap.isReady;

  @override
  bool get isOptedIn => false;

  @override
  Future<void> ensureSignedIn() async {
    throw UnsupportedError('Cloud backup is not enabled.');
  }
}

class FirebaseCloudBackupService implements CloudBackupService {
  FirebaseCloudBackupService(this._readOptIn);

  final bool Function() _readOptIn;

  @override
  bool get isProjectConfigured => DefaultFirebaseOptions.isConfigured;

  @override
  bool get isRuntimeReady => FirebaseBootstrap.isReady;

  @override
  bool get isOptedIn => _readOptIn();

  @override
  Future<void> ensureSignedIn() async {
    if (!isProjectConfigured) {
      throw StateError('Firebase project not configured.');
    }
    if (!isRuntimeReady) {
      throw StateError('Firebase is not initialized.');
    }
    if (!isOptedIn) {
      throw StateError('Cloud backup requires parent opt-in.');
    }
    throw UnimplementedError(
      'Parent sign-in and Firestore sync — see docs/FIREBASE_CLOUD_BACKUP.md',
    );
  }
}

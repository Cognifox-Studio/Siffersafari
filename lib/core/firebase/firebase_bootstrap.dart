import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:siffersafari/firebase_options.dart';

enum FirebaseBootstrapStatus {
  /// No Firebase project wired (default in repo until flutterfire configure).
  notConfigured,

  /// Skipped in tests or when configure flag is off.
  skipped,

  /// Firebase.initializeApp succeeded.
  ready,

  /// Init was attempted but failed (app continues offline).
  failed,
}

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static FirebaseBootstrapStatus status = FirebaseBootstrapStatus.notConfigured;
  static String? lastError;

  static bool get isReady => status == FirebaseBootstrapStatus.ready;

  /// Initializes Firebase when [DefaultFirebaseOptions.isConfigured] is true.
  ///
  /// Core gameplay does not require this; cloud backup is opt-in later.
  static Future<FirebaseBootstrapStatus> initialize() async {
    if (_isTestBinding) {
      status = FirebaseBootstrapStatus.skipped;
      return status;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      status = FirebaseBootstrapStatus.notConfigured;
      return status;
    }

    if (Firebase.apps.isNotEmpty) {
      status = FirebaseBootstrapStatus.ready;
      return status;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      status = FirebaseBootstrapStatus.ready;
      lastError = null;
      debugPrint('[FirebaseBootstrap] ready');
    } catch (e, st) {
      status = FirebaseBootstrapStatus.failed;
      lastError = e.toString();
      debugPrint('[FirebaseBootstrap] failed: $e');
      debugPrintStack(stackTrace: st);
    }

    return status;
  }

  static bool get _isTestBinding {
    // Avoid pulling in flutter_test from production code.
    return const bool.fromEnvironment('FLUTTER_TEST');
  }
}

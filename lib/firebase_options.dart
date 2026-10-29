import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase project options.
///
/// After creating a Firebase project, run:
/// `dart run flutterfire_cli:flutterfire configure`
///
/// See [docs/FIREBASE_SETUP.md].
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// Flip to `true` and fill in [currentPlatform] after `flutterfire configure`,
  /// or replace this file entirely with the generated output.
  static const bool isConfigured = false;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError(
        'Firebase is not configured. Run flutterfire configure — '
        'see docs/FIREBASE_SETUP.md',
      );
    }
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Placeholders — replaced by FlutterFire CLI.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    iosBundleId: 'se.cognifox.Siffersafari',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    iosBundleId: 'se.cognifox.Siffersafari',
  );
}

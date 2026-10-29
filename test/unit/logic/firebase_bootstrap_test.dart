import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/firebase/firebase_bootstrap.dart';
import 'package:siffersafari/firebase_options.dart';

void main() {
  test('bootstrap skips when Firebase project is not configured', () async {
    expect(DefaultFirebaseOptions.isConfigured, isFalse);

    final result = await FirebaseBootstrap.initialize();

    expect(result, FirebaseBootstrapStatus.notConfigured);
    expect(FirebaseBootstrap.isReady, isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:siffersafari/main.dart' as app;

import 'integration_test_utils.dart' as it;

/// Lightweight path: app boots with clean storage (profil → hem ready).
/// Full quiz → results → merge stays in [app_smoke_test.dart] with FULL_SMOKE.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile selection shell launches after clean boot', (tester) async {
    await app.main();
    await it.settle(tester, const Duration(milliseconds: 800));

    expect(find.textContaining('Välj'), findsWidgets);
  });
}

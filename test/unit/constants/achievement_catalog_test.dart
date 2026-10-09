import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/achievement_catalog.dart';

void main() {
  test('[Unit] AchievementCatalog has unique ids', () {
    final ids = AchievementCatalog.definitions.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(ids, isNotEmpty);
  });
}

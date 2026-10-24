import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';

void main() {
  group('[Unit] AppThemeConfig desert parity (#45)', () {
    test('Öken (fantasy) är implementerat med egen palett', () {
      expect(AppThemeConfig.implementedThemes, contains(AppTheme.fantasy));
      expect(AppTheme.fantasy.displayName, 'Öken');

      final config = AppThemeConfig.forTheme(AppTheme.fantasy);
      expect(config.theme, AppTheme.fantasy);
      expect(config.backgroundAsset, contains('desert'));
      expect(config.primaryActionColor, isNot(AppThemeConfig.forTheme(AppTheme.jungle).primaryActionColor));
      expect(config.primaryActionColor, isNot(AppThemeConfig.forTheme(AppTheme.space).primaryActionColor));
    });

    test('resolveTheme behåller Öken', () {
      expect(AppThemeConfig.resolveTheme(AppTheme.fantasy), AppTheme.fantasy);
    });
  });
}

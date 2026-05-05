// Assets configuration.

enum CharacterId {
  loke,
}

enum UiEffectId {
  none,
}

final class AssetPaths {
  const AssetPaths._();

  static String characterCompositeSvg(CharacterId id) {
    switch (id) {
      case CharacterId.loke:
        return 'assets/characters/loke/svg/loke_composite.svg';
    }
  }

  static String? characterRive(CharacterId id) {
    switch (id) {
      case CharacterId.loke:
        return null;
    }
  }

  static bool characterHasRive(CharacterId id) {
    return characterRive(id) != null;
  }

  static String uiEffect(UiEffectId id) {
    switch (id) {
      case UiEffectId.none:
        throw UnsupportedError('No UI effects are configured.');
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/outfit_resolver.dart';

void main() {
  // The real slots, kept small on purpose.
  String slotOf(String itemId) {
    if (itemId.contains('hat')) return 'head';
    if (itemId.contains('glasses')) return 'face';
    if (itemId.contains('shoes')) return 'feet';
    return 'accessory';
  }

  Map<String, String> resolve(
    Map<String, String> equipped,
    List<String> poseNames,
  ) =>
      OutfitResolver.resolve(
        equipped: equipped,
        poseNames: poseNames,
        slotOf: slotOf,
      );

  group('[Unit] OutfitResolver', () {
    test('plagg som valts i vila syns i alla poser', () {
      const equipped = {'idle_item_safari_hat': 'item_safari_hat'};

      for (final pose in ['idle', 'enter', 'answerCorrect', 'celebrate', 'run']) {
        expect(
          resolve(equipped, [pose]),
          containsPair('idle_item_safari_hat', 'item_safari_hat'),
          reason: 'Hatten försvann i pose $pose',
        );
      }
    });

    test('pose-specifikt val vinner över basen i samma slot', () {
      const equipped = {
        'idle_item_safari_hat': 'item_safari_hat',
        'celebrate_item_hat_pirate': 'item_hat_pirate',
      };

      expect(
        resolve(equipped, ['celebrate']),
        {'celebrate_item_hat_pirate': 'item_hat_pirate'},
        reason: 'Två hattar får aldrig ritas samtidigt',
      );
      expect(
        resolve(equipped, ['answerWrong']),
        {'idle_item_safari_hat': 'item_safari_hat'},
        reason: 'Andra poser behåller basoutfiten',
      );
    });

    test('en hatt i taget även när två poser har var sin', () {
      const equipped = {
        'celebrate_item_hat_pirate': 'item_hat_pirate',
        'answerCorrect_item_safari_hat': 'item_safari_hat',
      };

      // celebrate är högst prioriterad i listan.
      expect(
        resolve(equipped, ['celebrate', 'answerCorrect']),
        {'celebrate_item_hat_pirate': 'item_hat_pirate'},
      );
      expect(
        resolve(equipped, ['answerCorrect', 'celebrate']),
        {'answerCorrect_item_safari_hat': 'item_safari_hat'},
      );
    });

    test('äldre nycklar med bart slotnamn räknas som bas', () {
      const equipped = {'head': 'item_safari_hat', 'feet': 'item_shoes_safari'};

      expect(
        resolve(equipped, ['answerWrong']),
        containsPair('head', 'item_safari_hat'),
      );
      expect(resolve(equipped, ['answerWrong']).length, 2);
    });

    test('olika slots blandas inte', () {
      const equipped = {
        'idle_item_safari_hat': 'item_safari_hat',
        'answerWrong_item_glasses_nerd': 'item_glasses_nerd',
      };

      final resolved = resolve(equipped, ['answerWrong']);

      expect(resolved.length, 2, reason: 'Hatt och glasögon är olika slots');
      expect(resolved.containsValue('item_glasses_nerd'), isTrue);
      expect(resolved.containsValue('item_safari_hat'), isTrue);
    });

    test('andra posers plagg läcker inte in', () {
      const equipped = {'run_item_hat_pirate': 'item_hat_pirate'};

      expect(resolve(equipped, ['idle']), isEmpty);
      expect(resolve(equipped, ['run']).length, 1);
    });

    test('tom garderob ger tom outfit', () {
      expect(resolve(const {}, ['idle']), isEmpty);
    });
  });

  group('[Unit] OutfitResolver – nyckelformat', () {
    test('basnycklar känns igen', () {
      expect(OutfitResolver.isBaseKey('head'), isTrue);
      expect(OutfitResolver.isBaseKey('idle_item_safari_hat'), isTrue);
      expect(OutfitResolver.isBaseKey('celebrate_item_hat_pirate'), isFalse);
    });

    test('pose läses ut ur nyckeln', () {
      expect(OutfitResolver.poseOf('celebrate_item_hat_pirate'), 'celebrate');
      expect(OutfitResolver.poseOf('answerCorrect_item_safari_hat'),
          'answerCorrect');
      expect(OutfitResolver.poseOf('idle_item_safari_hat'), isNull);
      expect(OutfitResolver.poseOf('head'), isNull);
    });
  });
}

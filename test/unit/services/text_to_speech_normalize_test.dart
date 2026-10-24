import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/text_to_speech_service.dart';

void main() {
  test('expands arithmetic Mix prompt to Swedish speech', () {
    expect(
      normalizeQuestionForSpeech('3 × 4 = ?'),
      'tre gånger fyra är lika med vad?',
    );
  });

  test('expands ASCII operators and powers', () {
    expect(
      normalizeQuestionForSpeech('2^5'),
      'två upphöjt till fem',
    );
    expect(
      normalizeQuestionForSpeech('12/3'),
      'tolv delat med tre',
    );
  });

  test('expands percent and half symbol', () {
    expect(
      normalizeQuestionForSpeech('50% av 20'),
      'femtio procent av tjugo',
    );
    expect(
      normalizeQuestionForSpeech('½ av 8'),
      'en halv av åtta',
    );
  });

  test('expands negative integers', () {
    expect(
      normalizeQuestionForSpeech('-3 plus 5'),
      'minus tre plus fem',
    );
  });

  test('missing-number patterns stay natural', () {
    expect(
      normalizeQuestionForSpeech('? × 5 = 20'),
      'vilket tal gånger fem är lika med tjugo',
    );
  });

  test('feedback expands digits and operators', () {
    expect(
      normalizeFeedbackForSpeech('Rätt!\n3 × 4 = 12'),
      'Rätt!. tre gånger fyra är lika med tolv',
    );
  });
}

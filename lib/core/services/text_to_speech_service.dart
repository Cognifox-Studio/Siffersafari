import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  FlutterTts? _tts;
  bool _configured = false;
  bool _speaking = false;

  /// Fires when speaking starts/stops (including stop/cancel/complete).
  void Function(bool speaking)? onSpeakingChanged;

  bool get isSpeaking => _speaking;

  Future<void> speakQuestion(String text) {
    return _speak(normalizeQuestionForSpeech(text));
  }

  Future<void> speakFeedback(String text) {
    return _speak(normalizeFeedbackForSpeech(text));
  }

  Future<void> stop() async {
    final tts = _tts;
    if (tts == null) {
      _setSpeaking(false);
      return;
    }

    try {
      await tts.stop();
    } catch (_) {}
    _setSpeaking(false);
  }

  Future<void> _speak(String rawText) async {
    final text = collapseWhitespace(rawText);
    if (text.isEmpty) return;

    try {
      final tts = _instance;
      await _configure(tts);
      await tts.stop();
      _setSpeaking(true);
      await tts.speak(text);
    } catch (_) {
      _setSpeaking(false);
    }
  }

  Future<void> _configure(FlutterTts tts) async {
    if (_configured) return;

    try {
      await tts.setLanguage('sv-SE');
    } catch (_) {}
    try {
      await tts.setSpeechRate(0.42);
    } catch (_) {}
    try {
      await tts.setPitch(1.0);
    } catch (_) {}
    try {
      await tts.setVolume(1.0);
    } catch (_) {}

    tts.setCompletionHandler(() {
      _setSpeaking(false);
    });
    tts.setCancelHandler(() {
      _setSpeaking(false);
    });
    tts.setErrorHandler((_) {
      _setSpeaking(false);
    });

    _configured = true;
  }

  void _setSpeaking(bool speaking) {
    if (_speaking == speaking) return;
    _speaking = speaking;
    onSpeakingChanged?.call(speaking);
  }

  FlutterTts get _instance => _tts ??= FlutterTts();
}

/// Expands operators and digits so sv-SE TTS reads Mix/math prompts naturally.
@visibleForTesting
String normalizeQuestionForSpeech(String text) {
  var normalized = text;
  normalized = normalized.replaceAll('½', ' en halv ');
  normalized = normalized.replaceAll('? +', 'vilket tal plus');
  normalized = normalized.replaceAll('? -', 'vilket tal minus');
  normalized = normalized.replaceAll('? ×', 'vilket tal gånger');
  normalized = normalized.replaceAll('? ÷', 'vilket tal delat med');
  normalized = normalized.replaceAll('+ ?', 'plus vilket tal');
  normalized = normalized.replaceAll('- ?', 'minus vilket tal');
  normalized = normalized.replaceAll('× ?', 'gånger vilket tal');
  normalized = normalized.replaceAll('÷ ?', 'delat med vilket tal');
  normalized = normalized.replaceAll('×', ' gånger ');
  normalized = normalized.replaceAll('÷', ' delat med ');
  normalized = normalized.replaceAll('*', ' gånger ');
  normalized = normalized.replaceAll('/', ' delat med ');
  normalized = normalized.replaceAll('^', ' upphöjt till ');
  normalized = normalized.replaceAll('%', ' procent ');
  normalized = normalized.replaceAll('+', ' plus ');
  normalized = normalized.replaceAll(' − ', ' minus ');
  normalized = normalized.replaceAll(' – ', ' minus ');
  normalized = normalized.replaceAll(' - ', ' minus ');
  normalized = normalized.replaceAll('= ?', ' är lika med vad?');
  normalized = normalized.replaceAll('=', ' är lika med ');
  normalized = _expandSwedishNumberTokens(normalized);
  return collapseWhitespace(normalized);
}

@visibleForTesting
String normalizeFeedbackForSpeech(String text) {
  var normalized = text.replaceAll('\n', '. ');
  normalized = normalized.replaceAll('½', ' en halv ');
  normalized = normalized.replaceAll('×', ' gånger ');
  normalized = normalized.replaceAll('÷', ' delat med ');
  normalized = normalized.replaceAll('*', ' gånger ');
  normalized = normalized.replaceAll('^', ' upphöjt till ');
  normalized = normalized.replaceAll('%', ' procent ');
  normalized = normalized.replaceAll('=', ' är lika med ');
  normalized = _expandSwedishNumberTokens(normalized);
  return collapseWhitespace(normalized);
}

@visibleForTesting
String collapseWhitespace(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Replace integer tokens (optional leading minus) with Swedish words.
String _expandSwedishNumberTokens(String text) {
  return text.replaceAllMapped(RegExp(r'(?<![\wÅÄÖåäö])-?\d+'), (match) {
    final raw = match.group(0)!;
    final negative = raw.startsWith('-');
    final value = int.tryParse(negative ? raw.substring(1) : raw);
    if (value == null) return raw;
    final words = _swedishCardinal(value);
    if (words == null) return raw;
    return negative ? 'minus $words' : words;
  });
}

/// Swedish cardinals for quiz-sized integers (0–9999). Returns null if out of range.
String? _swedishCardinal(int value) {
  if (value < 0 || value > 9999) return null;
  if (value < 20) return _underTwenty[value];
  if (value < 100) {
    final tens = value ~/ 10;
    final ones = value % 10;
    if (ones == 0) return _tens[tens];
    return '${_tens[tens]}${_underTwenty[ones]}';
  }
  if (value < 1000) {
    final hundreds = value ~/ 100;
    final rest = value % 100;
    final head = hundreds == 1 ? 'etthundra' : '${_underTwenty[hundreds]}hundra';
    if (rest == 0) return head;
    return '$head${_swedishCardinal(rest)}';
  }
  final thousands = value ~/ 1000;
  final rest = value % 1000;
  final head = thousands == 1 ? 'ettusen' : '${_swedishCardinal(thousands)}tusen';
  if (rest == 0) return head;
  if (rest < 100) return '$head$_and${_swedishCardinal(rest)}';
  return '$head${_swedishCardinal(rest)}';
}

const _and = 'och';

const _underTwenty = <String>[
  'noll',
  'ett',
  'två',
  'tre',
  'fyra',
  'fem',
  'sex',
  'sju',
  'åtta',
  'nio',
  'tio',
  'elva',
  'tolv',
  'tretton',
  'fjorton',
  'femton',
  'sexton',
  'sjutton',
  'arton',
  'nitton',
];

const _tens = <String>[
  '',
  '',
  'tjugo',
  'trettio',
  'fyrtio',
  'femtio',
  'sextio',
  'sjuttio',
  'åttio',
  'nittio',
];

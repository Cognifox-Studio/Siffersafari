import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  FlutterTts? _tts;
  bool _configured = false;

  Future<void> speakQuestion(String text) {
    return _speak(_normalizeQuestion(text));
  }

  Future<void> speakFeedback(String text) {
    return _speak(_normalizeFeedback(text));
  }

  Future<void> stop() async {
    final tts = _tts;
    if (tts == null) return;

    try {
      await tts.stop();
    } catch (_) {}
  }

  Future<void> _speak(String rawText) async {
    final text = _collapseWhitespace(rawText);
    if (text.isEmpty) return;

    try {
      final tts = _instance;
      await _configure(tts);
      await tts.stop();
      await tts.speak(text);
    } catch (_) {}
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

    _configured = true;
  }

  FlutterTts get _instance => _tts ??= FlutterTts();

  String _normalizeQuestion(String text) {
    var normalized = text;
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
    normalized = normalized.replaceAll('+', ' plus ');
    normalized = normalized.replaceAll(' - ', ' minus ');
    normalized = normalized.replaceAll('= ?', ' är lika med vad?');
    normalized = normalized.replaceAll('=', ' är lika med ');
    return normalized;
  }

  String _normalizeFeedback(String text) {
    var normalized = text.replaceAll('\n', '. ');
    normalized = normalized.replaceAll('×', ' gånger ');
    normalized = normalized.replaceAll('÷', ' delat med ');
    return normalized;
  }

  String _collapseWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AppSoundEffect {
  click,
  correct,
  wrong,
  celebration,
  mapOpen,
  quizStart,
}

enum AppMusicTrack {
  home,
  story,
  quiz,
}

class AudioAssetSpec {
  const AudioAssetSpec({
    required this.primary,
    this.fallback,
    this.volume,
  });

  final String primary;
  final String? fallback;
  final double? volume;
}

const Map<AppSoundEffect, AudioAssetSpec> appSoundEffectAssets = {
  AppSoundEffect.click: AudioAssetSpec(
    primary: 'sounds/click.mp3',
    fallback: 'sounds/click.wav',
    volume: 0.55,
  ),
  AppSoundEffect.correct: AudioAssetSpec(
    primary: 'sounds/correct.mp3',
    fallback: 'sounds/correct.wav',
    volume: 0.78,
  ),
  AppSoundEffect.wrong: AudioAssetSpec(
    primary: 'sounds/wrong.mp3',
    fallback: 'sounds/wrong.wav',
    volume: 0.7,
  ),
  AppSoundEffect.celebration: AudioAssetSpec(
    primary: 'sounds/celebration.mp3',
    fallback: 'sounds/celebration.wav',
    volume: 0.82,
  ),
  AppSoundEffect.mapOpen: AudioAssetSpec(
    primary: 'sounds/map_open.mp3',
    fallback: 'sounds/map_open.wav',
    volume: 0.62,
  ),
  AppSoundEffect.quizStart: AudioAssetSpec(
    primary: 'sounds/quiz_start.mp3',
    fallback: 'sounds/quiz_start.wav',
    volume: 0.68,
  ),
};

const Map<AppMusicTrack, AudioAssetSpec> appMusicTrackAssets = {
  AppMusicTrack.home: AudioAssetSpec(
    primary: 'sounds/home_music.mp3',
    volume: 0.24,
  ),
  AppMusicTrack.story: AudioAssetSpec(
    primary: 'sounds/story_music.mp3',
    volume: 0.22,
  ),
  AppMusicTrack.quiz: AudioAssetSpec(
    primary: 'sounds/quiz_music.mp3',
    volume: 0.18,
  ),
};

/// Service for playing audio feedback and music
class AudioService {
  final _audioPlayer = AudioPlayer();
  final _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  AppMusicTrack? _currentMusicTrack;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  /// Enable or disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Enable or disable background music
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  Future<void> playSoundEffect(AppSoundEffect effect) async {
    if (!_soundEnabled) return;

    final spec = appSoundEffectAssets[effect];
    if (spec == null) return;

    try {
      await _playAssetWithFallback(
        player: _audioPlayer,
        primary: spec.primary,
        fallback: spec.fallback,
        volume: spec.volume,
      );
    } catch (_) {
      // Handle error silently for now
    }
  }

  Future<void> playMusicTrack(AppMusicTrack track) async {
    if (!_musicEnabled || _currentMusicTrack == track) return;

    final spec = appMusicTrackAssets[track];
    if (spec == null) return;

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _playAssetWithFallback(
        player: _musicPlayer,
        primary: spec.primary,
        fallback: spec.fallback,
        volume: spec.volume,
      );
      _currentMusicTrack = track;
    } catch (_) {
      // Handle error silently for now
    }
  }

  /// Play correct answer sound
  Future<void> playCorrectSound() =>
      playSoundEffect(AppSoundEffect.correct);

  /// Play wrong answer sound
  Future<void> playWrongSound() => playSoundEffect(AppSoundEffect.wrong);

  /// Play celebration sound
  Future<void> playCelebrationSound() =>
      playSoundEffect(AppSoundEffect.celebration);

  /// Play button click sound
  Future<void> playClickSound() => playSoundEffect(AppSoundEffect.click);

  /// Play story map open sound
  Future<void> playMapOpenSound() => playSoundEffect(AppSoundEffect.mapOpen);

  /// Play quiz start sound
  Future<void> playQuizStartSound() =>
      playSoundEffect(AppSoundEffect.quizStart);

  /// Play home background music
  Future<void> playHomeMusic() => playMusicTrack(AppMusicTrack.home);

  /// Play story background music
  Future<void> playStoryMusic() => playMusicTrack(AppMusicTrack.story);

  /// Play quiz background music
  Future<void> playQuizMusic() => playMusicTrack(AppMusicTrack.quiz);

  /// Play background music
  Future<void> playMusic() => playHomeMusic();

  Future<void> _playAssetWithFallback({
    required AudioPlayer player,
    required String primary,
    String? fallback,
    double? volume,
  }) async {
    try {
      await player.play(AssetSource(primary), volume: volume);
    } catch (_) {
      if (fallback == null) rethrow;

      // Fallback to WAV (larger file, should be converted to MP3 for production)
      debugPrint(
        '⚠️ Using WAV fallback for $primary - convert to MP3 to reduce APK size',
      );
      await player.play(AssetSource(fallback), volume: volume);
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    _currentMusicTrack = null;
    await _musicPlayer.stop();
  }

  /// Dispose audio players
  void dispose() {
    _audioPlayer.dispose();
    _musicPlayer.dispose();
  }
}

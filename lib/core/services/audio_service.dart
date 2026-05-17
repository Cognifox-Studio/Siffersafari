import 'dart:async';

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

enum AppAudioLevel {
  off(0.0),
  low(0.45),
  high(1.0);

  const AppAudioLevel(this.factor);

  final double factor;

  static AppAudioLevel fromVolume(double volume, {required bool enabled}) {
    if (!enabled || volume <= 0.01) return AppAudioLevel.off;
    if (volume < 0.75) return AppAudioLevel.low;
    return AppAudioLevel.high;
  }
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
  static const _musicRecoveryDelay = Duration(milliseconds: 120);

  AudioService();

  final _audioPlayer = AudioPlayer();
  final _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _playersConfigured = false;
  double _soundVolume = 1.0;
  double _musicVolume = 1.0;
  AppMusicTrack? _currentMusicTrack;
  Timer? _musicRecoveryTimer;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  Future<void> _ensurePlayersConfigured() async {
    if (_playersConfigured) return;

    try {
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );

      await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      _playersConfigured = true;
    } catch (_) {
      _playersConfigured = false;
      rethrow;
    }
  }

  double _clampVolume(double volume) => volume.clamp(0.0, 1.0);

  double _resolveVolume(double? baseVolume, double factor) {
    return ((baseVolume ?? 1.0) * _clampVolume(factor)).clamp(0.0, 1.0);
  }

  /// Enable or disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Enable or disable background music
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      unawaited(stopMusic(clearTrack: false));
      return;
    }

    final currentTrack = _currentMusicTrack;
    if (currentTrack != null && _musicPlayer.state != PlayerState.playing) {
      unawaited(playMusicTrack(currentTrack));
    }
  }

  /// Set the master volume factor for sound effects.
  void setSoundVolume(double volume) {
    _soundVolume = _clampVolume(volume);
  }

  /// Set the master volume factor for background music.
  void setMusicVolume(double volume) {
    _musicVolume = _clampVolume(volume);

    final currentTrack = _currentMusicTrack;
    if (!_musicEnabled || currentTrack == null) return;

    final spec = appMusicTrackAssets[currentTrack];
    if (spec == null) return;

    unawaited(
      _musicPlayer.setVolume(_resolveVolume(spec.volume, _musicVolume)),
    );
  }

  void _scheduleMusicRecovery() {
    final currentTrack = _currentMusicTrack;
    if (!_musicEnabled || currentTrack == null) return;

    _musicRecoveryTimer?.cancel();
    _musicRecoveryTimer = Timer(
      _musicRecoveryDelay,
      () => unawaited(_restoreMusicIfInterrupted(currentTrack)),
    );
  }

  Future<void> _restoreMusicIfInterrupted(AppMusicTrack track) async {
    if (!_musicEnabled || _currentMusicTrack != track) return;
    if (_musicPlayer.state == PlayerState.playing) return;

    try {
      if (_musicPlayer.state == PlayerState.paused) {
        await _musicPlayer.resume();
        return;
      }

      await playMusicTrack(track);
    } catch (_) {
      if (_musicEnabled && _currentMusicTrack == track) {
        await playMusicTrack(track);
      }
    }
  }

  Future<void> playSoundEffect(AppSoundEffect effect) async {
    if (!_soundEnabled) return;

    final spec = appSoundEffectAssets[effect];
    if (spec == null) return;

    try {
      await _ensurePlayersConfigured();
      await _playAssetWithFallback(
        player: _audioPlayer,
        primary: spec.primary,
        fallback: spec.fallback,
        volume: _resolveVolume(spec.volume, _soundVolume),
      );
      _scheduleMusicRecovery();
    } catch (_) {
      // Handle error silently for now
    }
  }

  Future<void> playMusicTrack(AppMusicTrack track) async {
    if (!_musicEnabled) {
      _currentMusicTrack = track;
      return;
    }

    final isSameTrackStillPlaying = _currentMusicTrack == track &&
        _musicPlayer.state == PlayerState.playing;
    if (isSameTrackStillPlaying) {
      return;
    }

    final spec = appMusicTrackAssets[track];
    if (spec == null) return;

    try {
      await _ensurePlayersConfigured();
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _playAssetWithFallback(
        player: _musicPlayer,
        primary: spec.primary,
        fallback: spec.fallback,
        volume: _resolveVolume(spec.volume, _musicVolume),
      );
      _currentMusicTrack = track;
    } catch (_) {
      // Handle error silently for now
    }
  }

  /// Play correct answer sound
  Future<void> playCorrectSound() => playSoundEffect(AppSoundEffect.correct);

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
  Future<void> stopMusic({bool clearTrack = true}) async {
    if (clearTrack) {
      _currentMusicTrack = null;
    }
    await _musicPlayer.stop();
  }

  /// Dispose audio players
  void dispose() {
    _musicRecoveryTimer?.cancel();
    unawaited(_audioPlayer.dispose());
    unawaited(_musicPlayer.dispose());
  }
}

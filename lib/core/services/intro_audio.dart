import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// Plays the first six seconds of the opening recording, once per cold start.
///
/// Uses [assets/audio/opening.mpeg] via just_audio (original splash sound).
class IntroAudio {
  static final IntroAudio instance = IntroAudio._();
  IntroAudio._();

  AudioPlayer? _player;
  bool _playedThisProcess = false;
  bool _active = false;
  bool _closed = false;
  Timer? _stopTimer;
  static const _clip = Duration(seconds: 6);
  static const _asset = 'assets/audio/opening.mpeg';

  bool get playedThisProcess => _playedThisProcess;
  bool get isActive => _active;

  Future<void> playIfAllowed() async {
    if (_playedThisProcess || _closed) return;

    try {
      await rootBundle.load(_asset);
      final player = AudioPlayer();
      _player = player;
      await player.setAsset(_asset);
      await player.setClip(start: Duration.zero, end: _clip);
      await player.setVolume(0.9);
      await player.play();
      _playedThisProcess = true;
      _active = true;
      _stopTimer = Timer(_clip, () {
        stop();
      });
    } catch (e) {
      debugPrint('IntroAudio play failed: $e');
      _active = false;
    }
  }

  void setVolume(double volume) {
    final player = _player;
    if (!_active || player == null) return;
    player.setVolume(volume.clamp(0, 1));
  }

  Future<void> pause() async {
    if (!_active) return;
    try {
      await _player?.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    if (!_active) return;
    try {
      await _player?.play();
    } catch (_) {}
  }

  Future<void> stop() async {
    if (_closed) return;
    _stopTimer?.cancel();
    _active = false;
    final player = _player;
    _player = null;
    if (player != null) {
      try {
        await player.stop();
      } catch (_) {}
      try {
        await player.dispose();
      } catch (_) {}
    }
    if (_playedThisProcess) {
      _closed = true;
    }
  }

}

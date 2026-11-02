import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/islamic_audio.dart';
import 'alnoor_audio_handler.dart';
import 'audio_position_store.dart';

/// Global Flutter-facing audio controller.
///
/// Production uses [AudioHandler] (media session + background). Unit tests can
/// omit the handler and fall back to a local [AudioPlayer] without Android
/// services.
class IslamicAudioPlayer extends ChangeNotifier {
  IslamicAudioPlayer({
    AudioHandler? handler,
    AudioPlayer? localFallback,
  })  : _handler = handler,
        _local = handler == null ? (localFallback ?? AudioPlayer()) : null {
    if (_handler != null) {
      _bindHandler(_handler!);
    } else {
      _bindLocal();
    }
  }

  AudioHandler? _handler;
  final AudioPlayer? _local;
  final AudioPositionStore _positions = AudioPositionStore();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;

  IslamicAudioTrack? _current;
  List<IslamicAudioTrack> _queue = [];
  int _queueIndex = 0;
  IslamicPlaybackPhase _phase = IslamicPlaybackPhase.idle;
  String? _error;
  Duration _position = Duration.zero;
  Duration? _duration;
  double _speed = 1;
  double _volume = 1;
  IslamicRepeatMode _repeatMode = IslamicRepeatMode.none;
  bool _shuffle = false;
  Timer? _sleepTimer;
  Duration? _sleepRemaining;
  Timer? _sleepTicker;

  IslamicAudioTrack? get current => _current;
  List<IslamicAudioTrack> get queue => List.unmodifiable(_queue);
  int get queueIndex => _queueIndex;
  IslamicPlaybackPhase get phase => _phase;
  bool get isPlaying => _phase == IslamicPlaybackPhase.playing;
  bool get loading =>
      _phase == IslamicPlaybackPhase.loading ||
      _phase == IslamicPlaybackPhase.buffering;
  bool get buffering => _phase == IslamicPlaybackPhase.buffering;
  String? get error => _error;
  Duration get position => _position;
  Duration? get duration => _duration ?? _current?.duration;
  double get speed => _speed;
  double get volume => _volume;
  IslamicRepeatMode get repeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffle;
  bool get hasTrack => _current != null;
  bool get hasNext => _queueIndex < _queue.length - 1;
  bool get hasPrevious => _queueIndex > 0 || _position > const Duration(seconds: 3);
  Duration? get sleepRemaining => _sleepRemaining;
  bool get sleepTimerActive => _sleepTimer != null;

  bool isCurrent(String trackId) => _current?.id == trackId;

  bool isPlayingTrack(String trackId) => isCurrent(trackId) && isPlaying;

  void attachHandler(AudioHandler handler) {
    if (_handler == handler) return;
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _handler = handler;
    _bindHandler(handler);
  }

  void _bindHandler(AudioHandler handler) {
    _subscriptions.add(handler.mediaItem.listen((item) {
      if (_disposed) return;
      if (item == null) {
        _current = null;
        _phase = IslamicPlaybackPhase.idle;
        notifyListeners();
        return;
      }
      _current = IslamicAudioTrack.fromMediaExtras(item.id, item.extras);
      if (item.duration != null) _duration = item.duration;
      notifyListeners();
    }));
    _subscriptions.add(handler.queue.listen((items) {
      if (_disposed) return;
      _queue = [
        for (final item in items)
          IslamicAudioTrack.fromMediaExtras(item.id, item.extras),
      ];
      notifyListeners();
    }));
    _subscriptions.add(handler.playbackState.listen((state) {
      if (_disposed) return;
      _speed = state.speed;
      _queueIndex = state.queueIndex ?? _queueIndex;
      _repeatMode = switch (state.repeatMode) {
        AudioServiceRepeatMode.one => IslamicRepeatMode.one,
        AudioServiceRepeatMode.all ||
        AudioServiceRepeatMode.group =>
          IslamicRepeatMode.all,
        _ => IslamicRepeatMode.none,
      };
      _shuffle = state.shuffleMode != AudioServiceShuffleMode.none;
      _phase = _mapPhase(state);
      if (state.processingState == AudioProcessingState.error) {
        _error = 'Playback error';
      } else if (_phase != IslamicPlaybackPhase.error) {
        _error = null;
      }
      notifyListeners();
    }));
    _subscriptions.add(AudioService.position.listen((pos) {
      if (_disposed) return;
      _position = pos;
      notifyListeners();
    }));
  }

  void _bindLocal() {
    final player = _local!;
    _subscriptions.add(player.playerStateStream.listen((_) {
      if (_disposed) return;
      _syncLocalPhase();
      notifyListeners();
    }));
    _subscriptions.add(player.positionStream.listen((position) {
      if (_disposed) return;
      _position = position;
      notifyListeners();
    }));
    _subscriptions.add(player.durationStream.listen((duration) {
      if (_disposed) return;
      _duration = duration;
      notifyListeners();
    }));
    _subscriptions.add(player.processingStateStream.listen((state) async {
      if (_disposed) return;
      if (state == ProcessingState.completed) {
        await _localOnCompleted();
      }
      _syncLocalPhase();
      notifyListeners();
    }));
  }

  IslamicPlaybackPhase _mapPhase(PlaybackState state) {
    switch (state.processingState) {
      case AudioProcessingState.idle:
        return IslamicPlaybackPhase.idle;
      case AudioProcessingState.loading:
        return IslamicPlaybackPhase.loading;
      case AudioProcessingState.buffering:
        return IslamicPlaybackPhase.buffering;
      case AudioProcessingState.ready:
        return state.playing
            ? IslamicPlaybackPhase.playing
            : IslamicPlaybackPhase.paused;
      case AudioProcessingState.completed:
        return IslamicPlaybackPhase.completed;
      case AudioProcessingState.error:
        return IslamicPlaybackPhase.error;
    }
  }

  void _syncLocalPhase() {
    final player = _local!;
    switch (player.processingState) {
      case ProcessingState.idle:
        _phase = IslamicPlaybackPhase.idle;
        break;
      case ProcessingState.loading:
        _phase = IslamicPlaybackPhase.loading;
        break;
      case ProcessingState.buffering:
        _phase = IslamicPlaybackPhase.buffering;
        break;
      case ProcessingState.ready:
        _phase = player.playing
            ? IslamicPlaybackPhase.playing
            : IslamicPlaybackPhase.paused;
        break;
      case ProcessingState.completed:
        _phase = IslamicPlaybackPhase.completed;
        break;
    }
  }

  Future<void> playTrack(
    IslamicAudioTrack track, {
    String? localFilePath,
    List<IslamicAudioTrack>? queue,
    int? startIndex,
  }) {
    final list = queue ?? [track];
    final index = startIndex ??
        list.indexWhere((t) => t.id == track.id).clamp(0, list.length - 1);
    final paths = <String, String?>{
      if (localFilePath != null) track.id: localFilePath,
    };
    return playQueue(list, startIndex: index, localPaths: paths);
  }

  Future<void> playQueue(
    List<IslamicAudioTrack> tracks, {
    int startIndex = 0,
    Map<String, String?> localPaths = const {},
  }) async {
    if (tracks.isEmpty) return;
    _error = null;
    _phase = IslamicPlaybackPhase.loading;
    _queue = List.of(tracks);
    _queueIndex = startIndex.clamp(0, tracks.length - 1);
    _current = tracks[_queueIndex];
    // Immediate UI update so mini/full player reflect the new source
    // before buffering (Quran ↔ Nasheed / reciter switches).
    notifyListeners();

    final handler = _handler;
    if (handler is AlNoorAudioHandler) {
      try {
        await handler.playTracks(
          tracks,
          startIndex: _queueIndex,
          localPaths: localPaths,
        );
      } catch (e) {
        _error = e.toString();
        _phase = IslamicPlaybackPhase.error;
        notifyListeners();
      }
      return;
    }
    if (handler != null) {
      try {
        await handler.customAction('clearQueue');
      } catch (_) {}
    }
    await _playLocal(_current!, localPaths[_current!.id]);
  }

  Future<void> _playLocal(IslamicAudioTrack track, String? localPath) async {
    final player = _local;
    if (player == null) return;
    try {
      if (localPath != null && localPath.isNotEmpty) {
        await player.setFilePath(localPath);
      } else if (track.streamUrl.startsWith('assets/')) {
        await player.setAsset(track.streamUrl);
      } else {
        await player.setUrl(track.streamUrl);
      }
      final saved = await _positions.load(track.id);
      if (saved != null) await player.seek(saved);
      await player.play();
      _phase = IslamicPlaybackPhase.playing;
    } catch (e) {
      _error = e.toString();
      _phase = IslamicPlaybackPhase.error;
      debugPrint('IslamicAudioPlayer local play error: $e');
    }
    notifyListeners();
  }

  Future<void> _localOnCompleted() async {
    switch (_repeatMode) {
      case IslamicRepeatMode.one:
        await _local?.seek(Duration.zero);
        await _local?.play();
        break;
      case IslamicRepeatMode.all:
        await skipToNext(forceWrap: true);
        break;
      case IslamicRepeatMode.none:
        if (hasNext) {
          await skipToNext();
        } else {
          _phase = IslamicPlaybackPhase.completed;
          notifyListeners();
        }
        break;
    }
  }

  Future<void> pause() async {
    if (_handler != null) {
      await _handler!.pause();
      return;
    }
    await _local?.pause();
    _phase = IslamicPlaybackPhase.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_handler != null) {
      await _handler!.play();
      return;
    }
    await _local?.play();
    _phase = IslamicPlaybackPhase.playing;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> stop() async {
    cancelSleepTimer();
    if (_handler != null) {
      await _handler!.stop();
      return;
    }
    await _local?.stop();
    _phase = IslamicPlaybackPhase.paused;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> clear() async {
    cancelSleepTimer();
    if (_handler != null) {
      await _handler!.customAction('clearQueue');
    } else {
      await _local?.stop();
    }
    _current = null;
    _queue = [];
    _queueIndex = 0;
    _duration = null;
    _position = Duration.zero;
    _error = null;
    _phase = IslamicPlaybackPhase.idle;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (_handler != null) {
      await _handler!.seek(position);
      return;
    }
    await _local?.seek(position);
  }

  Future<void> seekForward([Duration step = const Duration(seconds: 10)]) async {
    if (_handler != null) {
      await _handler!.customAction('seekForward', {'seconds': step.inSeconds});
      return;
    }
    final target = _position + step;
    final total = duration;
    await seek(total != null && target > total ? total : target);
  }

  Future<void> seekBackward([Duration step = const Duration(seconds: 10)]) async {
    if (_handler != null) {
      await _handler!.customAction('seekBackward', {'seconds': step.inSeconds});
      return;
    }
    final target = _position - step;
    await seek(target.isNegative ? Duration.zero : target);
  }

  Future<void> replay() async {
    if (_handler != null) {
      await _handler!.customAction('replay');
      return;
    }
    await seek(Duration.zero);
    await resume();
  }

  Future<void> skipToNext({bool forceWrap = false}) async {
    if (_handler != null) {
      await _handler!.skipToNext();
      return;
    }
    if (!hasNext) {
      if (!forceWrap || _queue.isEmpty) return;
      _queueIndex = 0;
    } else {
      _queueIndex += 1;
    }
    _current = _queue[_queueIndex];
    await _playLocal(_current!, null);
  }

  Future<void> skipToPrevious() async {
    if (_handler != null) {
      await _handler!.skipToPrevious();
      return;
    }
    if (_position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    if (!hasPrevious || _queueIndex <= 0) {
      await seek(Duration.zero);
      return;
    }
    _queueIndex -= 1;
    _current = _queue[_queueIndex];
    await _playLocal(_current!, null);
  }

  Future<void> skipToQueueIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    if (_handler != null) {
      await _handler!.skipToQueueItem(index);
      return;
    }
    _queueIndex = index;
    _current = _queue[index];
    await _playLocal(_current!, null);
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    if (_handler != null) {
      await _handler!.setSpeed(_speed);
    } else {
      await _local?.setSpeed(_speed);
    }
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_handler != null) {
      await _handler!.customAction('setVolume', {'volume': _volume});
    } else {
      await _local?.setVolume(_volume);
    }
    notifyListeners();
  }

  Future<void> setRepeatMode(IslamicRepeatMode mode) async {
    _repeatMode = mode;
    if (_handler != null) {
      await _handler!.setRepeatMode(switch (mode) {
        IslamicRepeatMode.none => AudioServiceRepeatMode.none,
        IslamicRepeatMode.one => AudioServiceRepeatMode.one,
        IslamicRepeatMode.all => AudioServiceRepeatMode.all,
      });
    }
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    final next = switch (_repeatMode) {
      IslamicRepeatMode.none => IslamicRepeatMode.one,
      IslamicRepeatMode.one => IslamicRepeatMode.all,
      IslamicRepeatMode.all => IslamicRepeatMode.none,
    };
    await setRepeatMode(next);
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    _shuffle = enabled;
    if (_handler != null) {
      await _handler!.setShuffleMode(
        enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      );
    }
    notifyListeners();
  }

  void startSleepTimer(Duration duration) {
    cancelSleepTimer();
    _sleepRemaining = duration;
    _sleepTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _sleepRemaining;
      if (left == null) return;
      final next = left - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        cancelSleepTimer();
        pause();
      } else {
        _sleepRemaining = next;
        notifyListeners();
      }
    });
    _sleepTimer = Timer(duration, () {
      cancelSleepTimer();
      pause();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    _sleepTimer = null;
    _sleepTicker = null;
    _sleepRemaining = null;
    notifyListeners();
  }

  static String formatClock(Duration value) {
    final total = value.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Test helper: updates queue/current without touching platform audio.
  @visibleForTesting
  void debugSetQueue(
    List<IslamicAudioTrack> tracks, {
    int startIndex = 0,
  }) {
    if (tracks.isEmpty) {
      _current = null;
      _queue = [];
      _queueIndex = 0;
      _phase = IslamicPlaybackPhase.idle;
      notifyListeners();
      return;
    }
    _queue = List.of(tracks);
    _queueIndex = startIndex.clamp(0, tracks.length - 1);
    _current = tracks[_queueIndex];
    _phase = IslamicPlaybackPhase.paused;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    cancelSleepTimer();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    try {
      _local?.dispose();
    } catch (_) {}
    super.dispose();
  }
}

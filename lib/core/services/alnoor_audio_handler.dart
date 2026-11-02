import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/islamic_audio.dart';
import 'audio_artwork_cache.dart';
import 'audio_position_store.dart';
import 'intro_audio.dart';

/// Single Android media-session / background audio engine for Al Noor.
///
/// Owns the only long-lived [AudioPlayer] used for Quran, Nasheeds, and
/// other Islamic library audio. Prayer-alert Adhan and splash intro chimes
/// remain separate short-lived players and must not replace this service.
class AlNoorAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AlNoorAudioHandler({
    AudioPlayer? player,
    AudioPositionStore? positionStore,
  })  : _player = player ?? AudioPlayer(),
        _positions = positionStore ?? AudioPositionStore() {
    _init();
  }

  final AudioPlayer _player;
  final AudioPositionStore _positions;
  final _playlist = ConcatenatingAudioSource(children: []);
  List<IslamicAudioTrack> _tracks = [];
  IslamicRepeatMode _repeatMode = IslamicRepeatMode.none;
  bool _shuffle = false;
  Timer? _persistTimer;
  int _loadGeneration = 0;

  IslamicRepeatMode get islamicRepeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffle;
  List<IslamicAudioTrack> get tracks => List.unmodifiable(_tracks);

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.35);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _player.pause();
              break;
          }
        } else {
          _player.setVolume(1);
          // Do not auto-resume after phone calls; user controls resume.
        }
      });
      session.becomingNoisyEventStream.listen((_) => _player.pause());
    } catch (e) {
      debugPrint('AlNoorAudioHandler session config: $e');
    }

    _player.playbackEventStream.listen(_broadcastState);
    _player.sequenceStateStream.listen((_) => _broadcastState());
    _player.durationStream.listen((duration) {
      final item = mediaItem.valueOrNull;
      if (item == null || duration == null) return;
      if (item.duration == duration) return;
      mediaItem.add(item.copyWith(duration: duration));
    });
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        await _onCompleted();
      }
    });
    _player.currentIndexStream.listen((index) {
      if (index == null || index < 0 || index >= _tracks.length) return;
      _publishMediaItem(_tracks[index]);
      _maybeResumeSaved(_tracks[index].id);
    });
    _player.positionStream.listen((position) {
      _schedulePersist(position);
    });
  }

  /// Replaces any previous Quran/Nasheed queue and starts the new source.
  Future<void> playTracks(
    List<IslamicAudioTrack> tracks, {
    int startIndex = 0,
    Map<String, String?> localPaths = const {},
    bool autoplay = true,
  }) async {
    if (tracks.isEmpty) return;
    final generation = ++_loadGeneration;
    final safeIndex = startIndex.clamp(0, tracks.length - 1);

    // Stop splash chime / previous library audio before swapping sources.
    if (IntroAudio.instance.isActive) {
      try {
        await IntroAudio.instance.stop();
      } catch (_) {}
    }
    try {
      await _player.stop();
    } catch (_) {}

    _tracks = List.of(tracks);

    // Publish metadata immediately so mini/full/notification UI update
    // before buffering finishes.
    final immediateItems = <MediaItem>[];
    for (final track in tracks) {
      immediateItems.add(
        await _mediaItemFor(track, localPaths[track.id]),
      );
    }
    if (generation != _loadGeneration) return;
    queue.add(immediateItems);
    mediaItem.add(immediateItems[safeIndex]);
    await _broadcastState();

    final sources = <AudioSource>[
      for (var i = 0; i < tracks.length; i++)
        _sourceFor(tracks[i], localPaths[tracks[i].id], immediateItems[i]),
    ];
    await _playlist.clear();
    await _playlist.addAll(sources);
    if (generation != _loadGeneration) return;

    await _player.setAudioSource(
      _playlist,
      initialIndex: safeIndex,
      initialPosition: Duration.zero,
    );
    if (generation != _loadGeneration) return;

    await _applyLoopMode();
    if (_shuffle) {
      await _player.setShuffleModeEnabled(true);
    }
    if (autoplay) {
      await play();
    } else {
      await _broadcastState();
    }
  }

  AudioSource _sourceFor(
    IslamicAudioTrack track,
    String? localPath,
    MediaItem tag,
  ) {
    if (localPath != null && localPath.isNotEmpty) {
      return AudioSource.file(localPath, tag: tag);
    }
    final url = track.streamUrl.trim();
    if (url.startsWith('assets/')) {
      return AudioSource.asset(url, tag: tag);
    }
    return AudioSource.uri(Uri.parse(url), tag: tag);
  }

  Future<void> _publishMediaItem(IslamicAudioTrack track) async {
    final item = await _mediaItemFor(track);
    final liveDuration = _player.duration;
    mediaItem.add(
      liveDuration == null ? item : item.copyWith(duration: liveDuration),
    );
  }

  Future<MediaItem> _mediaItemFor(
    IslamicAudioTrack track, [
    String? localPath,
  ]) async {
    Uri? art = track.coverUrl != null && track.coverUrl!.isNotEmpty
        ? Uri.tryParse(track.coverUrl!)
        : null;
    art ??= await AudioArtworkCache.uriForAsset(track.coverAsset);
    return MediaItem(
      id: track.id,
      title: track.titleEn,
      artist: track.artistEn,
      album: switch (track.kind) {
        IslamicAudioKind.quran => 'Quran',
        IslamicAudioKind.nasheed => 'Nasheed',
        IslamicAudioKind.adhan => 'Adhan',
        IslamicAudioKind.other => 'Al Noor',
      },
      duration: track.duration ?? _player.duration,
      artUri: art,
      displayTitle: track.titleEn,
      displaySubtitle: track.artistEn,
      extras: track.toMediaExtras(localFilePath: localPath),
    );
  }

  Future<void> _maybeResumeSaved(String trackId) async {
    try {
      final saved = await _positions.load(trackId);
      if (saved == null) return;
      final total = _player.duration;
      if (total != null && saved >= total - const Duration(seconds: 5)) {
        await _positions.clear(trackId);
        return;
      }
      await _player.seek(saved);
    } catch (_) {}
  }

  void _schedulePersist(Duration position) {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(seconds: 2), () async {
      final id = mediaItem.valueOrNull?.id;
      if (id == null) return;
      final total = _player.duration;
      if (total != null && position >= total - const Duration(seconds: 5)) {
        await _positions.clear(id);
      } else {
        await _positions.save(id, position);
      }
    });
  }

  Future<void> _onCompleted() async {
    switch (_repeatMode) {
      case IslamicRepeatMode.one:
        await _player.seek(Duration.zero);
        await _player.play();
        break;
      case IslamicRepeatMode.all:
        if (_player.hasNext) {
          await skipToNext();
        } else {
          await _player.seek(Duration.zero, index: 0);
          await _player.play();
        }
        break;
      case IslamicRepeatMode.none:
        if (_player.hasNext) {
          await skipToNext();
        } else {
          final id = mediaItem.valueOrNull?.id;
          if (id != null) await _positions.clear(id);
          await stop();
        }
        break;
    }
  }

  Future<void> setIslamicRepeatMode(IslamicRepeatMode mode) async {
    _repeatMode = mode;
    await _applyLoopMode();
    await _broadcastState();
  }

  Future<void> _applyLoopMode() async {
    await _player.setLoopMode(LoopMode.off);
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    _shuffle = enabled;
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(playbackState.value.copyWith(
      shuffleMode: enabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    final id = mediaItem.valueOrNull?.id;
    if (id != null) {
      await _positions.save(id, _player.position);
    }
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    await _player.seekToPrevious();
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await setIslamicRepeatMode(IslamicRepeatMode.none);
        break;
      case AudioServiceRepeatMode.one:
        await setIslamicRepeatMode(IslamicRepeatMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await setIslamicRepeatMode(IslamicRepeatMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await setShuffleEnabled(shuffleMode != AudioServiceShuffleMode.none);
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case 'setVolume':
        final volume = (extras?['volume'] as num?)?.toDouble() ?? 1;
        await _player.setVolume(volume.clamp(0.0, 1.0));
        return null;
      case 'replay':
        await _player.seek(Duration.zero);
        await _player.play();
        return null;
      case 'seekForward':
        final step = Duration(
          seconds: (extras?['seconds'] as num?)?.toInt() ?? 10,
        );
        final target = _player.position + step;
        final total = _player.duration;
        await _player.seek(
          total != null && target > total ? total : target,
        );
        return null;
      case 'seekBackward':
        final step = Duration(
          seconds: (extras?['seconds'] as num?)?.toInt() ?? 10,
        );
        final target = _player.position - step;
        await _player.seek(target < Duration.zero ? Duration.zero : target);
        return null;
      case 'clearQueue':
        _loadGeneration++;
        await stop();
        _tracks = [];
        await _playlist.clear();
        queue.add(const []);
        mediaItem.add(null);
        return null;
      default:
        return super.customAction(name, extras);
    }
  }

  Future<void> _broadcastState([PlaybackEvent? event]) async {
    final playing = _player.playing;
    final processing = _transformProcessing(_player.processingState);
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setSpeed,
        MediaAction.setRepeatMode,
        MediaAction.setShuffleMode,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processing,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
      repeatMode: switch (_repeatMode) {
        IslamicRepeatMode.none => AudioServiceRepeatMode.none,
        IslamicRepeatMode.one => AudioServiceRepeatMode.one,
        IslamicRepeatMode.all => AudioServiceRepeatMode.all,
      },
      shuffleMode: _shuffle
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    ));
  }

  AudioProcessingState _transformProcessing(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }
}

Future<AudioHandler> initAlNoorAudioService() {
  return AudioService.init(
    builder: () => AlNoorAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.islamic.backtoprayer.back_to_prayer.audio',
      androidNotificationChannelName: 'Islamic audio',
      androidNotificationChannelDescription:
          'Quran, nasheeds, and other Islamic playback controls',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/launcher_icon',
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(seconds: 10),
    ),
  );
}

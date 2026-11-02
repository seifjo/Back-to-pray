import 'package:flutter/foundation.dart';

import '../core/services/islamic_audio_player.dart';
import '../core/services/nasheed_offline_store.dart';
import '../core/services/nasheed_preferences_store.dart';
import '../data/nasheed_catalog.dart';
import '../models/islamic_audio.dart';

class NasheedLibraryProvider extends ChangeNotifier {
  NasheedLibraryProvider({
    NasheedPreferencesStore? store,
    NasheedOfflineStore? offline,
    IslamicAudioPlayer? player,
  })  : _store = store ?? NasheedPreferencesStore(),
        _offline = offline ?? NasheedOfflineStore(),
        _player = player;

  final NasheedPreferencesStore _store;
  final NasheedOfflineStore _offline;
  IslamicAudioPlayer? _player;

  bool _loading = true;
  String? _error;
  String _query = '';
  String? _categoryFilter;
  NasheedSort _sort = NasheedSort.titleAsc;
  bool _favoritesOnly = false;
  bool _playableOnly = false;
  Set<String> _favorites = {};
  List<String> _recentIds = [];
  Set<String> _downloaded = {};
  String? _downloadingId;
  double _downloadProgress = 0;

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  String? get categoryFilter => _categoryFilter;
  NasheedSort get sort => _sort;
  bool get favoritesOnly => _favoritesOnly;
  bool get playableOnly => _playableOnly;
  Set<String> get favorites => _favorites;
  String? get downloadingId => _downloadingId;
  double get downloadProgress => _downloadProgress;
  String get attributionEn => NasheedCatalog.attributionEn;
  String get attributionAr => NasheedCatalog.attributionAr;
  List<NasheedCategory> get categories => NasheedCatalog.categories;

  void attachPlayer(IslamicAudioPlayer player) {
    if (identical(_player, player)) return;
    _player = player;
  }

  IslamicAudioPlayer? get player => _player;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (NasheedCatalog.all.isEmpty) {
        throw StateError('Nasheed catalog is empty');
      }
      _favorites = await _store.loadFavorites();
      _recentIds = await _store.loadRecent();
      final downloaded = <String>{};
      for (final track in NasheedCatalog.all) {
        if (await _offline.isSaved(track.id)) {
          downloaded.add(track.id);
        }
      }
      _downloaded = downloaded;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<IslamicAudioTrack> get filtered => NasheedCatalog.search(
        query: _query,
        categoryId: _categoryFilter,
        sort: _sort,
        playableOnly: _playableOnly,
        favoritesOnly: _favoritesOnly,
        favoriteIds: _favorites,
      );

  List<IslamicAudioTrack> get featured => NasheedCatalog.featured();

  List<IslamicAudioTrack> get recommended => NasheedCatalog.recommended();

  List<IslamicAudioTrack> get trending => NasheedCatalog.trending();

  List<IslamicAudioTrack> get mostPopular => NasheedCatalog.mostPopular();

  List<IslamicAudioTrack> get shortFormFavorites =>
      NasheedCatalog.shortFormFavorites();

  List<IslamicAudioTrack> get newReleases => NasheedCatalog.newReleases();

  List<IslamicAudioTrack> get pendingLicense =>
      NasheedCatalog.pendingLicense();

  List<IslamicAudioTrack> get recent {
    return [
      for (final id in _recentIds)
        if (NasheedCatalog.byId(id) != null) NasheedCatalog.byId(id)!,
    ];
  }

  /// Continue listening = most recent track when any history exists.
  List<IslamicAudioTrack> get continueListening {
    final list = recent;
    if (list.isEmpty) return const [];
    return [list.first];
  }

  List<IslamicAudioTrack> get favoriteTracks {
    return [
      for (final id in _favorites)
        if (NasheedCatalog.byId(id) != null) NasheedCatalog.byId(id)!,
    ];
  }

  List<IslamicAudioTrack> related(IslamicAudioTrack track) =>
      NasheedCatalog.related(track);

  IslamicAudioTrack? byId(String id) => NasheedCatalog.byId(id);

  bool isFavorite(String id) => _favorites.contains(id);

  bool isDownloaded(String id) => _downloaded.contains(id);

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setSort(NasheedSort value) {
    _sort = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  void setPlayableOnly(bool value) {
    _playableOnly = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.add(id)) {
      _favorites.remove(id);
    }
    await _store.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> markPlayed(String id) async {
    _recentIds.remove(id);
    _recentIds.insert(0, id);
    if (_recentIds.length > 30) {
      _recentIds = _recentIds.take(30).toList();
    }
    await _store.saveRecent(_recentIds);
    notifyListeners();
  }

  /// Plays [track] via the shared [IslamicAudioPlayer]. Skips unavailable audio.
  Future<String?> play(IslamicAudioTrack track) async {
    if (!track.audioAvailable) {
      _error = 'audio_unavailable';
      notifyListeners();
      return 'audio_unavailable';
    }
    final player = _player;
    if (player == null) {
      _error = 'Audio player is not ready';
      notifyListeners();
      return 'player_not_ready';
    }
    final queue = NasheedCatalog.playable();
    final index = queue.indexWhere((t) => t.id == track.id);
    final localPaths = <String, String?>{};
    final local = await _offline.localPath(track.id);
    if (local != null) localPaths[track.id] = local;
    await player.playQueue(
      queue,
      startIndex: index < 0 ? 0 : index,
      localPaths: localPaths,
    );
    await markPlayed(track.id);
    return null;
  }

  Future<void> download(IslamicAudioTrack track) async {
    if (!track.audioAvailable ||
        !track.downloadAllowed ||
        _downloadingId != null) {
      return;
    }
    _downloadingId = track.id;
    _downloadProgress = 0;
    _error = null;
    notifyListeners();
    try {
      await _offline.download(
        track.id,
        track.streamUrl,
        onProgress: (value) {
          _downloadProgress = value;
          notifyListeners();
        },
      );
      _downloaded = {..._downloaded, track.id};
    } catch (e) {
      _error = e.toString();
    } finally {
      _downloadingId = null;
      _downloadProgress = 0;
      notifyListeners();
    }
  }

  Future<void> removeDownload(String trackId) async {
    await _offline.delete(trackId);
    _downloaded = {..._downloaded}..remove(trackId);
    notifyListeners();
  }
}

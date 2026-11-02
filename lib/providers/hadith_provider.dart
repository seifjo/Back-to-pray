import 'package:flutter/foundation.dart';

import '../core/services/hadith_preferences_store.dart';
import '../core/services/hadith_service.dart';
import '../models/hadith.dart';

class HadithProvider extends ChangeNotifier {
  HadithProvider({
    HadithService? service,
    HadithPreferencesStore? store,
  })  : _service = service ?? HadithService(),
        _store = store ?? HadithPreferencesStore();

  final HadithService _service;
  final HadithPreferencesStore _store;

  bool _loading = true;
  String? _error;
  String _query = '';
  String? _collectionFilter;
  String? _categoryFilter;
  String? _gradeFilter;
  int _visibleCount = 40;
  Set<String> _favorites = {};
  List<String> _recentIds = [];
  String? _downloadingId;
  double _downloadProgress = 0;

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  String? get collectionFilter => _collectionFilter;
  String? get categoryFilter => _categoryFilter;
  String? get gradeFilter => _gradeFilter;
  Set<String> get favorites => _favorites;
  String? get downloadingId => _downloadingId;
  double get downloadProgress => _downloadProgress;
  String get attribution => _service.attributionText;
  Set<String> get cachedCollections => _service.cachedCollections;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.initialize();
      _favorites = await _store.loadFavorites();
      _recentIds = await _store.loadRecent();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  HadithItem? hadithOfTheDay() {
    if (_service.all.isEmpty) return null;
    return _service.hadithOfTheDay();
  }

  HadithItem? featuredHadith() {
    if (_service.all.isEmpty) return null;
    return _service.featuredHadith();
  }

  bool get isBrowsingHome =>
      _query.isEmpty &&
      _collectionFilter == null &&
      _categoryFilter == null &&
      _gradeFilter == null;

  List<HadithItem> get filtered {
    return _service.search(
      query: _query,
      collectionId: _collectionFilter,
      categoryId: _categoryFilter,
      gradeFilter: _gradeFilter,
    );
  }

  List<HadithItem> get visiblePage => filtered.take(_visibleCount).toList();

  bool get canLoadMore => _visibleCount < filtered.length;

  List<HadithItem> get favoriteHadiths {
    return [
      for (final id in _favorites)
        if (_service.byId(id) != null) _service.byId(id)!,
    ];
  }

  List<HadithItem> get recentHadiths {
    return [
      for (final id in _recentIds)
        if (_service.byId(id) != null) _service.byId(id)!,
    ];
  }

  HadithItem? byId(String id) => _service.byId(id);

  List<HadithItem> related(HadithItem item) => _service.related(item);

  void setQuery(String value) {
    _query = value;
    _visibleCount = 40;
    notifyListeners();
  }

  void setCollectionFilter(String? value) {
    _collectionFilter = value;
    _visibleCount = 40;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _categoryFilter = value;
    _visibleCount = 40;
    notifyListeners();
  }

  void setGradeFilter(String? value) {
    _gradeFilter = value;
    _visibleCount = 40;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _collectionFilter = null;
    _categoryFilter = null;
    _gradeFilter = null;
    _visibleCount = 40;
    notifyListeners();
  }

  void loadMore() {
    if (!canLoadMore) return;
    _visibleCount += 40;
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.add(id)) {
      _favorites.remove(id);
    }
    await _store.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> markViewed(String id) async {
    _recentIds.remove(id);
    _recentIds.insert(0, id);
    if (_recentIds.length > 30) {
      _recentIds = _recentIds.take(30).toList();
    }
    await _store.saveRecent(_recentIds);
    notifyListeners();
  }

  Future<void> downloadCollection(String collectionId) async {
    if (_downloadingId != null) return;
    _downloadingId = collectionId;
    _downloadProgress = 0;
    _error = null;
    notifyListeners();
    try {
      await _service.downloadCollection(
        collectionId,
        onProgress: (value) {
          _downloadProgress = value;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _downloadingId = null;
      notifyListeners();
    }
  }
}

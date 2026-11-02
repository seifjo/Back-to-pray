import 'package:flutter/foundation.dart';

import '../core/services/dua_preferences_store.dart';
import '../data/dua_library.dart';
import '../models/dua.dart';

class DuaProvider extends ChangeNotifier {
  DuaProvider({DuaPreferencesStore? store})
      : _store = store ?? DuaPreferencesStore();

  final DuaPreferencesStore _store;

  bool _loading = true;
  String? _error;
  String _query = '';
  String? _categoryFilter;
  bool _favoritesOnly = false;
  Set<String> _favorites = {};
  List<String> _recentIds = [];
  double _arabicFontSize = DuaPreferencesStore.defaultArabicFontSize;
  int _visibleCount = 30;

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  String? get categoryFilter => _categoryFilter;
  bool get favoritesOnly => _favoritesOnly;
  Set<String> get favorites => _favorites;
  double get arabicFontSize => _arabicFontSize;
  String get attributionEn => DuaLibrary.attributionEn;
  String get attributionAr => DuaLibrary.attributionAr;

  List<DuaCategoryMeta> get categories => DuaLibrary.categories;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Touch catalog so any shared-Adhkar wiring errors surface early.
      if (DuaLibrary.all.isEmpty) {
        throw StateError('Dua catalog is empty');
      }
      _favorites = await _store.loadFavorites();
      _recentIds = await _store.loadRecent();
      _arabicFontSize = await _store.loadArabicFontSize();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<DuaItem> get filtered {
    return DuaLibrary.search(
      query: _query,
      categoryId: _categoryFilter,
      favoritesOnly: _favoritesOnly,
      favoriteIds: _favorites,
    );
  }

  List<DuaItem> get visiblePage => filtered.take(_visibleCount).toList();

  bool get canLoadMore => _visibleCount < filtered.length;

  List<DuaItem> get favoriteDuas {
    return [
      for (final id in _favorites)
        if (DuaLibrary.byId(id) != null) DuaLibrary.byId(id)!,
    ];
  }

  List<DuaItem> get recentDuas {
    return [
      for (final id in _recentIds)
        if (DuaLibrary.byId(id) != null) DuaLibrary.byId(id)!,
    ];
  }

  DuaItem? byId(String id) => DuaLibrary.byId(id);

  List<DuaItem> related(DuaItem item) => DuaLibrary.related(item);

  DuaCategoryMeta? categoryMeta(String id) => DuaLibrary.categoryById(id);

  bool isFavorite(String id) => _favorites.contains(id);

  void setQuery(String value) {
    _query = value;
    _visibleCount = 30;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _categoryFilter = value;
    _favoritesOnly = false;
    _visibleCount = 30;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    if (value) _categoryFilter = null;
    _visibleCount = 30;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _categoryFilter = null;
    _favoritesOnly = false;
    _visibleCount = 30;
    notifyListeners();
  }

  void loadMore() {
    if (!canLoadMore) return;
    _visibleCount += 30;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favorites.contains(id)) {
      _favorites = {..._favorites}..remove(id);
    } else {
      _favorites = {..._favorites, id};
    }
    notifyListeners();
    await _store.saveFavorites(_favorites);
  }

  Future<void> markViewed(String id) async {
    final next = [id, ..._recentIds.where((item) => item != id)];
    _recentIds = next.take(20).toList();
    notifyListeners();
    await _store.saveRecent(_recentIds);
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size.clamp(
      DuaPreferencesStore.minArabicFontSize,
      DuaPreferencesStore.maxArabicFontSize,
    );
    notifyListeners();
    await _store.saveArabicFontSize(_arabicFontSize);
  }
}

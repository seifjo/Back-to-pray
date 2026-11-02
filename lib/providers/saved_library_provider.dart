import 'package:flutter/foundation.dart';

import '../core/services/saved_library_repository.dart';
import '../models/saved_library.dart';

enum SavedLibrarySort {
  dateSavedNewest,
  dateSavedOldest,
}

class SavedLibraryProvider extends ChangeNotifier {
  SavedLibraryProvider({
    SavedLibraryRepository? repository,
  }) : _repository = repository ?? SavedLibraryRepository();

  final SavedLibraryRepository _repository;

  bool _loading = true;
  String? _error;
  String _query = '';
  SavedContentType? _typeFilter;
  SavedLibrarySort _sort = SavedLibrarySort.dateSavedNewest;
  List<SavedLibraryItem> _items = const [];
  List<String> _recentViewKeys = const [];

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  SavedContentType? get typeFilter => _typeFilter;
  SavedLibrarySort get sort => _sort;
  List<SavedLibraryItem> get allItems => _items;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.loadItems();
      _recentViewKeys = await _repository.loadRecentlyViewedLibraryKeys();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => initialize();

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setTypeFilter(SavedContentType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setSort(SavedLibrarySort sort) {
    _sort = sort;
    notifyListeners();
  }

  List<SavedLibraryItem> get filtered {
    final q = _query.trim().toLowerCase();
    var list = _items.where((item) {
      if (_typeFilter != null && item.type != _typeFilter) return false;
      if (q.isEmpty) return true;
      final haystack = [
        item.titleEn,
        item.titleAr,
        item.subtitleEn,
        item.subtitleAr,
        item.previewEn ?? '',
        item.previewAr ?? '',
        item.sourceId,
        item.type.name,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case SavedLibrarySort.dateSavedNewest:
          return b.savedAt.compareTo(a.savedAt);
        case SavedLibrarySort.dateSavedOldest:
          return a.savedAt.compareTo(b.savedAt);
      }
    });
    return list;
  }

  List<SavedLibraryItem> get recentlySaved => filtered.take(8).toList();

  List<SavedLibraryItem> get recentlyViewed {
    final byKey = {for (final item in _items) item.libraryKey: item};
    final result = <SavedLibraryItem>[];
    for (final key in _recentViewKeys) {
      final item = byKey[key];
      if (item == null) continue;
      if (_typeFilter != null && item.type != _typeFilter) continue;
      result.add(item);
      if (result.length >= 8) break;
    }
    return result;
  }

  int countFor(SavedContentType type) =>
      _items.where((item) => item.type == type).length;

  Future<void> remove(SavedLibraryItem item) async {
    await _repository.remove(item);
    await refresh();
  }

  Future<void> markOpened(SavedLibraryItem item) async {
    await _repository.markOpened(item.libraryKey);
    _recentViewKeys = [
      item.libraryKey,
      ..._recentViewKeys.where((key) => key != item.libraryKey),
    ];
    notifyListeners();
  }

  /// Pure helper used by tests for filter logic.
  static List<SavedLibraryItem> filterItems({
    required List<SavedLibraryItem> items,
    String query = '',
    SavedContentType? type,
    SavedLibrarySort sort = SavedLibrarySort.dateSavedNewest,
  }) {
    final provider = SavedLibraryProvider();
    provider._items = items;
    provider._query = query;
    provider._typeFilter = type;
    provider._sort = sort;
    return provider.filtered;
  }
}

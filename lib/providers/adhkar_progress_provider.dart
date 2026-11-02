import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/adhkar_library.dart';
import '../models/adhkar.dart';

/// One archived day of Adhkar progress (historical only; not shown as "today").
class AdhkarDayRecord {
  final String dateKey;
  final int completedCategories;
  final int totalCategories;
  final int completedItems;
  final int totalItems;
  final List<String> completedCategoryIds;
  final Map<String, int> counts;

  const AdhkarDayRecord({
    required this.dateKey,
    required this.completedCategories,
    required this.totalCategories,
    required this.completedItems,
    required this.totalItems,
    required this.completedCategoryIds,
    required this.counts,
  });

  bool get allComplete =>
      totalCategories > 0 && completedCategories >= totalCategories;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'completedCategories': completedCategories,
        'totalCategories': totalCategories,
        'completedItems': completedItems,
        'totalItems': totalItems,
        'completedCategoryIds': completedCategoryIds,
        'counts': counts,
      };

  factory AdhkarDayRecord.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['counts'];
    final counts = <String, int>{};
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        counts[entry.key.toString()] = (entry.value as num).toInt();
      }
    }
    final ids = (json['completedCategoryIds'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    return AdhkarDayRecord(
      dateKey: json['dateKey'] as String? ?? '',
      completedCategories: (json['completedCategories'] as num?)?.toInt() ?? 0,
      totalCategories: (json['totalCategories'] as num?)?.toInt() ?? 0,
      completedItems: (json['completedItems'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      completedCategoryIds: ids,
      counts: counts,
    );
  }
}

/// Tracks Adhkar repetitions for the current local calendar day.
///
/// Favorites persist across days. Daily counters reset when the local date
/// changes (on launch, resume, or explicit [ensureToday]). Prior days are
/// archived under [history] and are never shown as today's completion.
class AdhkarProgressProvider extends ChangeNotifier {
  static const _countKey = 'adhkar_counts_v1';
  static const _favoriteKey = 'adhkar_favorites_v1';
  static const _activeDatePrefKey = 'adhkar_active_date_v1';
  static const _historyKey = 'adhkar_history_v1';
  static const _contentVersionKey = 'adhkar_content_version_v1';
  static const _recentKey = 'adhkar_recent_v1';
  static const _maxRecent = 24;

  AdhkarProgressProvider({
    DateTime Function()? clock,
    Future<SharedPreferences> Function()? prefsFactory,
    bool autoLoad = true,
  })  : _clock = clock ?? DateTime.now,
        _prefsFactory = prefsFactory ?? SharedPreferences.getInstance {
    if (autoLoad) {
      load();
    }
  }

  final DateTime Function() _clock;
  final Future<SharedPreferences> Function() _prefsFactory;

  Map<String, int> _counts = {};
  Set<String> _favorites = {};
  Map<String, AdhkarDayRecord> _history = {};
  List<String> _recent = [];
  String? _activeDate;
  bool _loaded = false;
  bool _didResetToday = false;

  bool get loaded => _loaded;
  Set<String> get favorites => _favorites;
  List<String> get recentKeys => List.unmodifiable(_recent);
  String? get activeDateKey => _activeDate;
  bool get didResetOnLastCheck => _didResetToday;
  Map<String, AdhkarDayRecord> get history => Map.unmodifiable(_history);

  DateTime get today => _dateOnly(_clock());

  String get todayKey => dateKey(today);

  static String itemKey(String categoryId, String itemId) =>
      '$categoryId::$itemId';

  static String dateKey(DateTime date) {
    final d = _dateOnly(date);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int countFor(String categoryId, String itemId) =>
      _counts[itemKey(categoryId, itemId)] ?? 0;

  bool isFavorite(String categoryId, String itemId) =>
      _favorites.contains(itemKey(categoryId, itemId));

  double progressFor(AdhkarCategory category) {
    if (category.items.isEmpty) return 0;
    var done = 0;
    for (final item in category.items) {
      final id = item.id.isEmpty ? item.arabicText : item.id;
      if (countFor(category.stableId, id) >= item.repetitions) done++;
    }
    return done / category.items.length;
  }

  bool isCategoryComplete(AdhkarCategory category) =>
      progressFor(category) >= 1;

  List<AdhkarCategory> get completedCategoriesToday =>
      AdhkarLibrary.categories.where(isCategoryComplete).toList();

  List<AdhkarCategory> get remainingCategoriesToday =>
      AdhkarLibrary.categories.where((c) => !isCategoryComplete(c)).toList();

  int get todayCompletedCategoryCount => completedCategoriesToday.length;

  int get todayTotalCategoryCount => AdhkarLibrary.categories.length;

  int get todayCompletedItemCount {
    var done = 0;
    for (final category in AdhkarLibrary.categories) {
      for (final item in category.items) {
        final id = item.id.isEmpty ? item.arabicText : item.id;
        if (countFor(category.stableId, id) >= item.repetitions) done++;
      }
    }
    return done;
  }

  int get todayTotalItemCount => AdhkarLibrary.categories.fold<int>(
        0,
        (sum, category) => sum + category.items.length,
      );

  double get todayOverallProgress {
    final total = todayTotalItemCount;
    if (total == 0) return 0;
    return todayCompletedItemCount / total;
  }

  bool get todayFullyComplete =>
      todayTotalCategoryCount > 0 &&
      todayCompletedCategoryCount >= todayTotalCategoryCount;

  AdhkarDayRecord? historyFor(String dateKey) => _history[dateKey];

  Future<void> load() async {
    final prefs = await _prefsFactory();
    final rawCounts = prefs.getString(_countKey);
    final rawFavorites = prefs.getStringList(_favoriteKey);
    final rawHistory = prefs.getString(_historyKey);
    final rawRecent = prefs.getStringList(_recentKey);
    _activeDate = prefs.getString(_activeDatePrefKey);

    if (rawCounts != null) {
      try {
        final decoded = jsonDecode(rawCounts);
        if (decoded is Map) {
          _counts = decoded.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          );
        }
      } catch (e) {
        debugPrint('Adhkar count load failed: $e');
      }
    }
    _favorites = rawFavorites?.toSet() ?? {};
    _recent = rawRecent ?? [];
    _history = _decodeHistory(rawHistory);

    final storedContentVersion = prefs.getInt(_contentVersionKey);
    if (storedContentVersion != AdhkarLibrary.contentVersion) {
      await prefs.setInt(_contentVersionKey, AdhkarLibrary.contentVersion);
    }

    _loaded = true;
    await ensureToday();
    notifyListeners();
  }

  /// Compare last active local date to today. Safe to call on resume.
  Future<bool> ensureToday() async {
    final current = todayKey;
    _didResetToday = false;

    if (_activeDate == null) {
      // First run or migration: treat existing counts as today's without archive.
      _activeDate = current;
      await _persistActiveDate();
      notifyListeners();
      return false;
    }

    if (_activeDate == current) {
      notifyListeners();
      return false;
    }

    // Date changed (overnight, multi-day gap, or timezone calendar shift).
    await _archiveActiveDayIfNeeded();
    _counts = {};
    _activeDate = current;
    _didResetToday = true;
    await _persistActiveDate();
    await _saveCounts();
    notifyListeners();
    return true;
  }

  /// Alias used by app shell / lifecycle hooks.
  Future<bool> checkDailyReset() => ensureToday();

  Future<void> _archiveActiveDayIfNeeded() async {
    final previous = _activeDate;
    if (previous == null || previous.isEmpty) return;
    // Do not duplicate: keep the first archived snapshot for that day.
    if (_history.containsKey(previous)) return;
    if (_counts.isEmpty) return;

    final completedIds = <String>[
      for (final category in AdhkarLibrary.categories)
        if (isCategoryComplete(category)) category.stableId,
    ];
    _history[previous] = AdhkarDayRecord(
      dateKey: previous,
      completedCategories: completedIds.length,
      totalCategories: AdhkarLibrary.categories.length,
      completedItems: todayCompletedItemCount,
      totalItems: todayTotalItemCount,
      completedCategoryIds: completedIds,
      counts: Map<String, int>.from(_counts),
    );
    await _saveHistory();
  }

  Map<String, AdhkarDayRecord> _decodeHistory(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, AdhkarDayRecord>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          result[entry.key.toString()] = AdhkarDayRecord.fromJson(value);
        } else if (value is Map) {
          result[entry.key.toString()] = AdhkarDayRecord.fromJson(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      }
      return result;
    } catch (e) {
      debugPrint('Adhkar history load failed: $e');
      return {};
    }
  }

  Future<void> increment(String categoryId, String itemId, int limit) async {
    await ensureToday();
    final key = itemKey(categoryId, itemId);
    final next = (_counts[key] ?? 0) + 1;
    if (next > limit) return;
    _counts[key] = next;
    notifyListeners();
    await _saveCounts();
  }

  Future<void> reset(String categoryId, String itemId) async {
    await ensureToday();
    _counts.remove(itemKey(categoryId, itemId));
    notifyListeners();
    await _saveCounts();
  }

  Future<void> markComplete(String categoryId, AdhkarItem item) async {
    await ensureToday();
    final id = item.id.isEmpty ? item.arabicText : item.id;
    _counts[itemKey(categoryId, id)] = item.repetitions;
    notifyListeners();
    await _saveCounts();
  }

  Future<void> toggleFavorite(String categoryId, String itemId) async {
    final key = itemKey(categoryId, itemId);
    if (!_favorites.add(key)) _favorites.remove(key);
    notifyListeners();
    final prefs = await _prefsFactory();
    await prefs.setStringList(_favoriteKey, _favorites.toList());
  }

  Future<void> recordView(String categoryId, String itemId) async {
    final key = itemKey(categoryId, itemId);
    _recent.remove(key);
    _recent.insert(0, key);
    if (_recent.length > _maxRecent) {
      _recent = _recent.take(_maxRecent).toList();
    }
    notifyListeners();
    final prefs = await _prefsFactory();
    await prefs.setStringList(_recentKey, _recent);
  }

  List<({AdhkarCategory category, AdhkarItem item})> favoriteItems() {
    final result = <({AdhkarCategory category, AdhkarItem item})>[];
    for (final category in AdhkarLibrary.categories) {
      for (final item in category.items) {
        final id = item.id.isEmpty ? item.arabicText : item.id;
        if (isFavorite(category.stableId, id)) {
          result.add((category: category, item: item));
        }
      }
    }
    return result;
  }

  List<({AdhkarCategory category, AdhkarItem item})> recentlyViewed({
    int limit = 12,
  }) {
    final result = <({AdhkarCategory category, AdhkarItem item})>[];
    for (final key in _recent) {
      final parts = key.split('::');
      if (parts.length != 2) continue;
      final category = AdhkarLibrary.byId(parts[0]);
      if (category == null) continue;
      for (final item in category.items) {
        final id = item.id.isEmpty ? item.arabicText : item.id;
        if (id == parts[1]) {
          result.add((category: category, item: item));
          break;
        }
      }
      if (result.length >= limit) break;
    }
    return result;
  }

  Future<void> _saveCounts() async {
    final prefs = await _prefsFactory();
    await prefs.setString(_countKey, jsonEncode(_counts));
  }

  Future<void> _persistActiveDate() async {
    final prefs = await _prefsFactory();
    if (_activeDate != null) {
      await prefs.setString(_activeDatePrefKey, _activeDate!);
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await _prefsFactory();
    final encoded = {
      for (final entry in _history.entries) entry.key: entry.value.toJson(),
    };
    await prefs.setString(_historyKey, jsonEncode(encoded));
  }
}

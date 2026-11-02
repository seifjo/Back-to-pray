import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/services/device_feedback.dart';
import '../core/services/tasbeeh_store.dart';
import '../data/tasbeeh_catalog.dart';
import '../models/tasbeeh.dart';

class TasbeehProvider extends ChangeNotifier {
  TasbeehProvider({TasbeehStore? store}) : _store = store ?? TasbeehStore();

  final TasbeehStore _store;

  bool _loaded = false;
  String _selectedId = TasbeehCatalog.builtIn.first.id;
  final Map<String, int> _sessionCounts = {};
  final List<int> _undoStack = [];
  List<TasbeehDhikr> _custom = [];
  Set<String> _favorites = {};
  final Map<String, int> _personalTargets = {};
  final Map<String, TasbeehDailyStat> _history = {};
  bool _soundEnabled = false;
  bool _hapticEnabled = true;

  bool get loaded => _loaded;
  String get selectedId => _selectedId;
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  List<TasbeehDhikr> get allDhikr {
    final builtIn = [
      for (final item in TasbeehCatalog.builtIn)
        item.copyWith(
          isFavorite: _favorites.contains(item.id),
          personalTarget: _personalTargets[item.id],
          clearPersonalTarget: !_personalTargets.containsKey(item.id),
        ),
    ];
    final customs = [
      for (final item in _custom)
        item.copyWith(
          isFavorite: _favorites.contains(item.id),
          personalTarget: _personalTargets[item.id] ?? item.personalTarget,
          clearPersonalTarget: !_personalTargets.containsKey(item.id) &&
              item.personalTarget == null,
        ),
    ];
    return [...builtIn, ...customs];
  }

  List<TasbeehDhikr> get favoriteDhikr =>
      allDhikr.where((item) => item.isFavorite).toList();

  TasbeehDhikr get selected {
    return allDhikr.firstWhere(
      (item) => item.id == _selectedId,
      orElse: () => allDhikr.first,
    );
  }

  int get currentCount => _sessionCounts[_selectedId] ?? 0;

  int sessionCountFor(String id) => _sessionCounts[id] ?? 0;

  int? get activeTarget => selected.activeTarget;

  double get progress {
    final target = activeTarget;
    if (target == null || target <= 0) return 0;
    return (currentCount / target).clamp(0, 1);
  }

  bool get canUndo => _undoStack.isNotEmpty;

  List<TasbeehDailyStat> get historyDesc {
    final list = _history.values.toList()
      ..sort((a, b) => b.day.compareTo(a.day));
    return list;
  }

  Future<void> load() async {
    final state = await _store.load();
    _selectedId =
        state['selectedId']?.toString() ?? TasbeehCatalog.builtIn.first.id;
    _soundEnabled = state['soundEnabled'] as bool? ?? false;
    _hapticEnabled = state['hapticEnabled'] as bool? ?? true;

    _sessionCounts
      ..clear()
      ..addAll(_intMap(state['sessionCounts']));
    _personalTargets
      ..clear()
      ..addAll(_intMap(state['personalTargets']));

    final favorites = state['favorites'];
    _favorites = favorites is List
        ? favorites.map((e) => e.toString()).toSet()
        : <String>{};

    final custom = state['custom'];
    _custom = [];
    if (custom is List) {
      for (final item in custom) {
        if (item is Map) {
          _custom.add(TasbeehDhikr.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    _history.clear();
    final history = state['history'];
    if (history is List) {
      for (final item in history) {
        if (item is Map) {
          final stat =
              TasbeehDailyStat.fromJson(Map<String, dynamic>.from(item));
          if (stat.day.isNotEmpty) _history[stat.day] = stat;
        }
      }
    }

    _undoStack.clear();
    _loaded = true;
    notifyListeners();
  }

  Map<String, int> _intMap(dynamic raw) {
    final map = <String, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is num) map[key.toString()] = value.toInt();
      });
    }
    return map;
  }

  Future<void> _persist() async {
    await _store.save({
      'selectedId': _selectedId,
      'sessionCounts': _sessionCounts,
      'custom': _custom.map((item) => item.toJson()).toList(),
      'favorites': _favorites.toList(),
      'personalTargets': _personalTargets,
      'history': _history.values.map((item) => item.toJson()).toList(),
      'soundEnabled': _soundEnabled,
      'hapticEnabled': _hapticEnabled,
    });
  }

  String _todayKey([DateTime? now]) {
    final day = now ?? DateTime.now();
    final mm = day.month.toString().padLeft(2, '0');
    final dd = day.day.toString().padLeft(2, '0');
    return '${day.year}-$mm-$dd';
  }

  Future<void> selectDhikr(String id) async {
    if (_selectedId == id) return;
    _selectedId = id;
    _undoStack.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> increment() async {
    final next = currentCount + 1;
    _undoStack.add(currentCount);
    if (_undoStack.length > 100) {
      _undoStack.removeAt(0);
    }
    _sessionCounts[_selectedId] = next;
    _recordHistory(_selectedId, 1);
    if (_hapticEnabled) {
      // Fire immediately; do not wait on platform channel.
      // ignore: unawaited_futures
      DeviceFeedback.vibrate();
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    await _persist();
    notifyListeners();
  }

  void _recordHistory(String dhikrId, int delta) {
    final key = _todayKey();
    final existing = _history[key]?.byDhikr ?? <String, int>{};
    final updated = Map<String, int>.from(existing);
    updated[dhikrId] = (updated[dhikrId] ?? 0) + delta;
    if (updated[dhikrId]! <= 0) updated.remove(dhikrId);
    _history[key] = TasbeehDailyStat(day: key, byDhikr: updated);
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    final previous = _undoStack.removeLast();
    final current = currentCount;
    _sessionCounts[_selectedId] = previous;
    if (current > previous) {
      _recordHistory(_selectedId, previous - current);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> resetCurrent({bool confirmed = false}) async {
    if (!confirmed) return;
    final current = currentCount;
    if (current > 0) {
      _recordHistory(_selectedId, -current);
    }
    _sessionCounts[_selectedId] = 0;
    _undoStack.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.add(id)) _favorites.remove(id);
    await _persist();
    notifyListeners();
  }

  Future<void> setPersonalTarget(String id, int? target) async {
    if (target == null || target <= 0) {
      _personalTargets.remove(id);
    } else {
      _personalTargets[id] = target;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    if (value) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    await _persist();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    notifyListeners();
    if (value) {
      // Preview so the toggle feels immediate; fail soft if unavailable.
      // ignore: unawaited_futures
      DeviceFeedback.vibrate();
    }
    await _persist();
  }

  Future<void> addCustom({
    required String arabic,
    required String nameEn,
    required String nameAr,
    int? personalTarget,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    _custom.add(
      TasbeehDhikr(
        id: id,
        arabic: arabic.trim(),
        nameEn: nameEn.trim().isEmpty ? arabic.trim() : nameEn.trim(),
        nameAr: nameAr.trim().isEmpty ? arabic.trim() : nameAr.trim(),
        personalTarget: personalTarget,
        isCustom: true,
      ),
    );
    if (personalTarget != null && personalTarget > 0) {
      _personalTargets[id] = personalTarget;
    }
    _selectedId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> updateCustom({
    required String id,
    required String arabic,
    required String nameEn,
    required String nameAr,
    int? personalTarget,
  }) async {
    final index = _custom.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _custom[index] = _custom[index].copyWith(
      arabic: arabic.trim(),
      nameEn: nameEn.trim().isEmpty ? arabic.trim() : nameEn.trim(),
      nameAr: nameAr.trim().isEmpty ? arabic.trim() : nameAr.trim(),
      personalTarget: personalTarget,
      clearPersonalTarget: personalTarget == null || personalTarget <= 0,
    );
    await setPersonalTarget(id, personalTarget);
  }

  Future<void> deleteCustom(String id) async {
    _custom.removeWhere((item) => item.id == id);
    _favorites.remove(id);
    _personalTargets.remove(id);
    _sessionCounts.remove(id);
    if (_selectedId == id) {
      _selectedId = TasbeehCatalog.builtIn.first.id;
    }
    await _persist();
    notifyListeners();
  }

  int todayTotal([DateTime? now]) {
    final key = _todayKey(now);
    return _history[key]?.total ?? 0;
  }

  int rangeTotal(DateTime from, DateTime to) {
    var sum = 0;
    for (final stat in _history.values) {
      final parts = stat.day.split('-');
      if (parts.length != 3) continue;
      final day = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (!day.isBefore(DateTime(from.year, from.month, from.day)) &&
          !day.isAfter(DateTime(to.year, to.month, to.day))) {
        sum += stat.total;
      }
    }
    return sum;
  }

  Map<String, int> breakdownForRange(DateTime from, DateTime to) {
    final map = <String, int>{};
    for (final stat in _history.values) {
      final parts = stat.day.split('-');
      if (parts.length != 3) continue;
      final day = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (day.isBefore(DateTime(from.year, from.month, from.day)) ||
          day.isAfter(DateTime(to.year, to.month, to.day))) {
        continue;
      }
      stat.byDhikr.forEach((id, count) {
        map[id] = (map[id] ?? 0) + count;
      });
    }
    return map;
  }

  List<TasbeehDailyStat> lastDays(int days) {
    final today = DateTime.now();
    final list = <TasbeehDailyStat>[];
    for (var i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = _todayKey(day);
      list.add(_history[key] ?? TasbeehDailyStat(day: key, byDhikr: const {}));
    }
    return list;
  }

  String labelFor(String id, bool english) {
    for (final item in allDhikr) {
      if (item.id == id) return item.displayName(english);
    }
    return id;
  }
}

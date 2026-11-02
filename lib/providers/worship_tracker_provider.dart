import 'package:flutter/foundation.dart';

import '../core/services/notification_service.dart';
import '../core/services/worship_tracker_store.dart';
import '../models/worship_tracker.dart';

class WorshipTrackerProvider extends ChangeNotifier {
  WorshipTrackerProvider({
    WorshipTrackerStore? store,
    NotificationService? notifications,
    DateTime Function()? clock,
  })  : _store = store ?? WorshipTrackerStore(),
        _notifications = notifications ?? NotificationService(),
        _clock = clock ?? DateTime.now;

  final WorshipTrackerStore _store;
  final NotificationService _notifications;
  final DateTime Function() _clock;

  bool _loading = true;
  String? _error;
  List<WorshipActivity> _activities = [];
  Map<String, WorshipDayLog> _logs = {};
  DateTime _selectedDate = DateTime.now();

  DateTime? _viewingTodayAnchor;

  bool get loading => _loading;
  String? get error => _error;
  List<WorshipActivity> get activities => List.unmodifiable(_activities);
  DateTime get selectedDate => _selectedDate;
  DateTime get today => _dateOnly(_clock());

  String get selectedDateKey => dateKey(_selectedDate);

  List<WorshipActivity> get dashboardActivities {
    return _activities.where((item) => item.isActiveOnDashboard).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<WorshipActivity> get pausedActivities {
    return _activities.where((item) => item.paused).toList();
  }

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedDate = _dateOnly(_clock());
      _viewingTodayAnchor = _selectedDate;
      _activities = await _store.loadActivities();
      _logs = await _store.loadLogs();
      await _syncReminders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Snap the dashboard to the new calendar day when the user was viewing "today".
  void onDayBoundaryCheck() {
    final nextToday = today;
    final wasOnToday = _viewingTodayAnchor != null &&
        _isSameDay(_selectedDate, _viewingTodayAnchor!);
    if (wasOnToday && !_isSameDay(_selectedDate, nextToday)) {
      _selectedDate = nextToday;
    }
    _viewingTodayAnchor = nextToday;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = _dateOnly(date);
    notifyListeners();
  }

  void goToToday() {
    _selectedDate = today;
    _viewingTodayAnchor = _selectedDate;
    notifyListeners();
  }

  WorshipDayLog logFor(DateTime date) {
    final key = dateKey(date);
    return _logs[key] ?? WorshipDayLog(dateKey: key);
  }

  WorshipDayLog get selectedLog => logFor(_selectedDate);

  int get todayCompletedCount {
    final log = selectedLog;
    return dashboardActivities.where(log.isComplete).length;
  }

  int get todayTotalCount => dashboardActivities.length;

  double get todayProgress =>
      todayTotalCount == 0 ? 0 : todayCompletedCount / todayTotalCount;

  bool isCompleted(WorshipActivity activity, {DateTime? date}) {
    return logFor(date ?? _selectedDate).isComplete(activity);
  }

  /// Explicit user action only. Never call from navigation or reminders alone.
  Future<void> toggleCompleted(String activityId) async {
    final activity = byId(activityId);
    if (activity == null || activity.paused || !activity.enabled) return;
    final key = selectedDateKey;
    final current = _logs[key] ?? WorshipDayLog(dateKey: key);
    _logs = {..._logs, key: current.withToggle(activity)};
    notifyListeners();
    await _store.saveLogs(_logs);
  }

  WorshipActivity? byId(String id) {
    for (final activity in _activities) {
      if (activity.id == id) return activity;
    }
    return null;
  }

  Future<void> upsertActivity(WorshipActivity activity) async {
    final index = _activities.indexWhere((item) => item.id == activity.id);
    if (index >= 0) {
      _activities = [..._activities]..[index] = activity;
    } else {
      _activities = [..._activities, activity];
    }
    _activities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    notifyListeners();
    await _store.saveActivities(_activities);
    await _syncReminders();
  }

  Future<void> addCustom({
    required String titleEn,
    required String titleAr,
    WorshipActivityKind kind = WorshipActivityKind.custom,
    WorshipGoalNature nature = WorshipGoalNature.personal,
    String? noteEn,
    String? noteAr,
    String? shortcut,
  }) async {
    final id = 'custom_${_clock().millisecondsSinceEpoch}';
    await upsertActivity(
      WorshipActivity(
        id: id,
        kind: kind,
        titleEn: titleEn.trim(),
        titleAr: titleAr.trim().isEmpty ? titleEn.trim() : titleAr.trim(),
        noteEn: noteEn,
        noteAr: noteAr,
        nature: nature,
        shortcut: shortcut,
        sortOrder: _activities.length,
      ),
    );
  }

  Future<void> setPaused(String id, bool paused) async {
    final activity = byId(id);
    if (activity == null) return;
    await upsertActivity(activity.copyWith(paused: paused));
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final activity = byId(id);
    if (activity == null) return;
    await upsertActivity(activity.copyWith(enabled: enabled));
  }

  Future<void> removeActivity(String id) async {
    _activities = _activities.where((item) => item.id != id).toList();
    notifyListeners();
    await _store.saveActivities(_activities);
    try {
      await _notifications.cancelWorshipTrackerReminder(id);
    } catch (_) {}
  }

  Future<void> setReminder({
    required String id,
    required bool enabled,
    int hour = 20,
    int minute = 0,
  }) async {
    final activity = byId(id);
    if (activity == null) return;
    await upsertActivity(
      activity.copyWith(
        reminderEnabled: enabled,
        reminderHour: hour,
        reminderMinute: minute,
      ),
    );
  }

  WorshipPeriodSummary summaryForDays(int days) {
    final today = _dateOnly(_clock());
    final active = _activities.where((item) => item.enabled).toList();
    var completedSlots = 0;
    var possibleSlots = 0;
    final byActivity = <String, int>{
      for (final activity in active) activity.id: 0,
    };
    var daysTracked = 0;

    for (var i = 0; i < days; i++) {
      final day = today.subtract(Duration(days: i));
      final log = logFor(day);
      final hasAny = log.completions.isNotEmpty ||
          active.any((activity) => log.isComplete(activity));
      if (hasAny || i == 0) daysTracked++;
      for (final activity in active) {
        if (activity.paused && i > 0) continue;
        possibleSlots++;
        if (log.isComplete(activity)) {
          completedSlots++;
          byActivity[activity.id] = (byActivity[activity.id] ?? 0) + 1;
        }
      }
    }

    return WorshipPeriodSummary(
      daysTracked: daysTracked,
      completedSlots: completedSlots,
      possibleSlots: possibleSlots,
      completedByActivity: byActivity,
    );
  }

  WorshipPeriodSummary get weeklySummary => summaryForDays(7);

  WorshipPeriodSummary get monthlySummary => summaryForDays(30);

  List<WorshipDayLog> recentHistory({int days = 30}) {
    final today = _dateOnly(_clock());
    return [
      for (var i = 0; i < days; i++)
        logFor(today.subtract(Duration(days: i))),
    ];
  }

  static String dateKey(DateTime date) {
    final d = _dateOnly(date);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Re-schedule reminders using the current app language.
  Future<void> resyncReminders() => _syncReminders();

  Future<void> _syncReminders() async {
    for (final activity in _activities) {
      if (activity.reminderEnabled &&
          activity.enabled &&
          !activity.paused &&
          activity.reminderHour != null &&
          activity.reminderMinute != null) {
        try {
          await _notifications.scheduleWorshipTrackerReminder(
            activityId: activity.id,
            titleEn: activity.titleEn,
            titleAr: activity.titleAr,
            hour: activity.reminderHour!,
            minute: activity.reminderMinute!,
          );
        } catch (e) {
          debugPrint('Worship reminder schedule failed: $e');
        }
      } else {
        try {
          await _notifications.cancelWorshipTrackerReminder(activity.id);
        } catch (_) {}
      }
    }
  }
}

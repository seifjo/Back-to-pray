import 'package:flutter/foundation.dart';

import '../core/services/hijri_calendar_service.dart';
import '../core/services/hijri_preferences_store.dart';
import '../core/services/notification_service.dart';
import '../models/hijri_calendar.dart';

class HijriCalendarProvider extends ChangeNotifier {
  HijriCalendarProvider({
    HijriCalendarService? service,
    HijriPreferencesStore? store,
    NotificationService? notifications,
    DateTime Function()? clock,
  })  : _service = service ?? HijriCalendarService(),
        _store = store ?? HijriPreferencesStore(),
        _notifications = notifications ?? NotificationService(),
        _clock = clock ?? DateTime.now;

  final HijriCalendarService _service;
  final HijriPreferencesStore _store;
  final NotificationService _notifications;
  final DateTime Function() _clock;

  bool _loading = true;
  String? _error;
  int _adjustmentDays = 0;
  late int _viewYear;
  late int _viewMonth;
  DateTime? _selectedGregorian;
  Map<String, HijriReminderSetting> _reminders = {};
  bool? _notificationsGranted;

  bool get loading => _loading;
  String? get error => _error;
  int get adjustmentDays => _adjustmentDays;
  int get viewYear => _viewYear;
  int get viewMonth => _viewMonth;
  DateTime? get selectedGregorian => _selectedGregorian;
  Map<String, HijriReminderSetting> get reminders =>
      Map.unmodifiable(_reminders);
  bool? get notificationsGranted => _notificationsGranted;
  String get methodNameEn => HijriCalendarService.methodNameEn;
  String get methodNameAr => HijriCalendarService.methodNameAr;

  DateTime get today => DateTime(
        _clock().year,
        _clock().month,
        _clock().day,
      );

  HijriDate get todayHijri =>
      _service.toHijri(today, adjustmentDays: _adjustmentDays);

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _adjustmentDays = await _store.loadAdjustment();
      _reminders = await _store.loadReminders();
      final hijri = todayHijri;
      _viewYear = hijri.year;
      _viewMonth = hijri.month;
      _selectedGregorian = today;
      await _notifications.initialize();
      _notificationsGranted = await _notifications.notificationsEnabled();
      await syncReminders();
    } catch (e) {
      _error = e.toString();
      final fallback = HijriCalendarService().toHijri(DateTime.now());
      _viewYear = fallback.year;
      _viewMonth = fallback.month;
      _selectedGregorian = DateTime.now();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String monthTitle(bool english) {
    final name = _service.monthName(_viewMonth, english: english);
    return english ? '$name $_viewYear AH' : '$name $_viewYear هـ';
  }

  List<CalendarDayCell> get monthCells {
    return _service.buildMonthGrid(
      hijriYear: _viewYear,
      hijriMonth: _viewMonth,
      today: today,
      adjustmentDays: _adjustmentDays,
    );
  }

  List<IslamicEventOccurrence> get monthEvents => _service.eventsInHijriMonth(
        _viewYear,
        _viewMonth,
        adjustmentDays: _adjustmentDays,
      );

  List<IslamicEventOccurrence> get upcomingEvents => _service.upcomingEvents(
        from: today,
        adjustmentDays: _adjustmentDays,
      );

  CalendarDayCell? get selectedCell {
    final selected = _selectedGregorian;
    if (selected == null) return null;
    final key = DateTime(selected.year, selected.month, selected.day);
    for (final cell in monthCells) {
      if (cell.gregorian == key) return cell;
    }
    final hijri = _service.toHijri(key, adjustmentDays: _adjustmentDays);
    return CalendarDayCell(
      gregorian: key,
      hijri: hijri,
      isToday: key == today,
      isCurrentMonth: hijri.month == _viewMonth && hijri.year == _viewYear,
      events: _service.eventsForHijriDay(hijri, adjustmentDays: _adjustmentDays),
    );
  }

  void selectDay(DateTime gregorian) {
    _selectedGregorian = DateTime(gregorian.year, gregorian.month, gregorian.day);
    notifyListeners();
  }

  void goToToday() {
    final hijri = todayHijri;
    _viewYear = hijri.year;
    _viewMonth = hijri.month;
    _selectedGregorian = today;
    notifyListeners();
  }

  void nextMonth() {
    if (_viewMonth == 12) {
      _viewMonth = 1;
      _viewYear += 1;
    } else {
      _viewMonth += 1;
    }
    notifyListeners();
  }

  void previousMonth() {
    if (_viewMonth == 1) {
      _viewMonth = 12;
      _viewYear -= 1;
    } else {
      _viewMonth -= 1;
    }
    notifyListeners();
  }

  Future<void> setAdjustment(int days) async {
    _adjustmentDays = days.clamp(
      HijriCalendarService.minAdjustment,
      HijriCalendarService.maxAdjustment,
    );
    final hijri = todayHijri;
    _viewYear = hijri.year;
    _viewMonth = hijri.month;
    notifyListeners();
    await _store.saveAdjustment(_adjustmentDays);
    await syncReminders();
  }

  HijriReminderSetting reminderFor(String eventDefinitionId) {
    return _reminders[eventDefinitionId] ??
        HijriReminderSetting(eventDefinitionId: eventDefinitionId);
  }

  Future<bool> setReminder({
    required String eventDefinitionId,
    required bool enabled,
    int? daysBefore,
    int? hour,
    int? minute,
  }) async {
    var granted = true;
    if (enabled) {
      granted = await _notifications.requestPermissions();
      _notificationsGranted = granted;
    }
    final current = reminderFor(eventDefinitionId);
    _reminders = {
      ..._reminders,
      eventDefinitionId: current.copyWith(
        enabled: enabled,
        daysBefore: daysBefore,
        hour: hour,
        minute: minute,
      ),
    };
    notifyListeners();
    await _store.saveReminders(_reminders);
    await syncReminders();
    // Preference is saved either way; false means notifications may not fire.
    return !enabled || granted;
  }

  Future<void> syncReminders() async {
    final upcoming = upcomingEvents;

    for (final occurrence in upcoming.take(60)) {
      final setting = _reminders[occurrence.definition.id];
      if (setting == null || !setting.enabled) {
        try {
          await _notifications.cancelHijriOccurrenceReminder(occurrence.id);
        } catch (_) {}
        continue;
      }
      final when = DateTime(
        occurrence.gregorianDate.year,
        occurrence.gregorianDate.month,
        occurrence.gregorianDate.day,
        setting.hour,
        setting.minute,
      ).subtract(Duration(days: setting.daysBefore));
      if (!when.isAfter(_clock())) {
        try {
          await _notifications.cancelHijriOccurrenceReminder(occurrence.id);
        } catch (_) {}
        continue;
      }
      try {
        await _notifications.scheduleHijriEventReminder(
          occurrenceId: occurrence.id,
          eventDefinitionId: occurrence.definition.id,
          titleEn: occurrence.definition.nameEn,
          titleAr: occurrence.definition.nameAr,
          when: when,
        );
      } catch (e) {
        debugPrint('Hijri reminder schedule failed: $e');
      }
    }
  }
}
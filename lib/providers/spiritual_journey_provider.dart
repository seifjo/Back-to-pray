import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/notification_service.dart';
import '../data/spiritual_journey_catalog.dart';
import '../models/active_journey.dart';
import '../models/spiritual_journey.dart';

class SpiritualJourneyProvider extends ChangeNotifier {
  static const _key = 'spiritual_journeys_v1';

  SpiritualJourneyProvider({
    NotificationService? notifications,
    DateTime Function()? clock,
  })  : _notifications = notifications ?? NotificationService(),
        _clock = clock ?? DateTime.now {
    load();
  }

  final NotificationService _notifications;
  final DateTime Function() _clock;

  final Map<String, SpiritualJourneyProgress> _progress = {};
  bool _loaded = false;

  bool get loaded => _loaded;
  DateTime get now => _clock();

  List<SpiritualJourneyProgress> get allProgress => _progress.values.toList();

  List<SpiritualJourney> get activeJourneys => SpiritualJourneyCatalog.all
      .where((journey) =>
          _progress[journey.id]?.status == JourneyStatus.active)
      .toList();

  List<SpiritualJourney> get pausedJourneys => SpiritualJourneyCatalog.all
      .where((journey) =>
          _progress[journey.id]?.status == JourneyStatus.paused)
      .toList();

  List<SpiritualJourney> get completedJourneys => SpiritualJourneyCatalog.all
      .where((journey) =>
          _progress[journey.id]?.status == JourneyStatus.completed)
      .toList();

  List<SpiritualJourney> get availableJourneys => SpiritualJourneyCatalog.all
      .where((journey) {
        final progress = _progress[journey.id];
        return progress == null ||
            progress.status == JourneyStatus.abandoned;
      })
      .toList();

  SpiritualJourneyProgress? progressFor(String id) => _progress[id];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _progress.clear();
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              final progress = SpiritualJourneyProgress.fromJson(
                Map<String, dynamic>.from(item),
              );
              _progress[progress.journeyId] = progress;
            }
          }
        }
      } catch (e) {
        debugPrint('Spiritual journey load failed: $e');
      }
    }
    _loaded = true;
    await _syncReminders();
    notifyListeners();
  }

  Future<void> restart(String journeyId) async {
    _progress[journeyId] = SpiritualJourneyProgress(
      journeyId: journeyId,
      startDate: now,
      status: JourneyStatus.active,
    );
    await _save();
    await _syncReminders();
  }

  Future<void> start(String journeyId) async {
    final existing = _progress[journeyId];
    if (existing != null) {
      if (existing.status == JourneyStatus.active) return;
      if (existing.status == JourneyStatus.paused) {
        await setStatus(journeyId, JourneyStatus.active);
        return;
      }
    }
    _progress[journeyId] = SpiritualJourneyProgress(
      journeyId: journeyId,
      startDate: now,
      status: JourneyStatus.active,
      reminderEnabled: existing?.reminderEnabled ?? false,
      reminderHour: existing?.reminderHour ?? 20,
      reminderMinute: existing?.reminderMinute ?? 0,
    );
    await _save();
    await _syncReminders();
  }

  Future<void> pause(String journeyId) =>
      setStatus(journeyId, JourneyStatus.paused);

  Future<void> resume(String journeyId) =>
      setStatus(journeyId, JourneyStatus.active);

  Future<void> abandon(String journeyId) =>
      setStatus(journeyId, JourneyStatus.abandoned);

  Future<void> setStatus(String journeyId, JourneyStatus status) async {
    final current = _progress[journeyId];
    if (current == null) return;
    _progress[journeyId] = current.copyWith(status: status);
    await _save();
    await _syncReminders();
  }

  /// Explicit day completion. Missed earlier days are left unmarked (no reset).
  Future<bool> toggleToday(String journeyId, [DateTime? at]) async {
    final moment = at ?? now;
    final journey = SpiritualJourneyCatalog.byId(journeyId);
    final current = _progress[journeyId];
    if (journey == null || current == null) return false;
    if (current.status != JourneyStatus.active) return false;
    final key = spiritualDayKey(moment);
    final days = List<String>.from(current.completedDays);
    if (!days.remove(key)) days.add(key);
    var status = current.status;
    final justCompleted = days.length >= journey.durationDays;
    if (justCompleted) {
      status = JourneyStatus.completed;
    }
    _progress[journeyId] = current.copyWith(
      completedDays: days,
      status: status,
    );
    await _save();
    if (status == JourneyStatus.completed) {
      await _syncReminders();
    }
    return justCompleted && status == JourneyStatus.completed;
  }

  Future<void> setReminder({
    required String journeyId,
    required bool enabled,
    int hour = 20,
    int minute = 0,
  }) async {
    final current = _progress[journeyId];
    if (current == null) {
      await start(journeyId);
    }
    final updated = (_progress[journeyId] ??
            SpiritualJourneyProgress(
              journeyId: journeyId,
              startDate: now,
            ))
        .copyWith(
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    _progress[journeyId] = updated;
    await _save();
    await _syncReminders();
  }

  bool isTodayDone(String journeyId, [DateTime? at]) {
    return _progress[journeyId]
            ?.completedDays
            .contains(spiritualDayKey(at ?? now)) ??
        false;
  }

  double ratio(String journeyId) {
    final journey = SpiritualJourneyCatalog.byId(journeyId);
    final progress = _progress[journeyId];
    if (journey == null || progress == null || journey.durationDays == 0) {
      return 0;
    }
    return (progress.completedDays.length / journey.durationDays).clamp(0, 1);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(_progress.values.map((item) => item.toJson()).toList());
    await prefs.setString(_key, encoded);
    notifyListeners();
  }

  /// Re-schedule journey reminders using the current app language.
  Future<void> resyncReminders() => _syncReminders();

  Future<void> _syncReminders() async {
    for (final journey in SpiritualJourneyCatalog.all) {
      final progress = _progress[journey.id];
      final shouldRemind = progress != null &&
          progress.reminderEnabled &&
          progress.status == JourneyStatus.active &&
          progress.reminderHour != null &&
          progress.reminderMinute != null;
      try {
        if (shouldRemind) {
          await _notifications.scheduleWorshipTrackerReminder(
            activityId: 'journey_${journey.id}',
            titleEn: journey.titleEn,
            titleAr: journey.titleAr,
            hour: progress.reminderHour!,
            minute: progress.reminderMinute!,
          );
        } else {
          await _notifications
              .cancelWorshipTrackerReminder('journey_${journey.id}');
        }
      } catch (e) {
        debugPrint('Journey reminder sync failed: $e');
      }
    }
  }
}

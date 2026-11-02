import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/worship_tracker_catalog.dart';
import '../../models/worship_tracker.dart';

class WorshipTrackerStore {
  static const _activitiesKey = 'worship_tracker_activities_v1';
  static const _logsKey = 'worship_tracker_logs_v1';
  static const _initializedKey = 'worship_tracker_initialized_v1';

  Future<List<WorshipActivity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(_initializedKey) ?? false;
    final raw = prefs.getString(_activitiesKey);
    if (!initialized || raw == null) {
      final presets = List<WorshipActivity>.from(WorshipTrackerCatalog.presets);
      await saveActivities(presets);
      await prefs.setBool(_initializedKey, true);
      return presets;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => WorshipActivity.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> saveActivities(List<WorshipActivity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _activitiesKey,
      jsonEncode(activities.map((item) => item.toJson()).toList()),
    );
    await prefs.setBool(_initializedKey, true);
  }

  Future<Map<String, WorshipDayLog>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_logsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries)
        entry.key: WorshipDayLog.fromJson(entry.value as Map<String, dynamic>),
    };
  }

  Future<void> saveLogs(Map<String, WorshipDayLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _logsKey,
      jsonEncode({
        for (final entry in logs.entries) entry.key: entry.value.toJson(),
      }),
    );
  }
}

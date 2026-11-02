import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/hijri_calendar.dart';

class HijriPreferencesStore {
  static const _adjustmentKey = 'hijri_adjustment_v1';
  static const _remindersKey = 'hijri_reminders_v1';

  Future<int> loadAdjustment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_adjustmentKey) ?? 0;
  }

  Future<void> saveAdjustment(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adjustmentKey, days);
  }

  Future<Map<String, HijriReminderSetting>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_remindersKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries)
        entry.key: HijriReminderSetting.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        ),
    };
  }

  Future<void> saveReminders(Map<String, HijriReminderSetting> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _remindersKey,
      jsonEncode({
        for (final entry in reminders.entries) entry.key: entry.value.toJson(),
      }),
    );
  }
}

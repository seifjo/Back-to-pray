import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/notification_preferences.dart';

class NotificationPreferencesStore {
  static const storageKey = 'prayer_notification_preferences';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const NotificationPreferences();
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return NotificationPreferences.fromJson(json);
      }
      if (json is Map) {
        return NotificationPreferences.fromJson(Map<String, dynamic>.from(json));
      }
    } catch (_) {}
    return const NotificationPreferences();
  }

  Future<void> save(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(preferences.toJson()));
  }
}

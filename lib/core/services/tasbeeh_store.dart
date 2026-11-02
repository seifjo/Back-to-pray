import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/tasbeeh_catalog.dart';

class TasbeehStore {
  static const _stateKey = 'tasbeeh_state_v1';

  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) {
      return {
        'selectedId': TasbeehCatalog.builtIn.first.id,
        'sessionCounts': <String, int>{},
        'custom': <Map<String, dynamic>>[],
        'favorites': <String>[],
        'personalTargets': <String, int>{},
        'history': <Map<String, dynamic>>[],
        'soundEnabled': false,
        'hapticEnabled': true,
      };
    }
    final decoded = json.decode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  Future<void> save(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, json.encode(state));
  }
}

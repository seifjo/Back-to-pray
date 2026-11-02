import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/saved_library.dart';

/// Stores only user metadata (saved/viewed timestamps) keyed by library key.
class SavedLibraryMetaStore {
  static const _metaKey = 'saved_library_meta_v1';

  Future<Map<String, SavedLibraryMeta>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (key, value) => MapEntry(
          key,
          SavedLibraryMeta.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, SavedLibraryMeta> meta) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = meta.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_metaKey, jsonEncode(encoded));
  }
}

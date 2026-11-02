import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/hadith_explanation.dart';

/// Loads verified Hadith explanations keyed by stable Hadith IDs.
class HadithExplanationService {
  static const _bookmarkKey = 'hadith_explanation_bookmarks_v1';

  final Map<String, HadithExplanation> _byId = {};
  List<String> _orderedIds = [];
  String _limitation = '';
  bool _loaded = false;

  String get limitation => _limitation;
  List<String> get supportedIds => List.unmodifiable(_orderedIds);

  Future<void> initialize() async {
    if (_loaded) return;
    final raw =
        await rootBundle.loadString('assets/hadith/explanations.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final meta = decoded['_meta'];
    if (meta is Map && meta['limitation'] != null) {
      _limitation = meta['limitation'].toString();
    }
    final list = decoded['explanations'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;
        final explanation =
            HadithExplanation.fromJson(Map<String, dynamic>.from(item));
        if (!explanation.available || explanation.hadithId.isEmpty) continue;
        _byId[explanation.hadithId] = explanation;
      }
    }
    _orderedIds = _byId.keys.toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a.split(':').last) ?? 0;
        final bNum = int.tryParse(b.split(':').last) ?? 0;
        final byCollection = a.split(':').first.compareTo(b.split(':').first);
        if (byCollection != 0) return byCollection;
        return aNum.compareTo(bNum);
      });
    _loaded = true;
  }

  bool hasExplanation(String hadithId) => _byId.containsKey(hadithId);

  HadithExplanation forHadith(String hadithId) {
    return _byId[hadithId] ?? HadithExplanation.unavailable(hadithId);
  }

  String? previousId(String hadithId) {
    final index = _orderedIds.indexOf(hadithId);
    if (index <= 0) return null;
    return _orderedIds[index - 1];
  }

  String? nextId(String hadithId) {
    final index = _orderedIds.indexOf(hadithId);
    if (index < 0 || index >= _orderedIds.length - 1) return null;
    return _orderedIds[index + 1];
  }

  Future<Set<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarkKey)?.toSet() ?? {};
  }

  Future<void> saveBookmarks(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarkKey, ids.toList());
  }
}

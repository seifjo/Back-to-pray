import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../data/hadith_categories.dart';
import '../../models/hadith.dart';

/// Loads verified Hadith from the bundled seed and optional CDN collections.
/// Source: https://github.com/fawazahmed0/hadith-api (Unlicense).
class HadithService {
  static const _cdn =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';
  static const attribution =
      'Hadith texts from fawazahmed0/hadith-api (Unlicense). '
      'Grades appear only when that dataset provides them.';

  final Map<String, HadithItem> _byId = {};
  final Set<String> _cachedCollections = {};
  bool _seedLoaded = false;
  String? _metaAttribution;

  List<HadithItem> get all => _byId.values.toList()
    ..sort((a, b) {
      final byCollection = a.collection.compareTo(b.collection);
      if (byCollection != 0) return byCollection;
      return a.number.compareTo(b.number);
    });

  Set<String> get cachedCollections => Set.unmodifiable(_cachedCollections);

  String get attributionText => _metaAttribution ?? attribution;

  Future<void> initialize() async {
    await _loadSeed();
    try {
      await _restoreCachedCollections();
    } catch (_) {
      // Disk cache is optional in tests and on platforms without path_provider.
    }
  }

  Future<void> _loadSeed() async {
    if (_seedLoaded) return;
    final raw = await rootBundle.loadString('assets/hadith/library_seed.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final meta = decoded['_meta'];
    if (meta is Map && meta['attribution'] != null) {
      _metaAttribution = meta['attribution'].toString();
    }
    final list = decoded['hadiths'];
    if (list is List) {
      for (final item in list) {
        if (item is Map) {
          final hadith = HadithItem.fromJson(Map<String, dynamic>.from(item));
          _byId[hadith.id] = hadith;
        }
      }
    }
    _cachedCollections.add('nawawi');
    _seedLoaded = true;
  }

  Future<Directory> _cacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/hadith_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _restoreCachedCollections() async {
    final dir = await _cacheDir();
    for (final info in HadithCollections.available) {
      if (info.id == 'nawawi') continue;
      final file = File('${dir.path}/${info.id}.json');
      if (!file.existsSync()) continue;
      try {
        final decoded = json.decode(await file.readAsString()) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map) {
            final hadith = HadithItem.fromJson(Map<String, dynamic>.from(item));
            _byId[hadith.id] = hadith;
          }
        }
        _cachedCollections.add(info.id);
      } catch (_) {}
    }
  }

  Future<bool> isCollectionCached(String collectionId) async {
    if (_cachedCollections.contains(collectionId)) return true;
    if (collectionId == 'nawawi') return true;
    final dir = await _cacheDir();
    return File('${dir.path}/$collectionId.json').existsSync();
  }

  Future<void> downloadCollection(
    String collectionId, {
    void Function(double progress)? onProgress,
  }) async {
    final info = HadithCollections.available.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => throw Exception('Unknown collection'),
    );
    if (collectionId == 'nawawi') {
      _cachedCollections.add(collectionId);
      return;
    }

    onProgress?.call(0.05);
    final eng = await _fetchEdition(info.engEdition);
    onProgress?.call(0.5);
    final ara = await _fetchEdition(info.araEdition);
    onProgress?.call(0.8);

    final araBy = <int, Map<String, dynamic>>{};
    for (final item in ara['hadiths'] as List) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final number = (map['hadithnumber'] as num?)?.toInt();
        if (number != null) araBy[number] = map;
      }
    }

    final collectionName =
        (eng['metadata'] as Map?)?['name']?.toString() ?? info.id;
    final merged = <HadithItem>[];
    for (final item in eng['hadiths'] as List) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final number = (map['hadithnumber'] as num?)?.toInt() ?? 0;
      final arabicMap = araBy[number] ?? {};
      final reference = map['reference'];
      merged.add(
        HadithItem(
          id: '$collectionId:$number',
          collection: collectionId,
          collectionName: collectionName,
          number: number,
          arabicNumber: map['arabicnumber'] as num? ?? number,
          arabic: arabicMap['text']?.toString() ?? '',
          english: map['text']?.toString() ?? '',
          grades: [
            for (final g in (map['grades'] as List? ?? const []))
              if (g is Map)
                HadithGrade.fromJson(Map<String, dynamic>.from(g)),
          ],
          book: reference is Map ? (reference['book'] as num?)?.toInt() : null,
          hadithInBook:
              reference is Map ? (reference['hadith'] as num?)?.toInt() : null,
        ),
      );
    }

    for (final hadith in merged) {
      _byId[hadith.id] = hadith;
    }
    _cachedCollections.add(collectionId);

    final dir = await _cacheDir();
    final file = File('${dir.path}/$collectionId.json');
    await file.writeAsString(
      json.encode(merged.map((h) => h.toJson()).toList()),
    );
    onProgress?.call(1);
  }

  Future<Map<String, dynamic>> _fetchEdition(String edition) async {
    final uri = Uri.parse('$_cdn/$edition.min.json');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Could not download $edition');
    }
    return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  HadithItem? byId(String id) => _byId[id];

  HadithItem hadithOfTheDay({DateTime? now}) {
    final items = all;
    if (items.isEmpty) {
      throw StateError('No Hadith loaded');
    }
    final day = now ?? DateTime.now();
    final dayIndex = DateTime(day.year, day.month, day.day)
        .difference(DateTime(day.year))
        .inDays;
    final index = dayIndex % items.length;
    return items[index];
  }

  /// Second deterministic pick for the day (not random; stable across rebuilds).
  HadithItem featuredHadith({DateTime? now}) {
    final items = all;
    if (items.isEmpty) {
      throw StateError('No Hadith loaded');
    }
    final day = now ?? DateTime.now();
    final dayIndex = DateTime(day.year, day.month, day.day)
        .difference(DateTime(day.year))
        .inDays;
    final ofDay = dayIndex % items.length;
    final featured = (dayIndex * 7 + 13) % items.length;
    if (featured == ofDay && items.length > 1) {
      return items[(featured + 1) % items.length];
    }
    return items[featured];
  }

  List<HadithItem> search({
    String query = '',
    String? collectionId,
    String? categoryId,
    String? gradeFilter,
  }) {
    final q = query.trim().toLowerCase();
    HadithCategoryDef? category;
    if (categoryId != null && categoryId.isNotEmpty) {
      category = HadithCategories.byId(categoryId);
    }

    return all.where((item) {
      if (collectionId != null &&
          collectionId.isNotEmpty &&
          item.collection != collectionId) {
        return false;
      }
      if (category != null && !HadithCategories.matches(item, category)) {
        return false;
      }
      if (gradeFilter != null && gradeFilter.isNotEmpty) {
        if (!item.hasGrades) return false;
        final needle = gradeFilter.toLowerCase();
        final hit = item.grades.any(
          (g) => g.grade.toLowerCase().contains(needle),
        );
        if (!hit) return false;
      }
      if (q.isEmpty) return true;
      final narrator = item.narrator?.toLowerCase() ?? '';
      final grades = item.grades
          .map((g) => '${g.name} ${g.grade}')
          .join(' ')
          .toLowerCase();
      final topics = HadithCategories.allMatching(item)
          .expand((c) => [c.id, ...c.keywords])
          .join(' ')
          .toLowerCase();
      final haystack = [
        item.arabic,
        item.english,
        narrator,
        item.collectionName,
        item.collection,
        item.number.toString(),
        grades,
        item.referenceLabel,
        item.seedCategory ?? '',
        topics,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  List<HadithItem> related(HadithItem item, {int limit = 6}) {
    final sameCollection = all
        .where(
          (h) => h.collection == item.collection && h.id != item.id,
        )
        .toList()
      ..sort(
        (a, b) =>
            (a.number - item.number).abs().compareTo((b.number - item.number).abs()),
      );
    return sameCollection.take(limit).toList();
  }
}

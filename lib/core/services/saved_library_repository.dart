import 'package:shared_preferences/shared_preferences.dart';

import '../../data/adhkar_library.dart';
import '../../data/asma_ul_husna.dart';
import '../../data/dua_library.dart';
import '../../data/quran_data.dart';
import '../../models/saved_library.dart';
import 'asma_preferences_store.dart';
import 'dua_preferences_store.dart';
import 'hadith_explanation_service.dart';
import 'hadith_preferences_store.dart';
import 'hadith_service.dart';
import 'saved_library_meta_store.dart';

/// Aggregates saved IDs from existing module stores without copying full records.
class SavedLibraryRepository {
  static const _adhkarFavoritesKey = 'adhkar_favorites_v1';

  SavedLibraryRepository({
    HadithPreferencesStore? hadithStore,
    HadithExplanationService? explanationService,
    HadithService? hadithService,
    DuaPreferencesStore? duaStore,
    AsmaPreferencesStore? asmaStore,
    SavedLibraryMetaStore? metaStore,
    DateTime Function()? clock,
  })  : _hadithStore = hadithStore ?? HadithPreferencesStore(),
        _explanationService = explanationService ?? HadithExplanationService(),
        _hadithService = hadithService ?? HadithService(),
        _duaStore = duaStore ?? DuaPreferencesStore(),
        _asmaStore = asmaStore ?? AsmaPreferencesStore(),
        _metaStore = metaStore ?? SavedLibraryMetaStore(),
        _clock = clock ?? DateTime.now;

  final HadithPreferencesStore _hadithStore;
  final HadithExplanationService _explanationService;
  final HadithService _hadithService;
  final DuaPreferencesStore _duaStore;
  final AsmaPreferencesStore _asmaStore;
  final SavedLibraryMetaStore _metaStore;
  final DateTime Function() _clock;

  bool _hadithReady = false;

  Future<void> _ensureHadith() async {
    if (_hadithReady) return;
    await _hadithService.initialize();
    try {
      await _explanationService.initialize();
    } catch (_) {
      // Explanations are optional if assets fail in a test harness.
    }
    _hadithReady = true;
  }

  Future<List<SavedLibraryItem>> loadItems() async {
    await _ensureHadith();
    final meta = Map<String, SavedLibraryMeta>.from(await _metaStore.load());
    final now = _clock();
    final items = <SavedLibraryItem>[];

    final hadithFavorites = await _hadithStore.loadFavorites();
    for (final id in hadithFavorites) {
      items.add(_hadithItem(id, meta, now));
    }

    final explanationBookmarks = await _explanationService.loadBookmarks();
    for (final id in explanationBookmarks) {
      items.add(_explanationItem(id, meta, now));
    }

    final prefs = await SharedPreferences.getInstance();
    final adhkarKeys = prefs.getStringList(_adhkarFavoritesKey) ?? const [];
    for (final key in adhkarKeys) {
      items.add(_adhkarItem(key, meta, now));
    }

    final duaFavorites = await _duaStore.loadFavorites();
    for (final id in duaFavorites) {
      items.add(_duaItem(id, meta, now));
    }

    final asmaFavorites = await _asmaStore.loadFavorites();
    for (final id in asmaFavorites) {
      items.add(_asmaItem(id, meta, now));
    }

    final quran = await _loadQuranBookmark(meta, now);
    if (quran != null) items.add(quran);

    final liveKeys = items.map((i) => i.libraryKey).toSet();
    meta.removeWhere((key, _) => !liveKeys.contains(key));
    for (final item in items) {
      meta.putIfAbsent(
        item.libraryKey,
        () => SavedLibraryMeta(savedAt: item.savedAt),
      );
    }
    await _metaStore.save(meta);

    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }

  Future<List<String>> loadRecentlyViewedLibraryKeys() async {
    final hadithRecent = await _hadithStore.loadRecent();
    final duaRecent = await _duaStore.loadRecent();
    final meta = await _metaStore.load();
    final fromMeta = meta.entries
        .where((e) => e.value.lastViewedAt != null)
        .toList()
      ..sort(
        (a, b) => b.value.lastViewedAt!.compareTo(a.value.lastViewedAt!),
      );

    final keys = <String>[
      ...fromMeta.map((e) => e.key),
      ...hadithRecent
          .map((id) => SavedLibraryItem.keyFor(SavedContentType.hadith, id)),
      ...duaRecent
          .map((id) => SavedLibraryItem.keyFor(SavedContentType.dua, id)),
    ];
    final seen = <String>{};
    return [
      for (final key in keys)
        if (seen.add(key)) key,
    ];
  }

  Future<void> markOpened(String libraryKey) async {
    final meta = await _metaStore.load();
    final existing = meta[libraryKey];
    final now = _clock();
    meta[libraryKey] = SavedLibraryMeta(
      savedAt: existing?.savedAt ?? now,
      lastViewedAt: now,
    );
    await _metaStore.save(meta);
  }

  Future<void> remove(SavedLibraryItem item) async {
    switch (item.type) {
      case SavedContentType.hadith:
        final favorites = await _hadithStore.loadFavorites();
        favorites.remove(item.sourceId);
        await _hadithStore.saveFavorites(favorites);
      case SavedContentType.hadithExplanation:
        final bookmarks = await _explanationService.loadBookmarks();
        bookmarks.remove(item.sourceId);
        await _explanationService.saveBookmarks(bookmarks);
      case SavedContentType.adhkar:
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList(_adhkarFavoritesKey) ?? [];
        list.remove(item.sourceId);
        await prefs.setStringList(_adhkarFavoritesKey, list);
      case SavedContentType.dua:
        final favorites = await _duaStore.loadFavorites();
        favorites.remove(item.sourceId);
        await _duaStore.saveFavorites(favorites);
      case SavedContentType.namesOfAllah:
        final favorites = await _asmaStore.loadFavorites();
        favorites.remove(item.sourceId);
        await _asmaStore.saveFavorites(favorites);
      case SavedContentType.quranBookmark:
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('last_surah_number');
        await prefs.remove('last_ayah_number');
        await prefs.remove('last_surah_name');
    }

    final meta = await _metaStore.load();
    meta.remove(item.libraryKey);
    await _metaStore.save(meta);
  }

  SavedLibraryItem _hadithItem(
    String id,
    Map<String, SavedLibraryMeta> meta,
    DateTime now,
  ) {
    final key = SavedLibraryItem.keyFor(SavedContentType.hadith, id);
    final hadith = _hadithService.byId(id);
    final stamp = meta[key]?.savedAt ?? now;
    if (hadith == null) {
      return SavedLibraryItem(
        type: SavedContentType.hadith,
        sourceId: id,
        libraryKey: key,
        titleEn: 'Hadith unavailable',
        titleAr: 'حديث غير متوفر',
        subtitleEn: 'Saved Hadith',
        subtitleAr: 'حديث محفوظ',
        available: false,
        savedAt: stamp,
        lastViewedAt: meta[key]?.lastViewedAt,
      );
    }
    return SavedLibraryItem(
      type: SavedContentType.hadith,
      sourceId: id,
      libraryKey: key,
      titleEn: hadith.collectionName,
      titleAr: hadith.collectionName,
      subtitleEn: 'Favorite Hadith · #${hadith.number}',
      subtitleAr: 'حديث مفضل · #${hadith.number}',
      previewEn: _clip(hadith.english),
      previewAr: _clip(hadith.arabic),
      available: true,
      savedAt: stamp,
      lastViewedAt: meta[key]?.lastViewedAt,
    );
  }

  SavedLibraryItem _explanationItem(
    String id,
    Map<String, SavedLibraryMeta> meta,
    DateTime now,
  ) {
    final key = SavedLibraryItem.keyFor(SavedContentType.hadithExplanation, id);
    final stamp = meta[key]?.savedAt ?? now;
    final has = _explanationService.hasExplanation(id);
    final hadith = _hadithService.byId(id);
    return SavedLibraryItem(
      type: SavedContentType.hadithExplanation,
      sourceId: id,
      libraryKey: key,
      titleEn: has ? 'Hadith explanation' : 'Explanation unavailable',
      titleAr: has ? 'شرح حديث' : 'الشرح غير متوفر',
      subtitleEn: hadith != null
          ? '${hadith.collectionName} · #${hadith.number}'
          : 'Saved explanation',
      subtitleAr: hadith != null
          ? '${hadith.collectionName} · #${hadith.number}'
          : 'شرح محفوظ',
      previewEn: hadith == null ? null : _clip(hadith.english),
      previewAr: hadith == null ? null : _clip(hadith.arabic),
      available: has,
      savedAt: stamp,
      lastViewedAt: meta[key]?.lastViewedAt,
    );
  }

  SavedLibraryItem _adhkarItem(
    String compositeKey,
    Map<String, SavedLibraryMeta> meta,
    DateTime now,
  ) {
    final key = SavedLibraryItem.keyFor(SavedContentType.adhkar, compositeKey);
    final stamp = meta[key]?.savedAt ?? now;
    final parts = compositeKey.split('::');
    if (parts.length < 2) {
      return SavedLibraryItem(
        type: SavedContentType.adhkar,
        sourceId: compositeKey,
        libraryKey: key,
        titleEn: 'Adhkar unavailable',
        titleAr: 'ذكر غير متوفر',
        subtitleEn: 'Favorite Adhkar',
        subtitleAr: 'ذكر مفضل',
        available: false,
        savedAt: stamp,
        lastViewedAt: meta[key]?.lastViewedAt,
      );
    }
    final category = AdhkarLibrary.byId(parts[0]);
    final itemId = parts.sublist(1).join('::');
    if (category == null) {
      return SavedLibraryItem(
        type: SavedContentType.adhkar,
        sourceId: compositeKey,
        libraryKey: key,
        titleEn: 'Adhkar unavailable',
        titleAr: 'ذكر غير متوفر',
        subtitleEn: 'Favorite Adhkar',
        subtitleAr: 'ذكر مفضل',
        available: false,
        savedAt: stamp,
        lastViewedAt: meta[key]?.lastViewedAt,
        routeArgs: {'categoryId': parts[0], 'itemId': itemId},
      );
    }
    final index = category.items.indexWhere((item) {
      final id = item.id.isEmpty ? item.arabicText : item.id;
      return id == itemId;
    });
    if (index < 0) {
      return SavedLibraryItem(
        type: SavedContentType.adhkar,
        sourceId: compositeKey,
        libraryKey: key,
        titleEn: 'Adhkar unavailable',
        titleAr: 'ذكر غير متوفر',
        subtitleEn: category.displayName(true),
        subtitleAr: category.displayName(false),
        available: false,
        savedAt: stamp,
        lastViewedAt: meta[key]?.lastViewedAt,
        routeArgs: {
          'categoryId': category.stableId,
          'itemId': itemId,
        },
      );
    }
    final item = category.items[index];
    return SavedLibraryItem(
      type: SavedContentType.adhkar,
      sourceId: compositeKey,
      libraryKey: key,
      titleEn: category.displayName(true),
      titleAr: category.displayName(false),
      subtitleEn: 'Favorite Adhkar',
      subtitleAr: 'ذكر مفضل',
      previewEn: _clip(item.translation),
      previewAr: _clip(item.arabicText),
      available: true,
      savedAt: stamp,
      lastViewedAt: meta[key]?.lastViewedAt,
      routeArgs: {
        'categoryId': category.stableId,
        'itemId': itemId,
        'index': '$index',
      },
    );
  }

  SavedLibraryItem _duaItem(
    String id,
    Map<String, SavedLibraryMeta> meta,
    DateTime now,
  ) {
    final key = SavedLibraryItem.keyFor(SavedContentType.dua, id);
    final stamp = meta[key]?.savedAt ?? now;
    final dua = DuaLibrary.byId(id);
    if (dua == null) {
      return SavedLibraryItem(
        type: SavedContentType.dua,
        sourceId: id,
        libraryKey: key,
        titleEn: 'Dua unavailable',
        titleAr: 'دعاء غير متوفر',
        subtitleEn: 'Favorite Dua',
        subtitleAr: 'دعاء مفضل',
        available: false,
        savedAt: stamp,
        lastViewedAt: meta[key]?.lastViewedAt,
      );
    }
    final category = DuaLibrary.categoryById(dua.categoryId);
    return SavedLibraryItem(
      type: SavedContentType.dua,
      sourceId: id,
      libraryKey: key,
      titleEn: category?.name(true) ?? 'Dua',
      titleAr: category?.name(false) ?? 'دعاء',
      subtitleEn: 'Favorite Dua · ${dua.reference}',
      subtitleAr: 'دعاء مفضل · ${dua.reference}',
      previewEn: _clip(dua.translationEn),
      previewAr: _clip(dua.arabic),
      available: true,
      savedAt: stamp,
      lastViewedAt: meta[key]?.lastViewedAt,
    );
  }

  SavedLibraryItem _asmaItem(
    String id,
    Map<String, SavedLibraryMeta> meta,
    DateTime now,
  ) {
    final key = SavedLibraryItem.keyFor(SavedContentType.namesOfAllah, id);
    final stamp = meta[key]?.savedAt ?? now;
    final name = AsmaUlHusna.byId(id);
    if (name == null) {
      return SavedLibraryItem(
        type: SavedContentType.namesOfAllah,
        sourceId: id,
        libraryKey: key,
        titleEn: 'Name unavailable',
        titleAr: 'اسم غير متوفر',
        subtitleEn: 'Names of Allah',
        subtitleAr: 'أسماء الله الحسنى',
        available: false,
        savedAt: stamp,
        lastViewedAt: meta[key]?.lastViewedAt,
      );
    }
    return SavedLibraryItem(
      type: SavedContentType.namesOfAllah,
      sourceId: id,
      libraryKey: key,
      titleEn: name.transliteration,
      titleAr: name.arabic,
      subtitleEn: 'Names of Allah · ${name.meaningEn}',
      subtitleAr: 'أسماء الله الحسنى · ${name.meaningAr}',
      previewEn: _clip(name.explanationEn),
      previewAr: _clip(name.explanationAr),
      available: true,
      savedAt: stamp,
      lastViewedAt: meta[key]?.lastViewedAt,
    );
  }

  Future<SavedLibraryItem?> _loadQuranBookmark(
    Map<String, SavedLibraryMeta> meta,
    DateTime now,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final surahNumber = prefs.getInt('last_surah_number');
    final ayahNumber = prefs.getInt('last_ayah_number');
    final surahName = prefs.getString('last_surah_name');
    if (surahNumber == null || ayahNumber == null) return null;

    final sourceId = '$surahNumber:$ayahNumber';
    final key =
        SavedLibraryItem.keyFor(SavedContentType.quranBookmark, sourceId);
    final stamp = meta[key]?.savedAt ?? now;
    String? arabicName;
    String? englishName;
    for (final s in QuranData.surahs) {
      if (s.number == surahNumber) {
        arabicName = s.name;
        englishName = s.englishName;
        break;
      }
    }
    final available = arabicName != null;
    return SavedLibraryItem(
      type: SavedContentType.quranBookmark,
      sourceId: sourceId,
      libraryKey: key,
      titleEn: englishName ?? (surahName ?? 'Quran bookmark'),
      titleAr: arabicName ?? (surahName ?? 'علامة قرآن'),
      subtitleEn: 'Quran bookmark · Ayah $ayahNumber',
      subtitleAr: 'علامة قرآن · آية $ayahNumber',
      available: available,
      savedAt: stamp,
      lastViewedAt: meta[key]?.lastViewedAt,
      routeArgs: {
        'surahNumber': '$surahNumber',
        'ayahNumber': '$ayahNumber',
      },
    );
  }

  String _clip(String value, [int max = 120]) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max).trim()}…';
  }
}

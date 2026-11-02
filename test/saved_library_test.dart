import 'package:back_to_prayer/core/services/asma_preferences_store.dart';
import 'package:back_to_prayer/core/services/dua_preferences_store.dart';
import 'package:back_to_prayer/core/services/hadith_explanation_service.dart';
import 'package:back_to_prayer/core/services/hadith_preferences_store.dart';
import 'package:back_to_prayer/core/services/saved_library_meta_store.dart';
import 'package:back_to_prayer/core/services/saved_library_repository.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/saved_library.dart';
import 'package:back_to_prayer/providers/saved_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Saved Library available', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'saved_library');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.savedLibrary);
  });

  test('aggregates favorites across modules and sorts by date saved', () async {
    final hadithStore = HadithPreferencesStore();
    final duaStore = DuaPreferencesStore();
    final asmaStore = AsmaPreferencesStore();
    final explanation = HadithExplanationService();
    await explanation.initialize();

    await hadithStore.saveFavorites({'nawawi:1'});
    await duaStore.saveFavorites({'huda-taqwa'});
    await asmaStore.saveFavorites({'ar-rahmaan'});
    await explanation.saveBookmarks({'nawawi:1'});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('adhkar_favorites_v1', ['morning::morning-kursi']);
    await prefs.setInt('last_surah_number', 1);
    await prefs.setInt('last_ayah_number', 1);
    await prefs.setString('last_surah_name', 'الفاتحة');

    var tick = DateTime(2026, 3, 20, 10);
    final repo = SavedLibraryRepository(
      hadithStore: hadithStore,
      duaStore: duaStore,
      asmaStore: asmaStore,
      explanationService: explanation,
      metaStore: SavedLibraryMetaStore(),
      clock: () => tick,
    );

    final firstPass = await repo.loadItems();
    expect(firstPass.length, greaterThanOrEqualTo(5));
    expect(
      firstPass.any((i) => i.type == SavedContentType.hadith),
      isTrue,
    );
    expect(
      firstPass.any((i) => i.type == SavedContentType.dua),
      isTrue,
    );
    expect(
      firstPass.any((i) => i.type == SavedContentType.namesOfAllah),
      isTrue,
    );
    expect(
      firstPass.any((i) => i.type == SavedContentType.quranBookmark),
      isTrue,
    );
    expect(
      firstPass.any((i) => i.type == SavedContentType.adhkar && i.available),
      isTrue,
    );

    // Second load keeps prior savedAt (not rewritten to a later clock).
    tick = DateTime(2026, 3, 21, 12);
    final secondPass = await repo.loadItems();
    final hadith = secondPass.firstWhere(
      (i) => i.type == SavedContentType.hadith && i.sourceId == 'nawawi:1',
    );
    expect(hadith.savedAt, DateTime(2026, 3, 20, 10));
    expect(hadith.available, isTrue);
  });

  test('filtering by type and query', () {
    final items = [
      SavedLibraryItem(
        type: SavedContentType.hadith,
        sourceId: 'nawawi:1',
        libraryKey: 'hadith:nawawi:1',
        titleEn: 'An-Nawawi',
        titleAr: 'النووي',
        subtitleEn: 'Favorite Hadith',
        subtitleAr: 'حديث مفضل',
        available: true,
        savedAt: DateTime(2026, 3, 20),
      ),
      SavedLibraryItem(
        type: SavedContentType.dua,
        sourceId: 'huda-taqwa',
        libraryKey: 'dua:huda-taqwa',
        titleEn: 'Guidance',
        titleAr: 'الهداية',
        subtitleEn: 'Favorite Dua',
        subtitleAr: 'دعاء مفضل',
        available: true,
        savedAt: DateTime(2026, 3, 19),
      ),
    ];

    final onlyDua = SavedLibraryProvider.filterItems(
      items: items,
      type: SavedContentType.dua,
    );
    expect(onlyDua.length, 1);
    expect(onlyDua.single.sourceId, 'huda-taqwa');

    final search = SavedLibraryProvider.filterItems(
      items: items,
      query: 'nawawi',
    );
    expect(search.length, 1);
    expect(search.single.type, SavedContentType.hadith);

    final oldest = SavedLibraryProvider.filterItems(
      items: items,
      sort: SavedLibrarySort.dateSavedOldest,
    );
    expect(oldest.first.sourceId, 'huda-taqwa');
  });

  test('removal updates source stores and persists across reloads', () async {
    final hadithStore = HadithPreferencesStore();
    final asmaStore = AsmaPreferencesStore();
    await hadithStore.saveFavorites({'nawawi:1', 'nawawi:2'});
    await asmaStore.saveFavorites({'ar-rahmaan'});

    final provider = SavedLibraryProvider(
      repository: SavedLibraryRepository(
        hadithStore: hadithStore,
        asmaStore: asmaStore,
        clock: () => DateTime(2026, 3, 20, 15),
      ),
    );
    await provider.initialize();
    expect(
      provider.allItems.any((i) => i.sourceId == 'nawawi:1'),
      isTrue,
    );

    final target = provider.allItems.firstWhere(
      (i) => i.type == SavedContentType.hadith && i.sourceId == 'nawawi:1',
    );
    await provider.remove(target);

    final favorites = await hadithStore.loadFavorites();
    expect(favorites.contains('nawawi:1'), isFalse);
    expect(favorites.contains('nawawi:2'), isTrue);
    expect(
      provider.allItems.any((i) => i.sourceId == 'nawawi:1'),
      isFalse,
    );

    final restored = SavedLibraryProvider(
      repository: SavedLibraryRepository(
        hadithStore: hadithStore,
        asmaStore: asmaStore,
      ),
    );
    await restored.initialize();
    expect(
      restored.allItems.any((i) => i.sourceId == 'nawawi:1'),
      isFalse,
    );
    expect(
      restored.allItems.any(
        (i) =>
            i.type == SavedContentType.namesOfAllah &&
            i.sourceId == 'ar-rahmaan',
      ),
      isTrue,
    );
  });

  test('unavailable source content is flagged without crashing', () async {
    final hadithStore = HadithPreferencesStore();
    await hadithStore.saveFavorites({'missing-hadith-id'});
    final asmaStore = AsmaPreferencesStore();
    await asmaStore.saveFavorites({'not-a-real-name'});

    final repo = SavedLibraryRepository(
      hadithStore: hadithStore,
      asmaStore: asmaStore,
      clock: () => DateTime(2026, 3, 20),
    );
    final items = await repo.loadItems();
    final missingHadith = items.firstWhere(
      (i) => i.sourceId == 'missing-hadith-id',
    );
    final missingAsma = items.firstWhere(
      (i) => i.sourceId == 'not-a-real-name',
    );
    expect(missingHadith.available, isFalse);
    expect(missingAsma.available, isFalse);
  });

  test('navigation targets keep stable source identifiers', () async {
    final hadithStore = HadithPreferencesStore();
    await hadithStore.saveFavorites({'nawawi:1'});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('adhkar_favorites_v1', ['morning::morning-kursi']);
    await prefs.setInt('last_surah_number', 2);
    await prefs.setInt('last_ayah_number', 255);

    final items = await SavedLibraryRepository(
      hadithStore: hadithStore,
      clock: () => DateTime(2026, 3, 20),
    ).loadItems();

    final hadith = items.firstWhere((i) => i.type == SavedContentType.hadith);
    expect(hadith.sourceId, 'nawawi:1');

    final adhkar = items.firstWhere((i) => i.type == SavedContentType.adhkar);
    expect(adhkar.routeArgs['categoryId'], 'morning');
    expect(adhkar.routeArgs['index'], isNotNull);

    final quran =
        items.firstWhere((i) => i.type == SavedContentType.quranBookmark);
    expect(quran.routeArgs['surahNumber'], '2');
    expect(quran.routeArgs['ayahNumber'], '255');
  });

  test('localization keys exist in English and Arabic', () {
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    const keys = [
      'savedTitle',
      'savedSearchHint',
      'savedFilterHadith',
      'savedFilterDuas',
      'savedFilterQuran',
      'savedFilterAsma',
      'savedEmptyTitle',
      'savedRemove',
      'savedUnavailableBody',
      'savedSortNewest',
    ];
    for (final key in keys) {
      expect(en.tr(key), isNot(equals(key)));
      expect(ar.tr(key), isNot(equals(key)));
      expect(ar.tr(key), isNot(equals(en.tr(key))));
    }
  });
}

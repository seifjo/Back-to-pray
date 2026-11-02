import 'package:back_to_prayer/core/services/dua_preferences_store.dart';
import 'package:back_to_prayer/data/adhkar_library.dart';
import 'package:back_to_prayer/data/dua_library.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/models/dua.dart';
import 'package:back_to_prayer/providers/dua_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Dua Library as available', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'dua_library');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.duaLibrary);
  });

  test('catalog covers required categories with verified sources', () {
    final ids = DuaLibrary.categories.map((c) => c.id).toSet();
    expect(
      ids.containsAll({
        'quranic',
        'prophetic',
        'forgiveness',
        'guidance',
        'patience_gratitude',
        'family',
        'travel',
        'difficult_times',
        'daily',
      }),
      isTrue,
    );
    expect(DuaLibrary.all, isNotEmpty);

    for (final item in DuaLibrary.all) {
      expect(item.arabic.trim(), isNotEmpty);
      expect(item.reference.trim(), isNotEmpty);
      expect(item.translationEn.trim(), isNotEmpty);
      if (item.isQuranic) {
        expect(
          item.reference.contains(':') ||
              item.reference.contains('آل') ||
              item.reference.contains('البقرة') ||
              item.reference.contains('الفاتحة') ||
              item.reference.contains('طه') ||
              item.reference.contains('الأنبياء') ||
              item.reference.contains('الفرقان') ||
              item.reference.contains('النمل') ||
              item.reference.contains('نوح'),
          isTrue,
          reason: '${item.id} should cite a Quranic reference',
        );
      }
    }
  });

  test('shared Adhkar relationships reuse the same Arabic text', () {
    final shared = DuaLibrary.all
        .where((item) => item.sharedAdhkarKey != null)
        .toList();
    expect(shared, isNotEmpty);

    for (final dua in shared) {
      final adhkar = DuaLibrary.sharedAdhkar(dua);
      expect(adhkar, isNotNull, reason: dua.sharedAdhkarKey);
      expect(adhkar!.arabicText, dua.arabic);

      final parts = dua.sharedAdhkarKey!.split('::');
      final category = AdhkarLibrary.byId(parts[0]);
      expect(category, isNotNull);
      expect(category!.items.any((item) => item.id == parts[1]), isTrue);
    }
  });

  test('search matches Arabic and English, and filters by category', () {
    final arabicHits = DuaLibrary.search(query: 'حَسْبُنَا');
    expect(arabicHits.any((item) => item.id == 'hasbunallah'), isTrue);

    final englishHits = DuaLibrary.search(query: 'straight path');
    expect(englishHits.any((item) => item.id == 'fatiha-ihdina'), isTrue);

    final family = DuaLibrary.search(categoryId: 'family');
    expect(family.every((item) => item.categoryId == 'family'), isTrue);
    expect(family, isNotEmpty);
  });

  test('related duas prefer same category then same source type', () {
    final seed = DuaLibrary.byId('sayyid-istighfar')!;
    final related = DuaLibrary.related(seed);
    expect(related, isNotEmpty);
    expect(related.any((item) => item.id == seed.id), isFalse);
    expect(
      related.first.categoryId == seed.categoryId ||
          related.first.sourceType == seed.sourceType,
      isTrue,
    );
  });

  test('favorites, recent, and font size persist', () async {
    final provider = DuaProvider(store: DuaPreferencesStore());
    await provider.initialize();
    expect(provider.loading, isFalse);
    expect(provider.error, isNull);

    final dua = DuaLibrary.all.first;
    await provider.toggleFavorite(dua.id);
    expect(provider.isFavorite(dua.id), isTrue);
    await provider.markViewed(dua.id);
    expect(provider.recentDuas.first.id, dua.id);
    await provider.setArabicFontSize(32);
    expect(provider.arabicFontSize, 32);

    final restored = DuaProvider(store: DuaPreferencesStore());
    await restored.initialize();
    expect(restored.isFavorite(dua.id), isTrue);
    expect(restored.recentDuas.first.id, dua.id);
    expect(restored.arabicFontSize, 32);
  });

  test('provider filter navigation for favorites and categories', () async {
    final provider = DuaProvider();
    await provider.initialize();

    final first = DuaLibrary.byCategory('travel').first;
    await provider.toggleFavorite(first.id);
    provider.setFavoritesOnly(true);
    expect(provider.filtered.map((item) => item.id), contains(first.id));

    provider.setCategoryFilter('quranic');
    expect(provider.favoritesOnly, isFalse);
    expect(
      provider.filtered.every((item) => item.categoryId == 'quranic'),
      isTrue,
    );

    provider.setQuery('رَبَّنَا');
    expect(provider.filtered, isNotEmpty);
    provider.clearFilters();
    expect(provider.query, isEmpty);
    expect(provider.categoryFilter, isNull);
  });

  test('Quranic and prophetic source types stay distinct', () {
    final quranic = DuaLibrary.byId('fatiha-ihdina')!;
    final prophetic = DuaLibrary.byId('huda-taqwa')!;
    expect(quranic.sourceType, DuaSourceType.quranic);
    expect(prophetic.sourceType, DuaSourceType.prophetic);
    expect(quranic.isQuranic, isTrue);
    expect(prophetic.isQuranic, isFalse);
  });
}

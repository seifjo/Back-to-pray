import 'package:back_to_prayer/core/services/hadith_preferences_store.dart';
import 'package:back_to_prayer/core/services/hadith_service.dart';
import 'package:back_to_prayer/core/utils/hadith_locale.dart';
import 'package:back_to_prayer/data/hadith_categories.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/models/hadith.dart';
import 'package:back_to_prayer/providers/hadith_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Hadith as available', () {
    final hadith = MoreFeaturesCatalog.features
        .firstWhere((feature) => feature.id == 'hadith');
    expect(hadith.available, isTrue);
  });

  test('Hadith seed loads, searches, and opens by id', () async {
    final service = HadithService();
    await service.initialize();
    expect(service.all.length, greaterThan(40));

    final prayer = service.search(categoryId: 'prayer');
    expect(prayer, isNotEmpty);

    final bukhari = service.search(query: 'bukhari');
    expect(bukhari, isNotEmpty);

    final first = service.all.first;
    expect(service.byId(first.id)?.id, first.id);
    expect(service.hadithOfTheDay().id, isNotEmpty);
  });

  test('category matching uses seed tags and keywords', () {
    const item = HadithItem(
      id: 'bukhari:1',
      collection: 'bukhari',
      collectionName: 'Sahih al-Bukhari',
      number: 1,
      arabicNumber: 1,
      arabic: 'عربي',
      english: 'The reward of deeds depends upon the intentions',
      seedCategory: 'faith',
    );
    expect(
      HadithCategories.matches(item, HadithCategories.all.firstWhere((c) => c.id == 'faith')),
      isTrue,
    );
  });

  test('favorites and recent Hadith persist locally', () async {
    final store = HadithPreferencesStore();
    await store.saveFavorites({'nawawi:1', 'bukhari:1'});
    await store.saveRecent(['bukhari:1', 'nawawi:1']);
    expect(await store.loadFavorites(), {'nawawi:1', 'bukhari:1'});
    expect(await store.loadRecent(), ['bukhari:1', 'nawawi:1']);
  });

  test('search, select, favorite, and recent Hadith flow', () async {
    final provider = HadithProvider();
    await provider.initialize();
    provider.setQuery('bukhari');
    expect(provider.filtered, isNotEmpty);

    final openTarget = provider.filtered.first;
    expect(provider.byId(openTarget.id)?.id, openTarget.id);

    await provider.toggleFavorite(openTarget.id);
    expect(provider.isFavorite(openTarget.id), isTrue);
    expect(provider.favoriteHadiths.map((h) => h.id), contains(openTarget.id));

    await provider.markViewed(openTarget.id);
    expect(provider.recentHadiths.first.id, openTarget.id);

    final related = provider.related(openTarget);
    expect(related.every((h) => h.collection == openTarget.collection), isTrue);
  });

  test('Hadith of the Day is deterministic for a calendar day', () async {
    final service = HadithService();
    await service.initialize();
    final day = DateTime(2026, 10, 5);
    final a = service.hadithOfTheDay(now: day);
    final b = service.hadithOfTheDay(now: day);
    expect(a.id, b.id);
    final featured = service.featuredHadith(now: day);
    expect(featured.id, isNot(equals(a.id)));
    expect(service.featuredHadith(now: day).id, featured.id);
  });

  test('topics are only assigned from seed tags or English keywords', () {
    const unmatched = HadithItem(
      id: 'x:1',
      collection: 'nawawi',
      collectionName: 'Nawawi',
      number: 1,
      arabicNumber: 1,
      arabic: 'نص',
      english: 'Something unrelated to filters',
    );
    expect(HadithCategories.primaryFor(unmatched), isNull);

    const prayer = HadithItem(
      id: 'x:2',
      collection: 'nawawi',
      collectionName: 'Nawawi',
      number: 2,
      arabicNumber: 2,
      arabic: 'نص',
      english: 'Establish the prayer at its fixed times',
    );
    expect(HadithCategories.primaryFor(prayer)?.id, 'prayer');
  });

  test('heading and preview are derived from source text only', () {
    const item = HadithItem(
      id: 'bukhari:1',
      collection: 'bukhari',
      collectionName: 'Sahih al-Bukhari',
      number: 1,
      arabicNumber: 1,
      arabic: 'إنما الأعمال بالنيات',
      english:
          'Narrated Umar bin Al-Khattab: The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.',
    );
    final heading = HadithLocale.heading(item, english: true);
    expect(heading, isNotNull);
    expect(heading!.toLowerCase(), contains('reward of deeds'));
    expect(heading.toLowerCase().startsWith('narrated'), isFalse);
    expect(HadithLocale.preview(item, english: true), isNotEmpty);
    expect(HadithLocale.heading(item, english: false), contains('الأعمال'));
  });

  test('search matches topic keywords', () async {
    final service = HadithService();
    await service.initialize();
    final byTopic = service.search(query: 'patience');
    expect(byTopic, isNotEmpty);
  });
}

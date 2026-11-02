import 'package:back_to_prayer/data/adhkar_library.dart';
import 'package:back_to_prayer/data/adhkar_shared_catalog.dart';
import 'package:back_to_prayer/providers/adhkar_progress_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('library loads all requested categories with items', () {
    final ids = AdhkarLibrary.categories.map((c) => c.stableId).toSet();
    expect(
      ids,
      containsAll([
        'morning',
        'evening',
        'after_prayer',
        'before_sleep',
        'waking',
        'enter_home',
        'leave_home',
        'enter_mosque',
        'leave_mosque',
        'before_eating',
        'after_eating',
        'travel',
        'weather',
        'forgiveness',
        'repentance',
        'tasbeeh',
        'quranic_duas',
        'prophetic',
        'friday',
        'protection',
        'anxiety',
        'gratitude',
        'daily_duas',
      ]),
    );
    expect(AdhkarLibrary.categories.length, greaterThanOrEqualTo(22));
    expect(AdhkarLibrary.contentVersion, greaterThanOrEqualTo(3));
    expect(AdhkarLibrary.totalItemPlacements, greaterThan(80));

    for (final category in AdhkarLibrary.categories) {
      expect(category.itemCount, greaterThan(0), reason: category.stableId);
      expect(category.nameEn, isNotEmpty);
      expect(category.name, isNotEmpty);
      for (final item in category.items) {
        expect(item.id, isNotEmpty, reason: '${category.stableId}');
        expect(item.contentId, isNotEmpty, reason: item.id);
        expect(item.arabicText.trim(), isNotEmpty);
        expect(item.reference.trim(), isNotEmpty);
        expect(item.translation.trim(), isNotEmpty);
        expect(item.repetitions, greaterThan(0));
        expect(item.attributionLine, isNotEmpty);
      }
    }
  });

  test('shared catalog deduplicates content across categories', () {
    final kursiPlacements = <String>[];
    for (final category in AdhkarLibrary.categories) {
      for (final item in category.items) {
        if (item.contentId == 'shared-ayat-kursi') {
          kursiPlacements.add('${category.stableId}::${item.id}');
          expect(
            item.arabicText,
            AdhkarSharedCatalog.byContentId('shared-ayat-kursi')!.arabicText,
          );
        }
      }
    }
    expect(kursiPlacements.length, greaterThanOrEqualTo(3));

    // Unique content ids are fewer than total placements (shared reuse).
    expect(
      AdhkarLibrary.allContentIds.length,
      lessThan(AdhkarLibrary.totalItemPlacements),
    );
  });

  test('localization fields present for every category', () {
    for (final category in AdhkarLibrary.categories) {
      expect(category.displayName(true), isNotEmpty);
      expect(category.displayName(false), isNotEmpty);
      expect(category.displayDescription(true), isNotEmpty);
      expect(category.displayDescription(false), isNotEmpty);
      expect(category.displayName(true), isNot(category.displayName(false)));
    }
  });

  test('favorites and recently viewed persist', () async {
    final provider = AdhkarProgressProvider(autoLoad: false);
    await provider.load();

    final morning = AdhkarLibrary.byId('morning')!;
    final item = morning.items.first;
    await provider.toggleFavorite(morning.stableId, item.id);
    await provider.recordView(morning.stableId, item.id);

    expect(provider.isFavorite(morning.stableId, item.id), isTrue);
    expect(provider.recentlyViewed(), isNotEmpty);
    expect(provider.recentlyViewed().first.item.id, item.id);

    final reloaded = AdhkarProgressProvider(autoLoad: false);
    await reloaded.load();
    expect(reloaded.isFavorite(morning.stableId, item.id), isTrue);
    expect(reloaded.recentlyViewed().first.item.id, item.id);
  });

  test('authenticity Sahih only when Bukhari/Muslim cited', () {
    for (final category in AdhkarLibrary.categories) {
      for (final item in category.items) {
        if (item.authenticity == 'Sahih') {
          final ref = '${item.reference} ${item.sourceBook ?? ''}'.toLowerCase();
          expect(
            ref.contains('بخاري') ||
                ref.contains('مسلم') ||
                ref.contains('bukhari') ||
                ref.contains('muslim'),
            isTrue,
            reason: '${item.id} marked Sahih without Bukhari/Muslim',
          );
        }
      }
    }
  });

  test('UI-facing categories resolve by id', () {
    for (final id in [
      'morning',
      'protection',
      'gratitude',
      'repentance',
      'anxiety',
    ]) {
      final category = AdhkarLibrary.byId(id);
      expect(category, isNotNull, reason: id);
      expect(category!.items, isNotEmpty);
    }
  });
}

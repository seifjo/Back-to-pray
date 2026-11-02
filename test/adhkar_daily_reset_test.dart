import 'package:back_to_prayer/data/adhkar_library.dart';
import 'package:back_to_prayer/providers/adhkar_progress_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime clock;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = DateTime(2026, 10, 5, 9, 0);
  });

  Future<AdhkarProgressProvider> buildProvider() async {
    final provider = AdhkarProgressProvider(
      clock: () => clock,
      autoLoad: false,
    );
    await provider.load();
    return provider;
  }

  test('same-day launch keeps counts and does not archive', () async {
    final provider = await buildProvider();
    final morning = AdhkarLibrary.byId('morning')!;
    final item = morning.items.first;
    await provider.markComplete(morning.stableId, item);

    expect(provider.countFor(morning.stableId, item.id), item.repetitions);
    expect(provider.activeDateKey, '2026-10-05');

    final reset = await provider.ensureToday();
    expect(reset, isFalse);
    expect(provider.countFor(morning.stableId, item.id), item.repetitions);
    expect(provider.history, isEmpty);
  });

  test('new calendar day resets today and archives history once', () async {
    final provider = await buildProvider();
    final morning = AdhkarLibrary.byId('morning')!;
    final item = morning.items.first;
    await provider.markComplete(morning.stableId, item);
    await provider.toggleFavorite(morning.stableId, item.id);

    clock = DateTime(2026, 10, 6, 8, 15);
    final reset = await provider.ensureToday();

    expect(reset, isTrue);
    expect(provider.activeDateKey, '2026-10-06');
    expect(provider.countFor(morning.stableId, item.id), 0);
    expect(provider.isCategoryComplete(morning), isFalse);
    expect(provider.isFavorite(morning.stableId, item.id), isTrue);

    final archived = provider.historyFor('2026-10-05');
    expect(archived, isNotNull);
    expect(archived!.counts.isNotEmpty, isTrue);
    expect(archived.completedItems, greaterThan(0));
    expect(
      archived.counts.keys.any((k) => k.startsWith('morning::')),
      isTrue,
    );

    // Second ensureToday on the new day must not duplicate history.
    await provider.ensureToday();
    expect(provider.history.keys.where((k) => k == '2026-10-05').length, 1);
  });

  test('opening after several days archives only the last active day', () async {
    final provider = await buildProvider();
    final evening = AdhkarLibrary.byId('evening')!;
    await provider.markComplete(evening.stableId, evening.items.first);

    clock = DateTime(2026, 10, 9, 10, 0);
    await provider.ensureToday();

    expect(provider.activeDateKey, '2026-10-09');
    expect(provider.history.containsKey('2026-10-05'), isTrue);
    expect(provider.history.containsKey('2026-10-06'), isFalse);
    expect(provider.history.containsKey('2026-10-09'), isFalse);
    expect(provider.todayCompletedCategoryCount, 0);
  });

  test('resume after midnight resets without wiping favorites', () async {
    final provider = await buildProvider();
    final morning = AdhkarLibrary.byId('morning')!;
    final item = morning.items.first;
    await provider.increment(morning.stableId, item.id, item.repetitions);
    await provider.toggleFavorite(morning.stableId, item.id);

    clock = DateTime(2026, 10, 6, 0, 5);
    final reset = await provider.checkDailyReset();
    expect(reset, isTrue);
    expect(provider.countFor(morning.stableId, item.id), 0);
    expect(provider.favorites, isNotEmpty);
  });

  test('timezone calendar date shift is treated as a new day', () async {
    // Simulate local calendar moving from Oct 5 to Oct 6 (e.g. TZ change).
    clock = DateTime(2026, 10, 5, 23, 30);
    final provider = await buildProvider();
    final morning = AdhkarLibrary.byId('morning')!;
    await provider.markComplete(morning.stableId, morning.items.first);

    clock = DateTime(2026, 10, 6, 0, 10);
    await provider.ensureToday();
    expect(provider.isCategoryComplete(morning), isFalse);
    expect(provider.historyFor('2026-10-05')?.completedItems, greaterThan(0));
    expect(provider.historyFor('2026-10-05')?.counts.isNotEmpty, isTrue);
  });

  test('history survives reload and offline same-day usage', () async {
    var provider = await buildProvider();
    final morning = AdhkarLibrary.byId('morning')!;
    await provider.markComplete(morning.stableId, morning.items.first);

    clock = DateTime(2026, 10, 6, 9, 0);
    await provider.ensureToday();

    // Simulate cold start offline on the new day.
    provider = AdhkarProgressProvider(
      clock: () => clock,
      autoLoad: false,
    );
    await provider.load();

    expect(provider.activeDateKey, '2026-10-06');
    expect(provider.historyFor('2026-10-05'), isNotNull);
    expect(provider.countFor(morning.stableId, morning.items.first.id), 0);
    expect(AdhkarLibrary.contentVersion, greaterThan(0));
  });

  test('today summary getters reflect only current day state', () async {
    final provider = await buildProvider();
    expect(provider.todayOverallProgress, 0);
    expect(provider.remainingCategoriesToday.length, provider.todayTotalCategoryCount);

    final morning = AdhkarLibrary.byId('morning')!;
    for (final item in morning.items) {
      await provider.markComplete(morning.stableId, item);
    }

    expect(provider.isCategoryComplete(morning), isTrue);
    expect(provider.completedCategoriesToday.map((c) => c.stableId), contains('morning'));
    expect(provider.remainingCategoriesToday.map((c) => c.stableId), isNot(contains('morning')));
    expect(provider.todayCompletedItemCount, greaterThan(0));
  });
}

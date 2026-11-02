import 'package:back_to_prayer/core/services/worship_tracker_store.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/data/worship_tracker_catalog.dart';
import 'package:back_to_prayer/models/worship_tracker.dart';
import 'package:back_to_prayer/providers/worship_tracker_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features routes Worship Tracker to its screen', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'worship_tracker');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.worshipTracker);
  });

  test('daily progress requires explicit toggle', () async {
    final provider = WorshipTrackerProvider(
      store: WorshipTrackerStore(),
      clock: () => DateTime(2026, 10, 2, 9),
    );
    await provider.initialize();
    expect(provider.dashboardActivities, isNotEmpty);
    expect(provider.todayCompletedCount, 0);

    final prayer = provider.byId('prayer_daily')!;
    expect(provider.isCompleted(prayer), isFalse);

    await provider.toggleCompleted(prayer.id);
    expect(provider.isCompleted(prayer), isTrue);
    expect(provider.todayCompletedCount, 1);

    await provider.toggleCompleted(prayer.id);
    expect(provider.isCompleted(prayer), isFalse);
  });

  test('editing goals: pause, custom add, and remove persist', () async {
    final store = WorshipTrackerStore();
    final provider = WorshipTrackerProvider(
      store: store,
      clock: () => DateTime(2026, 10, 2, 10),
    );
    await provider.initialize();
    expect(provider.activities.length, WorshipTrackerCatalog.presets.length);

    await provider.setPaused('tasbeeh', true);
    expect(provider.dashboardActivities.any((a) => a.id == 'tasbeeh'), isFalse);
    expect(provider.pausedActivities.any((a) => a.id == 'tasbeeh'), isTrue);

    await provider.addCustom(
      titleEn: 'Night Quran page',
      titleAr: 'صفحة قرآن ليلاً',
      kind: WorshipActivityKind.quran,
      nature: WorshipGoalNature.personal,
      shortcut: 'quran',
    );
    expect(
      provider.activities.any((a) => a.titleEn == 'Night Quran page'),
      isTrue,
    );

    final customId =
        provider.activities.firstWhere((a) => a.titleEn == 'Night Quran page').id;
    await provider.removeActivity(customId);

    final restored = WorshipTrackerProvider(
      store: store,
      clock: () => DateTime(2026, 10, 2, 11),
    );
    await restored.initialize();
    expect(restored.byId('tasbeeh')!.paused, isTrue);
    expect(
      restored.activities.any((a) => a.titleEn == 'Night Quran page'),
      isFalse,
    );
  });

  test('date change keeps history and resets today view', () async {
    var now = DateTime(2026, 10, 2, 21);
    final store = WorshipTrackerStore();
    final provider = WorshipTrackerProvider(
      store: store,
      clock: () => now,
    );
    await provider.initialize();
    await provider.toggleCompleted('quran_read');
    expect(provider.selectedDateKey, '2026-10-02');
    expect(provider.todayCompletedCount, 1);

    now = DateTime(2026, 10, 3, 8);
    provider.onDayBoundaryCheck();
    expect(provider.selectedDateKey, '2026-10-03');
    expect(provider.todayCompletedCount, 0);
    expect(
      provider.logFor(DateTime(2026, 10, 2)).isComplete(
            provider.byId('quran_read')!,
          ),
      isTrue,
    );
  });

  test('weekly summary and obligation/personal distinction', () async {
    final provider = WorshipTrackerProvider(
      clock: () => DateTime(2026, 10, 5, 12),
    );
    await provider.initialize();
    final prayer = provider.byId('prayer_daily')!;
    final learning = provider.byId('learning')!;
    expect(prayer.nature, WorshipGoalNature.obligation);
    expect(learning.nature, WorshipGoalNature.personal);

    await provider.toggleCompleted(prayer.id);
    final week = provider.weeklySummary;
    expect(week.completedSlots, greaterThanOrEqualTo(1));
    expect(week.possibleSlots, greaterThan(0));
    expect(week.completedByActivity[prayer.id], greaterThanOrEqualTo(1));
  });

  test('opening linked features is separate from completion state', () async {
    final provider = WorshipTrackerProvider(
      clock: () => DateTime(2026, 10, 2, 15),
    );
    await provider.initialize();
    final quran = provider.byId('quran_read')!;
    expect(quran.shortcut, 'quran');
    expect(provider.isCompleted(quran), isFalse);
    // No auto-complete API exists; only toggleCompleted mutates logs.
    expect(provider.selectedLog.completions, isEmpty);
  });
}

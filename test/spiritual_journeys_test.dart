import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/data/spiritual_journey_catalog.dart';
import 'package:back_to_prayer/models/active_journey.dart';
import 'package:back_to_prayer/models/spiritual_journey.dart';
import 'package:back_to_prayer/providers/spiritual_journey_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features exposes Journeys', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'journeys');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.journeys);
  });

  test('catalog includes the suggested spiritual journeys', () {
    final ids = SpiritualJourneyCatalog.all.map((j) => j.id).toSet();
    expect(
      ids.containsAll({
        'prayer_7',
        'quran_30',
        'adhkar_daily',
        'gratitude',
        'repentance',
        'character',
        'hifz',
        'ramadan_prep',
        'good_deeds',
      }),
      isTrue,
    );
    for (final journey in SpiritualJourneyCatalog.all) {
      expect(journey.durationDays, greaterThan(0));
      expect(journey.tasksEn.length, journey.durationDays);
      expect(journey.disclaimerEn, isNotEmpty);
    }
  });

  test('start, pause, resume, and restore progress', () async {
    final provider = SpiritualJourneyProvider(
      clock: () => DateTime(2026, 10, 3, 9),
    );
    await provider.load();

    await provider.start('prayer_7');
    expect(provider.progressFor('prayer_7')!.status, JourneyStatus.active);
    expect(provider.activeJourneys.any((j) => j.id == 'prayer_7'), isTrue);

    await provider.pause('prayer_7');
    expect(provider.progressFor('prayer_7')!.status, JourneyStatus.paused);

    await provider.resume('prayer_7');
    expect(provider.progressFor('prayer_7')!.status, JourneyStatus.active);

    await provider.toggleToday('prayer_7');
    expect(provider.isTodayDone('prayer_7'), isTrue);

    final restored = SpiritualJourneyProvider(
      clock: () => DateTime(2026, 10, 3, 10),
    );
    await restored.load();
    expect(restored.progressFor('prayer_7')!.status, JourneyStatus.active);
    expect(restored.isTodayDone('prayer_7'), isTrue);
    expect(restored.progressFor('prayer_7')!.completedDays, isNotEmpty);
  });

  test('missed days do not reset progress', () async {
    var now = DateTime(2026, 10, 1, 8);
    final provider = SpiritualJourneyProvider(clock: () => now);
    await provider.load();
    await provider.start('gratitude');
    await provider.toggleToday('gratitude');
    expect(provider.progressFor('gratitude')!.completedDays.length, 1);

    now = DateTime(2026, 10, 3, 8);
    expect(
      hasEarlierUnmarkedDay(
        start: provider.progressFor('gratitude')!.startDate,
        now: now,
        durationDays: 7,
        completedDays: provider.progressFor('gratitude')!.completedDays,
      ),
      isTrue,
    );
    expect(provider.progressFor('gratitude')!.completedDays.length, 1);
    expect(provider.ratio('gratitude'), greaterThan(0));
  });

  test('completing required days marks journey complete', () async {
    var day = DateTime(2026, 10, 1, 12);
    final provider = SpiritualJourneyProvider(clock: () => day);
    await provider.load();
    await provider.start('gratitude'); // 7 days

    for (var i = 0; i < 7; i++) {
      day = DateTime(2026, 10, 1 + i, 12);
      final finished = await provider.toggleToday('gratitude');
      if (i < 6) {
        expect(finished, isFalse);
        expect(
          provider.progressFor('gratitude')!.status,
          JourneyStatus.active,
        );
      } else {
        expect(finished, isTrue);
        expect(
          provider.progressFor('gratitude')!.status,
          JourneyStatus.completed,
        );
      }
    }
    expect(provider.completedJourneys.any((j) => j.id == 'gratitude'), isTrue);
  });

  test('multiple journeys can be active and abandon returns to available',
      () async {
    final provider = SpiritualJourneyProvider(
      clock: () => DateTime(2026, 10, 3, 11),
    );
    await provider.load();
    await provider.start('prayer_7');
    await provider.start('adhkar_daily');
    expect(provider.activeJourneys.length, greaterThanOrEqualTo(2));

    await provider.abandon('adhkar_daily');
    expect(
      provider.progressFor('adhkar_daily')!.status,
      JourneyStatus.abandoned,
    );
    expect(provider.availableJourneys.any((j) => j.id == 'adhkar_daily'), isTrue);
  });
}

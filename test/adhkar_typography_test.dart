import 'package:back_to_prayer/data/adhkar_library.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/adhkar.dart';
import 'package:back_to_prayer/providers/adhkar_progress_provider.dart';
import 'package:back_to_prayer/providers/app_settings_provider.dart';
import 'package:back_to_prayer/providers/daily_achievements_provider.dart';
import 'package:back_to_prayer/screens/adhkar/adhkar_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('library exposes required categories with stable ids and sources', () {
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
    expect(AdhkarLibrary.contentVersion, greaterThanOrEqualTo(3));

    for (final category in AdhkarLibrary.categories) {
      expect(category.items, isNotEmpty, reason: category.stableId);
      for (final item in category.items) {
        expect(item.id, isNotEmpty, reason: category.stableId);
        expect(item.arabicText.trim(), isNotEmpty);
        expect(item.reference.trim(), isNotEmpty);
        expect(item.repetitions, greaterThan(0));
        expect(item.translation.trim(), isNotEmpty);
      }
    }
  });

  test('long sleep adhkar keeps full arabic without truncation metadata', () {
    final sleep = AdhkarLibrary.byId('before_sleep')!;
    final long = sleep.items.firstWhere((i) => i.id == 'sleep-baqarah-end');
    expect(long.arabicText.length, greaterThan(200));
    expect(long.arabicText.contains('آمَنَ الرَّسُولُ'), isTrue);
  });

  test('font presets cover small through extra-large', () {
    expect(AppSettingsProvider.fontSmall, 20);
    expect(AppSettingsProvider.fontMedium, 26);
    expect(AppSettingsProvider.fontLarge, 32);
    expect(AppSettingsProvider.fontExtraLarge, 40);
  });

  testWidgets('reader shows Arabic + translation without dual Expanded clipping',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'adhkar_show_translation': true,
      'adhkar_font_size': 40.0,
    });

    final sleep = AdhkarLibrary.byId('before_sleep')!;
    final long = sleep.items.firstWhere((i) => i.id == 'sleep-baqarah-end');
    final index = sleep.items.indexWhere((i) => i.id == long.id);

    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(
            create: (_) => AdhkarProgressProvider(autoLoad: false),
          ),
          ChangeNotifierProvider(create: (_) => DailyAchievementsProvider()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdhkarReaderScreen(
            category: sleep,
            initialIndex: index,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Full long Arabic is in the tree (not clipped out by a fixed Expanded pane).
    expect(find.text(long.arabicText), findsOneWidget);
    expect(find.text(long.translation), findsOneWidget);
    expect(find.text(long.attributionLine), findsOneWidget);

    // Scrollable card content — not two Expanded siblings competing for height.
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -600),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(long.arabicText), findsOneWidget);
  });

  testWidgets('translation off keeps Arabic primary and hides translation',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'adhkar_show_translation': false,
      'adhkar_font_size': 32.0,
    });

    final shortCategory = AdhkarCategory(
      id: 'test_short',
      name: 'اختبار',
      nameEn: 'Test',
      description: 't',
      descriptionEn: 't',
      recommendedTime: 'now',
      recommendedTimeEn: 'now',
      items: const [
        AdhkarItem(
          id: 'short-1',
          contentId: 'short-1',
          arabicText: 'سُبْحَانَ اللهِ',
          repetitions: 33,
          reference: 'صحيح مسلم',
          translation: 'Glory be to Allah.',
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(
            create: (_) => AdhkarProgressProvider(autoLoad: false),
          ),
          ChangeNotifierProvider(create: (_) => DailyAchievementsProvider()),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdhkarReaderScreen(category: shortCategory),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('سُبْحَانَ اللهِ'), findsOneWidget);
    expect(find.text('Glory be to Allah.'), findsNothing);
    expect(find.textContaining('صحيح مسلم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

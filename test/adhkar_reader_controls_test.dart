import 'package:back_to_prayer/data/adhkar_library.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
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
    SharedPreferences.setMockInitialValues({
      'adhkar_show_translation': true,
      'adhkar_font_size': 26.0,
    });
  });

  Future<(WidgetTester, AdhkarProgressProvider)> pumpReader(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    int initialIndex = 0,
  }) async {
    final leaving = AdhkarLibrary.byId('leave_home')!;
    final progress = AdhkarProgressProvider(autoLoad: false);
    await progress.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider.value(value: progress),
          ChangeNotifierProvider(create: (_) => DailyAchievementsProvider()),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdhkarReaderScreen(
            category: leaving,
            initialIndex: initialIndex,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    return (tester, progress);
  }

  testWidgets('count increments and bookmark toggles live', (tester) async {
    final leaving = AdhkarLibrary.byId('leave_home')!;
    final firstId = leaving.items.first.id;
    final (_, progress) = await pumpReader(tester);

    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.textContaining('Swipe left or right'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pump();
    expect(progress.isFavorite(leaving.stableId, firstId), isTrue);

    await tester.tap(find.text('Count'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      progress.countFor(leaving.stableId, firstId),
      leaving.items.first.repetitions,
    );
  });

  testWidgets('next and previous buttons change pages', (tester) async {
    await pumpReader(tester);

    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('Arabic locale shows Arabic swipe hint', (tester) async {
    await pumpReader(tester, locale: const Locale('ar'));
    expect(find.textContaining('اسحب يمينًا أو يسارًا'), findsOneWidget);
  });
}

import 'package:back_to_prayer/core/theme/app_theme.dart';
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

  const longArabic =
      'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ '
      'لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ '
      'يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ '
      'وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ';

  const longTranslation =
      'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. '
      'Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens '
      'and whatever is on the earth. Who is it that can intercede with Him except by His permission? '
      'He knows what is before them and what will be after them, and they encompass not a thing '
      'of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, '
      'and their preservation tires Him not. And He is the Most High, the Most Great.';

  AdhkarCategory longCategory() => const AdhkarCategory(
        id: 'layout_test',
        name: 'اختبار',
        nameEn: 'Layout Test',
        description: 't',
        descriptionEn: 't',
        recommendedTime: 'now',
        recommendedTimeEn: 'now',
        items: [
          AdhkarItem(
            id: 'long-1',
            contentId: 'long-1',
            arabicText: longArabic,
            repetitions: 1,
            reference: 'البقرة: 255',
            translation: longTranslation,
            explanation: 'آية الكرسي — نص طويل للتحقق من التخطيط.',
          ),
        ],
      );

  Future<void> pumpReader(
    WidgetTester tester, {
    required double fontSize,
    required bool showTranslation,
    ThemeData? theme,
    Size size = const Size(360, 640),
    AdhkarCategory? category,
    Locale locale = const Locale('en'),
  }) async {
    SharedPreferences.setMockInitialValues({
      'adhkar_show_translation': showTranslation,
      'adhkar_font_size': fontSize,
    });

    await tester.binding.setSurfaceSize(size);
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
          theme: theme ?? AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdhkarReaderScreen(category: category ?? longCategory()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> expectNoOverflow(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      if ('${details.exception}'.contains('RenderFlex overflowed') ||
          '${details.exception}'.contains('OVERFLOWED')) {
        errors.add(details);
      }
      old?.call(details);
    };
    await tester.pump();
    FlutterError.onError = old;
    expect(errors, isEmpty, reason: 'RenderFlex overflow detected');
  }

  Future<void> scrollContentFully(WidgetTester tester) async {
    final scrollables = find.byType(SingleChildScrollView);
    expect(scrollables, findsWidgets);
    // Drag several times so Extra Large content is fully reachable.
    for (var i = 0; i < 6; i++) {
      await tester.drag(scrollables.first, const Offset(0, -400));
      await tester.pump();
    }
  }

  testWidgets('Arabic only + Small — full text, no overflow', (tester) async {
    await pumpReader(
      tester,
      fontSize: AppSettingsProvider.fontSmall,
      showTranslation: false,
    );
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsNothing);
    await expectNoOverflow(tester);
  });

  testWidgets('Arabic only + Large — full text, no overflow', (tester) async {
    await pumpReader(
      tester,
      fontSize: AppSettingsProvider.fontLarge,
      showTranslation: false,
    );
    expect(find.text(longArabic), findsOneWidget);
    await scrollContentFully(tester);
    expect(find.text(longArabic), findsOneWidget);
    await expectNoOverflow(tester);
  });

  testWidgets('Arabic + Translation + Small — both visible', (tester) async {
    await pumpReader(
      tester,
      fontSize: AppSettingsProvider.fontSmall,
      showTranslation: true,
    );
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsOneWidget);
    await expectNoOverflow(tester);
  });

  testWidgets('Arabic + Translation + Large — both remain in tree',
      (tester) async {
    await pumpReader(
      tester,
      fontSize: AppSettingsProvider.fontLarge,
      showTranslation: true,
    );
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsOneWidget);
    await scrollContentFully(tester);
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsOneWidget);
    await expectNoOverflow(tester);
  });

  testWidgets(
      'Arabic + Translation + Extra Large — no clipped/disappearing text',
      (tester) async {
    await pumpReader(
      tester,
      fontSize: AppSettingsProvider.fontExtraLarge,
      showTranslation: true,
      size: const Size(360, 640),
    );

    // Both strings must remain in the widget tree (not dropped by clipping layout).
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsOneWidget);

    final arabicText = tester.widget<Text>(find.text(longArabic));
    expect(arabicText.softWrap, isTrue);
    expect(arabicText.maxLines, isNull);
    expect(arabicText.style?.fontSize, AppSettingsProvider.fontExtraLarge);

    final translationText = tester.widget<Text>(find.text(longTranslation));
    expect(translationText.softWrap, isTrue);
    expect(translationText.maxLines, isNull);
    // Translation tracks Arabic size (not capped at 24).
    expect(translationText.style?.fontSize, greaterThan(24));

    await scrollContentFully(tester);
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsOneWidget);
    expect(find.textContaining('البقرة'), findsOneWidget);
    await expectNoOverflow(tester);
  });

  testWidgets('Extra Large + translation works in dark theme', (tester) async {
    await pumpReader(
      tester,
      fontSize: AppSettingsProvider.fontExtraLarge,
      showTranslation: true,
      theme: AppTheme.darkTheme,
    );
    expect(find.text(longArabic), findsOneWidget);
    expect(find.text(longTranslation), findsOneWidget);
    await scrollContentFully(tester);
    expect(find.text(longTranslation), findsOneWidget);
    await expectNoOverflow(tester);
  });

  testWidgets('library long sleep ayah stays fully readable at XL',
      (tester) async {
    final sleep = AdhkarLibrary.byId('before_sleep')!;
    final long = sleep.items.firstWhere((i) => i.id == 'sleep-baqarah-end');
    final index = sleep.items.indexWhere((i) => i.id == long.id);

    SharedPreferences.setMockInitialValues({
      'adhkar_show_translation': true,
      'adhkar_font_size': 40.0,
    });
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
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdhkarReaderScreen(category: sleep, initialIndex: index),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(long.arabicText), findsOneWidget);
    expect(find.text(long.translation), findsOneWidget);
    await scrollContentFully(tester);
    expect(find.text(long.arabicText), findsOneWidget);
    expect(find.text(long.translation), findsOneWidget);
    await expectNoOverflow(tester);
  });
}

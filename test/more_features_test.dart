import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/screens/more/more_features_screen.dart';
import 'package:back_to_prayer/widgets/more/feature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:back_to_prayer/providers/app_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('feature search matches English and Arabic names', () {
    expect(MoreFeaturesCatalog.search('qibla').map((f) => f.id), ['qibla']);
    expect(MoreFeaturesCatalog.search('القبلة').map((f) => f.id), ['qibla']);
    expect(
      MoreFeaturesCatalog.search('adhkar').map((f) => f.id),
      contains('adhkar'),
    );
    expect(
      MoreFeaturesCatalog.search('الأذكار').map((f) => f.id),
      contains('adhkar'),
    );
    expect(MoreFeaturesCatalog.search('xyz-missing'), isEmpty);
  });

  test('grouped search keeps category keys and drops empty sections later', () {
    final grouped = MoreFeaturesCatalog.grouped('tasbeeh');
    expect(grouped[MoreFeatureCategory.worship]!.single.id, 'tasbeeh');
    expect(grouped[MoreFeatureCategory.knowledge], isEmpty);
    expect(grouped[MoreFeatureCategory.tools], isEmpty);
  });

  test('catalog never lists a Quran reader duplicate', () {
    expect(
      MoreFeaturesCatalog.features.any(
        (feature) =>
            feature.id == 'quran' ||
            feature.route.name.toLowerCase() == 'quran',
      ),
      isFalse,
    );
    // Race and Journeys belong in More Features (not bottom nav).
    expect(
      MoreFeaturesCatalog.features.map((f) => f.id),
      containsAll(['race', 'journeys']),
    );
  });

  test('existing features are marked available for navigation', () {
    final available = MoreFeaturesCatalog.features
        .where((feature) => feature.available)
        .map((feature) => feature.id)
        .toSet();
    expect(
      available,
      containsAll(['adhkar', 'journeys', 'qibla', 'worship_tracker']),
    );
  });

  testWidgets('More Features screen filters cards and clears search',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppSettingsProvider(),
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MoreFeaturesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(MoreFeaturesScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FeatureCard), findsWidgets);

    await tester.enterText(find.byType(TextField), 'xyz-missing');
    await tester.pumpAndSettle();
    expect(find.byType(FeatureCard), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(FeatureCard), findsWidgets);
  });
}

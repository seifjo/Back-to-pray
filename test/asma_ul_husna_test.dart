import 'package:back_to_prayer/core/services/asma_preferences_store.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/data/asma_ul_husna.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/asma.dart';
import 'package:back_to_prayer/providers/asma_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Names of Allah as available', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'names_of_allah');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.namesOfAllah);
  });

  test('primary ranking has 99 names beginning with Allah', () {
    expect(AsmaUlHusna.primary.length, 99);
    expect(AsmaUlHusna.primary.first.arabic, 'الله');
    expect(AsmaUlHusna.primary.first.id, 'allah');
    expect(AsmaUlHusna.primary[1].arabic, 'الرحمن');
    expect(AsmaUlHusna.primary[2].arabic, 'الرحيم');
    expect(AsmaUlHusna.primary.last.arabic, 'ذو الجلال والإكرام');
    expect(AsmaUlHusna.compoundQuran.length, 35);
    expect(AsmaUlHusna.sunnahExtra.length, 12);
    expect(AsmaUlHusna.all.length, 99 + 35 + 12);
    expect(AsmaUlHusna.attributionEn.toLowerCase(), contains('surahquran'));
    for (final name in AsmaUlHusna.primary) {
      expect(name.collection, AsmaCollectionKind.primary);
      expect(name.arabic.trim(), isNotEmpty);
      expect(name.explanationAr.trim(), isNotEmpty);
      expect(name.meaningEn.trim(), isNotEmpty);
    }
  });

  test('SurahQuran ranking includes key ordered Names', () {
    const expected = <(int, String)>[
      (1, 'الله'),
      (2, 'الرحمن'),
      (3, 'الرحيم'),
      (4, 'الملك'),
      (5, 'القدوس'),
      (6, 'السلام'),
      (7, 'المؤمن'),
      (8, 'المهيمن'),
      (9, 'العزيز'),
      (10, 'الجبار'),
      (15, 'الأول'),
      (26, 'علّام الغيوب'),
      (50, 'الحي'),
      (51, 'القيوم'),
      (74, 'الواحد'),
      (75, 'الأحد'),
      (98, 'مالك الملك'),
      (99, 'ذو الجلال والإكرام'),
    ];
    for (final entry in expected) {
      final name = AsmaUlHusna.byIndex(entry.$1);
      expect(name, isNotNull, reason: '${entry.$1}');
      expect(name!.arabic, entry.$2);
      expect(name.index, entry.$1);
    }
  });

  test('compound and sunnah sections stay separate', () {
    expect(
      AsmaUlHusna.compoundQuran.every(
        (n) => n.collection == AsmaCollectionKind.quranCompound,
      ),
      isTrue,
    );
    expect(
      AsmaUlHusna.sunnahExtra.every(
        (n) =>
            n.collection == AsmaCollectionKind.sunnahExtra &&
            n.sourceKind == AsmaSourceKind.sunnah,
      ),
      isTrue,
    );
    expect(
      AsmaUlHusna.search(collection: AsmaCollectionKind.quranCompound).first
          .arabic,
      'غافر الذنب',
    );
    expect(
      AsmaUlHusna.search(collection: AsmaCollectionKind.sunnahExtra)
          .map((n) => n.arabic),
      contains('القابض'),
    );
  });

  test('complete primary ordering has unique indices 1..99', () {
    final indices = AsmaUlHusna.primary.map((n) => n.index).toList();
    expect(indices, List.generate(99, (i) => i + 1));
    expect(indices.toSet().length, 99);
  });

  test('learning session follows primary ranking without shuffling', () async {
    final provider = AsmaProvider();
    await provider.initialize();
    await provider.startSession(size: 5, quizMode: false, unreviewedOnly: false);
    expect(
      provider.session!.nameIds,
      AsmaUlHusna.primary.take(5).map((n) => n.id).toList(),
    );
    expect(provider.currentLearningName?.arabic, 'الله');
  });

  test('search and related navigation helpers', () {
    final allah = AsmaUlHusna.search(query: 'الله');
    expect(allah.any((n) => n.id == 'allah'), isTrue);

    final mercy = AsmaUlHusna.search(query: 'merciful');
    expect(mercy.any((n) => n.arabic == 'الرحمن'), isTrue);

    final seed = AsmaUlHusna.byId('allah')!;
    final related = AsmaUlHusna.related(seed);
    expect(related, isNotEmpty);
    expect(related.any((n) => n.id == seed.id), isFalse);
  });

  test('favorites and learning progress persist', () async {
    final provider = AsmaProvider(store: AsmaPreferencesStore());
    await provider.initialize();
    expect(provider.error, isNull);
    expect(provider.totalCount, 99);
    expect(provider.catalogCount, greaterThan(99));

    final name = AsmaUlHusna.byId('al-hakeem')!;
    await provider.toggleFavorite(name.id);
    await provider.markReviewed(name.id);
    expect(provider.isFavorite(name.id), isTrue);
    expect(provider.isReviewed(name.id), isTrue);
    expect(provider.reviewedCount, 1);

    await provider.startSession(size: 5, quizMode: false);
    expect(provider.session, isNotNull);
    expect(provider.currentLearningName, isNotNull);
    await provider.markCurrentReviewedAndNext();

    final restored = AsmaProvider(store: AsmaPreferencesStore());
    await restored.initialize();
    expect(restored.isFavorite(name.id), isTrue);
    expect(restored.reviewedCount, greaterThanOrEqualTo(1));
    expect(restored.session, isNotNull);
  });

  test('quiz session tracks answers and can restart', () async {
    final provider = AsmaProvider();
    await provider.initialize();
    await provider.startSession(size: 3, quizMode: true, unreviewedOnly: false);
    final current = provider.currentLearningName!;
    final correct = await provider.answerQuiz(current.meaningEn);
    expect(correct, isTrue);
    expect(provider.lifetimeQuizCorrect, 1);
    expect(provider.lifetimeQuizAnswered, 1);

    await provider.restartSession();
    expect(provider.session!.cursor, 0);
    expect(provider.session!.quizMode, isTrue);
  });

  test('artwork asset path and source url are configured', () {
    expect(AsmaUlHusna.artworkAsset, contains('asma_ul_husna_grid.png'));
    expect(AsmaUlHusna.sourceUrl, contains('surahquran.com'));
  });

  test('localization keys exist in English and Arabic', () {
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    const keys = [
      'asmaTitle',
      'asmaLearningMode',
      'asmaFavorites',
      'asmaPrimary99',
      'asmaCompound',
      'asmaSunnahExtra',
      'asmaArtwork',
      'asmaPrimaryInArtwork',
      'asmaExplanation',
      'asmaOpenSourcePage',
      'asmaBegin',
      'asmaQuizMode',
    ];
    for (final key in keys) {
      expect(en.tr(key), isNot(equals(key)), reason: 'en $key');
      expect(ar.tr(key), isNot(equals(key)), reason: 'ar $key');
      expect(ar.tr(key), isNot(equals(en.tr(key))), reason: 'diff $key');
    }
    expect(
      ar.tr('asmaCompound'),
      'أسماء الله الحسنى المركبة الواردة القرآن الكريم',
    );
    expect(
      ar.tr('asmaSunnahExtra'),
      'أسماء الله الحسنى الواردة في السنة الصحيحة',
    );
  });
}

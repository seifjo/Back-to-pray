import 'package:back_to_prayer/core/utils/hadith_locale.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/hadith.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sample = HadithItem(
    id: 'nawawi:1',
    collection: 'nawawi',
    collectionName: 'An-Nawawi\'s Forty',
    number: 1,
    arabicNumber: 1,
    arabic: 'إنما الأعمال بالنيات',
    english: 'Actions are but by intention.',
  );

  test('body stays language-strict', () {
    expect(HadithLocale.body(sample, english: false), contains('الأعمال'));
    expect(HadithLocale.body(sample, english: false), isNot(contains('Actions')));
    expect(HadithLocale.body(sample, english: true), contains('Actions'));
    expect(HadithLocale.body(sample, english: true), isNot(contains('الأعمال')));
  });

  test('reference labels localize collection and wording', () {
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    final enRef = HadithLocale.referenceLabel(sample, en);
    final arRef = HadithLocale.referenceLabel(sample, ar);
    expect(enRef, contains('No.'));
    expect(enRef.toLowerCase(), isNot(contains('رقم')));
    expect(arRef, contains('رقم'));
    expect(arRef.toLowerCase(), isNot(contains('no.')));
    expect(arRef, isNot(contains('An-Nawawi')));
  });

  test('narrator only appears in English mode', () {
    const withNarrator = HadithItem(
      id: 'bukhari:1',
      collection: 'bukhari',
      collectionName: 'Sahih al-Bukhari',
      number: 1,
      arabicNumber: 1,
      arabic: 'نص عربي',
      english: 'Narrated Umar: Actions are by intentions.',
    );
    expect(HadithLocale.narrator(withNarrator, english: true), 'Umar');
    expect(HadithLocale.narrator(withNarrator, english: false), isNull);
  });
}

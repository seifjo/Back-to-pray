import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supported locales include Arabic and English', (tester) async {
    expect(AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
        containsAll(['ar', 'en']));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

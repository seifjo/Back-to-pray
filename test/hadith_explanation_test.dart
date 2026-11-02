import 'package:back_to_prayer/core/services/hadith_explanation_service.dart';
import 'package:back_to_prayer/providers/hadith_explanation_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('explanation for nawawi:1 is the matching classical entry', () async {
    final service = HadithExplanationService();
    await service.initialize();

    final first = service.forHadith('nawawi:1');
    expect(first.available, isTrue);
    expect(first.hadithId, 'nawawi:1');
    expect(first.scholarlyArabic, isNotEmpty);
    expect(first.authorEn, contains('Ibn Daqiq'));
    expect(first.sourceBookAr, contains('الأربعين'));

    final other = service.forHadith('nawawi:2');
    expect(other.hadithId, 'nawawi:2');
    expect(other.scholarlyArabic, isNot(equals(first.scholarlyArabic)));
  });

  test('unsupported Hadith IDs open an unavailable explanation', () async {
    final service = HadithExplanationService();
    await service.initialize();

    final missing = service.forHadith('bukhari:1');
    expect(missing.available, isFalse);
    expect(service.hasExplanation('bukhari:1'), isFalse);
    expect(service.hasExplanation('nawawi:1'), isTrue);
  });

  test('previous and next stay on supported explanation IDs', () async {
    final service = HadithExplanationService();
    await service.initialize();

    expect(service.previousId('nawawi:1'), isNull);
    expect(service.nextId('nawawi:1'), 'nawawi:2');
    expect(service.previousId('nawawi:2'), 'nawawi:1');
    expect(service.supportedIds.length, 42);
  });

  test('explanation bookmarks persist locally', () async {
    final provider = HadithExplanationProvider();
    await provider.initialize();
    await provider.toggleBookmark('nawawi:1');
    expect(provider.isBookmarked('nawawi:1'), isTrue);

    final again = HadithExplanationProvider();
    await again.initialize();
    expect(again.isBookmarked('nawawi:1'), isTrue);
  });

  test('provider returns the explanation for the selected Hadith only', () async {
    final provider = HadithExplanationProvider();
    await provider.initialize();
    final selected = provider.forHadith('nawawi:5');
    expect(selected.hadithId, 'nawawi:5');
    expect(selected.available, isTrue);
    expect(provider.forHadith('nawawi:1').hadithId, isNot(equals(selected.hadithId)));
  });
}

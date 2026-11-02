import 'package:back_to_prayer/core/services/tasbeeh_store.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/data/tasbeeh_catalog.dart';
import 'package:back_to_prayer/providers/tasbeeh_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Tasbeeh as available', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'tasbeeh');
    expect(feature.available, isTrue);
  });

  test('counting, undo, and reset persist', () async {
    final provider = TasbeehProvider(store: TasbeehStore());
    await provider.load();
    expect(provider.selected.arabic, contains('سُبْحَانَ'));

    await provider.increment();
    await provider.increment();
    expect(provider.currentCount, 2);
    expect(provider.todayTotal(), 2);

    await provider.undo();
    expect(provider.currentCount, 1);

    await provider.resetCurrent(confirmed: true);
    expect(provider.currentCount, 0);

    final restored = TasbeehProvider(store: TasbeehStore());
    await restored.load();
    expect(restored.selectedId, TasbeehCatalog.builtIn.first.id);
    expect(restored.todayTotal(), greaterThanOrEqualTo(0));
  });

  test('custom dhikr can be added, targeted, and deleted', () async {
    final provider = TasbeehProvider();
    await provider.load();

    await provider.addCustom(
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      nameEn: 'Subhanallah wa bihamdihi',
      nameAr: 'سبحان الله وبحمده',
      personalTarget: 100,
    );
    expect(provider.selected.isCustom, isTrue);
    expect(provider.activeTarget, 100);

    await provider.increment();
    expect(provider.currentCount, 1);

    final id = provider.selectedId;
    await provider.deleteCustom(id);
    expect(provider.allDhikr.any((item) => item.id == id), isFalse);
    expect(provider.selectedId, TasbeehCatalog.builtIn.first.id);
  });

  test('traditional and personal goals stay distinct', () async {
    final provider = TasbeehProvider();
    await provider.load();
    await provider.selectDhikr('subhanallah');
    expect(provider.selected.hasTraditionalTarget, isTrue);
    expect(provider.selected.traditionalTarget, 33);

    await provider.setPersonalTarget('subhanallah', 50);
    expect(provider.selected.usesPersonalGoal, isTrue);
    expect(provider.activeTarget, 50);

    await provider.setPersonalTarget('subhanallah', null);
    expect(provider.activeTarget, 33);
  });

  test('favorites persist across reloads', () async {
    final provider = TasbeehProvider();
    await provider.load();
    await provider.toggleFavorite('hawqala');
    expect(provider.favoriteDhikr.any((item) => item.id == 'hawqala'), isTrue);

    final again = TasbeehProvider();
    await again.load();
    expect(again.favoriteDhikr.any((item) => item.id == 'hawqala'), isTrue);
  });

  test('haptic and sound preferences persist and apply immediately', () async {
    final provider = TasbeehProvider();
    await provider.load();
    expect(provider.hapticEnabled, isTrue);
    expect(provider.soundEnabled, isFalse);

    await provider.setHapticEnabled(false);
    await provider.setSoundEnabled(true);
    expect(provider.hapticEnabled, isFalse);
    expect(provider.soundEnabled, isTrue);

    final restored = TasbeehProvider();
    await restored.load();
    expect(restored.hapticEnabled, isFalse);
    expect(restored.soundEnabled, isTrue);
  });

  test('personal goal updates progress and persists per dhikr', () async {
    final provider = TasbeehProvider();
    await provider.load();
    await provider.selectDhikr('subhanallah');
    await provider.setPersonalTarget('subhanallah', 10);
    expect(provider.activeTarget, 10);

    await provider.increment();
    await provider.increment();
    expect(provider.currentCount, 2);
    expect(provider.progress, closeTo(0.2, 0.001));

    await provider.selectDhikr('alhamdulillah');
    expect(provider.currentCount, 0);
    expect(provider.activeTarget, isNot(equals(10)));

    await provider.selectDhikr('subhanallah');
    expect(provider.currentCount, 2);
    expect(provider.activeTarget, 10);

    final restored = TasbeehProvider();
    await restored.load();
    expect(restored.selectedId, 'subhanallah');
    expect(restored.currentCount, 2);
    expect(restored.activeTarget, 10);

    await restored.setPersonalTarget('subhanallah', null);
    expect(restored.activeTarget, 33);
  });

  test('reject non-positive personal goals as unlimited', () async {
    final provider = TasbeehProvider();
    await provider.load();
    await provider.setPersonalTarget('subhanallah', 0);
    expect(provider.selected.personalTarget, isNull);
    await provider.setPersonalTarget('subhanallah', -5);
    expect(provider.selected.personalTarget, isNull);
  });
}

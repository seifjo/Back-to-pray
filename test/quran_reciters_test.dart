import 'package:back_to_prayer/core/services/quran_audio_catalog.dart';
import 'package:back_to_prayer/data/quran_data.dart';
import 'package:back_to_prayer/data/quran_reciters_catalog.dart';
import 'package:back_to_prayer/models/islamic_audio.dart';
import 'package:back_to_prayer/models/quran_reciter.dart';
import 'package:back_to_prayer/providers/quran_audio_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('catalog exposes documented mp3quran / islamic.network sources', () {
    expect(QuranRecitersCatalog.all, isNotEmpty);
    expect(QuranRecitersCatalog.all.length, greaterThanOrEqualTo(15));
    final alafasy = QuranRecitersCatalog.defaultReciter;
    expect(alafasy.id, 'mishary-alafasy');
    expect(alafasy.surahServerBase, contains('cdn.mp3quran.net'));
    expect(alafasy.ayahEdition, 'ar.alafasy');
    expect(alafasy.ayahBitrates, containsAll([64, 128]));
    expect(alafasy.surahUri(1).toString(), endsWith('/001.mp3'));
    expect(QuranRecitersCatalog.isKnown('abdulrahman-sudais'), isTrue);
    expect(QuranRecitersCatalog.isKnown('yasser-dosari'), isTrue);
  });

  test('unknown reciter id does not invent a substitute preference', () {
    final fallback = QuranRecitersCatalog.byId('not-a-real-reciter');
    expect(fallback.id, QuranRecitersCatalog.defaultReciterId);
    expect(QuranRecitersCatalog.isKnown('not-a-real-reciter'), isFalse);
  });

  test('surah-only reciter keeps ayah unavailable without fallback', () {
    final ghamdi = QuranRecitersCatalog.byId('saad-ghamdi');
    expect(ghamdi.surahAvailable, isTrue);
    expect(ghamdi.hasAyahAudio, isFalse);
    expect(ghamdi.ayahUri(1, 128), isNull);
    expect(ghamdi.availability, QuranReciterAvailability.surahOnly);

    final ayah = QuranAudioCatalog.ayah(
      surahNumber: 1,
      surahNameEn: 'Al-Fatihah',
      surahNameAr: 'الفاتحة',
      ayahNumber: 1,
      absoluteAyah: 1,
      reciter: ghamdi,
    );
    expect(ayah, isNull);
  });

  test('surah queue uses selected reciter and respects auto-play flag', () {
    final husary = QuranRecitersCatalog.byId('mahmoud-husary');
    final queue = QuranAudioCatalog.surahQueueFrom(
      QuranData.surahs,
      110,
      reciter: husary,
      includeFollowing: true,
    );
    expect(queue.length, 5);
    expect(queue.every((t) => t.extras['reciterId'] == husary.id), isTrue);
    expect(queue.first.artistEn, husary.nameEn);
    expect(queue.first.streamUrl, contains('mahmoud-husary'));

    final single = QuranAudioCatalog.surahQueueFrom(
      QuranData.surahs,
      110,
      reciter: husary,
      includeFollowing: false,
    );
    expect(single.length, 1);
    expect(single.first.extras['surahNumber'], '110');
  });

  test('ayah quality resolves within the same reciter only', () {
    final minshawi = QuranRecitersCatalog.byId('muhammad-minshawi');
    expect(minshawi.supportsAyahQuality(64), isFalse);
    expect(minshawi.resolveAyahBitrate(64), 128);

    final basit = QuranRecitersCatalog.byId('abdulbasit-abdulsamad');
    expect(basit.supportsAyahQuality(128), isFalse);
    expect(basit.resolveAyahBitrate(128), 64);

    final track = QuranAudioCatalog.ayah(
      surahNumber: 1,
      surahNameEn: 'Al-Fatihah',
      surahNameAr: 'الفاتحة',
      ayahNumber: 1,
      absoluteAyah: 1,
      reciter: basit,
      qualityKbps: 128,
    );
    expect(track, isNotNull);
    expect(track!.streamUrl, contains('/64/'));
    expect(track.streamUrl, contains('ar.abdulbasitmurattal'));
    expect(track.extras['reciterId'], basit.id);
  });

  test('Quran audio settings persist reciter and options', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = QuranAudioSettingsProvider();
    while (!settings.isLoaded) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(settings.reciterId, QuranRecitersCatalog.defaultReciterId);

    await settings.setReciterId('mahmoud-husary');
    await settings.setAyahQualityKbps(64);
    await settings.setAutoPlayNextSurah(false);
    await settings.setOfflineDownloadsEnabled(false);

    final reloaded = QuranAudioSettingsProvider();
    while (!reloaded.isLoaded) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(reloaded.reciterId, 'mahmoud-husary');
    expect(reloaded.ayahQualityKbps, 64);
    expect(reloaded.autoPlayNextSurah, isFalse);
    expect(reloaded.offlineDownloadsEnabled, isFalse);
  });

  test('switching reciter updates catalog URLs for the same surah', () {
    final a = QuranAudioCatalog.surah(
      QuranData.surahs.first,
      reciter: QuranRecitersCatalog.byId('mishary-alafasy'),
    )!;
    final b = QuranAudioCatalog.surah(
      QuranData.surahs.first,
      reciter: QuranRecitersCatalog.byId('maher-muaiqly'),
    )!;
    expect(a.kind, IslamicAudioKind.quran);
    expect(a.id, b.id);
    expect(a.streamUrl, isNot(equals(b.streamUrl)));
    expect(a.extras['reciterId'], isNot(equals(b.extras['reciterId'])));
  });
}

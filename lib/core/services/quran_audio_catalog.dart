import '../../data/quran_reciters_catalog.dart';
import '../../models/islamic_audio.dart';
import '../../models/quran.dart';
import '../../models/quran_reciter.dart';
import 'quran_offline_store.dart';

/// Builds [IslamicAudioTrack] items for Quran playback on the global player.
class QuranAudioCatalog {
  QuranAudioCatalog._();

  static const licenseEn =
      'Public Quran recitation (mp3quran.net API v3 / islamic.network CDN)';
  static const licenseAr =
      'تسجيل قرآني عام (واجهة mp3quran.net / شبكة islamic.network)';

  static IslamicAudioTrack? surah(
    Surah surah, {
    QuranReciter? reciter,
  }) {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    if (!r.surahAvailable) return null;
    return IslamicAudioTrack(
      id: 'quran_surah_${surah.number}',
      kind: IslamicAudioKind.quran,
      titleEn: surah.englishName,
      titleAr: surah.name,
      artistEn: r.nameEn,
      artistAr: r.nameAr,
      streamUrl: QuranOfflineStore.urlFor(surah.number, reciter: r).toString(),
      licenseEn: licenseEn,
      licenseAr: licenseAr,
      coverAsset: r.imageAsset ?? 'assets/images/alnoor_logo.png',
      extras: {
        'surahNumber': '${surah.number}',
        'reciterId': r.id,
      },
    );
  }

  /// Queue of surahs from [startSurahNumber]. When [includeFollowing] is false,
  /// only the starting surah is returned (auto-play next off).
  static List<IslamicAudioTrack> surahQueueFrom(
    List<Surah> all,
    int startSurahNumber, {
    QuranReciter? reciter,
    bool includeFollowing = true,
  }) {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    final tracks = <IslamicAudioTrack>[];
    for (final surah in all) {
      if (surah.number < startSurahNumber) continue;
      final track = QuranAudioCatalog.surah(surah, reciter: r);
      if (track != null) tracks.add(track);
      if (!includeFollowing) break;
    }
    return tracks;
  }

  static IslamicAudioTrack? ayah({
    required int surahNumber,
    required String surahNameEn,
    required String surahNameAr,
    required int ayahNumber,
    required int absoluteAyah,
    QuranReciter? reciter,
    int qualityKbps = 128,
  }) {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    final url = QuranOfflineStore.ayahUrl(
      absoluteAyah,
      reciter: r,
      qualityKbps: qualityKbps,
    );
    if (url == null) return null;
    final bitrate = r.resolveAyahBitrate(qualityKbps) ?? qualityKbps;
    return IslamicAudioTrack(
      id: 'quran_ayah_$absoluteAyah',
      kind: IslamicAudioKind.quran,
      titleEn: '$surahNameEn · Ayah $ayahNumber',
      titleAr: '$surahNameAr · آية $ayahNumber',
      artistEn: r.nameEn,
      artistAr: r.nameAr,
      streamUrl: url.toString(),
      licenseEn: licenseEn,
      licenseAr: licenseAr,
      coverAsset: r.imageAsset ?? 'assets/images/alnoor_logo.png',
      extras: {
        'surahNumber': '$surahNumber',
        'ayahNumber': '$ayahNumber',
        'absoluteAyah': '$absoluteAyah',
        'reciterId': r.id,
        'qualityKbps': '$bitrate',
      },
    );
  }

  static int absoluteAyahNumber(int surahNumber, int ayahNumber) {
    const ayahsPerSurah = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
      111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
      54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
      49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52,
      44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19,
      26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
      6, 3, 5, 4, 5, 6,
    ];
    var absolute = 0;
    for (var i = 0; i < surahNumber - 1; i++) {
      absolute += ayahsPerSurah[i];
    }
    return absolute + ayahNumber;
  }
}

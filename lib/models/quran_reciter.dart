/// A Quran audio reciter with documented stream endpoints.
///
/// Surah streams use [mp3quran.net](https://mp3quran.net/api/v3/reciters)
/// CDN folders. Ayah streams use
/// [islamic.network](https://cdn.islamic.network/quran/audio) when an edition
/// is published for that reciter.
class QuranReciter {
  const QuranReciter({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.surahServerBase,
    required this.sourceNoteEn,
    required this.sourceNoteAr,
    this.ayahEdition,
    this.ayahBitrates = const [],
    this.imageAsset,
    this.surahAvailable = true,
    this.ayahAvailable = true,
  });

  /// Stable preference key (e.g. `mishary-alafasy`).
  final String id;
  final String nameEn;
  final String nameAr;

  /// Trailing-slash CDN folder from mp3quran API v3 `moshaf.server`.
  final String surahServerBase;

  /// islamic.network edition id (e.g. `ar.alafasy`), null if ayah audio N/A.
  final String? ayahEdition;

  /// Supported islamic.network bitrates for this edition (typically 64 / 128).
  final List<int> ayahBitrates;

  final String? imageAsset;
  final bool surahAvailable;
  final bool ayahAvailable;
  final String sourceNoteEn;
  final String sourceNoteAr;

  bool get hasAyahAudio =>
      ayahAvailable && ayahEdition != null && ayahBitrates.isNotEmpty;

  bool supportsAyahQuality(int bitrate) => ayahBitrates.contains(bitrate);

  /// Best matching ayah bitrate for [preferred], without changing reciter.
  int? resolveAyahBitrate(int preferred) {
    if (!hasAyahAudio) return null;
    if (ayahBitrates.contains(preferred)) return preferred;
    final sorted = [...ayahBitrates]..sort();
    // Prefer higher quality when preferred is missing.
    return sorted.last;
  }

  Uri surahUri(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return Uri.parse('$surahServerBase$padded.mp3');
  }

  Uri? ayahUri(int absoluteAyah, int preferredBitrate) {
    final bitrate = resolveAyahBitrate(preferredBitrate);
    final edition = ayahEdition;
    if (bitrate == null || edition == null) return null;
    return Uri.parse(
      'https://cdn.islamic.network/quran/audio/$bitrate/$edition/$absoluteAyah.mp3',
    );
  }

  String qualityLabel() {
    if (!hasAyahAudio) return 'Surah only';
    return ayahBitrates.map((b) => '${b}kbps').join(' · ');
  }

  String qualityLabelAr() {
    if (!hasAyahAudio) return 'سور كاملة فقط';
    return ayahBitrates.map((b) => '$b كيلوبت').join(' · ');
  }
}

enum QuranReciterAvailability {
  available,
  surahOnly,
  unavailable,
}

extension QuranReciterAvailabilityX on QuranReciter {
  QuranReciterAvailability get availability {
    if (!surahAvailable && !hasAyahAudio) {
      return QuranReciterAvailability.unavailable;
    }
    if (surahAvailable && !hasAyahAudio) {
      return QuranReciterAvailability.surahOnly;
    }
    if (!surahAvailable) return QuranReciterAvailability.unavailable;
    return QuranReciterAvailability.available;
  }
}

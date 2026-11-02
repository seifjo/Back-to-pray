import 'nasheed_source.dart';

export 'nasheed_source.dart'
    show
        AudioLicensingStatus,
        NasheedSource,
        NasheedSourceType,
        NasheedTrendBadge;

/// Kinds of Islamic audio the shared player can handle.
enum IslamicAudioKind {
  nasheed,
  quran,
  adhan,
  other,
}

/// UI / service playback phase for the shared player.
enum IslamicPlaybackPhase {
  idle,
  loading,
  buffering,
  playing,
  paused,
  completed,
  error,
}

enum IslamicRepeatMode {
  none,
  one,
  all,
}

/// Stable audio item used by Nasheeds, Quran, and future libraries.
class IslamicAudioTrack {
  final String id;
  final IslamicAudioKind kind;
  final String titleEn;
  final String titleAr;
  final String artistEn;
  final String artistAr;
  final String? categoryId;
  final String streamUrl;
  final int? durationSeconds;
  final String? coverAsset;
  final String? coverUrl;
  final bool downloadAllowed;
  final String licenseEn;
  final String licenseAr;
  final bool featured;
  final List<String> searchTags;
  final Map<String, String> extras;
  final String descriptionEn;
  final String descriptionAr;
  final String sourceProviderEn;
  final String sourceProviderAr;
  final AudioLicensingStatus licensingStatus;
  final NasheedSource? source;
  final List<NasheedTrendBadge> trendBadges;
  final String discoveryEvidenceEn;
  final String discoveryEvidenceAr;

  const IslamicAudioTrack({
    required this.id,
    required this.kind,
    required this.titleEn,
    required this.titleAr,
    required this.artistEn,
    required this.artistAr,
    required this.streamUrl,
    required this.licenseEn,
    required this.licenseAr,
    this.categoryId,
    this.durationSeconds,
    this.coverAsset,
    this.coverUrl,
    this.downloadAllowed = false,
    this.featured = false,
    this.searchTags = const [],
    this.extras = const {},
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.sourceProviderEn = '',
    this.sourceProviderAr = '',
    this.licensingStatus = AudioLicensingStatus.available,
    this.source,
    this.trendBadges = const [],
    this.discoveryEvidenceEn = '',
    this.discoveryEvidenceAr = '',
  });

  String title(bool english) => english ? titleEn : titleAr;

  String artist(bool english) {
    final value = english ? artistEn : artistAr;
    if (value.trim().isNotEmpty) return value;
    return english ? artistAr : artistEn;
  }

  String license(bool english) => english ? licenseEn : licenseAr;

  String description(bool english) =>
      english || descriptionAr.isEmpty ? descriptionEn : descriptionAr;

  String sourceProvider(bool english) => english || sourceProviderAr.isEmpty
      ? sourceProviderEn
      : sourceProviderAr;

  /// True only when a real playable URL/path is configured and licensed.
  bool get audioAvailable {
    if (source != null) return source!.isPlayable;
    return licensingStatus == AudioLicensingStatus.available &&
        streamUrl.trim().isNotEmpty;
  }

  bool get hasExternalSource => source?.hasExternalPage ?? false;

  String? get externalPageUrl => source?.externalPageUrl;

  String discoveryEvidence(bool english) =>
      english || discoveryEvidenceAr.isEmpty
          ? discoveryEvidenceEn
          : discoveryEvidenceAr;

  Duration? get duration =>
      durationSeconds == null ? null : Duration(seconds: durationSeconds!);

  String get formattedDuration {
    final seconds = durationSeconds;
    if (seconds == null || seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMediaExtras({String? localFilePath}) => {
        'kind': kind.name,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'artistEn': artistEn,
        'artistAr': artistAr,
        'streamUrl': streamUrl,
        if (categoryId != null) 'categoryId': categoryId,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (coverAsset != null) 'coverAsset': coverAsset,
        if (coverUrl != null) 'coverUrl': coverUrl,
        'downloadAllowed': downloadAllowed,
        'licenseEn': licenseEn,
        'licenseAr': licenseAr,
        'licensingStatus': licensingStatus.name,
        if (descriptionEn.isNotEmpty) 'descriptionEn': descriptionEn,
        if (descriptionAr.isNotEmpty) 'descriptionAr': descriptionAr,
        if (sourceProviderEn.isNotEmpty) 'sourceProviderEn': sourceProviderEn,
        if (sourceProviderAr.isNotEmpty) 'sourceProviderAr': sourceProviderAr,
        if (discoveryEvidenceEn.isNotEmpty)
          'discoveryEvidenceEn': discoveryEvidenceEn,
        if (discoveryEvidenceAr.isNotEmpty)
          'discoveryEvidenceAr': discoveryEvidenceAr,
        if (trendBadges.isNotEmpty)
          'trendBadges': trendBadges.map((b) => b.name).join(','),
        if (source != null) ...source!.toExtras(),
        if (localFilePath != null && localFilePath.isNotEmpty)
          'localFilePath': localFilePath,
        ...extras,
      };

  factory IslamicAudioTrack.fromMediaExtras(
    String id,
    Map<String, dynamic>? extras,
  ) {
    final map = extras ?? const <String, dynamic>{};
    final statusName = map['licensingStatus'] as String?;
    final badgesRaw = map['trendBadges'] as String?;
    final badges = <NasheedTrendBadge>[];
    if (badgesRaw != null && badgesRaw.isNotEmpty) {
      for (final name in badgesRaw.split(',')) {
        for (final badge in NasheedTrendBadge.values) {
          if (badge.name == name.trim()) {
            badges.add(badge);
            break;
          }
        }
      }
    }
    final source = map.containsKey('sourceType')
        ? NasheedSource.fromExtras(map)
        : null;
    return IslamicAudioTrack(
      id: id,
      kind: IslamicAudioKind.values.firstWhere(
        (k) => k.name == map['kind'],
        orElse: () => IslamicAudioKind.other,
      ),
      titleEn: (map['titleEn'] as String?) ?? id,
      titleAr: (map['titleAr'] as String?) ?? id,
      artistEn: (map['artistEn'] as String?) ?? '',
      artistAr: (map['artistAr'] as String?) ?? '',
      streamUrl: (map['streamUrl'] as String?) ?? id,
      licenseEn: (map['licenseEn'] as String?) ?? '',
      licenseAr: (map['licenseAr'] as String?) ?? '',
      categoryId: map['categoryId'] as String?,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      coverAsset: map['coverAsset'] as String?,
      coverUrl: map['coverUrl'] as String?,
      downloadAllowed: map['downloadAllowed'] == true,
      descriptionEn: (map['descriptionEn'] as String?) ?? '',
      descriptionAr: (map['descriptionAr'] as String?) ?? '',
      sourceProviderEn: (map['sourceProviderEn'] as String?) ?? '',
      sourceProviderAr: (map['sourceProviderAr'] as String?) ?? '',
      licensingStatus: AudioLicensingStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => AudioLicensingStatus.available,
      ),
      source: source,
      trendBadges: badges,
      discoveryEvidenceEn: (map['discoveryEvidenceEn'] as String?) ?? '',
      discoveryEvidenceAr: (map['discoveryEvidenceAr'] as String?) ?? '',
      extras: {
        for (final entry in map.entries)
          if (entry.value is String) entry.key: entry.value as String,
      },
    );
  }
}

class NasheedCategory {
  final String id;
  final String nameEn;
  final String nameAr;
  final int accent;

  const NasheedCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.accent,
  });

  String name(bool english) => english ? nameEn : nameAr;
}

enum NasheedSort {
  titleAsc,
  artistAsc,
  durationAsc,
  durationDesc,
}

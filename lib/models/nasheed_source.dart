/// Whether a catalog entry may legally be streamed/downloaded in-app.
enum AudioLicensingStatus {
  /// Freely usable licensed source (e.g. CC0) with a real URL.
  available,

  /// Catalogued for discovery; no legal stream configured yet.
  pendingLicense,

  /// Explicitly blocked / unavailable.
  unavailable,
}

/// How Al Noor may obtain or reference a nasheed’s audio.
enum NasheedSourceType {
  /// Direct HTTPS/file stream the app is licensed to play.
  directAudio,

  /// Hosted on a CDN/archive the app may stream.
  hostedAudio,

  /// Explicitly authorized by the creator for in-app use.
  creatorAuthorized,

  /// Public-domain / CC0 dedication.
  publicDomain,

  /// Licensed third-party provider / API.
  licensedProvider,

  /// Discovery metadata only — open the legitimate page outside the app.
  externalReference,
}

/// Evidence-based shelf badges. Never invent view counts.
enum NasheedTrendBadge {
  trending,
  popular,
  newRelease,
  recommended,
  shortForm,
}

/// Scalable audio/source descriptor for one catalog entry.
class NasheedSource {
  final NasheedSourceType sourceType;
  final String sourceUrl;
  final String provider;
  final String? providerId;
  final AudioLicensingStatus licensingStatus;
  final String attributionEn;
  final String attributionAr;
  final bool offlineAllowed;

  /// Legitimate public page (artist site, official upload, encyclopedia).
  /// Never used as an in-app stream URL.
  final String? externalPageUrl;

  const NasheedSource({
    required this.sourceType,
    required this.licensingStatus,
    this.sourceUrl = '',
    this.provider = '',
    this.providerId,
    this.attributionEn = '',
    this.attributionAr = '',
    this.offlineAllowed = false,
    this.externalPageUrl,
  });

  bool get isPlayable =>
      licensingStatus == AudioLicensingStatus.available &&
      sourceUrl.trim().isNotEmpty &&
      sourceType != NasheedSourceType.externalReference;

  bool get hasExternalPage =>
      externalPageUrl != null && externalPageUrl!.trim().isNotEmpty;

  String attribution(bool english) =>
      english || attributionAr.isEmpty ? attributionEn : attributionAr;

  Map<String, String> toExtras() => {
        'sourceType': sourceType.name,
        'sourceUrl': sourceUrl,
        'sourceProvider': provider,
        if (providerId != null) 'providerId': providerId!,
        'licensingStatus': licensingStatus.name,
        'attributionEn': attributionEn,
        'attributionAr': attributionAr,
        'offlineAllowed': offlineAllowed.toString(),
        if (externalPageUrl != null) 'externalPageUrl': externalPageUrl!,
      };

  factory NasheedSource.fromExtras(Map<String, dynamic>? map) {
    final m = map ?? const <String, dynamic>{};
    final typeName = m['sourceType'] as String?;
    final statusName = m['licensingStatus'] as String?;
    return NasheedSource(
      sourceType: NasheedSourceType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => NasheedSourceType.externalReference,
      ),
      sourceUrl: (m['sourceUrl'] as String?) ??
          (m['streamUrl'] as String?) ??
          '',
      provider: (m['sourceProvider'] as String?) ?? '',
      providerId: m['providerId'] as String?,
      licensingStatus: AudioLicensingStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => AudioLicensingStatus.pendingLicense,
      ),
      attributionEn: (m['attributionEn'] as String?) ?? '',
      attributionAr: (m['attributionAr'] as String?) ?? '',
      offlineAllowed: m['offlineAllowed'] == true ||
          m['offlineAllowed']?.toString() == 'true',
      externalPageUrl: m['externalPageUrl'] as String?,
    );
  }
}

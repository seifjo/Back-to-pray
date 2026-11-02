import '../models/islamic_audio.dart';

/// Nasheed catalog for Al Noor — owner-bundled Anashed audio only.
///
/// Every entry maps to a real file under [assets/Anashed/]. Titles without
/// a matching local file are omitted permanently. Never invent stream URLs.
class NasheedCatalog {
  NasheedCatalog._();

  static const attributionEn =
      'All playable nasheeds are bundled in Al Noor’s Anashed library '
      '(owner-provided audio assets).';

  static const attributionAr =
      'جميع الأناشيد القابلة للتشغيل مضمّنة في مكتبة أناشيد النور '
      '(ملفات صوتية موفّرة مع التطبيق).';

  static const licenseEn = 'Bundled Anashed library (in-app playback)';
  static const licenseAr = 'مكتبة أناشيد مضمّنة (تشغيل داخل التطبيق)';

  static const sourceBundledEn = 'Al Noor · assets/Anashed';
  static const sourceBundledAr = 'النور · assets/Anashed';

  /// Genre shelves + discovery shelves used by filters / UI.
  static const categories = <NasheedCategory>[
    NasheedCategory(
      id: 'trending',
      nameEn: 'Trending Now',
      nameAr: 'الأكثر تداولاً',
      accent: 0xFFC45C26,
    ),
    NasheedCategory(
      id: 'most_popular',
      nameEn: 'Most Popular',
      nameAr: 'الأكثر شهرة',
      accent: 0xFFB8860B,
    ),
    NasheedCategory(
      id: 'spiritual',
      nameEn: 'Spiritual',
      nameAr: 'روحاني',
      accent: 0xFF0D7377,
    ),
    NasheedCategory(
      id: 'emotional',
      nameEn: 'Emotional',
      nameAr: 'عاطفي',
      accent: 0xFF8B6F47,
    ),
    NasheedCategory(
      id: 'calm',
      nameEn: 'Calm & Relaxing',
      nameAr: 'هادئ ومريح',
      accent: 0xFF5B8C5A,
    ),
    NasheedCategory(
      id: 'inspirational',
      nameEn: 'Motivation',
      nameAr: 'تحفيزي',
      accent: 0xFF3D7EA6,
    ),
    NasheedCategory(
      id: 'ramadan',
      nameEn: 'Ramadan',
      nameAr: 'رمضان',
      accent: 0xFFC9A227,
    ),
    NasheedCategory(
      id: 'reflection',
      nameEn: 'Reflection',
      nameAr: 'للتأمل',
      accent: 0xFF6B5B95,
    ),
    NasheedCategory(
      id: 'classic',
      nameEn: 'Classic Nasheeds',
      nameAr: 'أناشيد كلاسيكية',
      accent: 0xFF8B5A2B,
    ),
    NasheedCategory(
      id: 'new_releases',
      nameEn: 'New Releases',
      nameAr: 'إصدارات جديدة',
      accent: 0xFF2A9D8F,
    ),
    NasheedCategory(
      id: 'short_form',
      nameEn: 'Short-Form Favorites',
      nameAr: 'مفضّلات المقاطع القصيرة',
      accent: 0xFF9B5DE5,
    ),
    NasheedCategory(
      id: 'quranic_faith',
      nameEn: 'Quranic / Faith',
      nameAr: 'قرآني / إيمان',
      accent: 0xFF0D7377,
    ),
    NasheedCategory(
      id: 'traditional',
      nameEn: 'Traditional',
      nameAr: 'تراثي',
      accent: 0xFF8B5A2B,
    ),
    NasheedCategory(
      id: 'modern',
      nameEn: 'Modern Islamic',
      nameAr: 'إسلامي معاصر',
      accent: 0xFF2A9D8F,
    ),
  ];

  static final List<IslamicAudioTrack> all = List.unmodifiable(_bundled);

  /// Exact filenames under assets/Anashed (UTF-8).
  static final List<IslamicAudioTrack> _bundled = List.unmodifiable([
    _asset(
      id: 'nasheed_tawil_al_shawq',
      titleEn: 'Tawil al-Shawq',
      titleAr: 'طويل الشوق',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'classic',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.recommended,
        NasheedTrendBadge.trending,
      ],
      tags: const ['shawq', 'شوق', 'bukhatir', 'بوخاطر'],
      assetFile: 'tawil_al_shawq.mp3',
    ),
    _asset(
      id: 'nasheed_lasawfa_aud_ummi',
      titleEn: 'Lasawfa A\'ud Ya Ummi',
      titleAr: 'لسوف أعود يا أمي',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'emotional',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.recommended,
      ],
      tags: const ['ummi', 'أمي', 'bukhatir', 'بوخاطر'],
      assetFile: 'lasawfa_aud_ummi.mp3',
    ),
    _asset(
      id: 'nasheed_hubb_wa_hayah',
      titleEn: 'Hubb wa Hayah',
      titleAr: 'حب وحياة',
      artistEn: 'Ahmed Saeed',
      artistAr: 'أحمد سعيد',
      categoryId: 'inspirational',
      featured: true,
      badges: const [
        NasheedTrendBadge.trending,
        NasheedTrendBadge.popular,
        NasheedTrendBadge.shortForm,
      ],
      tags: const ['hubb', 'حب', 'حياة', 'لا تحسب'],
      assetFile: 'hubb_wa_hayah.mp3',
    ),
    _asset(
      id: 'nasheed_hazzatni',
      titleEn: 'Hazzatni',
      titleAr: 'هزتني',
      artistEn: 'Mohammad Al-Matari',
      artistAr: 'محمد مطري',
      categoryId: 'spiritual',
      featured: true,
      badges: const [
        NasheedTrendBadge.trending,
        NasheedTrendBadge.recommended,
      ],
      tags: const ['hazzatni', 'هزتني', 'قدسي', 'مطري'],
      assetFile: 'hazzatni.mp3',
    ),
    _asset(
      id: 'nasheed_ashraqat_nafsi',
      titleEn: 'Ashraqat Nafsi',
      titleAr: 'أشرقت نفسي',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'spiritual',
      featured: true,
      badges: const [NasheedTrendBadge.recommended],
      tags: const ['ashraqat', 'أشرقت', 'bukhatir'],
      assetFile: 'ashraqat_nafsi.mp3',
    ),
    _asset(
      id: 'nasheed_kun_anta',
      titleEn: 'Kun Anta',
      titleAr: 'كن أنت',
      artistEn: 'Humood AlKhudher',
      artistAr: 'حمود الخضر',
      categoryId: 'inspirational',
      featured: true,
      badges: const [
        NasheedTrendBadge.trending,
        NasheedTrendBadge.popular,
        NasheedTrendBadge.shortForm,
      ],
      tags: const ['kun anta', 'كن أنت', 'humood', 'حمود'],
      assetFile: 'kun_anta.mp3',
    ),
    _asset(
      id: 'nasheed_eidun_saeed',
      titleEn: 'Eidun Saeed',
      titleAr: 'عيد سعيد',
      artistEn: 'Mesut Kurtis feat. Maher Zain',
      artistAr: 'مسعود كرتس مع ماهر زين',
      categoryId: 'ramadan',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.newRelease,
      ],
      tags: const ['eid', 'عيد', 'mesut', 'maher'],
      assetFile: 'eidun_saeed.mp3',
    ),
    _asset(
      id: 'nasheed_burdah',
      titleEn: 'Burdah (Maula Ya Salli)',
      titleAr: 'البردة · مولاي صل وسلم',
      artistEn: 'Mesut Kurtis',
      artistAr: 'مسعود كرتس',
      categoryId: 'traditional',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.recommended,
      ],
      tags: const ['burdah', 'بردة', 'maula', 'مولاي'],
      assetFile: 'burdah.mp3',
    ),
    _asset(
      id: 'nasheed_assalamu_alayka',
      titleEn: 'Assalamu Alayka',
      titleAr: 'السلام عليك',
      artistEn: 'Maher Zain',
      artistAr: 'ماهر زين',
      categoryId: 'spiritual',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.trending,
        NasheedTrendBadge.recommended,
      ],
      tags: const ['assalamu', 'السلام عليك', 'maher', 'رسول'],
      assetFile: 'assalamu_alayka.mp3',
    ),
    _asset(
      id: 'nasheed_insha_allah_mz',
      titleEn: 'Insha Allah',
      titleAr: 'إن شاء الله',
      artistEn: 'Maher Zain',
      artistAr: 'ماهر زين',
      categoryId: 'modern',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.shortForm,
      ],
      tags: const ['insha', 'إن شاء الله', 'maher'],
      assetFile: 'insha_allah.mp3',
    ),
    _asset(
      id: 'nasheed_kam_tashtaki',
      titleEn: 'Kam Tashtaki',
      titleAr: 'كم تشتكي',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'reflection',
      featured: false,
      badges: const [NasheedTrendBadge.recommended],
      tags: const ['kam tashtaki', 'كم تشتكي', 'bukhatir'],
      assetFile: 'kam_tashtaki.mp3',
    ),
    _asset(
      id: 'nasheed_dar_al_ghoroor',
      titleEn: 'Dar al-Ghoroor',
      titleAr: 'دار الغرور',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'reflection',
      featured: false,
      badges: const [NasheedTrendBadge.popular],
      tags: const ['ghoroor', 'غرور', 'bukhatir'],
      assetFile: 'dar_al_ghoroor.mp3',
    ),
    _asset(
      id: 'nasheed_atfaluna',
      titleEn: 'Atfaluna (Our Children)',
      titleAr: 'أطفالنا',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'emotional',
      featured: false,
      badges: const [NasheedTrendBadge.recommended],
      tags: const ['atfaluna', 'أطفالنا', 'bukhatir'],
      assetFile: 'atfaluna.mp3',
    ),
    _asset(
      id: 'nasheed_hawd_al_nabi',
      titleEn: 'Hawd al-Nabi',
      titleAr: 'حوض النبي',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'quranic_faith',
      featured: true,
      badges: const [
        NasheedTrendBadge.popular,
        NasheedTrendBadge.recommended,
      ],
      tags: const ['hawd', 'حوض', 'nabi', 'النبي'],
      assetFile: 'hawd_al_nabi.mp3',
    ),
    _asset(
      id: 'nasheed_al_quds_tunadina',
      titleEn: 'Al-Quds Tunadina',
      titleAr: 'القدس تنادينا',
      artistEn: 'Ahmed Bukhatir',
      artistAr: 'أحمد بوخاطر',
      categoryId: 'inspirational',
      featured: true,
      badges: const [
        NasheedTrendBadge.trending,
        NasheedTrendBadge.popular,
      ],
      tags: const ['quds', 'القدس', 'tunadina', 'bukhatir'],
      assetFile: 'al_quds_tunadina.mp3',
    ),
  ]);

  static IslamicAudioTrack _asset({
    required String id,
    required String titleEn,
    required String titleAr,
    required String artistEn,
    required String artistAr,
    required String categoryId,
    required String assetFile,
    required List<String> tags,
    List<NasheedTrendBadge> badges = const [],
    bool featured = false,
  }) {
    final assetPath = 'assets/Anashed/$assetFile';
    final source = NasheedSource(
      sourceType: NasheedSourceType.directAudio,
      licensingStatus: AudioLicensingStatus.available,
      sourceUrl: assetPath,
      provider: sourceBundledEn,
      attributionEn: attributionEn,
      attributionAr: attributionAr,
      offlineAllowed: true,
    );
    return IslamicAudioTrack(
      id: id,
      kind: IslamicAudioKind.nasheed,
      titleEn: titleEn,
      titleAr: titleAr,
      artistEn: artistEn,
      artistAr: artistAr,
      categoryId: categoryId,
      streamUrl: assetPath,
      durationSeconds: null,
      downloadAllowed: false,
      licenseEn: licenseEn,
      licenseAr: licenseAr,
      featured: featured,
      searchTags: tags,
      coverAsset: 'assets/images/alnoor_logo.png',
      descriptionEn:
          'Bundled Anashed audio matched to this title for offline in-app playback.',
      descriptionAr:
          'صوت أناشيد مضمّن مطابق لهذا العنوان للتشغيل دون اتصال داخل التطبيق.',
      sourceProviderEn: sourceBundledEn,
      sourceProviderAr: sourceBundledAr,
      licensingStatus: AudioLicensingStatus.available,
      source: source,
      trendBadges: badges,
      discoveryEvidenceEn:
          'Matched to owner-provided file in assets/Anashed.',
      discoveryEvidenceAr:
          'مطابق لملف موفّر في مجلد assets/Anashed.',
    );
  }

  static IslamicAudioTrack? byId(String id) {
    for (final track in all) {
      if (track.id == id) return track;
    }
    return null;
  }

  static NasheedCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static List<IslamicAudioTrack> featured() =>
      all.where((track) => track.featured).toList();

  static List<IslamicAudioTrack> playable() =>
      all.where((track) => track.audioAvailable).toList();

  static List<IslamicAudioTrack> pendingLicense() => all
      .where(
        (track) =>
            track.licensingStatus == AudioLicensingStatus.pendingLicense,
      )
      .toList();

  static List<IslamicAudioTrack> withBadge(
    NasheedTrendBadge badge, {
    int limit = 24,
  }) {
    return all
        .where((t) => t.trendBadges.contains(badge))
        .take(limit)
        .toList();
  }

  static List<IslamicAudioTrack> trending({int limit = 16}) =>
      withBadge(NasheedTrendBadge.trending, limit: limit);

  static List<IslamicAudioTrack> shortFormFavorites({int limit = 16}) =>
      withBadge(NasheedTrendBadge.shortForm, limit: limit);

  static List<IslamicAudioTrack> mostPopular({int limit = 16}) =>
      withBadge(NasheedTrendBadge.popular, limit: limit);

  static List<IslamicAudioTrack> newReleases({int limit = 12}) =>
      withBadge(NasheedTrendBadge.newRelease, limit: limit);

  /// Recommended: badge-marked first, then featured playable.
  static List<IslamicAudioTrack> recommended({int limit = 16}) {
    final badge = withBadge(NasheedTrendBadge.recommended, limit: limit);
    if (badge.length >= limit) return badge;
    final seen = badge.map((t) => t.id).toSet();
    final extra = <IslamicAudioTrack>[
      for (final t in featured())
        if (!seen.contains(t.id) && t.audioAvailable) t,
    ];
    return [...badge, ...extra].take(limit).toList();
  }

  static List<IslamicAudioTrack> related(
    IslamicAudioTrack track, {
    int limit = 8,
  }) {
    final sameCategory = <IslamicAudioTrack>[];
    final sameArtist = <IslamicAudioTrack>[];
    final others = <IslamicAudioTrack>[];
    for (final other in all) {
      if (other.id == track.id) continue;
      final sameArt = track.artistEn.isNotEmpty &&
          other.artistEn.toLowerCase() == track.artistEn.toLowerCase();
      if (sameArt) {
        sameArtist.add(other);
      } else if (other.categoryId == track.categoryId) {
        sameCategory.add(other);
      } else {
        others.add(other);
      }
    }
    return [...sameArtist, ...sameCategory, ...others].take(limit).toList();
  }

  /// Lightweight page slice for future remote catalogs.
  static List<IslamicAudioTrack> page({
    int offset = 0,
    int limit = 40,
    String query = '',
    String? categoryId,
    NasheedSort sort = NasheedSort.titleAsc,
    bool playableOnly = false,
    bool favoritesOnly = false,
    Set<String> favoriteIds = const {},
  }) {
    final list = search(
      query: query,
      categoryId: categoryId,
      sort: sort,
      playableOnly: playableOnly,
      favoritesOnly: favoritesOnly,
      favoriteIds: favoriteIds,
    );
    if (offset >= list.length) return const [];
    return list.skip(offset).take(limit).toList();
  }

  static List<IslamicAudioTrack> search({
    String query = '',
    String? categoryId,
    NasheedSort sort = NasheedSort.titleAsc,
    bool playableOnly = false,
    bool favoritesOnly = false,
    Set<String> favoriteIds = const {},
  }) {
    final q = query.trim().toLowerCase();
    var list = all.where((track) {
      if (playableOnly && !track.audioAvailable) return false;
      if (favoritesOnly && !favoriteIds.contains(track.id)) return false;
      if (categoryId != null) {
        final matchesGenre = track.categoryId == categoryId;
        final matchesShelf = switch (categoryId) {
          'trending' =>
            track.trendBadges.contains(NasheedTrendBadge.trending),
          'most_popular' =>
            track.trendBadges.contains(NasheedTrendBadge.popular),
          'new_releases' =>
            track.trendBadges.contains(NasheedTrendBadge.newRelease) ||
                track.categoryId == 'new_releases',
          'short_form' =>
            track.trendBadges.contains(NasheedTrendBadge.shortForm) ||
                track.categoryId == 'short_form',
          'classic' =>
            track.categoryId == 'classic' ||
                track.categoryId == 'traditional',
          _ => matchesGenre,
        };
        if (categoryId == 'trending' ||
            categoryId == 'most_popular' ||
            categoryId == 'new_releases' ||
            categoryId == 'short_form' ||
            categoryId == 'classic') {
          if (!matchesShelf) return false;
        } else if (!matchesGenre) {
          return false;
        }
      }
      if (q.isEmpty) return true;
      final haystack = [
        track.titleEn,
        track.titleAr,
        track.artistEn,
        track.artistAr,
        track.categoryId ?? '',
        track.descriptionEn,
        track.descriptionAr,
        track.discoveryEvidenceEn,
        track.discoveryEvidenceAr,
        ...track.searchTags,
        ...track.trendBadges.map((b) => b.name),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();

    list.sort((a, b) {
      if (a.audioAvailable != b.audioAvailable) {
        return a.audioAvailable ? -1 : 1;
      }
      switch (sort) {
        case NasheedSort.titleAsc:
          return a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
        case NasheedSort.artistAsc:
          return a.artistEn.toLowerCase().compareTo(b.artistEn.toLowerCase());
        case NasheedSort.durationAsc:
          return (a.durationSeconds ?? 1 << 30)
              .compareTo(b.durationSeconds ?? 1 << 30);
        case NasheedSort.durationDesc:
          return (b.durationSeconds ?? 0).compareTo(a.durationSeconds ?? 0);
      }
    });
    return list;
  }
}

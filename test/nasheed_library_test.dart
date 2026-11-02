import 'package:back_to_prayer/core/services/islamic_audio_player.dart';
import 'package:back_to_prayer/core/services/nasheed_preferences_store.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/data/nasheed_catalog.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/islamic_audio.dart';
import 'package:back_to_prayer/providers/nasheed_library_provider.dart';
import 'package:back_to_prayer/screens/nasheed/nasheed_detail_screen.dart';
import 'package:back_to_prayer/screens/nasheed/nasheed_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('catalog maps Anashed assets and drops unmatched titles', () {
    expect(NasheedCatalog.all.length, 15);
    expect(NasheedCatalog.pendingLicense(), isEmpty);

    const requested = {
      'nasheed_tawil_al_shawq': ('طويل الشوق', 'Ahmed Bukhatir'),
      'nasheed_lasawfa_aud_ummi': ('لسوف أعود يا أمي', 'Ahmed Bukhatir'),
      'nasheed_hubb_wa_hayah': ('حب وحياة', 'Ahmed Saeed'),
      'nasheed_hazzatni': ('هزتني', 'Mohammad Al-Matari'),
      'nasheed_ashraqat_nafsi': ('أشرقت نفسي', 'Ahmed Bukhatir'),
      'nasheed_kun_anta': ('كن أنت', 'Humood AlKhudher'),
      'nasheed_eidun_saeed': ('عيد سعيد', 'Mesut Kurtis feat. Maher Zain'),
      'nasheed_burdah': ('البردة · مولاي صل وسلم', 'Mesut Kurtis'),
      'nasheed_assalamu_alayka': ('السلام عليك', 'Maher Zain'),
      'nasheed_insha_allah_mz': ('إن شاء الله', 'Maher Zain'),
      'nasheed_kam_tashtaki': ('كم تشتكي', 'Ahmed Bukhatir'),
      'nasheed_dar_al_ghoroor': ('دار الغرور', 'Ahmed Bukhatir'),
      'nasheed_atfaluna': ('أطفالنا', 'Ahmed Bukhatir'),
      'nasheed_hawd_al_nabi': ('حوض النبي', 'Ahmed Bukhatir'),
      'nasheed_al_quds_tunadina': ('القدس تنادينا', 'Ahmed Bukhatir'),
    };
    for (final entry in requested.entries) {
      final track = NasheedCatalog.byId(entry.key);
      expect(track, isNotNull, reason: entry.key);
      expect(track!.titleAr, entry.value.$1);
      expect(track.artistEn, entry.value.$2);
      expect(track.audioAvailable, isTrue);
      expect(track.streamUrl.startsWith('assets/Anashed/'), isTrue);
      expect(track.streamUrl.endsWith('.mp3'), isTrue);
      expect(track.licensingStatus, AudioLicensingStatus.available);
      expect(track.source?.sourceType, NasheedSourceType.directAudio);
      expect(track.source?.isPlayable, isTrue);
      expect(track.source?.offlineAllowed, isTrue);
    }

    // Titles without a matching Anashed file must stay deleted.
    expect(NasheedCatalog.byId('nasheed_alhamdulillah'), isNull);
    expect(NasheedCatalog.byId('nasheed_ya_nabi_salam'), isNull);
  });

  test('every catalog track is playable from bundled assets', () {
    expect(NasheedCatalog.playable().length, NasheedCatalog.all.length);
    for (final track in NasheedCatalog.playable()) {
      expect(track.kind, IslamicAudioKind.nasheed);
      expect(track.streamUrl, startsWith('assets/Anashed/'));
      expect(track.audioAvailable, isTrue);
      expect(track.source, isNotNull);
      expect(track.source!.isPlayable, isTrue);
    }
  });

  test('trending shelves are evidence-based without fake view counts', () {
    expect(NasheedCatalog.trending(), isNotEmpty);
    expect(NasheedCatalog.mostPopular(), isNotEmpty);
    expect(NasheedCatalog.shortFormFavorites(), isNotEmpty);
    expect(NasheedCatalog.recommended(), isNotEmpty);
    for (final track in NasheedCatalog.trending()) {
      expect(track.trendBadges, contains(NasheedTrendBadge.trending));
      expect(track.discoveryEvidenceEn, isNotEmpty);
    }
  });

  test('required categories and discovery shelves exist', () {
    final ids = NasheedCatalog.categories.map((c) => c.id).toSet();
    expect(
      ids,
      containsAll([
        'trending',
        'most_popular',
        'spiritual',
        'emotional',
        'calm',
        'inspirational',
        'ramadan',
        'reflection',
        'classic',
        'new_releases',
        'short_form',
        'quranic_faith',
        'traditional',
        'modern',
      ]),
    );
  });

  test('search matches English, Arabic, performer, tags, and shelves', () {
    expect(
      NasheedCatalog.search(query: 'طويل الشوق').map((t) => t.id),
      contains('nasheed_tawil_al_shawq'),
    );
    expect(
      NasheedCatalog.search(query: 'bukhatir').map((t) => t.id),
      contains('nasheed_tawil_al_shawq'),
    );
    expect(
      NasheedCatalog.search(query: 'maher').length,
      greaterThan(0),
    );
    expect(
      NasheedCatalog.search(categoryId: 'trending'),
      isNotEmpty,
    );
    expect(
      NasheedCatalog.search(categoryId: 'emotional'),
      isNotEmpty,
    );
    expect(
      NasheedCatalog.search(playableOnly: true)
          .every((t) => t.audioAvailable),
      isTrue,
    );
    expect(NasheedCatalog.search(query: 'xyz-missing-nasheed'), isEmpty);
  });

  test('catalog page helper supports lazy slices', () {
    final page = NasheedCatalog.page(offset: 0, limit: 10);
    expect(page.length, 10);
    final next = NasheedCatalog.page(offset: 10, limit: 10);
    expect(next.first.id, isNot(equals(page.first.id)));
  });

  test('provider accepts bundled anashed tracks as playable', () async {
    final provider = NasheedLibraryProvider(player: IslamicAudioPlayer());
    await provider.initialize();
    final track = NasheedCatalog.byId('nasheed_hazzatni')!;
    expect(track.audioAvailable, isTrue);
    expect(track.streamUrl.startsWith('assets/Anashed/'), isTrue);
    // Would only refuse with audio_unavailable when no stream is configured.
    expect(track.licensingStatus, AudioLicensingStatus.available);
  });

  test('favorites and recent persist via preferences store', () async {
    final store = NasheedPreferencesStore();
    await store.saveFavorites({'nasheed_tawil_al_shawq'});
    await store.saveRecent(['nasheed_hubb_wa_hayah', 'nasheed_tawil_al_shawq']);

    expect(await store.loadFavorites(), {'nasheed_tawil_al_shawq'});
    expect(await store.loadRecent(), [
      'nasheed_hubb_wa_hayah',
      'nasheed_tawil_al_shawq',
    ]);
  });

  test('provider filters, trending, and recommended work offline', () async {
    final provider = NasheedLibraryProvider();
    await provider.initialize();
    expect(provider.loading, isFalse);
    expect(provider.error, isNull);
    expect(provider.filtered, isNotEmpty);
    expect(provider.featured, isNotEmpty);
    expect(provider.trending, isNotEmpty);
    expect(provider.recommended, isNotEmpty);

    final first = NasheedCatalog.playable().first;
    await provider.toggleFavorite(first.id);
    expect(provider.isFavorite(first.id), isTrue);
    await provider.markPlayed(first.id);
    expect(provider.recent.first.id, first.id);
    expect(provider.continueListening.first.id, first.id);

    provider.setPlayableOnly(true);
    expect(provider.filtered.every((t) => t.audioAvailable), isTrue);
    provider.setCategoryFilter('emotional');
    expect(
      provider.filtered.every((t) => t.categoryId == 'emotional'),
      isTrue,
    );
  });

  test('More Features catalog includes nasheed library', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((f) => f.id == 'nasheed_library');
    expect(feature.route, MoreFeatureRoute.nasheedLibrary);
    expect(feature.available, isTrue);
  });

  test('screen types exist for routing', () {
    expect(const NasheedLibraryScreen(), isA<NasheedLibraryScreen>());
    expect(
      const NasheedDetailScreen(trackId: 'nasheed_tawil_al_shawq'),
      isA<NasheedDetailScreen>(),
    );
  });

  test('localization keys resolve in English and Arabic', () {
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    const keys = [
      'nasheedTitle',
      'nasheedRecommended',
      'nasheedTrending',
      'nasheedAudioUnavailable',
      'nasheedPendingHelp',
      'nasheedExternalSource',
      'nasheedRelated',
      'nasheedArtistUnknown',
      'nasheedBadgeTrending',
      'nasheedContinue',
    ];
    for (final key in keys) {
      expect(en.tr(key), isNot(equals(key)));
      expect(ar.tr(key), isNot(equals(key)));
      expect(ar.tr(key), isNot(equals(en.tr(key))));
    }
  });
}

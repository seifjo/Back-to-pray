import 'package:back_to_prayer/core/services/islamic_audio_player.dart';
import 'package:back_to_prayer/core/services/audio_position_store.dart';
import 'package:back_to_prayer/core/services/quran_audio_catalog.dart';
import 'package:back_to_prayer/data/nasheed_catalog.dart';
import 'package:back_to_prayer/data/quran_data.dart';
import 'package:back_to_prayer/models/islamic_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Quran and Nasheed tracks share IslamicAudioTrack model', () {
    final surah = QuranAudioCatalog.surah(QuranData.surahs.first);
    final nasheed = NasheedCatalog.playable().first;
    expect(surah, isNotNull);
    expect(surah!.kind, IslamicAudioKind.quran);
    expect(nasheed.kind, IslamicAudioKind.nasheed);
    expect(surah.id, isNot(equals(nasheed.id)));
    expect(surah.streamUrl, isNotEmpty);
    expect(nasheed.streamUrl, contains('archive.org'));
  });

  test('surah queue continues from selected surah', () {
    final queue = QuranAudioCatalog.surahQueueFrom(QuranData.surahs, 110);
    expect(queue.length, 5);
    expect(queue.first.extras['surahNumber'], '110');
    expect(queue.last.extras['surahNumber'], '114');
  });

  test('audio position store persists and clears short positions', () async {
    final store = AudioPositionStore();
    await store.save('track_a', const Duration(seconds: 2));
    expect(await store.load('track_a'), isNull);

    await store.save('track_a', const Duration(seconds: 42));
    expect(await store.load('track_a'), const Duration(seconds: 42));
    await store.clear('track_a');
    expect(await store.load('track_a'), isNull);
  });

  test('IslamicAudioPlayer local fallback exposes queue controls', () async {
    final player = IslamicAudioPlayer();
    addTearDown(player.dispose);
    final tracks = NasheedCatalog.playable().take(3).toList();
    expect(player.phase, IslamicPlaybackPhase.idle);
    expect(player.hasTrack, isFalse);

    // Queue metadata can be set without hitting network by only asserting helpers.
    expect(player.hasNext, isFalse);
    expect(IslamicAudioPlayer.formatClock(const Duration(seconds: 75)), '01:15');

    await player.setRepeatMode(IslamicRepeatMode.one);
    expect(player.repeatMode, IslamicRepeatMode.one);
    await player.cycleRepeatMode();
    expect(player.repeatMode, IslamicRepeatMode.all);
    await player.setShuffleEnabled(true);
    expect(player.shuffleEnabled, isTrue);
    await player.setSpeed(1.25);
    expect(player.speed, 1.25);
    await player.setVolume(0.5);
    expect(player.volume, 0.5);

    player.startSleepTimer(const Duration(minutes: 5));
    expect(player.sleepTimerActive, isTrue);
    player.cancelSleepTimer();
    expect(player.sleepTimerActive, isFalse);

    // Ensure track list identity for queue switching scenarios.
    expect(tracks.map((t) => t.id).toSet().length, 3);
  });

  test('media extras round-trip track metadata', () {
    final original = NasheedCatalog.playable().first;
    final extras = original.toMediaExtras(localFilePath: '/tmp/a.mp3');
    final restored = IslamicAudioTrack.fromMediaExtras(original.id, extras);
    expect(restored.id, original.id);
    expect(restored.kind, IslamicAudioKind.nasheed);
    expect(restored.titleEn, original.titleEn);
    expect(restored.titleAr, original.titleAr);
    expect(restored.streamUrl, original.streamUrl);
    expect(extras['localFilePath'], '/tmp/a.mp3');
  });

  test('switching kinds uses distinct stable ids on one player API', () {
    final quran = QuranAudioCatalog.surah(QuranData.surahs[1]);
    final nasheed = NasheedCatalog.featured().first;
    final player = IslamicAudioPlayer();
    addTearDown(player.dispose);
    expect(quran, isNotNull);
    expect(player.isCurrent(quran!.id), isFalse);
    expect(player.isCurrent(nasheed.id), isFalse);
    expect(quran.id.startsWith('quran_'), isTrue);
    expect(nasheed.id.startsWith('nasheed_'), isTrue);
  });

  test('playQueue optimistically switches Quran ↔ Nasheed metadata', () {
    final player = IslamicAudioPlayer();
    addTearDown(player.dispose);

    final quran = QuranAudioCatalog.surah(QuranData.surahs.first)!;
    final nasheed = NasheedCatalog.playable().first;
    final otherNasheed = NasheedCatalog.playable()[1];

    player.debugSetQueue([quran]);
    expect(player.current?.id, quran.id);
    expect(player.current?.kind, IslamicAudioKind.quran);

    player.debugSetQueue([nasheed, otherNasheed], startIndex: 0);
    expect(player.current?.id, nasheed.id);
    expect(player.current?.kind, IslamicAudioKind.nasheed);
    expect(player.queue.map((t) => t.id), [nasheed.id, otherNasheed.id]);

    player.debugSetQueue([quran]);
    expect(player.current?.kind, IslamicAudioKind.quran);
    expect(player.current?.id, quran.id);

    player.debugSetQueue([otherNasheed]);
    expect(player.current?.id, otherNasheed.id);
  });

  test('clear resets shared player to idle for next feature', () async {
    final player = IslamicAudioPlayer();
    addTearDown(player.dispose);
    final track = NasheedCatalog.playable().first;
    player.debugSetQueue([track]);
    expect(player.hasTrack, isTrue);
    await player.clear();
    expect(player.hasTrack, isFalse);
    expect(player.phase, IslamicPlaybackPhase.idle);
    expect(player.queue, isEmpty);
  });
}

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../data/quran_reciters_catalog.dart';
import '../../models/quran_reciter.dart';

/// Saves Quran audio on this phone so it plays without internet.
///
/// Surah / ayah files are stored per reciter so switching voices does not
/// reuse the wrong offline file.
class QuranOfflineStore {
  static bool cancelAll = false;

  static Uri urlFor(
    int surahNumber, {
    QuranReciter? reciter,
  }) {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    return r.surahUri(surahNumber);
  }

  static Uri? ayahUrl(
    int absoluteAyah, {
    QuranReciter? reciter,
    int qualityKbps = 128,
  }) {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    return r.ayahUri(absoluteAyah, qualityKbps);
  }

  static Future<Directory> _folder(String reciterId) async {
    final base = await getApplicationDocumentsDirectory();
    final folder = Directory('${base.path}/quran_audio/$reciterId');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  static Future<File> fileFor(
    int surahNumber, {
    String? reciterId,
  }) async {
    final id = reciterId ?? QuranRecitersCatalog.defaultReciterId;
    final folder = await _folder(id);
    final padded = surahNumber.toString().padLeft(3, '0');
    return File('${folder.path}/$padded.mp3');
  }

  static Future<bool> isSaved(
    int surahNumber, {
    String? reciterId,
  }) async {
    final file = await fileFor(surahNumber, reciterId: reciterId);
    return file.existsSync() && file.lengthSync() > 20000;
  }

  static Future<File> ayahFile(
    int absoluteAyah, {
    String? reciterId,
    int qualityKbps = 128,
  }) async {
    final id = reciterId ?? QuranRecitersCatalog.defaultReciterId;
    final base = await getApplicationDocumentsDirectory();
    final folder = Directory('${base.path}/quran_ayah/$id/$qualityKbps');
    if (!await folder.exists()) await folder.create(recursive: true);
    return File('${folder.path}/$absoluteAyah.mp3');
  }

  static Future<bool> isAyahSaved(
    int absoluteAyah, {
    String? reciterId,
    int qualityKbps = 128,
  }) async {
    final file = await ayahFile(
      absoluteAyah,
      reciterId: reciterId,
      qualityKbps: qualityKbps,
    );
    return file.existsSync() && file.lengthSync() > 800;
  }

  static Future<void> downloadAyah(
    int absoluteAyah, {
    QuranReciter? reciter,
    int qualityKbps = 128,
  }) async {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    if (!r.hasAyahAudio) {
      throw StateError('Ayah audio unavailable for ${r.id}');
    }
    final bitrate = r.resolveAyahBitrate(qualityKbps);
    if (bitrate == null) {
      throw StateError('No ayah bitrate for ${r.id}');
    }
    if (await isAyahSaved(
      absoluteAyah,
      reciterId: r.id,
      qualityKbps: bitrate,
    )) {
      return;
    }
    final file = await ayahFile(
      absoluteAyah,
      reciterId: r.id,
      qualityKbps: bitrate,
    );
    final url = r.ayahUri(absoluteAyah, bitrate);
    if (url == null) {
      throw StateError('Could not build ayah URL for ${r.id}');
    }
    await _save(url, file, canCancel: false);
  }

  static Future<void> downloadSurah(
    int surahNumber, {
    QuranReciter? reciter,
    void Function(double progress)? onProgress,
  }) async {
    final r = reciter ?? QuranRecitersCatalog.defaultReciter;
    if (!r.surahAvailable) {
      throw StateError('Surah audio unavailable for ${r.id}');
    }
    final file = await fileFor(surahNumber, reciterId: r.id);
    await _save(
      r.surahUri(surahNumber),
      file,
      onProgress: onProgress,
      canCancel: true,
    );
  }

  static Future<void> _save(
    Uri url,
    File file, {
    void Function(double progress)? onProgress,
    required bool canCancel,
  }) async {
    final partial = File('${file.path}.part');
    if (partial.existsSync()) await partial.delete();
    final client = http.Client();
    try {
      final response = await client.send(http.Request('GET', url));
      if (response.statusCode != 200) {
        throw Exception('Could not download audio');
      }
      final total = response.contentLength ?? 0;
      final sink = partial.openWrite();
      var received = 0;
      try {
        await for (final chunk in response.stream) {
          if (canCancel && cancelAll) break;
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) onProgress?.call(received / total);
        }
      } finally {
        await sink.close();
      }
      if (canCancel && cancelAll) {
        if (partial.existsSync()) await partial.delete();
        return;
      }
      if (partial.existsSync()) {
        if (file.existsSync()) await file.delete();
        await partial.rename(file.path);
      }
    } catch (error) {
      if (partial.existsSync()) await partial.delete();
      rethrow;
    } finally {
      client.close();
    }
  }
}

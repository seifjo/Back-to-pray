import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Offline storage for legally downloadable nasheed streams (CC0).
class NasheedOfflineStore {
  Future<Directory> _folder() async {
    final base = await getApplicationDocumentsDirectory();
    final folder = Directory('${base.path}/nasheed_audio');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  Future<File> fileFor(String trackId) async {
    final folder = await _folder();
    final safe = trackId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return File('${folder.path}/$safe.mp3');
  }

  Future<bool> isSaved(String trackId) async {
    try {
      final file = await fileFor(trackId);
      return file.existsSync() && file.lengthSync() > 20000;
    } catch (_) {
      return false;
    }
  }

  Future<String?> localPath(String trackId) async {
    if (!await isSaved(trackId)) return null;
    return (await fileFor(trackId)).path;
  }

  Future<void> download(
    String trackId,
    String streamUrl, {
    void Function(double progress)? onProgress,
  }) async {
    final file = await fileFor(trackId);
    if (await isSaved(trackId)) return;
    final partial = File('${file.path}.part');
    if (partial.existsSync()) await partial.delete();
    final client = http.Client();
    try {
      final response =
          await client.send(http.Request('GET', Uri.parse(streamUrl)));
      if (response.statusCode != 200) {
        throw Exception('Could not download nasheed');
      }
      final total = response.contentLength ?? 0;
      final sink = partial.openWrite();
      var received = 0;
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) onProgress?.call(received / total);
        }
      } finally {
        await sink.close();
      }
      if (partial.existsSync()) {
        if (file.existsSync()) await file.delete();
        await partial.rename(file.path);
      }
    } catch (e) {
      if (partial.existsSync()) await partial.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> delete(String trackId) async {
    final file = await fileFor(trackId);
    if (file.existsSync()) await file.delete();
  }
}

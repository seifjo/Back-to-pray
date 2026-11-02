import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Copies bundled cover assets to a cache file so [audio_service] can show
/// artwork on Android media notifications / lock screen (needs a file/http URI).
class AudioArtworkCache {
  AudioArtworkCache._();

  static final Map<String, Uri> _memo = {};

  static Future<Uri?> uriForAsset(String? assetPath) async {
    if (assetPath == null || assetPath.isEmpty) return null;
    final cached = _memo[assetPath];
    if (cached != null) return cached;
    try {
      final data = await rootBundle.load(assetPath);
      final dir = await getTemporaryDirectory();
      final safe = assetPath.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final file = File('${dir.path}/alnoor_art_$safe');
      if (!await file.exists()) {
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
      }
      final uri = Uri.file(file.path);
      _memo[assetPath] = uri;
      return uri;
    } catch (_) {
      return null;
    }
  }
}

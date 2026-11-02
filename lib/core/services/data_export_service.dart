import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

/// Shares a JSON copy of the data stored on this device.
class DataExportService {
  Future<void> shareExport() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'Al Noor',
    };
    for (final key in prefs.getKeys()) {
      payload[key] = prefs.get(key);
    }
    final text = const JsonEncoder.withIndent('  ').convert(payload);
    await Share.share(text, subject: 'Al Noor data export');
  }
}

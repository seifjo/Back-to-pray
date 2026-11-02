import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/islamic_audio_player.dart';
import '../../core/theme/app_theme.dart';
import '../../data/quran_reciters_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../models/islamic_audio.dart';
import '../../models/quran_reciter.dart';
import '../../providers/quran_audio_settings_provider.dart';

/// Settings for Quran audio: reciter, quality, auto-play, offline.
class QuranAudioSettingsScreen extends StatelessWidget {
  const QuranAudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<QuranAudioSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isAr = context.isArabic;
    final reciter = settings.reciter;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('quranAudioSettings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.tr('quranAudioSettingsHelp'),
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('quranReciter'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _ReciterAvatar(reciter: reciter),
            title: Text(isAr ? reciter.nameAr : reciter.nameEn),
            subtitle: Text(_availabilityLabel(context, reciter)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openReciterPicker(context),
          ),
          const Divider(height: 28),
          Text(
            context.tr('quranAudioQuality'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('quranAudioQualityHelp'),
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          if (!reciter.hasAyahAudio)
            Text(
              context.tr('reciterAyahUnavailable'),
              style: TextStyle(color: scheme.error),
            )
          else
            SegmentedButton<int>(
              segments: [
                for (final bitrate in const [64, 128])
                  ButtonSegment(
                    value: bitrate,
                    label: Text('${bitrate}kbps'),
                    enabled: reciter.supportsAyahQuality(bitrate),
                  ),
              ],
              selected: {
                reciter.resolveAyahBitrate(settings.ayahQualityKbps) ??
                    settings.ayahQualityKbps,
              },
              onSelectionChanged: (value) =>
                  settings.setAyahQualityKbps(value.first),
            ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('autoPlayNextSurah')),
            subtitle: Text(context.tr('autoPlayNextSurahHelp')),
            value: settings.autoPlayNextSurah,
            onChanged: settings.setAutoPlayNextSurah,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('quranOfflineDownloads')),
            subtitle: Text(context.tr('quranOfflineDownloadsHelp')),
            value: settings.offlineDownloadsEnabled,
            onChanged: settings.setOfflineDownloadsEnabled,
          ),
          const SizedBox(height: 12),
          Text(
            isAr ? reciter.sourceNoteAr : reciter.sourceNoteEn,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.55),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _availabilityLabel(BuildContext context, QuranReciter reciter) {
    switch (reciter.availability) {
      case QuranReciterAvailability.available:
        return '${context.tr('reciterAvailable')} · ${context.isArabic ? reciter.qualityLabelAr() : reciter.qualityLabel()}';
      case QuranReciterAvailability.surahOnly:
        return context.tr('reciterSurahOnly');
      case QuranReciterAvailability.unavailable:
        return context.tr('reciterUnavailable');
    }
  }

  Future<void> _openReciterPicker(BuildContext context) async {
    final settings = context.read<QuranAudioSettingsProvider>();
    final player = context.read<IslamicAudioPlayer>();
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ReciterPickerScreen()),
    );
    if (selected == null || selected == settings.reciterId) return;
    await settings.setReciterId(selected);
    // Keep the global player aligned with the chosen reciter.
    if (player.current?.kind == IslamicAudioKind.quran &&
        player.current?.extras['reciterId'] != selected) {
      await player.clear();
    }
  }
}

class _ReciterPickerScreen extends StatelessWidget {
  const _ReciterPickerScreen();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<QuranAudioSettingsProvider>();
    final isAr = context.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('chooseReciter'))),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: QuranRecitersCatalog.all.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final reciter = QuranRecitersCatalog.all[index];
          final selected = reciter.id == settings.reciterId;
          final unavailable =
              reciter.availability == QuranReciterAvailability.unavailable;
          return ListTile(
            leading: _ReciterAvatar(reciter: reciter),
            title: Text(
              isAr ? reciter.nameAr : reciter.nameEn,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: unavailable
                    ? Theme.of(context).disabledColor
                    : null,
              ),
            ),
            subtitle: Text(
              [
                if (unavailable)
                  context.tr('reciterUnavailable')
                else if (reciter.availability ==
                    QuranReciterAvailability.surahOnly)
                  context.tr('reciterSurahOnly')
                else
                  context.tr('reciterAvailable'),
                isAr ? reciter.qualityLabelAr() : reciter.qualityLabel(),
              ].join(' · '),
            ),
            trailing: selected
                ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                : null,
            enabled: !unavailable,
            onTap: unavailable
                ? null
                : () => Navigator.pop(context, reciter.id),
          );
        },
      ),
    );
  }
}

class _ReciterAvatar extends StatelessWidget {
  const _ReciterAvatar({required this.reciter});

  final QuranReciter reciter;

  @override
  Widget build(BuildContext context) {
    final asset = reciter.imageAsset;
    return CircleAvatar(
      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
      backgroundImage: asset != null ? AssetImage(asset) : null,
      child: asset == null
          ? Text(
              reciter.nameEn.isNotEmpty ? reciter.nameEn[0] : '?',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

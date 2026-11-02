import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/prayer_times.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/hijri_calendar_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/spiritual_journey_provider.dart';
import '../../providers/worship_tracker_provider.dart';
import '../../core/services/data_export_service.dart';
import '../../core/services/device_feedback.dart';
import '../../providers/rewards_provider.dart';
import 'adhan_settings_screen.dart';
import 'quran_audio_settings_screen.dart';

/// Central settings for language, theme, alerts, and reading.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settingsTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(context.tr('sectionAppearance')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('language')),
            subtitle: Text(settings.isArabic ? context.tr('arabic') : context.tr('english')),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'ar', label: Text(context.tr('arabic'))),
                ButtonSegment(value: 'en', label: Text(context.tr('english'))),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (value) async {
                final prayer = context.read<PrayerProvider>();
                final hijri = context.read<HijriCalendarProvider>();
                final worship = context.read<WorshipTrackerProvider>();
                final journeys = context.read<SpiritualJourneyProvider>();
                await settings.setLocale(Locale(value.first));
                // Refresh scheduled notification text to match the new language.
                try {
                  await prayer.refreshPrayerTimes();
                } catch (_) {}
                try {
                  await hijri.syncReminders();
                } catch (_) {}
                try {
                  await worship.resyncReminders();
                } catch (_) {}
                try {
                  await journeys.resyncReminders();
                } catch (_) {}
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(context.tr('theme')),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, label: Text(context.tr('themeLight'))),
              ButtonSegment(value: ThemeMode.dark, label: Text(context.tr('themeDark'))),
              ButtonSegment(value: ThemeMode.system, label: Text(context.tr('themeSystem'))),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (value) => settings.setThemeMode(value.first),
          ),
          const SizedBox(height: 20),
          _SectionTitle(context.tr('darkColorThemes')),
          Text(
            context.tr('themeHint'),
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 12),
          const _ThemePicker(),
          const SizedBox(height: 24),
          _SectionTitle(context.tr('sectionNotifications')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined),
            title: Text(context.tr('openAdhanSettings')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdhanSettingsScreen()),
              );
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('introSound')),
            subtitle: Text(context.tr('introSoundHelp')),
            value: settings.introSoundEnabled,
            onChanged: (value) => settings.setIntroSoundEnabled(value),
          ),
          const SizedBox(height: 8),
          _SectionTitle(context.tr('sectionQuranAudio')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.record_voice_over_outlined),
            title: Text(context.tr('quranAudioSettings')),
            subtitle: Text(context.tr('quranReciter')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuranAudioSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _SectionTitle(context.tr('sectionReading')),
          Text(context.tr('arabicTextSize')),
          const SizedBox(height: 4),
          Text(
            settings.adhkarFontSizeLabel(settings.isArabic),
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 8),
          SegmentedButton<double>(
            segments: [
              ButtonSegment(
                value: AppSettingsProvider.fontSmall,
                label: Text(context.tr('fontSizeSmall')),
              ),
              ButtonSegment(
                value: AppSettingsProvider.fontMedium,
                label: Text(context.tr('fontSizeMedium')),
              ),
              ButtonSegment(
                value: AppSettingsProvider.fontLarge,
                label: Text(context.tr('fontSizeLarge')),
              ),
              ButtonSegment(
                value: AppSettingsProvider.fontExtraLarge,
                label: Text(context.tr('fontSizeExtraLarge')),
              ),
            ],
            selected: {_nearestFontPreset(settings.adhkarFontSize)},
            onSelectionChanged: (value) =>
                settings.setAdhkarFontSize(value.first),
          ),
          const SizedBox(height: 8),
          Slider(
            min: AppSettingsProvider.fontSmall,
            max: AppSettingsProvider.fontExtraLarge,
            divisions: 10,
            value: settings.adhkarFontSize.clamp(
              AppSettingsProvider.fontSmall,
              AppSettingsProvider.fontExtraLarge,
            ),
            label: settings.adhkarFontSize.round().toString(),
            onChanged: (value) => settings.setAdhkarFontSize(value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('haptic')),
            subtitle: Text(context.tr('hapticHelp')),
            value: settings.hapticEnabled,
            onChanged: (value) async {
              await settings.setHapticEnabled(value);
              if (value) await DeviceFeedback.vibrate();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('showTranslation')),
            subtitle: Text(context.tr('showTranslationHelp')),
            isThreeLine: true,
            value: settings.showTranslation,
            onChanged: (value) => settings.setShowTranslation(value),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('replayIntro')),
            trailing: const Icon(Icons.replay),
            onTap: () => settings.setJourneyIntroSeen(false),
          ),
          const SizedBox(height: 8),
          _SectionTitle(context.tr('sectionPrayerCalc')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calculate_outlined),
            title: Text(context.tr('calculationMethod')),
            subtitle: Text(
              context.read<PrayerProvider>().calculationMethod.localizedName(
                    !context.isArabic,
                  ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMethods(context),
          ),
          const SizedBox(height: 12),
          Text(context.tr('timeFormat')),
          const SizedBox(height: 4),
          Text(
            context.tr('timeFormatHelp'),
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(context.tr('hour12'))),
              ButtonSegment(value: true, label: Text(context.tr('hour24'))),
            ],
            selected: {settings.use24HourClock},
            onSelectionChanged: (value) => settings.setUse24HourClock(value.first),
          ),
          const SizedBox(height: 8),
          _SectionTitle(context.tr('sectionAbout')),
          Text(context.tr('appInfo'), style: const TextStyle(height: 1.5)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('version')),
            subtitle: const Text('1.0.1+5'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('privacy')),
            subtitle: Text(context.tr('privacyBody')),
            isThreeLine: true,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('permissionsInfo')),
            subtitle: Text(context.tr('permissionsBody')),
            isThreeLine: true,
          ),
          FilledButton.icon(
            onPressed: () => _exportData(context),
            icon: const Icon(Icons.download),
            label: Text(context.tr('exportData')),
          ),
        ],
      ),
    );
  }

  double _nearestFontPreset(double size) {
    const presets = [
      AppSettingsProvider.fontSmall,
      AppSettingsProvider.fontMedium,
      AppSettingsProvider.fontLarge,
      AppSettingsProvider.fontExtraLarge,
    ];
    return presets.reduce(
      (a, b) => (a - size).abs() <= (b - size).abs() ? a : b,
    );
  }

  void _showMethods(BuildContext context) {
    final provider = context.read<PrayerProvider>();
    final english = !context.isArabic;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('calculationMethod')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: CalculationMethod.values.map((method) {
              return RadioListTile<CalculationMethod>(
                title: Text(method.localizedName(english)),
                value: method,
                groupValue: provider.calculationMethod,
                onChanged: (value) {
                  if (value != null) {
                    provider.changeCalculationMethod(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.tr('exportReady');
    try {
      await DataExportService().shareExport();
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsProvider>(
      builder: (context, rewards, _) {
        final owned = rewards.getOwnedThemes();
        return Column(
          children: [
            _ThemeCard(
              title: context.tr('originalTheme'),
              description: context.tr('defaultThemeDesc'),
              icon: '🏠',
              active: rewards.activeThemeId == null,
              onTap: () {
                rewards.resetToDefaultTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('themeRestored'))),
                );
              },
            ),
            const SizedBox(height: 12),
            if (owned.isEmpty)
              Text(context.tr('noExtraThemes'))
            else
              ...owned.map(
                (theme) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ThemeCard(
                    title: theme.title,
                    description: theme.description,
                    icon: theme.icon,
                    active: rewards.activeThemeId == theme.themeId,
                    onTap: () {
                      final themeId = theme.themeId;
                      if (themeId == null) return;
                      rewards.setActiveTheme(themeId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('themeApplied'))),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool active;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: active
            ? const BorderSide(color: AppTheme.accentCyan, width: 2)
            : BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(description),
                  ],
                ),
              ),
              if (active) const Icon(Icons.check_circle, color: AppTheme.accentCyan),
            ],
          ),
        ),
      ),
    );
  }
}

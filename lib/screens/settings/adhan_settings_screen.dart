import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/notification_preferences.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/prayer_provider.dart';

class AdhanSettingsScreen extends StatefulWidget {
  const AdhanSettingsScreen({super.key});

  @override
  State<AdhanSettingsScreen> createState() => _AdhanSettingsScreenState();
}

class _AdhanSettingsScreenState extends State<AdhanSettingsScreen> {
  final NotificationService _notifications = NotificationService();
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final enabled = await _notifications.notificationsEnabled();
    if (mounted) setState(() => _permissionGranted = enabled);
  }

  Future<void> _save(NotificationPreferences preferences) async {
    final settings = context.read<AppSettingsProvider>();
    final prayers = context.read<PrayerProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final message = context.tr('notificationsUpdated');
    await settings.updateNotifications(preferences);
    await prayers.refreshPrayerTimes();
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppSettingsProvider>().notifications;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('adhanSettings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('notificationsGlobal')),
            subtitle: Text(context.tr('notificationsGlobalHelp')),
            value: preferences.enabled,
            onChanged: (value) => _save(preferences.copyWith(enabled: value)),
          ),
          const Divider(),
          Text(context.tr('perPrayer'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final key in NotificationPreferences.prayerKeys)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.prayerName(key)),
              value: preferences.prayers[key] ?? false,
              onChanged: preferences.enabled
                  ? (value) {
                      final next = Map<String, bool>.from(preferences.prayers);
                      next[key] = value;
                      _save(preferences.copyWith(prayers: next));
                    }
                  : null,
            ),
          const Divider(),
          Text(context.tr('sound'), style: Theme.of(context).textTheme.titleMedium),
          RadioListTile<AdhanSoundMode>(
            title: Text(context.tr('soundSilent')),
            value: AdhanSoundMode.silent,
            groupValue: preferences.soundMode,
            onChanged: (value) {
              if (value != null) _save(preferences.copyWith(soundMode: value));
            },
          ),
          RadioListTile<AdhanSoundMode>(
            title: Text(context.tr('soundShort')),
            value: AdhanSoundMode.shortTone,
            groupValue: preferences.soundMode,
            onChanged: (value) {
              if (value != null) _save(preferences.copyWith(soundMode: value));
            },
          ),
          RadioListTile<AdhanSoundMode>(
            title: Text(context.tr('soundAdhan')),
            value: AdhanSoundMode.adhan,
            groupValue: preferences.soundMode,
            onChanged: (value) {
              if (value != null) _save(preferences.copyWith(soundMode: value));
            },
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () async {
              final sent = context.tr('testSent');
              final denied = context.tr('permissionDenied');
              final failed = context.tr('testFailed');
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _notifications.initialize();
                final granted = await _notifications.requestPermissions();
                await _notifications.showTestNotification(
                  soundMode: preferences.soundMode,
                );
                await _refreshPermission();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(granted ? sent : denied)),
                );
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text(failed)));
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(context.tr('testNotification')),
          ),
          if (_permissionGranted == false) ...[
            const SizedBox(height: 8),
            Text(
              context.tr('permissionDenied'),
              style: TextStyle(color: scheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Text(context.tr('permissionExplain'), style: const TextStyle(height: 1.5)),
          const SizedBox(height: 12),
          Text(context.tr('exactAlarmExplain'), style: const TextStyle(height: 1.5)),
          const SizedBox(height: 12),
          Text(
            context.tr('adhanAssetExplain'),
            style: TextStyle(height: 1.5, color: AppTheme.accentGold),
          ),
        ],
      ),
    );
  }
}

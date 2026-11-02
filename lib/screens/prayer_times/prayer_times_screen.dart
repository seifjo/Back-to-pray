import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/app_settings_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/prayer_times.dart';
import '../settings/settings_screen.dart';

/// Prayer Times Screen
/// Displays prayer times with live countdown
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<AppSettingsProvider>().use24HourClock;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('prayerTimes'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.tr('themesAndSettings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: context.tr('calculationMethod'),
            onPressed: () => _showCalculationMethodDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PrayerProvider>().refreshPrayerTimes();
            },
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      switch (provider.error) {
                        'location_denied' => context.tr('locationDenied'),
                        'location_disabled' => context.tr('locationDisabled'),
                        'location_timeout' => context.tr('locationTimeout'),
                        _ => context.tr('prayerLoadError'),
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.requestPermissions(),
                    child: Text(
                      provider.error == 'location_denied' ||
                              provider.error == 'location_disabled' ||
                              provider.error == 'location_timeout'
                          ? context.tr('enableLocation')
                          : context.tr('retry'),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.prayerTimes == null) {
            return Center(
              child: Text(
                context.tr('noPrayerTimes'),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }

          final prayerTimes = provider.prayerTimes!;
          final nextPrayer = provider.getNextPrayer();

          return RefreshIndicator(
            onRefresh: provider.refreshPrayerTimes,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Next Prayer Card with Countdown
                  _buildNextPrayerCard(nextPrayer),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: false, label: Text(context.tr('hour12'))),
                      ButtonSegment(value: true, label: Text(context.tr('hour24'))),
                    ],
                    selected: {use24Hour},
                    onSelectionChanged: (value) {
                      context.read<AppSettingsProvider>().setUse24HourClock(value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // All Prayer Times
                  _buildPrayerTimesList(prayerTimes, nextPrayer?['name'] as String?),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build next prayer countdown card
  Widget _buildNextPrayerCard(Map<String, dynamic>? nextPrayer) {
    if (nextPrayer == null) return const SizedBox();

    final prayerName = nextPrayer['name'] as String;
    final prayerTime = nextPrayer['time'] as DateTime;
    final duration = prayerTime.difference(DateTime.now());

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.getPrayerColor(prayerName),
              AppTheme.getPrayerColor(prayerName).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              context.tr('nextPrayer'),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.prayerName(prayerName),
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit(hours.toString().padLeft(2, '0'), context.tr('hours')),
                const SizedBox(width: 8),
                const Text(':', style: TextStyle(fontSize: 32, color: Colors.white)),
                const SizedBox(width: 8),
                _buildTimeUnit(minutes.toString().padLeft(2, '0'), context.tr('minutes')),
                const SizedBox(width: 8),
                const Text(':', style: TextStyle(fontSize: 32, color: Colors.white)),
                const SizedBox(width: 8),
                _buildTimeUnit(seconds.toString().padLeft(2, '0'), context.tr('seconds')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatTime(prayerTime),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build time unit widget for countdown
  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// Build list of all prayer times
  Widget _buildPrayerTimesList(PrayerTimes prayerTimes, String? nextPrayerName) {
    final prayers = prayerTimes.toMap();

    return Column(
      children: prayers.entries.map((entry) {
        final isNext = entry.key == nextPrayerName;
        return _buildPrayerTimeCard(entry.key, entry.value, isNext);
      }).toList(),
    );
  }

  /// Build individual prayer time card
  Widget _buildPrayerTimeCard(String prayerName, DateTime time, bool isNext) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isNext ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNext
            ? BorderSide(color: AppTheme.getPrayerColor(prayerName), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.getPrayerColor(prayerName).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getPrayerIcon(prayerName),
            color: AppTheme.getPrayerColor(prayerName),
            size: 32,
          ),
        ),
        title: Text(
          context.l10n.prayerName(prayerName),
          style: TextStyle(
            fontSize: 24,
            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
            color: isNext
                ? AppTheme.getPrayerColor(prayerName)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isNext
                    ? AppTheme.getPrayerColor(prayerName)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isNext)
              Text(
                context.tr('upcoming'),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get icon for each prayer
  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Icons.wb_twilight;
      case 'الشروق':
        return Icons.wb_sunny;
      case 'الظهر':
        return Icons.light_mode;
      case 'العصر':
        return Icons.wb_cloudy;
      case 'المغرب':
        return Icons.nightlight;
      case 'العشاء':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  String _formatTime(DateTime time) {
    final settings = context.read<AppSettingsProvider>();
    return PrayerClock.format(
      time,
      use24Hour: settings.use24HourClock,
      arabic: context.isArabic,
    );
  }

  /// Show calculation method selection dialog
  void _showCalculationMethodDialog(BuildContext context) {
    final provider = context.read<PrayerProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('calculationMethod'), textAlign: TextAlign.center),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: CalculationMethod.values.map((method) {
                return RadioListTile<CalculationMethod>(
                  title: Text(method.localizedName(!context.isArabic)),
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
      ),
    );
  }
}
